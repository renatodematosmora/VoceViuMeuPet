import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/router/app_router.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/providers/auth_provider.dart';
import 'package:voce_viu_meu_pet/features/pets/data/datasources/pet_datasource.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<Pet> _pets = [];
  bool _loadingPets = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final pets = await ref.read(petDataSourceProvider).fetchMyPets(userId);
    if (mounted) setState(() { _pets = pets; _loadingPets = false; });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final isDark = context.isDark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar com avatar ──────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            backgroundImage: profile?.avatarUrl != null
                                ? CachedNetworkImageProvider(profile!.avatarUrl!)
                                : null,
                            child: profile?.avatarUrl == null
                                ? const Text('🐾',
                                    style: TextStyle(fontSize: 40))
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile?.fullName ?? 'Carregando...',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (profile?.city != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              profile!.city!,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () => context.push(AppRoutes.editProfile),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (mounted) context.go(AppRoutes.login);
                },
              ),
            ],
          ),

          // ── Estatísticas ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  _Stat(
                    value: _pets.where((p) => p.isActive).length.toString(),
                    label: 'Buscando',
                  ),
                  const _Divider(),
                  _Stat(
                    value: _pets.where((p) => p.isFound).length.toString(),
                    label: 'Encontrados',
                  ),
                  const _Divider(),
                  _Stat(
                    value: _pets.length.toString(),
                    label: 'Total',
                  ),
                ],
              ),
            ),
          ),

          // ── Meus animais ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text('Meus animais', style: context.textTheme.titleLarge),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.addPet),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Novo'),
                  ),
                ],
              ),
            ),
          ),

          if (_loadingPets)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_pets.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Text('🐾', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      'Você ainda não cadastrou nenhum animal',
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _PetListTile(
                    pet: _pets[i],
                    onTap: () => context.push('/pets/${_pets[i].id}'),
                  ),
                  childCount: _pets.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecond)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: AppTheme.divider,
      );
}

class _PetListTile extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  const _PetListTile({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (pet.status) {
      PetStatus.active => (AppTheme.primary, 'Buscando'),
      PetStatus.found  => (AppTheme.accent, 'Encontrado 🎉'),
      PetStatus.closed => (AppTheme.textSecond, 'Encerrado'),
    };
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: pet.mainPhoto.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: pet.mainPhoto,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              )
            : Container(
                width: 56,
                height: 56,
                color: AppTheme.primary.withOpacity(0.1),
                child: Center(
                  child: Text(pet.species.emoji,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
      ),
      title: Text(pet.name, style: context.textTheme.titleSmall),
      subtitle: Text(pet.lostAt.formattedDate,
          style: context.textTheme.bodySmall),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
