import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/providers/feed_provider.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/widgets/pet_card.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/widgets/species_filter_bar.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/widgets/feed_empty_state.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/widgets/feed_shimmer.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleProximity() async {
    final state = ref.read(feedProvider);
    if (state.userLat != null) {
      ref.read(feedProvider.notifier).disableProximitySearch();
      return;
    }

    if (mounted) context.showSnackBar('Buscando localizacao...');
    try {
      final geo = html.window.navigator.geolocation;
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 10),
      );
      final coords = pos.coords;
      if (coords == null || coords.latitude == null || coords.longitude == null) {
        if (mounted) {
          context.showSnackBar('Localização indisponível', isError: true);
        }
        return;
      }
      final lat = coords.latitude!.toDouble();
      final lng = coords.longitude!.toDouble();
      ref.read(feedProvider.notifier).enableProximitySearch(lat, lng);
    } catch (e) {
      print('[FeedScreen] Erro ao obter localização: $e');
      if (mounted) context.showSnackBar('Nao foi possivel obter a localizacao', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.heroGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🐾', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animais perdidos',
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      'perto de você',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  state.userLat != null ? Icons.location_on : Icons.location_on_outlined,
                  color: state.userLat != null ? AppTheme.accent : null,
                ),
                onPressed: _toggleProximity,
                tooltip: state.userLat != null ? 'Desativar proximidade' : 'Buscar próximos',
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.push('/search'),
                tooltip: 'Buscar',
              ),
              const SizedBox(width: 4),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: SpeciesFilterBar(),
            ),
          ),

          // ── Pull-to-refresh + conteúdo ───────────────────────
          if (state.isLoading)
            const SliverToBoxAdapter(child: FeedShimmer())
          else if (state.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('😿', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(state.error!, style: context.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(feedProvider.notifier).refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          else if (state.pets.isEmpty)
            const SliverFillRemaining(child: FeedEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == state.pets.length) {
                      return state.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                    return PetCard(
                      pet: state.pets[index],
                      onTap: () => context.push(
                        '/pets/${state.pets[index].id}',
                      ),
                    );
                  },
                  childCount: state.pets.length + 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
