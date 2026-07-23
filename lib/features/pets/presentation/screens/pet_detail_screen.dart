import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/features/pets/data/datasources/pet_datasource.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';
import 'package:voce_viu_meu_pet/features/pets/presentation/widgets/pet_detail_sightings_section.dart';
import 'package:voce_viu_meu_pet/features/pets/presentation/widgets/pet_detail_comments_section.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/providers/feed_provider.dart';
import 'package:voce_viu_meu_pet/features/sightings/domain/entities/sighting.dart';
import 'package:voce_viu_meu_pet/features/sightings/data/datasources/sighting_datasource.dart';
import 'package:voce_viu_meu_pet/features/comments/domain/entities/comment.dart';
import 'package:voce_viu_meu_pet/features/comments/data/datasources/comment_datasource.dart';

class PetDetailScreen extends ConsumerStatefulWidget {
  final String petId;
  const PetDetailScreen({super.key, required this.petId});

  @override
  ConsumerState<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends ConsumerState<PetDetailScreen> {
  Pet? _pet;
  bool _loading = true;
  int _photoIndex = 0;
  List<Sighting> _sightings = [];
  List<Comment> _comments = [];
  final _commentCtrl = TextEditingController();
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    _load();
    _setupRealtime();
  }

  RealtimeChannel? _commentsChannel;
  RealtimeChannel? _sightingsChannel;

  @override
  void dispose() {
    _commentsChannel?.unsubscribe();
    _sightingsChannel?.unsubscribe();
    _commentCtrl.dispose();
    super.dispose();
  }

  void _setupRealtime() {
    try {
      _commentsChannel = Supabase.instance.client
          .channel('public:comments:${widget.petId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'comments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'pet_id',
              value: widget.petId,
            ),
            callback: (payload) async {
              await _reloadComments();
            },
          )
          .subscribe();
    } catch (e) {
      print('[PetDetailScreen] Erro ao setup realtime comments: $e');
    }

