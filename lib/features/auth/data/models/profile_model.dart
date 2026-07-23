import 'package:voce_viu_meu_pet/features/auth/domain/entities/user_profile.dart';

class ProfileModel extends UserProfile {
  const ProfileModel({
    required super.id,
    required super.username,
    required super.fullName,
    super.avatarUrl,
    super.city,
    super.phone,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        username: json['username'] as String,
        fullName: json['full_name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        city: json['city'] as String?,
        phone: json['phone'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (city != null) 'city': city,
        if (phone != null) 'phone': phone,
      };
}
