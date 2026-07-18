import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/tournament.dart';
import '../../models/player.dart';
import '../../providers/tournament_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/match_provider.dart';
import '../matches/rankings_screen.dart';
import 'tournament_form_screen.dart';

class TournamentDetailScreen extends ConsumerWidget {
  final String tournamentId;
  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourneysAsync = ref.watch(tournamentListProvider);
    final playersAsync = ref.watch(playerListProvider);

    return tourneysAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
      data: (tournaments) {
        final tournament = tournaments.cast<Tournament?>().firstWhere(
            (t) => t?.id == tournamentId,
            orElse: () => null);
        if (tournament == null) {
          return const Scaffold(
              body: Center(child: Text('Tournament not found')));
        }

        return playersAsync.when(
          loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator())),
          error: (e, _) =>
              Scaffold(body: Center(child: Text('Error: $e'))),
          data: (allPlayers) {
            final enrolled = allPlayers
                .where((p) => tournament.playerIds.contains(p.id))
                .toList();
            final available = allPlayers
                .where((p) => !tournament.playerIds.contains(p.id))
                .toList();
            final fmt = DateFormat('MMM dd, yyyy');
            final canStart = enrolled.length >= 2 &&
                tournament.status != TournamentStatus.completed;

            return Scaffold(
              appBar: AppBar(
                title: Text(tournament.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TournamentFormScreen(
                                tournament: tournament))),
                  ),
                  if (tournament.status == TournamentStatus.completed)
                    IconButton(
                      icon: const Icon(Icons.leaderboard),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RankingsScreen(
                                  tournamentId: tournamentId))),
                    ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(fmt.format(tournament.date),
                                style:
                                    const TextStyle(color: Colors.grey)),
                            const Spacer(),
                            _StatusChip(status: tournament.status),
                          ]),
                          if (tournament.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(tournament.description),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Enrolled Players',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (available.isNotEmpty &&
                          tournament.status !=
                              TournamentStatus.completed)
                        TextButton.icon(
                          onPressed: () => _showAddPlayerDialog(
                              context, ref, tournament, available),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Add'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (enrolled.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                            child: Text('No players enrolled yet',
                                style: TextStyle(color: Colors.grey))),
                      ),
                    )
                  else
                    ...enrolled.map((p) => _EnrolledPlayerTile(
                          player: p,
                          canRemove: tournament.status !=
                              TournamentStatus.completed,
                          onRemove: () => ref
                              .read(tournamentListProvider.notifier)
                              .removePlayerFromTournament(
                                  tournamentId, p.id),
                        )),
                  const SizedBox(height: 24),
                  if (canStart)
                    FilledButton.icon(
                      onPressed: () => _startTournament(
                          context, ref, tournament, enrolled),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text(
                          'Generate Matches & Run Tournament'),
                      style: FilledButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  if (tournament.status ==
                      TournamentStatus.completed) ...[
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RankingsScreen(
                                  tournamentId: tournamentId))),
                      icon: const Icon(Icons.leaderboard),
                      label: const Text('View Rankings & Results'),
                      style: FilledButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _resetTournament(
                          context, ref, tournament, enrolled),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Re-run Tournament'),
                      style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPlayerDialog(BuildContext context, WidgetRef ref,
      Tournament tournament, List<Player> available) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Add Player',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...available.map((p) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1B4332),
                  child: Text(p.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(p.name),
                subtitle: Text('Rating: ${p.rating}'),
                onTap: () {
                  ref
                      .read(tournamentListProvider.notifier)
                      .addPlayerToTournament(tournament.id, p.id);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _startTournament(BuildContext context, WidgetRef ref,
      Tournament tournament, List<Player> enrolled) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Tournament'),
        content: Text(
            'Generate random matches for ${enrolled.length} players?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(tournamentListProvider.notifier)
                  .updateStatus(
                      tournament.id, TournamentStatus.ongoing);
              ref
                  .read(matchListProvider(tournament.id).notifier)
                  .generateMatches(
                      enrolled.map((p) => p.id).toList());
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _resetTournament(BuildContext context, WidgetRef ref,
      Tournament tournament, List<Player> enrolled) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Re-run Tournament'),
        content: const Text(
            'This will clear all previous results and generate new random matches.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(matchListProvider(tournament.id).notifier)
                  .generateMatches(
                      enrolled.map((p) => p.id).toList());
            },
            child: const Text('Re-run'),
          ),
        ],
      ),
    );
  }
}

class _EnrolledPlayerTile extends StatelessWidget {
  final Player player;
  final bool canRemove;
  final VoidCallback onRemove;

  const _EnrolledPlayerTile(
      {required this.player,
      required this.canRemove,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1B4332),
          child: Text(player.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(player.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Rating: ${player.rating}'),
        trailing: canRemove
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red),
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TournamentStatus status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case TournamentStatus.upcoming:
        return Colors.blue;
      case TournamentStatus.ongoing:
        return Colors.orange;
      case TournamentStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.name.toUpperCase(),
          style: TextStyle(
              color: _color,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }
}
