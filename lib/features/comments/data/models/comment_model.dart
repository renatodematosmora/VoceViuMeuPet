import 'package:voce_viu_meu_pet/features/comments/domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.petId,
    required super.authorId,
    required super.authorName,
    super.authorAvatarUrl,
    required super.content,
    required super.isPinned,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['profiles'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      authorId: json['author_id'] as String,
      authorName: (authorJson?['full_name'] as String?) ?? 'Usuário',
      authorAvatarUrl: authorJson?['avatar_url'] as String?,
      content: json['content'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'author_id': authorId,
      'content': content,
      'is_pinned': isPinned,
    };
  }
}
