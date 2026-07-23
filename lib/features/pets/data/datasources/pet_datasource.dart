import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/constants/supabase_constants.dart';
import 'package:voce_viu_meu_pet/core/errors/app_exception.dart';
import 'package:voce_viu_meu_pet/features/pets/data/models/pet_model.dart';

final petDataSourceProvider = Provider<PetDataSource>(
  (ref) => PetDataSource(Supabase.instance.client),
);

class PetDataSource {
  final SupabaseClient _client;
  PetDataSource(this._client);

  // ── Listar animais ativos (feed) ─────────────────────────────
  Future<List<PetModel>> fetchActivePets({
    int page = 0,
    int pageSize = 20,
    String? species,
    double? userLat,
    double? userLng,
    double radiusMeters = 20000,
  }) async {
    try {
      if (userLat != null && userLng != null) {
        final data = await _client.rpc('search_nearby_pets', params: {
          'user_lat': userLat,
          'user_lng': userLng,
          'radius_meters': radiusMeters,
          'species_filter': species,
          'page_num': page,
          'page_size': pageSize,
        });

        return (data as List<dynamic>).map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          map['profiles'] = {
            'full_name': map['profile_name'],
            'avatar_url': map['profile_avatar'],
          };
          return PetModel.fromJson(map);
        }).toList();
      }

      var query = _client
          .from(SupabaseConstants.petsTable)
          .select('*, profiles(full_name, avatar_url)')
          .eq('status', 'active');

      if (species != null) query = query.eq('species', species);

      final data = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      return data.map((e) => PetModel.fromJson(e)).toList();
    } catch (e, st) {
      print('[PetDataSource] Erro ao buscar animais ativos: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao carregar animais',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Buscar animal por ID ─────────────────────────────────────
  Future<PetModel?> fetchPetById(String id) async {
    try {
      final data = await _client
          .from(SupabaseConstants.petsTable)
          .select('*, profiles(full_name, avatar_url, city)')
          .eq('id', id)
          .maybeSingle();
      return data == null ? null : PetModel.fromJson(data);
    } catch (e, st) {
      print('[PetDataSource] Erro ao buscar animal por ID: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao carregar detalhes do animal',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Animais do dono ──────────────────────────────────────────
  Future<List<PetModel>> fetchMyPets(String ownerId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.petsTable)
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);
      return data.map((e) => PetModel.fromJson(e)).toList();
    } catch (e, st) {
      print('[PetDataSource] Erro ao buscar meus animais: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao carregar seus animais',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Criar animal perdido ─────────────────────────────────────
  Future<PetModel> createPet(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(SupabaseConstants.petsTable)
          .insert(data)
          .select()
          .single();
      return PetModel.fromJson(result);
    } catch (e, st) {
      print('[PetDataSource] Erro ao criar animal: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao cadastrar animal',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Atualizar status ─────────────────────────────────────────
  Future<void> updateStatus(String petId, String status) async {
    try {
      await _client
          .from(SupabaseConstants.petsTable)
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', petId);
    } catch (e, st) {
      print('[PetDataSource] Erro ao atualizar status: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao atualizar status',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Upload de fotos ──────────────────────────────────────────
  Future<String> uploadPhoto(
    String petId,
    String fileName,
    List<int> bytes,
  ) async {
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
          .from(SupabaseConstants.petPhotosBucket)
          .uploadBinary(path, Uint8List.fromList(bytes), fileOptions: const FileOptions(upsert: true));
      return _client.storage
          .from(SupabaseConstants.petPhotosBucket)
          .getPublicUrl(path);
    } catch (e, st) {
      print('[PetDataSource] Erro ao fazer upload de foto: $e');
      print(st);
      throw AppStorageException(
        message: 'Erro ao fazer upload da foto',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Busca textual ────────────────────────────────────────────
  Future<List<PetModel>> searchPets(String query) async {
    try {
      final data = await _client
          .from(SupabaseConstants.petsTable)
          .select()
          .eq('status', 'active')
          .or('name.ilike.%$query%,breed.ilike.%$query%,color.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(30);
      return data.map((e) => PetModel.fromJson(e)).toList();
    } catch (e, st) {
      print('[PetDataSource] Erro ao buscar animais: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao buscar animais',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }
}
