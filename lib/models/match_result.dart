class MatchResult {
  final String id;
  final String tournamentId;
  final String whitePlayerId;
  final String blackPlayerId;
  final String winnerId;
  final String round;
  final DateTime playedAt;

  MatchResult({
    required this.id,
    required this.tournamentId,
    required this.whitePlayerId,
    required this.blackPlayerId,
    required this.winnerId,
    required this.round,
    required this.playedAt,
  });

  factory MatchResult.fromMap(Map<String, dynamic> map) {
    return MatchResult(
      id: map['id'] as String,
      tournamentId: map['tournament_id'] as String,
      whitePlayerId: map['white_player_id'] as String,
      blackPlayerId: map['black_player_id'] as String,
      winnerId: map['winner_id'] as String,
      round: map['round'] as String,
      playedAt: DateTime.parse(map['played_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'white_player_id': whitePlayerId,
      'black_player_id': blackPlayerId,
      'winner_id': winnerId,
      'round': round,
      'played_at': playedAt.toIso8601String(),
    };
  }
}
