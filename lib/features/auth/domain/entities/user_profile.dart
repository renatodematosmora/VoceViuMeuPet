// Entidade: Usuário/Perfil
class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? city;
  final String? phone;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.city,
    this.phone,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? city,
    String? phone,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}