    try {
      _sightingsChannel = Supabase.instance.client
          .channel('public:sightings:${widget.petId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'sightings',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'pet_id',
              value: widget.petId,
            ),
            callback: (payload) async {
              await _reloadSightings();
            },
          )
          .subscribe();
    } catch (e) {
      print('[PetDetailScreen] Erro ao setup realtime sightings: $e');
    }
  }

  Future<void> _reloadComments() async {
    final comments = await ref
        .read(commentDataSourceProvider)
        .fetchComments(widget.petId);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

  Future<void> _reloadSightings() async {
    final sightings = await ref
        .read(sightingDataSourceProvider)
        .fetchSightings(widget.petId);
    if (mounted) {
      setState(() {
        _sightings = sightings;
      });
    }
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ref.read(petDataSourceProvider).fetchPetById(widget.petId),
        ref.read(sightingDataSourceProvider).fetchSightings(widget.petId),
        ref.read(commentDataSourceProvider).fetchComments(widget.petId),
      ]);
      final pet = results[0] as Pet?;
      final sightings = results[1] as List<Sighting>;
      final comments = results[2] as List<Comment>;
      if (mounted) {
        setState(() {
          _pet = pet;
          _sightings = sightings;
          _comments = comments;
          _loading = false;
        });
      }
    } catch (e) {
      print('[PetDetailScreen] Erro ao carregar dados: $e');
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _submittingComment = true);
    try {
      final comment = await ref.read(commentDataSourceProvider).createComment({
        'pet_id': widget.petId,
        'author_id': userId,
        'content': text,
        'is_pinned': false,
      });
      _commentCtrl.clear();
      if (mounted) {
        setState(() {
          _comments.add(comment);
          _submittingComment = false;
        });
        context.showSnackBar('Comentário enviado!');
      }
    } catch (e) {
      print('[PetDetailScreen] Erro ao adicionar comentário: $e');
      if (mounted) {
        setState(() => _submittingComment = false);
        context.showSnackBar('Erro ao enviar comentário', isError: true);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await ref.read(commentDataSourceProvider).deleteComment(commentId);
      if (mounted) {
        setState(() {
          _comments.removeWhere((c) => c.id == commentId);
        });
        context.showSnackBar('Comentário excluído.');
      }
    } catch (e) {
      print('[PetDetailScreen] Erro ao deletar comentário: $e');
      if (mounted) {
        context.showSnackBar('Erro ao excluir comentário', isError: true);
      }
    }
  }

  Future<void> _togglePinComment(String commentId, bool currentPin) async {
    try {
      await ref
          .read(commentDataSourceProvider)
          .togglePinComment(commentId, !currentPin);
      final comments = await ref
          .read(commentDataSourceProvider)
          .fetchComments(widget.petId);
      if (mounted) {
        setState(() {
          _comments = comments;
        });
        context.showSnackBar(
          !currentPin ? 'Comentário fixado no topo!' : 'Comentário desafixado.',
        );
      }
    } catch (e) {
      print('[PetDetailScreen] Erro ao fixar/desafixar comentário: $e');
      if (mounted) {
        context.showSnackBar('Erro ao alterar fixação', isError: true);
      }
    }
  }

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  bool get _isOwner => _pet?.ownerId == _currentUserId;

  Future<void> _changeStatus(String status) async {
    final label = status == 'found' ? 'encontrado' : 'encerrado';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          status == 'found' ? '🎉 Pet encontrado!' : 'Encerrar busca',
        ),
        content: Text(
          'Tem certeza que deseja marcar como $label? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'found'
                  ? AppTheme.accent
                  : AppTheme.textSecond,
            ),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref
        .read(petDataSourceProvider)
        .updateStatus(widget.petId, status);
    ref.read(feedProvider.notifier).removePet(widget.petId);
    if (mounted) {
      context.showSnackBar(
        status == 'found' ? '🎉 Que alegria! Pet marcado como encontrado!' : 'Busca encerrada.',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_pet == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Animal não encontrado')),
      );
    }
    final pet = _pet!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Galeria de fotos ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: pet.photos.isNotEmpty ? pet.photos.length : 1,
                    onPageChanged: (i) => setState(() => _photoIndex = i),
                    itemBuilder: (_, i) => pet.photos.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: pet.photos[i],
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppTheme.primary.withOpacity(0.2),
                            child: const Center(
                              child: Text('🐾',
                                  style: TextStyle(fontSize: 80)),
                            ),
                          ),
                  ),
                  if (pet.photos.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pet.photos.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 3),
                            width: _photoIndex == i ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _photoIndex == i
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Status badge
                  Positioned(
                    top: 100,
                    right: 16,
                    child: _StatusBadge(status: pet.status),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Nome e espécie ──────────────────────────
                  Row(
                    children: [
                      Text(pet.species.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pet.name,
                          style: context.textTheme.displaySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pet.lostAt.daysAgo.daysLostLabel,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Características ─────────────────────────
                  Text('Características',
                      style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip('Espécie', pet.species.label),
                      _InfoChip('Cor', pet.color),
                      _InfoChip('Porte', pet.size.label.split(' ').first),
                      if (pet.breed != null) _InfoChip('Raça', pet.breed!),
                      if (pet.ageApprox != null)
                        _InfoChip('Idade', pet.ageApprox!),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Text('Descrição', style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(pet.description, style: context.textTheme.bodyLarge),

                  if (pet.reward != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.warning.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Text('💰',
                              style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recompensa oferecida',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                                Text(pet.reward!,
                                    style: context.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Local do desaparecimento ────────────────
                  Text('Local do desaparecimento',
                      style: context.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 16, color: AppTheme.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(pet.lostAddress,
                            style: context.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 180,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter:
                              LatLng(pet.lostLat, pet.lostLng),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.voceviumeupet.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(pet.lostLat, pet.lostLng),
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: AppTheme.cardShadow,
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Sightings ───────────────────────────────
                  PetDetailSightingsSection(sightings: _sightings),

                  // ── Comments ─────────────────────────────────
                  if (Supabase.instance.client.auth.currentUser != null)
                    PetDetailCommentsSection(
                      comments: _comments,
                      commentCtrl: _commentCtrl,
                      currentUserId: _currentUserId,
                      submittingComment: _submittingComment,
                      onAddComment: _addComment,
                      onTogglePinComment: _togglePinComment,
                      onDeleteComment: _deleteComment,
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text('Comentários (${_comments.length})',
                            style: context.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text('Faça login para comentar.',
                            style: context.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecond)),
                      ],
                    ),

                  const SizedBox(height: 28),

                  // ── Ações ────────────────────────────────────
                  if (!_isOwner && pet.isActive) ...[
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/pets/${pet.id}/sighting'),
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('Vi este animal!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],

                  if (_isOwner && pet.isActive) ...[
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _changeStatus('found'),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Meu pet foi encontrado! 🎉'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _changeStatus('closed'),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Encerrar busca'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PetStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      PetStatus.active => (AppTheme.primary, '🔍 Procurando'),
      PetStatus.found  => (AppTheme.accent,  '🎉 Encontrado'),
      PetStatus.closed => (AppTheme.textSecond, '✖ Encerrado'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecond,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
