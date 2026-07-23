import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/constants/supabase_constants.dart';
import 'package:voce_viu_meu_pet/core/errors/app_exception.dart';
import 'package:voce_viu_meu_pet/features/auth/data/models/profile_model.dart';

final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => AuthDataSource(Supabase.instance.client),
);

class AuthDataSource {
  final SupabaseClient _client;
  AuthDataSource(this._client);

  // ── Sign In com e-mail/senha ─────────────────────────────────
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e, st) {
      print('[AuthDataSource] Erro ao fazer login: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao fazer login',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Sign Up ──────────────────────────────────────────────────
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
    } catch (e, st) {
      print('[AuthDataSource] Erro ao registrar: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao registrar usuário',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── OAuth Google ─────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.voceviumeupet://login-callback',
      );
    } catch (e, st) {
      print('[AuthDataSource] Erro ao fazer login com Google: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao fazer login com Google',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────
  Future<void> signOut() => _client.auth.signOut();

  // ── Perfil atual ─────────────────────────────────────────────
  Future<ProfileModel?> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data == null ? null : ProfileModel.fromJson(data);
    } catch (e, st) {
      print('[AuthDataSource] Erro ao buscar perfil: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao carregar perfil',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Atualizar perfil ─────────────────────────────────────────
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _client
          .from(SupabaseConstants.profilesTable)
          .update(data)
          .eq('id', userId);
    } catch (e, st) {
      print('[AuthDataSource] Erro ao atualizar perfil: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao atualizar perfil',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Upload avatar ────────────────────────────────────────────
  Future<String> uploadAvatar(String userId, List<int> bytes, String ext) async {
    try {
      final path = '$userId/avatar.$ext';
      await _client.storage
          .from(SupabaseConstants.avatarsBucket)
          .uploadBinary(path, Uint8List.fromList(bytes), fileOptions: const FileOptions(upsert: true));
      return _client.storage
          .from(SupabaseConstants.avatarsBucket)
          .getPublicUrl(path);
    } catch (e, st) {
      print('[AuthDataSource] Erro ao fazer upload de avatar: $e');
      print(st);
      throw AppStorageException(
        message: 'Erro ao fazer upload do avatar',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Stream de auth state ─────────────────────────────────────
  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
}
