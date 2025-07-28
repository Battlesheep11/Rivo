
class Profile {
  final String id;
  final String fullName;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int followers;
  final int following;
  final List<String> tags;

  Profile({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.followers,
    required this.following,
    required this.tags,
  });

  Profile copyWith({
    String? id,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? bio,
    int? followers,
    int? following,
    List<String>? tags,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      tags: tags ?? this.tags,
    );
  }

  factory Profile.fromData(Map<String, dynamic> data) {
    final profileData = data['profile'] as Map<String, dynamic>;
    final tagsData = data['tags'] as List<dynamic>;

    return Profile(
      id: profileData['id'],
      fullName: profileData['full_name'] ?? 'No Name',
      username: profileData['username'] ?? 'no_username',
      avatarUrl: profileData['avatar_url'],
      bio: profileData['bio'],
      followers: data['followers_count'] as int,
      following: data['following_count'] as int,
      tags: tagsData.map((tag) => tag['name'] as String).toList(),
    );
  }
}
