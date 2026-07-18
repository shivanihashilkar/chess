class Player {
  final String id;
  final String name;
  final String email;
  final int rating;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.createdAt,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      rating: map['rating'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Player copyWith({
    String? id,
    String? name,
    String? email,
    int? rating,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
