class UserProfileEntity {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isSeller;
  final String language; // 'he' or 'en'
  final DateTime? lastSeenAt;
  final DateTime? createdAt;

  const UserProfileEntity({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.isSeller,
    required this.language,
    this.lastSeenAt,
    this.createdAt,
  });

  String get displayLabel => displayName?.isNotEmpty == true ? displayName! : username;
}
