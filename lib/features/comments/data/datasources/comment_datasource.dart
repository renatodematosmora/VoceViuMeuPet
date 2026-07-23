import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/constants/supabase_constants.dart';
import 'package:voce_viu_meu_pet/core/errors/app_exception.dart';
import 'package:voce_viu_meu_pet/features/comments/data/models/comment_model.dart';

final commentDataSourceProvider = Provider<CommentDataSource>(
  (ref) => CommentDataSource(Supabase.instance.client),
);

class CommentDataSource {
  final SupabaseClient _client;
  CommentDataSource(this._client);

  // ── Buscar comentários de um pet ─────────────────────────────
  Future<List<CommentModel>> fetchComments(String petId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.commentsTable)
          .select('*, profiles(full_name, avatar_url)')
          .eq('pet_id', petId)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: true);
      return data.map((e) => CommentModel.fromJson(e)).toList();
    } catch (e, st) {
      print('[CommentDataSource] Erro ao buscar comentários: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao carregar comentários',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Criar comentário ─────────────────────────────────────────
  Future<CommentModel> createComment(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(SupabaseConstants.commentsTable)
          .insert(data)
          .select('*, profiles(full_name, avatar_url)')
          .single();
      return CommentModel.fromJson(result);
    } catch (e, st) {
      print('[CommentDataSource] Erro ao criar comentário: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao enviar comentário',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Excluir comentário ───────────────────────────────────────
  Future<void> deleteComment(String commentId) async {
    try {
      await _client
          .from(SupabaseConstants.commentsTable)
          .delete()
          .eq('id', commentId);
    } catch (e, st) {
      print('[CommentDataSource] Erro ao deletar comentário: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao deletar comentário',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  // ── Fixar/desafixar comentário ──────────────────────────────
  Future<void> togglePinComment(String commentId, bool isPinned) async {
    try {
      await _client
          .from(SupabaseConstants.commentsTable)
          .update({'is_pinned': isPinned})
          .eq('id', commentId);
    } catch (e, st) {
      print('[CommentDataSource] Erro ao fixar comentário: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao fixar comentário',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }
}
