import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/constants/supabase_constants.dart';
import 'package:voce_viu_meu_pet/core/errors/app_exception.dart';
import 'package:voce_viu_meu_pet/features/sightings/data/models/sighting_model.dart';

final sightingDataSourceProvider = Provider<SightingDataSource>(
  (ref) => SightingDataSource(Supabase.instance.client),
);

class SightingDataSource {
  final SupabaseClient _client;
  SightingDataSource(this._client);

  Future<List<SightingModel>> fetchSightings(String petId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.sightingsTable)
          .select('*, profiles(full_name, avatar_url)')
          .eq('pet_id', petId)
          .order('seen_at', ascending: false);
      return data.map((e) => SightingModel.fromJson(e)).toList();
    } catch (e, st) {
      print('[SightingDataSource] Erro ao buscar avistamentos: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao carregar avistamentos',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  Future<SightingModel> createSighting(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(SupabaseConstants.sightingsTable)
          .insert(data)
          .select()
          .single();
      return SightingModel.fromJson(result);
    } catch (e, st) {
      print('[SightingDataSource] Erro ao criar avistamento: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao registrar avistamento',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  Future<String> uploadPhoto(
      String petId, String fileName, List<int> bytes) async {
    try {
      // SEGURANÇA: Validar extensão de arquivo
      // Apenas formatos de imagem seguros são permitidos
      final ext = fileName.split('.').last.toLowerCase();
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

      if (!allowedExtensions.contains(ext)) {
        throw ValidationException(
          message: 'Formato de arquivo não permitido',
          internalMessage: 'Extensão de arquivo não permitida: .$ext. '
              'Formatos aceitos: ${allowedExtensions.join(", ")}',
        );
      }

      final path = '$petId/$fileName';
      await _client.storage
          .from(SupabaseConstants.sightingsBucket)
          .uploadBinary(path, Uint8List.fromList(bytes),
              fileOptions: const FileOptions(upsert: true));
      return _client.storage
          .from(SupabaseConstants.sightingsBucket)
          .getPublicUrl(path);
    } catch (e, st) {
      print('[SightingDataSource] Erro ao fazer upload de foto: $e');
      print(st);
      throw AppStorageException(
        message: 'Erro ao fazer upload da foto',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }
}
