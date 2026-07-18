import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/tournament.dart';

final tournamentListProvider =
    StateNotifierProvider<TournamentNotifier, AsyncValue<List<Tournament>>>(
        (ref) {
  return TournamentNotifier();
});

class TournamentNotifier
    extends StateNotifier<AsyncValue<List<Tournament>>> {
  TournamentNotifier() : super(const AsyncValue.loading()) {
    loadTournaments();
  }

  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<void> loadTournaments() async {
    state = const AsyncValue.loading();
    try {
      final tournaments = await _db.getAllTournaments();
      state = AsyncValue.data(tournaments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTournament({
    required String name,
    required String description,
    required DateTime date,
  }) async {
    final t = Tournament(
      id: _uuid.v4(),
      name: name,
      description: description,
      date: date,
      status: TournamentStatus.upcoming,
      playerIds: [],
      createdAt: DateTime.now(),
    );
    await _db.insertTournament(t);
    await loadTournaments();
  }

  Future<void> updateTournament(Tournament tournament) async {
    await _db.updateTournament(tournament);
    await loadTournaments();
  }

  Future<void> deleteTournament(String id) async {
    await _db.deleteTournament(id);
    await loadTournaments();
  }

  Future<void> addPlayerToTournament(
      String tournamentId, String playerId) async {
    final current = await _db.getTournament(tournamentId);
    if (current == null) return;
    if (current.playerIds.contains(playerId)) return;
    final updated =
        current.copyWith(playerIds: [...current.playerIds, playerId]);
    await _db.updateTournament(updated);
    await loadTournaments();
  }

  Future<void> removePlayerFromTournament(
      String tournamentId, String playerId) async {
    final current = await _db.getTournament(tournamentId);
    if (current == null) return;
    final updated = current.copyWith(
        playerIds:
            current.playerIds.where((id) => id != playerId).toList());
    await _db.updateTournament(updated);
    await loadTournaments();
  }

  Future<void> updateStatus(
      String tournamentId, TournamentStatus status) async {
    final current = await _db.getTournament(tournamentId);
    if (current == null) return;
    await _db.updateTournament(current.copyWith(status: status));
    await loadTournaments();
  }
}
