import 'package:flutter_test/flutter_test.dart';
import 'package:voce_viu_meu_pet/features/sightings/data/models/sighting_model.dart';

void main() {
  group('SightingModel', () {
    final tDateTime = DateTime(2024, 1, 1);
    final tJson = {
      'id': 'sighting1',
      'pet_id': 'pet123',
      'reporter_id': 'user1',
      'photo_url': 'https://example.com/sighting.jpg',
      'lat': -23.5505,
      'lng': -46.6333,
      'address': 'Parque Ibirapuera, São Paulo',
      'description': 'Vi esse cachorro branco perto do lago',
      'seen_at': tDateTime.toIso8601String(),
      'created_at': tDateTime.toIso8601String(),
      'profiles': {
        'full_name': 'Maria Santos',
        'avatar_url': 'https://example.com/avatar.jpg',
      }
    };

    test('fromJson creates SightingModel from JSON', () {
      // Act
      final result = SightingModel.fromJson(tJson);

      // Assert
      expect(result.id, 'sighting1');
      expect(result.petId, 'pet123');
      expect(result.reporterId, 'user1');
      expect(result.photoUrl, 'https://example.com/sighting.jpg');
      expect(result.lat, -23.5505);
      expect(result.lng, -46.6333);
      expect(result.address, 'Parque Ibirapuera, São Paulo');
      expect(result.description, 'Vi esse cachorro branco perto do lago');
      expect(result.reporterName, 'Maria Santos');
    });

    test('fromJson with integer coordinates converts to double', () {
      // Arrange
      final jsonWithInt = {
        ...tJson,
        'lat': -23,
        'lng': -46,
      };

      // Act
      final result = SightingModel.fromJson(jsonWithInt);

      // Assert
      expect(result.lat, isA<double>());
      expect(result.lng, isA<double>());
      expect(result.lat, -23.0);
      expect(result.lng, -46.0);
    });

    test('fromJson without reporter info handles null', () {
      // Arrange
      final jsonNoReporter = {
        ...tJson,
      };
      jsonNoReporter.remove('profiles');

      // Act
      final result = SightingModel.fromJson(jsonNoReporter);

      // Assert
      expect(result.reporterName, isNull);
      expect(result.reporterAvatar, isNull);
    });

    test('fromJson with optional description', () {
      // Arrange
      final jsonNoDesc = {...tJson, 'description': null};

      // Act
      final result = SightingModel.fromJson(jsonNoDesc);

      // Assert
      expect(result.description, isNull);
    });

    test('createdAt and seenAt are parsed correctly', () {
      // Act
      final result = SightingModel.fromJson(tJson);

      // Assert
      expect(result.createdAt.year, 2024);
      expect(result.seenAt.month, 1);
      expect(result.seenAt.day, 1);
    });

    test('coordinates are stored as double', () {
      // Act
      final result = SightingModel.fromJson(tJson);

      // Assert
      expect(result.lat, isA<double>());
      expect(result.lng, isA<double>());
    });
  });
}
