// ignore_for_file: constant_identifier_names

import 'dart:io';

/// Constantes de conexão com o Supabase.
/// Os valores são carregados via environment variables por questões de segurança.
///
/// CONFIGURAÇÃO:
/// - Configure as variáveis de ambiente SUPABASE_URL e SUPABASE_ANON_KEY
/// - Em development, valores padrão são usados como fallback
/// - Em production, as variáveis devem estar sempre definidas
class SupabaseConstants {
  SupabaseConstants._();

  /// URL do projeto Supabase
  /// Carregada da variável de ambiente SUPABASE_URL
  /// Fallback para ambiente local de desenvolvimento
  static String get supabaseUrl {
    return _getEnv('SUPABASE_URL', 'http://127.0.0.1:54321');
  }

  /// Chave anon pública do Supabase
  /// Carregada da variável de ambiente SUPABASE_ANON_KEY
  /// Em production, esta deve estar definida obrigatoriamente
  static String get supabaseAnonKey {
    return _getEnv(
      'SUPABASE_ANON_KEY',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
    );
  }

  /// Obtém variável de ambiente com fallback seguro
  /// Em production (ENVIRONMENT=production), lança exceção se variável não existir
  static String _getEnv(String key, [String? fallback]) {
    final value = Platform.environment[key];

    if (value != null && value.isNotEmpty) {
      return value;
    }

    final environment = Platform.environment['ENVIRONMENT'] ?? 'development';

    if (environment == 'production' && fallback == null) {
      throw Exception(
        'Variável de ambiente "$key" é obrigatória em production. '
        'Configure a variável antes de iniciar a aplicação.'
      );
    }

    if (fallback != null) {
      return fallback;
    }

    throw Exception('Variável de ambiente "$key" não encontrada e sem fallback disponível.');
  }

  // ── Storage Buckets ─────────────────────────────────────────
  static const String petPhotosBucket    = 'pet-photos';
  static const String sightingsBucket    = 'sighting-photos';
  static const String avatarsBucket      = 'avatars';

  // ── Tabelas ─────────────────────────────────────────────────
  static const String profilesTable      = 'profiles';
  static const String petsTable          = 'pets';
  static const String sightingsTable     = 'sightings';
  static const String commentsTable      = 'comments';
  static const String notificationsTable = 'notifications';
}
