import 'package:flutter_test/flutter_test.dart';
import 'package:voce_viu_meu_pet/features/notifications/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    final tDateTime = DateTime(2024, 1, 1);
    final tJson = {
      'id': 'notif1',
      'user_id': 'user123',
      'type': 'comment',
      'title': 'Novo comentário',
      'message': 'João comentou no seu pet',
      'pet_id': 'pet123',
      'is_read': false,
      'created_at': tDateTime.toIso8601String(),
    };

    test('fromJson creates NotificationModel from JSON', () {
      // Act
      final result = NotificationModel.fromJson(tJson);

      // Assert
      expect(result.id, 'notif1');
      expect(result.userId, 'user123');
      expect(result.type, 'comment');
      expect(result.title, 'Novo comentário');
      expect(result.message, 'João comentou no seu pet');
      expect(result.petId, 'pet123');
      expect(result.isRead, false);
    });

    test('fromJson with missing petId uses null', () {
      // Arrange
      final jsonNoPet = {...tJson};
      jsonNoPet.remove('pet_id');

      // Act
      final result = NotificationModel.fromJson(jsonNoPet);

      // Assert
      expect(result.petId, isNull);
    });

    test('fromJson with missing isRead defaults to false', () {
      // Arrange
      final jsonNoRead = {...tJson};
      jsonNoRead.remove('is_read');

      // Act
      final result = NotificationModel.fromJson(jsonNoRead);

      // Assert
      expect(result.isRead, false);
    });

    test('toJson converts NotificationModel to JSON', () {
      // Arrange
      final model = NotificationModel.fromJson(tJson);

      // Act
      final result = model.toJson();

      // Assert
      expect(result['user_id'], 'user123');
      expect(result['type'], 'comment');
      expect(result['title'], 'Novo comentário');
      expect(result['message'], 'João comentou no seu pet');
      expect(result['pet_id'], 'pet123');
      expect(result['is_read'], false);
    });

    test('fromJson → toJson roundtrip preserves data', () {
      // Act
      final model = NotificationModel.fromJson(tJson);
      final resultJson = model.toJson();

      // Assert
      expect(resultJson['user_id'], tJson['user_id']);
      expect(resultJson['type'], tJson['type']);
      expect(resultJson['title'], tJson['title']);
    });

    test('different notification types are parsed correctly', () {
      // Arrange
      final types = ['comment', 'sighting', 'found'];

      // Act & Assert
      for (final type in types) {
        final json = {...tJson, 'type': type};
        final result = NotificationModel.fromJson(json);
        expect(result.type, type);
      }
    });

    test('read notification is marked correctly', () {
      // Arrange
      final readJson = {...tJson, 'is_read': true};

      // Act
      final result = NotificationModel.fromJson(readJson);

      // Assert
      expect(result.isRead, true);
    });

    test('createdAt is parsed correctly', () {
      // Act
      final result = NotificationModel.fromJson(tJson);

      // Assert
      expect(result.createdAt.year, 2024);
      expect(result.createdAt.month, 1);
      expect(result.createdAt.day, 1);
    });
  });
}
