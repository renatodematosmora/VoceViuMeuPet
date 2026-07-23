import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voce_viu_meu_pet/features/auth/data/datasources/auth_datasource.dart';
import 'package:voce_viu_meu_pet/features/auth/domain/entities/user_profile.dart';

// ── Estado de Auth ────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final UserProfile? profile;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    UserProfile? profile,
    String? error,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        profile: profile ?? this.profile,
        error: error,
      );
}

// ── Provider ──────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authDataSourceProvider));
});

// ── Provider do perfil atual ──────────────────────────────────
final currentProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authProvider).profile;
});

// ── Notifier ──────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthDataSource _ds;

  AuthNotifier(this._ds) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final user = _ds.currentUser;
    if (user != null) _loadProfile(user.id);
  }

  Future<void> _loadProfile(String userId) async {
    final profile = await _ds.fetchProfile(userId);
    state = state.copyWith(profile: profile);
  }

  // ── Sign In ──────────────────────────────────────────────────
  Future<String?> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _ds.signInWithEmail(email, password);
      if (res.user != null) await _loadProfile(res.user!.id);
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return _parseError(e);
    }
  }

  // ── Sign Up ──────────────────────────────────────────────────
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _ds.signUpWithEmail(email, password, fullName);
      if (res.user != null) await _loadProfile(res.user!.id);
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return _parseError(e);
    }
  }

  // ── Google ───────────────────────────────────────────────────
  Future<String?> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _ds.signInWithGoogle();
      if (res.user != null) await _loadProfile(res.user!.id);
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return _parseError(e);
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────
  Future<void> signOut() async {
    await _ds.signOut();
    state = const AuthState();
  }

  // ── Update Profile ───────────────────────────────────────────
  Future<String?> updateProfile(Map<String, dynamic> data) async {
    final userId = _ds.currentUser?.id;
    if (userId == null) return 'Usuário não autenticado';
    state = state.copyWith(isLoading: true);
    try {
      await _ds.updateProfile(userId, data);
      await _loadProfile(userId);
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return _parseError(e);
    }
  }

  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login')) return 'E-mail ou senha incorretos';
    if (msg.contains('email already')) return 'E-mail já cadastrado';
    if (msg.contains('network')) return 'Sem conexão com internet';
    if (msg.contains('weak password')) return 'Senha muito fraca (min. 8 caracteres)';
    print('[AuthProvider] Erro de login: $e');
    return 'Falha ao fazer login. Verifique suas credenciais e tente novamente.';
  }
}
