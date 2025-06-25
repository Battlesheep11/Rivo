class TagEntity {
  final String name;
  final String? id;

  TagEntity({
    required this.name,
    this.id,
  });

  factory TagEntity.fromJson(Map<String, dynamic> json) {
    return TagEntity(
      id: json['id'] as String?,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
