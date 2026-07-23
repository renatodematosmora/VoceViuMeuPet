class Comment {
  final String id;
  final String petId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final bool isPinned;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.petId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.isPinned,
    required this.createdAt,
  });
}
