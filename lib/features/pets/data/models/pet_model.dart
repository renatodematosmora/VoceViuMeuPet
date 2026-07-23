import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

class PetModel extends Pet {
  const PetModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.species,
    super.breed,
    required super.color,
    required super.size,
    super.ageApprox,
    required super.description,
    super.reward,
    required super.status,
    required super.lostAt,
    required super.lostLat,
    required super.lostLng,
    required super.lostAddress,
    required super.photos,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
        id: json['id'] as String,
        ownerId: json['owner_id'] as String,
        name: json['name'] as String,
        species: PetSpecies.values.firstWhere(
          (e) => e.name == json['species'],
          orElse: () => PetSpecies.other,
        ),
        breed: json['breed'] as String?,
        color: json['color'] as String,
        size: PetSize.values.firstWhere(
          (e) => e.name == json['size'],
          orElse: () => PetSize.medium,
        ),
        ageApprox: json['age_approx'] as String?,
        description: json['description'] as String,
        reward: json['reward'] as String?,
        status: PetStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PetStatus.active,
        ),
        lostAt: DateTime.parse(json['lost_at'] as String),
        lostLat: (json['lost_lat'] as num).toDouble(),
        lostLng: (json['lost_lng'] as num).toDouble(),
        lostAddress: json['lost_address'] as String,
        photos: List<String>.from(json['photos'] as List? ?? []),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'owner_id': ownerId,
        'name': name,
        'species': species.value,
        if (breed != null) 'breed': breed,
        'color': color,
        'size': size.value,
        if (ageApprox != null) 'age_approx': ageApprox,
        'description': description,
        if (reward != null) 'reward': reward,
        'status': status.value,
        'lost_at': lostAt.toIso8601String(),
        'lost_lat': lostLat,
        'lost_lng': lostLng,
        'lost_address': lostAddress,
        'photos': photos,
      };
}
