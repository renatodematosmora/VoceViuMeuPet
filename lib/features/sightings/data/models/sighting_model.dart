import 'package:voce_viu_meu_pet/features/sightings/domain/entities/sighting.dart';

class SightingModel extends Sighting {
  const SightingModel({
    required super.id,
    required super.petId,
    required super.reporterId,
    required super.photoUrl,
    required super.lat,
    required super.lng,
    required super.address,
    super.description,
    required super.seenAt,
    required super.createdAt,
    super.reporterName,
    super.reporterAvatar,
  });

  factory SightingModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    return SightingModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      reporterId: json['reporter_id'] as String,
      photoUrl: json['photo_url'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
      description: json['description'] as String?,
      seenAt: DateTime.parse(json['seen_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      reporterName: profiles?['full_name'] as String?,
      reporterAvatar: profiles?['avatar_url'] as String?,
    );
  }
}
