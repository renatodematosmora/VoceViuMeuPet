import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/features/notifications/domain/entities/notification.dart';
import 'package:voce_viu_meu_pet/features/notifications/data/datasources/notification_datasource.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _loading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _load();
    _setupRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<void> _load() async {
    if (_currentUserId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final notifs = await ref
          .read(notificationDataSourceProvider)
          .fetchNotifications(_currentUserId);
      if (mounted) {
        setState(() {
          _notifications = notifs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setupRealtime() {
    if (_currentUserId.isEmpty) return;
    _channel = Supabase.instance.client
        .channel('public:notifications:$_currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId,
          ),
          callback: (payload) {
            _load();
          },
        )
        .subscribe();
  }

  Future<void> _markAllAsRead() async {
    if (_currentUserId.isEmpty) return;
    try {
      await ref
          .read(notificationDataSourceProvider)
          .markAllAsRead(_currentUserId);
      _load();
    } catch (_) {}
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ref.read(notificationDataSourceProvider).markAsRead(id);
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          TextButton(
            onPressed: _notifications.any((n) => !n.isRead) ? _markAllAsRead : null,
            child: const Text('Marcar todas lidas'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 52)),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma notificação ainda',
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                  itemBuilder: (_, i) => _NotificationTile(
                    item: _notifications[i],
                    onTap: () {
                      if (!_notifications[i].isRead) {
                        _markAsRead(_notifications[i].id);
                      }
                    },
                  ),
                ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;
  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.type) {
      'sighting' => '👁️',
      'comment' => '💬',
      'status_change' => '🎉',
      _ => '🔔',
    };

    return ListTile(
      onTap: onTap,
      tileColor: !item.isRead
          ? AppTheme.primary.withOpacity(0.05)
          : Colors.transparent,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 22)),
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight:
              !item.isRead ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        item.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.createdAt.timeAgo, style: context.textTheme.bodySmall),
          if (!item.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
