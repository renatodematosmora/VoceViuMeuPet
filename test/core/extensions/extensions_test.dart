import 'package:flutter_test/flutter_test.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

void main() {
  group('Pet Extensions', () {
    Pet makePet({required DateTime lostAt}) => Pet(
          id: '1',
          name: 'Rex',
          species: PetSpecies.dog,
          breed: 'Poodle',
          color: 'Branco',
          size: PetSize.small,
          ageApprox: 'adult',
          description: 'Dócil',
          lostAt: lostAt,
          lostAddress: 'Rua A',
          lostLat: 0,
          lostLng: 0,
          photos: [],
          reward: null,
          status: PetStatus.active,
          ownerId: '123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    test('timeAgo formatado corretamente para 2 horas', () {
      final pet = makePet(lostAt: DateTime.now().subtract(const Duration(hours: 2)));
      // timeAgo is defined on DateTime
      expect(pet.lostAt.timeAgo, contains('2h'));
    });

    test('daysAgo deve retornar 3 para 3 dias atrás', () {
      final pet = makePet(lostAt: DateTime.now().subtract(const Duration(days: 3)));
      expect(pet.lostAt.daysAgo, 3);
    });

    test('daysLostLabel deve formatar corretamente', () {
      expect(3.daysLostLabel, 'Desaparecido há 3 dias');
      expect(1.daysLostLabel, 'Desapareceu há 1 dia');
      expect(0.daysLostLabel, 'Desapareceu hoje');
    });

    test('species label', () {
      expect(PetSpecies.dog.label, 'Cachorro');
      expect(PetSpecies.cat.label, 'Gato');
      expect(PetSpecies.bird.label, 'Pássaro');
    });
  });
}
