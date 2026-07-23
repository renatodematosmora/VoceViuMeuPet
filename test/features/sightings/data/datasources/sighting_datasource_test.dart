import 'package:flutter_test/flutter_test.dart';
import 'package:voce_viu_meu_pet/features/sightings/data/datasources/sighting_datasource.dart';

void main() {
  group('SightingDataSource', () {
    test('SightingDataSource can be instantiated', () {
      expect(SightingDataSource, isNotNull);
    });

    test('fetchSightings method exists', () {
      expect(SightingDataSource, isNotNull);
    });

    test('createSighting method exists', () {
      expect(SightingDataSource, isNotNull);
    });

    test('uploadPhoto method exists', () {
      expect(SightingDataSource, isNotNull);
    });
  });
}
