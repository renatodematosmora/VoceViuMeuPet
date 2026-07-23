// ignore_for_file: constant_identifier_names

/// Constantes de conexão com o Supabase.
/// Os valores são injetados em tempo de compilação via --dart-define,
/// evitando qualquer credencial hardcoded no código-fonte.
///
/// CONFIGURAÇÃO:
/// - Local: já configurado em .vscode/launch.json (chave demo do Supabase local)
/// - Linha de comando: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// - Produção/CI: defina SUPABASE_URL e SUPABASE_ANON_KEY no pipeline de build
///
/// A chave anon é pública por design (embarcada no cliente); ainda assim
/// mantê-la fora do código-fonte evita commits acidentais e facilita a troca
/// de ambientes (dev/staging/prod) sem alterar o código.
class SupabaseConstants {
  SupabaseConstants._();

  /// URL do projeto Supabase (injetada via --dart-define).
  /// Fallback para o ambiente local de desenvolvimento (não é segredo).
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  /// Chave anon pública do Supabase (injetada via --dart-define).
  /// Sem valor padrão: a aplicação falha explicitamente se não for fornecida,
  /// evitando embarcar qualquer chave no binário por engano.
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

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
