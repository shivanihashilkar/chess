import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../models/match_result.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chess_tournament.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE players (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL,
      rating INTEGER NOT NULL, created_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE tournaments (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT NOT NULL,
      date TEXT NOT NULL, status TEXT NOT NULL,
      player_ids TEXT NOT NULL, created_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE match_results (
      id TEXT PRIMARY KEY, tournament_id TEXT NOT NULL,
      white_player_id TEXT NOT NULL, black_player_id TEXT NOT NULL,
      winner_id TEXT NOT NULL, round TEXT NOT NULL, played_at TEXT NOT NULL)''');
  }

  Future<void> insertPlayer(Player p) async =>
      (await database).insert('players', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<Player>> getAllPlayers() async =>
      ((await database).query('players', orderBy: 'name ASC')).then((r) => r.map((m) => Player.fromMap(m)).toList());

  Future<Player?> getPlayer(String id) async {
    final r = await (await database).query('players', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : Player.fromMap(r.first);
  }

  Future<void> updatePlayer(Player p) async =>
      (await database).update('players', p.toMap(), where: 'id=?', whereArgs: [p.id]);

  Future<void> deletePlayer(String id) async =>
      (await database).delete('players', where: 'id=?', whereArgs: [id]);

  Future<void> insertTournament(Tournament t) async =>
      (await database).insert('tournaments', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<Tournament>> getAllTournaments() async =>
      ((await database).query('tournaments', orderBy: 'created_at DESC')).then((r) => r.map((m) => Tournament.fromMap(m)).toList());

  Future<Tournament?> getTournament(String id) async {
    final r = await (await database).query('tournaments', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : Tournament.fromMap(r.first);
  }

  Future<void> updateTournament(Tournament t) async =>
      (await database).update('tournaments', t.toMap(), where: 'id=?', whereArgs: [t.id]);

  Future<void> deleteTournament(String id) async {
    await (await database).delete('tournaments', where: 'id=?', whereArgs: [id]);
    await deleteMatchesForTournament(id);
  }

  Future<void> insertMatchResult(MatchResult m) async =>
      (await database).insert('match_results', m.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<MatchResult>> getMatchesForTournament(String tid) async =>
      ((await database).query('match_results', where: 'tournament_id=?', whereArgs: [tid], orderBy: 'played_at ASC'))
          .then((r) => r.map((m) => MatchResult.fromMap(m)).toList());

  Future<void> deleteMatchesForTournament(String tid) async =>
      (await database).delete('match_results', where: 'tournament_id=?', whereArgs: [tid]);
}