import 'package:flutter_test/flutter_test.dart';
import 'package:voce_viu_meu_pet/features/pets/data/models/pet_model.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

void main() {
  group('PetModel', () {
    final tDateTime = DateTime.now();
    final tJson = {
      'id': '123',
      'name': 'Rex',
      'species': 'dog',
      'breed': 'Poodle',
      'color': 'Branco',
      'size': 'small',
      'age_approx': 'adult',
      'description': 'Cachorro dócil',
      'lost_at': tDateTime.toIso8601String(),
      'lost_address': 'Rua A',
      'lost_lat': -23.5,
      'lost_lng': -46.6,
      'photos': ['http://photo.com/1.jpg'],
      'reward': 'R\$ 100',
      'status': 'active',
      'owner_id': 'owner123',
      'created_at': tDateTime.toIso8601String(),
      'updated_at': tDateTime.toIso8601String(),
      'profiles': {
        'full_name': 'João',
        'avatar_url': 'http://avatar.com/1.jpg',
      }
    };

    test('fromJson deve retornar um PetModel válido', () {
      final result = PetModel.fromJson(tJson);

      expect(result.id, '123');
      expect(result.name, 'Rex');
      expect(result.species, PetSpecies.dog);
    });

    test('toJson deve retornar um mapa válido', () {
      final model = PetModel.fromJson(tJson);
      final result = model.toJson();

      expect(result['name'], 'Rex');
      expect(result['species'], 'dog');
      expect(result['color'], 'Branco');
      expect(result['owner_id'], 'owner123');
    });
  });
}
