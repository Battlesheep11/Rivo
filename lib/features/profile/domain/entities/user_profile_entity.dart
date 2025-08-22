class UserProfileEntity {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? bio;
  final bool isSeller;
  final String language;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;
  final String? onboardingSource;

  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;
  final String? utmTerm;
  final String? utmContent;
  final String? referralCode;

  const UserProfileEntity({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.bio,
    required this.isSeller,
    required this.language,
    this.lastSeenAt,
    this.createdAt,
    this.onboardingSource,
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
    this.utmTerm,
    this.utmContent,
    this.referralCode,
  });

  String get fullName => [firstName, lastName].where((s) => s?.isNotEmpty == true).join(' ');
}
