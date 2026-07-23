import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/providers/feed_provider.dart';
import 'package:voce_viu_meu_pet/features/pets/data/datasources/pet_datasource.dart';
import 'package:voce_viu_meu_pet/features/pets/data/models/pet_model.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

class MockPetDataSource extends Mock implements PetDataSource {}

void main() {
  late MockPetDataSource mockDS;
  late FeedNotifier notifier;

  setUp(() {
    mockDS = MockPetDataSource();
    
    when(() => mockDS.fetchActivePets(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          species: any(named: 'species'),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        )).thenAnswer((_) async => <PetModel>[]);

    notifier = FeedNotifier(mockDS);
  });

  group('FeedNotifier', () {
    test('loadFeed deve atualizar o estado para loading e depois carregar pets', () async {
      final List<PetModel> tPets = [
        PetModel(
          id: '1',
          name: 'Rex',
          species: PetSpecies.dog,
          breed: 'Poodle',
          color: 'Branco',
          size: PetSize.small,
          ageApprox: 'adult',
          description: 'Dócil',
          lostAt: DateTime.now(),
          lostAddress: 'Rua',
          lostLat: 0,
          lostLng: 0,
          photos: [],
          reward: null,
          status: PetStatus.active,
          ownerId: '12',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      ];

      when(() => mockDS.fetchActivePets(
            page: 0,
            pageSize: 20,
            species: null,
          )).thenAnswer((_) async => tPets);

      await notifier.loadFeed();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.pets.length, 1);
      expect(notifier.state.page, 1);
    });

    test('setSpeciesFilter deve filtrar por espécie e recarregar', () async {
      when(() => mockDS.fetchActivePets(
            page: 0,
            pageSize: 20,
            species: PetSpecies.cat.value,
          )).thenAnswer((_) async => <PetModel>[]);

      await notifier.setSpeciesFilter(PetSpecies.cat.value);

      expect(notifier.state.speciesFilter, PetSpecies.cat.value);
      verify(() => mockDS.fetchActivePets(
            page: 0,
            pageSize: 20,
            species: PetSpecies.cat.value,
          )).called(1);
    });

    test('enableProximitySearch deve atualizar lat lng e recarregar', () async {
      when(() => mockDS.fetchActivePets(
            page: 0,
            pageSize: 20,
            species: null,
            userLat: 10.0,
            userLng: 20.0,
          )).thenAnswer((_) async => <PetModel>[]);

      await notifier.enableProximitySearch(10.0, 20.0);

      expect(notifier.state.userLat, 10.0);
      expect(notifier.state.userLng, 20.0);
    });
  });
}
