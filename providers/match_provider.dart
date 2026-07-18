import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/match_result.dart';
import '../models/tournament.dart';
import 'tournament_provider.dart';

final matchListProvider = StateNotifierProvider.family<MatchNotifier,
    AsyncValue<List<MatchResult>>, String>((ref, tournamentId) {
  return MatchNotifier(tournamentId, ref);
});

class MatchNotifier extends StateNotifier<AsyncValue<List<MatchResult>>> {
  final String tournamentId;
  final Ref ref;

  MatchNotifier(this.tournamentId, this.ref)
      : super(const AsyncValue.loading()) {
    loadMatches();
  }

  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();
  final _rng = Random();

  Future<void> loadMatches() async {
    state = const AsyncValue.loading();
    try {
      final matches = await _db.getMatchesForTournament(tournamentId);
      state = AsyncValue.data(matches);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generateMatches(List<String> playerIds) async {
    if (playerIds.length < 2) return;

    await _db.deleteMatchesForTournament(tournamentId);

    final shuffled = [...playerIds]..shuffle(_rng);
    int roundNumber = 1;

    for (var i = 0; i + 1 < shuffled.length; i += 2) {
      final white = shuffled[i];
      final black = shuffled[i + 1];
      final winner = _rng.nextBool() ? white : black;

      final match = MatchResult(
        id: _uuid.v4(),
        tournamentId: tournamentId,
        whitePlayerId: white,
        blackPlayerId: black,
        winnerId: winner,
        round: 'Round $roundNumber',
        playedAt: DateTime.now(),
      );
      await _db.insertMatchResult(match);
      roundNumber++;
    }

    ref
        .read(tournamentListProvider.notifier)
        .updateStatus(tournamentId, TournamentStatus.completed);

    await loadMatches();
  }
}

final rankingsProvider =
    Provider.family<Map<String, int>, String>((ref, tournamentId) {
  final matchesAsync = ref.watch(matchListProvider(tournamentId));
  return matchesAsync.when(
    data: (matches) {
      final wins = <String, int>{};
      for (final m in matches) {
        wins[m.winnerId] = (wins[m.winnerId] ?? 0) + 1;
      }
      return wins;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
