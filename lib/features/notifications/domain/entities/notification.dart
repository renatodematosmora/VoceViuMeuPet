class AppNotification {
  final String id;
  final String userId;
  final String type; // 'sighting', 'comment', 'status_change'
  final String title;
  final String message;
  final String? petId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.petId,
    required this.isRead,
    required this.createdAt,
  });
}
