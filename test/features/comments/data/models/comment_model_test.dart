import 'package:flutter_test/flutter_test.dart';
import 'package:voce_viu_meu_pet/features/comments/data/models/comment_model.dart';

void main() {
  group('CommentModel', () {
    final tDateTime = DateTime(2024, 1, 1);
    final tJson = {
      'id': 'comment1',
      'pet_id': 'pet123',
      'author_id': 'user1',
      'content': 'Vi esse cachorro ontem no parque!',
      'is_pinned': false,
      'created_at': tDateTime.toIso8601String(),
      'profiles': {
        'full_name': 'João Silva',
        'avatar_url': 'https://example.com/avatar.jpg',
      }
    };

    test('fromJson creates CommentModel from JSON', () {
      // Act
      final result = CommentModel.fromJson(tJson);

      // Assert
      expect(result.id, 'comment1');
      expect(result.petId, 'pet123');
      expect(result.authorId, 'user1');
      expect(result.authorName, 'João Silva');
      expect(result.content, 'Vi esse cachorro ontem no parque!');
      expect(result.isPinned, false);
    });

    test('fromJson with missing author info uses default', () {
      // Arrange
      final jsonNoAuthor = {
        'id': 'comment2',
        'pet_id': 'pet456',
        'author_id': 'user2',
        'content': 'Another comment',
        'is_pinned': false,
        'created_at': tDateTime.toIso8601String(),
      };

      // Act
      final result = CommentModel.fromJson(jsonNoAuthor);

      // Assert
      expect(result.authorName, 'Usuário');
      expect(result.authorAvatarUrl, isNull);
    });

    test('toJson converts CommentModel to JSON', () {
      // Arrange
      final model = CommentModel.fromJson(tJson);

      // Act
      final result = model.toJson();

      // Assert
      expect(result['pet_id'], 'pet123');
      expect(result['author_id'], 'user1');
      expect(result['content'], 'Vi esse cachorro ontem no parque!');
      expect(result['is_pinned'], false);
    });

    test('fromJson → toJson roundtrip preserves data', () {
      // Act
      final model = CommentModel.fromJson(tJson);
      final resultJson = model.toJson();

      // Assert
      expect(resultJson['pet_id'], tJson['pet_id']);
      expect(resultJson['content'], tJson['content']);
    });

    test('pinned comment is marked correctly', () {
      // Arrange
      final pinnedJson = {...tJson, 'is_pinned': true};

      // Act
      final result = CommentModel.fromJson(pinnedJson);

      // Assert
      expect(result.isPinned, true);
    });

    test('createdAt is parsed correctly', () {
      // Act
      final result = CommentModel.fromJson(tJson);

      // Assert
      expect(result.createdAt.year, 2024);
      expect(result.createdAt.month, 1);
      expect(result.createdAt.day, 1);
    });
  });
}
