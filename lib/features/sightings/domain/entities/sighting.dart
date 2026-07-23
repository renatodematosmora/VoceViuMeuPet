class Sighting {
  final String id;
  final String petId;
  final String reporterId;
  final String photoUrl;
  final double lat;
  final double lng;
  final String address;
  final String? description;
  final DateTime seenAt;
  final DateTime createdAt;

  // join com profiles
  final String? reporterName;
  final String? reporterAvatar;

  const Sighting({
    required this.id,
    required this.petId,
    required this.reporterId,
    required this.photoUrl,
    required this.lat,
    required this.lng,
    required this.address,
    this.description,
    required this.seenAt,
    required this.createdAt,
    this.reporterName,
    this.reporterAvatar,
  });
}
