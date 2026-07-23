import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/constants/supabase_constants.dart';
import 'package:voce_viu_meu_pet/core/errors/app_exception.dart';
import 'package:voce_viu_meu_pet/features/notifications/data/models/notification_model.dart';

final notificationDataSourceProvider = Provider<NotificationDataSource>(
  (ref) => NotificationDataSource(Supabase.instance.client),
);

class NotificationDataSource {
  final SupabaseClient _client;
  NotificationDataSource(this._client);

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e, st) {
      print('[NotificationDataSource] Erro ao buscar notificações: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao carregar notificações',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e, st) {
      print('[NotificationDataSource] Erro ao marcar como lido: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao atualizar notificação',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e, st) {
      print('[NotificationDataSource] Erro ao marcar tudo como lido: $e');
      print(st);
      throw SupabaseException(
        message: 'Erro ao marcar como lido',
        internalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }
}
