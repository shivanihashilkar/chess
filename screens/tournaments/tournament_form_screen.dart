import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/tournament.dart';
import '../../providers/tournament_provider.dart';

class TournamentFormScreen extends ConsumerStatefulWidget {
  final Tournament? tournament;
  const TournamentFormScreen({super.key, this.tournament});

  @override
  ConsumerState<TournamentFormScreen> createState() =>
      _TournamentFormScreenState();
}

class _TournamentFormScreenState
    extends ConsumerState<TournamentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.tournament?.name ?? '');
    _descCtrl = TextEditingController(
        text: widget.tournament?.description ?? '');
    if (widget.tournament != null) {
      _selectedDate = widget.tournament!.date;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final notifier = ref.read(tournamentListProvider.notifier);
    if (widget.tournament == null) {
      await notifier.addTournament(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate,
      );
    } else {
      await notifier.updateTournament(widget.tournament!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tournament != null;
    final fmt = DateFormat('MMM dd, yyyy');
    return Scaffold(
      appBar: AppBar(
          title:
              Text(isEdit ? 'Edit Tournament' : 'New Tournament')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tournament Name',
                  prefixIcon: Icon(Icons.emoji_events),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text('Date: ${fmt.format(_selectedDate)}'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(isEdit
                    ? 'Update Tournament'
                    : 'Create Tournament'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
