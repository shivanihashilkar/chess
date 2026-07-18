import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/player.dart';

final playerListProvider =
    StateNotifierProvider<PlayerNotifier, AsyncValue<List<Player>>>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<AsyncValue<List<Player>>> {
  PlayerNotifier() : super(const AsyncValue.loading()) {
    loadPlayers();
  }

  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<void> loadPlayers() async {
    state = const AsyncValue.loading();
    try {
      final players = await _db.getAllPlayers();
      state = AsyncValue.data(players);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPlayer({
    required String name,
    required String email,
    required int rating,
  }) async {
    final player = Player(
      id: _uuid.v4(),
      name: name,
      email: email,
      rating: rating,
      createdAt: DateTime.now(),
    );
    await _db.insertPlayer(player);
    await loadPlayers();
  }

  Future<void> updatePlayer(Player player) async {
    await _db.updatePlayer(player);
    await loadPlayers();
  }

  Future<void> deletePlayer(String id) async {
    await _db.deletePlayer(id);
    await loadPlayers();
  }
}
