import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/match_provider.dart';
import '../../providers/player_provider.dart';
import '../../models/match_result.dart';

class RankingsScreen extends ConsumerWidget {
  final String tournamentId;
  const RankingsScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchListProvider(tournamentId));
    final playersAsync = ref.watch(playerListProvider);
    final winsMap = ref.watch(rankingsProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings & Results',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (matches) => playersAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (allPlayers) {
            final playerMap = {for (final p in allPlayers) p.id: p};
            final ranked = winsMap.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (ranked.isNotEmpty) ...[
                  const Text('Final Rankings',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...ranked.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final playerId = entry.value.key;
                    final wins = entry.value.value;
                    final player = playerMap[playerId];
                    final totalMatches = matches
                        .where((m) =>
                            m.whitePlayerId == playerId ||
                            m.blackPlayerId == playerId)
                        .length;
                    return _RankingCard(
                      rank: rank,
                      playerName: player?.name ?? 'Unknown',
                      wins: wins,
                      totalMatches: totalMatches,
                    );
                  }),
                  const SizedBox(height: 24),
                ],
                const Text('Match Results',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (matches.isEmpty)
                  const Center(
                      child: Text('No matches played yet.',
                          style: TextStyle(color: Colors.grey)))
                else
                  ...matches.map((m) => _MatchCard(
                        match: m,
                        whiteName:
                            playerMap[m.whitePlayerId]?.name ?? 'Unknown',
                        blackName:
                            playerMap[m.blackPlayerId]?.name ?? 'Unknown',
                        winnerName:
                            playerMap[m.winnerId]?.name ?? 'Unknown',
                      )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int rank;
  final String playerName;
  final int wins;
  final int totalMatches;

  const _RankingCard({
    required this.rank,
    required this.playerName,
    required this.wins,
    required this.totalMatches,
  });

  Color get _medalColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade300;
    }
  }

  String get _medal {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: rank <= 3 ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: rank <= 3
            ? BorderSide(color: _medalColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _medalColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: rank <= 3
                    ? Text(_medal,
                        style: const TextStyle(fontSize: 24))
                    : Text('#$rank',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('$wins win(s) out of $totalMatches match(es)',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4332).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$wins W',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332))),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchResult match;
  final String whiteName;
  final String blackName;
  final String winnerName;

  const _MatchCard({
    required this.match,
    required this.whiteName,
    required this.blackName,
    required this.winnerName,
  });

  @override
  Widget build(BuildContext context) {
    final whiteWon = match.winnerId == match.whitePlayerId;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(match.round,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _PlayerSide(
                        name: whiteName,
                        isWinner: whiteWon,
                        side: 'White')),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('vs',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                    child: _PlayerSide(
                        name: blackName,
                        isWinner: !whiteWon,
                        side: 'Black',
                        alignRight: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerSide extends StatelessWidget {
  final String name;
  final bool isWinner;
  final String side;
  final bool alignRight;

  const _PlayerSide({
    required this.name,
    required this.isWinner,
    required this.side,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(side,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Row(
          mainAxisAlignment: alignRight
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!alignRight && isWinner)
              const Icon(Icons.emoji_events,
                  color: Color(0xFFFFD700), size: 16),
            if (!alignRight && isWinner) const SizedBox(width: 4),
            Flexible(
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: isWinner
                          ? FontWeight.bold
                          : FontWeight.normal)),
            ),
            if (alignRight && isWinner) const SizedBox(width: 4),
            if (alignRight && isWinner)
              const Icon(Icons.emoji_events,
                  color: Color(0xFFFFD700), size: 16),
          ],
        ),
        if (isWinner)
          Text('Winner',
              style: TextStyle(
                  color: Colors.green.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
      ],
    );
  }
}
