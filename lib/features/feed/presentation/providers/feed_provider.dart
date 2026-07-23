import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voce_viu_meu_pet/features/pets/data/datasources/pet_datasource.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

// ── Estado do Feed ────────────────────────────────────────────
class FeedState {
  final List<Pet> pets;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? speciesFilter;
  final int page;
  final double? userLat;
  final double? userLng;

  const FeedState({
    this.pets = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.speciesFilter,
    this.page = 0,
    this.userLat,
    this.userLng,
  });

  FeedState copyWith({
    List<Pet>? pets,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? speciesFilter,
    int? page,
    double? userLat,
    double? userLng,
  }) =>
      FeedState(
        pets: pets ?? this.pets,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: error,
        speciesFilter: speciesFilter ?? this.speciesFilter,
        page: page ?? this.page,
        userLat: userLat ?? this.userLat,
        userLng: userLng ?? this.userLng,
      );
}

// ── Provider ──────────────────────────────────────────────────
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(ref.read(petDataSourceProvider));
});

class FeedNotifier extends StateNotifier<FeedState> {
  final PetDataSource _ds;
  static const _pageSize = 20;

  FeedNotifier(this._ds) : super(const FeedState()) {
    loadFeed();
  }

  // ── Carregar feed inicial ────────────────────────────────────
  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, error: null, page: 0);
    try {
      final pets = await _ds.fetchActivePets(
        page: 0,
        pageSize: _pageSize,
        species: state.speciesFilter,
        userLat: state.userLat,
        userLng: state.userLng,
      );
      state = state.copyWith(
        pets: pets,
        isLoading: false,
        hasMore: pets.length == _pageSize,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar publicações',
      );
    }
  }

  // ── Carregar mais (paginação) ────────────────────────────────
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final more = await _ds.fetchActivePets(
        page: state.page,
        pageSize: _pageSize,
        species: state.speciesFilter,
        userLat: state.userLat,
        userLng: state.userLng,
      );
      state = state.copyWith(
        pets: [...state.pets, ...more],
        isLoadingMore: false,
        hasMore: more.length == _pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      print('[FeedProvider] Erro ao carregar mais animais: $e');
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // ── Filtro por espécie ───────────────────────────────────────
  Future<void> setSpeciesFilter(String? species) async {
    state = state.copyWith(speciesFilter: species);
    await loadFeed();
  }

  // ── Refresh ──────────────────────────────────────────────────
  Future<void> refresh() => loadFeed();

  // ── Remover animal do feed (após encerrar) ───────────────────
  void removePet(String petId) {
    state = state.copyWith(
      pets: state.pets.where((p) => p.id != petId).toList(),
    );
  }

  // ── Habilitar Busca por Proximidade ───────────────────────────
  Future<void> enableProximitySearch(double lat, double lng) async {
    state = state.copyWith(userLat: lat, userLng: lng);
    await loadFeed();
  }

  Future<void> disableProximitySearch() async {
    // We cannot pass null cleanly to copyWith as it falls back to current.
    // Need a specific method to clear it.
    state = FeedState(
      pets: state.pets,
      isLoading: state.isLoading,
      isLoadingMore: state.isLoadingMore,
      hasMore: state.hasMore,
      error: state.error,
      speciesFilter: state.speciesFilter,
      page: state.page,
      userLat: null,
      userLng: null,
    );
    await loadFeed();
  }
}
