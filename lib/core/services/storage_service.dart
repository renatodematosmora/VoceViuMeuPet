import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/errors/app_exception.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(Supabase.instance.client),
);

/// Serviço centralizado para upload de arquivos no Supabase Storage
class StorageService {
  final SupabaseClient _client;

  const StorageService(this._client);

  /// Faz upload de um arquivo binário para um bucket específico
  ///
  /// [bucket]: Nome do bucket (ex: 'avatars', 'photos', 'pet-photos')
  /// [path]: Caminho do arquivo no bucket (ex: 'user-123/avatar.jpg')
  /// [bytes]: Dados binários do arquivo
  /// [allowedExtensions]: Lista de extensões permitidas (default: jpg, jpeg, png, webp)
  /// [upsert]: Se true, sobrescreve arquivo existente
  ///
  /// Retorna a URL pública do arquivo
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    List<String> allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
    bool upsert = true,
  }) async {
    try {
      // Validar extensão
      final ext = path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(ext)) {
        throw AppStorageException(
          message: 'Formato de arquivo não permitido',
          internalMessage: 'Extensão: $ext. Permitidas: ${allowedExtensions.join(", ")}',
          stackTrace: StackTrace.current,
        );
      }

      // Upload
      await _client.storage.from(bucket).uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(upsert: upsert),
          );

      // Retornar URL pública
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e, st) {
      print('[StorageService] Erro ao fazer upload: $e');
      if (e is AppStorageException) rethrow;
      throw AppStorageException(
        message: 'Erro ao fazer upload do arquivo',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }
}
