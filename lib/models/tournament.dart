enum TournamentStatus { upcoming, ongoing, completed }

class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final TournamentStatus status;
  final List<String> playerIds;
  final DateTime createdAt;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.status,
    required this.playerIds,
    required this.createdAt,
  });

  factory Tournament.fromMap(Map<String, dynamic> map) {
    final playerIdsStr = map['player_ids'] as String? ?? '';
    final playerIds = playerIdsStr.isEmpty
        ? <String>[]
        : playerIdsStr.split(',').where((e) => e.isNotEmpty).toList();
    return Tournament(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      status: TournamentStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => TournamentStatus.upcoming,
      ),
      playerIds: playerIds,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'status': status.name,
      'player_ids': playerIds.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Tournament copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    TournamentStatus? status,
    List<String>? playerIds,
    DateTime? createdAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      playerIds: playerIds ?? this.playerIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
