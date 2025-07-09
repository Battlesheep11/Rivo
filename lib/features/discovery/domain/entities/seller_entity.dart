class SellerEntity {
  final String id;
  final String username;
  final String? avatarUrl;
  final List<String> tags;

  SellerEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.tags = const [],
  });

  factory SellerEntity.fromJson(Map<String, dynamic> json) {
    return SellerEntity(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
    );
  }

factory SellerEntity.empty() {
    return SellerEntity(
      id: '',
      username: 'Unknown',
      avatarUrl: null,
tags: const [],  
    );
  }

  factory SellerEntity.fromMap(Map<String, dynamic> json) {
    return SellerEntity(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
    );
  }

}
