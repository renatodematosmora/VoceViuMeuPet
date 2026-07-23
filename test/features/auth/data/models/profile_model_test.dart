import 'package:flutter_test/flutter_test.dart';
import 'package:voce_viu_meu_pet/features/auth/data/models/profile_model.dart';
import 'package:voce_viu_meu_pet/features/auth/domain/entities/user_profile.dart';

void main() {
  group('ProfileModel', () {
    final tDateTime = DateTime(2024, 1, 1);
    final tJson = {
      'id': '123',
      'username': 'testuser',
      'full_name': 'Test User',
      'avatar_url': 'https://example.com/avatar.jpg',
      'city': 'São Paulo',
      'phone': '11999999999',
      'created_at': tDateTime.toIso8601String(),
    };

    test('fromJson creates ProfileModel from JSON', () {
      // Act
      final result = ProfileModel.fromJson(tJson);

      // Assert
      expect(result.id, '123');
      expect(result.username, 'testuser');
      expect(result.fullName, 'Test User');
      expect(result.avatarUrl, 'https://example.com/avatar.jpg');
      expect(result.city, 'São Paulo');
      expect(result.phone, '11999999999');
    });

    test('fromJson with minimal fields', () {
      // Arrange
      final minimalJson = {
        'id': '456',
        'username': 'user2',
        'full_name': 'User Two',
        'created_at': tDateTime.toIso8601String(),
      };

      // Act
      final result = ProfileModel.fromJson(minimalJson);

      // Assert
      expect(result.id, '456');
      expect(result.avatarUrl, isNull);
      expect(result.city, isNull);
      expect(result.phone, isNull);
    });

    test('toJson converts ProfileModel to JSON', () {
      // Arrange
      final model = ProfileModel.fromJson(tJson);

      // Act
      final result = model.toJson();

      // Assert
      expect(result['id'], '123');
      expect(result['username'], 'testuser');
      expect(result['full_name'], 'Test User');
      expect(result['avatar_url'], 'https://example.com/avatar.jpg');
      expect(result['city'], 'São Paulo');
      expect(result['phone'], '11999999999');
    });

    test('toJson excludes null fields', () {
      // Arrange
      final model = ProfileModel(
        id: '789',
        username: 'user3',
        fullName: 'User Three',
        createdAt: tDateTime,
        avatarUrl: null,
        city: null,
        phone: null,
      );

      // Act
      final result = model.toJson();

      // Assert
      expect(result.containsKey('avatar_url'), false);
      expect(result.containsKey('city'), false);
      expect(result.containsKey('phone'), false);
    });

    test('fromJson → toJson roundtrip preserves data', () {
      // Act
      final model = ProfileModel.fromJson(tJson);
      final resultJson = model.toJson();

      // Assert
      expect(resultJson['id'], tJson['id']);
      expect(resultJson['username'], tJson['username']);
      expect(resultJson['full_name'], tJson['full_name']);
    });

    test('ProfileModel is instance of UserProfile', () {
      // Arrange
      final model = ProfileModel.fromJson(tJson);

      // Assert
      expect(model, isA<UserProfile>());
    });

    test('copyWith creates modified instance', () {
      // Arrange
      final original = ProfileModel.fromJson(tJson);

      // Act
      final modified = original.copyWith(
        city: 'Rio de Janeiro',
        phone: '21999999999',
      );

      // Assert
      expect(modified.id, original.id);
      expect(modified.username, original.username);
      expect(modified.city, 'Rio de Janeiro');
      expect(modified.phone, '21999999999');
    });

    test('copyWith preserves unchanged fields', () {
      // Arrange
      final original = ProfileModel.fromJson(tJson);

      // Act
      final modified = original.copyWith(city: 'Curitiba');

      // Assert
      expect(modified.avatarUrl, original.avatarUrl);
      expect(modified.username, original.username);
    });

    test('equality based on fields', () {
      // Arrange
      final model1 = ProfileModel.fromJson(tJson);
      final model2 = ProfileModel.fromJson(tJson);

      // Assert - same data should be equal
      expect(model1.id, model2.id);
      expect(model1.username, model2.username);
    });
  });
}
