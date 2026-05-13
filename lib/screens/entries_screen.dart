import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../repositories/local_journal_entry_repository.dart';
import '../widgets/section_card.dart';
import 'entry_editor_screen.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  bool _isLoading = true;
  List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalJournalEntryRepository(prefs);
    final entries = await repository.listEntries();
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _openEntry(JournalEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryEditorScreen(date: entry.date),
      ),
    );
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Previous entries',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _entries.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return GestureDetector(
                          onTap: () => _openEntry(entry),
                          child: SectionCard(
                            title: _formatDate(entry.date),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StatusPill(label: _statusLabel(entry)),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, size: 18),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _previewText(entry),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _lastSavedLabel(entry.lastSavedAt),
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No entries yet. Start writing in Home.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  String _previewText(JournalEntry entry) {
    final rough = entry.roughDiary.trim();
    final summary = entry.aiSummary.trim();
    final source = rough.isNotEmpty ? rough : summary;
    if (source.isEmpty) {
      return 'No text yet.';
    }
    return source.split('\n').first.trim();
  }

  String _statusLabel(JournalEntry entry) {
    if (entry.isCommitted) {
      final committedAt = entry.lastCommittedAt;
      if (committedAt != null && entry.updatedAt.isAfter(committedAt)) {
        return 'Modified after commit';
      }
      return 'Committed';
    }
    return 'Not committed';
  }

  String _lastSavedLabel(DateTime? savedAt) {
    if (savedAt == null) {
      return 'Not saved yet';
    }
    return 'Saved ${_formatElapsed(savedAt)}';
  }

  String _formatElapsed(DateTime since) {
    final diff = DateTime.now().difference(since);
    if (diff.inSeconds < 5) {
      return 'just now';
    }
    if (diff.inMinutes < 1) {
      return '${diff.inSeconds} sec ago';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} hr ago';
    }
    return '${diff.inDays} days ago';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.4)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
