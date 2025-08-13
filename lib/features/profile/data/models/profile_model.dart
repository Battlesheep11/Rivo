class Profile {
  final String id;
  final String fullName;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int followers;
  final int following;
  final List<String> tags;

  const Profile({
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

  /// Accepts EITHER:
  /// A) a "joined" payload:
  ///    { profile: {...}, tags: [{name: '…'}], followers_count: 0, following_count: 0 }
  /// B) a plain profiles row:
  ///    { id, username, first_name, last_name, full_name?, avatar_url, bio, ... }
  ///
  /// Never blindly casts; returns a valid Profile or throws a clear error.
  factory Profile.fromData(Map<String, dynamic> data) {
    // If the server returned a "joined" shape, unwrap it.
    final Map<String, dynamic> profileMap = (data['profile'] is Map)
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : data;

    // Followers / following can live at root (joined) or inside profile (plain none).
    int asInt(dynamic v) => (v is num) ? v.toInt() : 0;
    final followers =
        asInt(data['followers_count'] ?? profileMap['followers_count']);
    final following =
        asInt(data['following_count'] ?? profileMap['following_count']);

    // Tags can be:
    // - List<Map> with {name}
    // - List<String>
    // - missing/null → []
    List<String> parseTags(dynamic raw) {
      if (raw is List) {
        return raw
            .map((e) {
              if (e is Map && e['name'] is String) return e['name'] as String;
              if (e is String) return e;
              return null;
            })
            .whereType<String>()
            .toList(growable: false);
      }
      return const <String>[];
    }

    final tags = parseTags(data['tags'] ?? profileMap['tags']);

    // full_name fallback: first_name + last_name
    String buildFullName(Map<String, dynamic> m) {
      final explicit = m['full_name'] as String?;
      if (explicit != null && explicit.trim().isNotEmpty) return explicit;
      final fn = (m['first_name'] as String?)?.trim() ?? '';
      final ln = (m['last_name'] as String?)?.trim() ?? '';
      final combined = '$fn $ln'.trim();
      return combined.isEmpty ? 'No Name' : combined;
    }

    // Required fields with safe casts
    final id = profileMap['id'] as String?;
    final username = (profileMap['username'] as String?) ?? 'no_username';

    if (id == null || id.isEmpty) {
      throw StateError('Profile.fromData: missing required "id".');
    }

    return Profile(
      id: id,
      fullName: buildFullName(profileMap),
      username: username,
      avatarUrl: profileMap['avatar_url'] as String?,
      bio: profileMap['bio'] as String?,
      followers: followers,
      following: following,
      tags: tags,
    );
  }

  /// Null‑safe helper: returns `null` instead of throwing.
  static Profile? tryParse(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      try {
        return Profile.fromData(data);
      } catch (_) {
        return null;
      }
    }
    // If some SDK returns Map<dynamic,dynamic>, coerce it.
    if (data is Map) {
      try {
        return Profile.fromData(Map<String, dynamic>.from(data));
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
