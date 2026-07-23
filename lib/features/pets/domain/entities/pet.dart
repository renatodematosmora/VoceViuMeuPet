enum PetSpecies { dog, cat, bird, rabbit, other }
enum PetSize { small, medium, large }
enum PetStatus { active, found, closed }

extension PetSpeciesLabel on PetSpecies {
  String get label => switch (this) {
    PetSpecies.dog    => 'Cachorro',
    PetSpecies.cat    => 'Gato',
    PetSpecies.bird   => 'Pássaro',
    PetSpecies.rabbit => 'Coelho',
    PetSpecies.other  => 'Outro',
  };
  String get emoji => switch (this) {
    PetSpecies.dog    => '🐶',
    PetSpecies.cat    => '🐱',
    PetSpecies.bird   => '🐦',
    PetSpecies.rabbit => '🐰',
    PetSpecies.other  => '🐾',
  };
  String get value => name;
}

extension PetSizeLabel on PetSize {
  String get label => switch (this) {
    PetSize.small  => 'Pequeno (até 10kg)',
    PetSize.medium => 'Médio (10–25kg)',
    PetSize.large  => 'Grande (acima de 25kg)',
  };
  String get value => name;
}

extension PetStatusLabel on PetStatus {
  String get label => switch (this) {
    PetStatus.active => 'Procurando',
    PetStatus.found  => 'Encontrado',
    PetStatus.closed => 'Encerrado',
  };
  String get value => name;
}

class Pet {
  final String id;
  final String ownerId;
  final String name;
  final PetSpecies species;
  final String? breed;
  final String color;
  final PetSize size;
  final String? ageApprox;
  final String description;
  final String? reward;
  final PetStatus status;
  final DateTime lostAt;
  final double lostLat;
  final double lostLng;
  final String lostAddress;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.breed,
    required this.color,
    required this.size,
    this.ageApprox,
    required this.description,
    this.reward,
    required this.status,
    required this.lostAt,
    required this.lostLat,
    required this.lostLng,
    required this.lostAddress,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  String get mainPhoto => photos.isNotEmpty ? photos.first : '';
  bool get isActive => status == PetStatus.active;
  bool get isFound => status == PetStatus.found;
}
