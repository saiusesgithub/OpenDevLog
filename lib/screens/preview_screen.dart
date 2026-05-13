import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../repositories/local_journal_entry_repository.dart';
import '../services/markdown_builder.dart';
import '../widgets/section_card.dart';
import 'summary_screen.dart';

class PreviewScreen extends StatefulWidget {
  PreviewScreen({super.key, DateTime? date}) : date = date ?? DateTime.now();

  final DateTime date;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _builder = MarkdownBuilder();
  String _markdown = '';
  bool _isLoading = true;
  LocalJournalEntryRepository? _repository;
  JournalEntry? _entry;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalJournalEntryRepository(prefs);
    final entry = await repository.getEntryByDate(widget.date) ??
        JournalEntry.empty(widget.date);
    final markdown = _builder.build(
      date: widget.date,
      aiSummary: entry.aiSummary,
      roughDiary: entry.roughDiary,
    );

    if (!mounted) {
      return;
    }

    _repository = repository;
    _entry = entry;

    setState(() {
      _markdown = markdown;
      _isLoading = false;
    });

    if (entry.aiSummary.trim().isNotEmpty ||
        entry.roughDiary.trim().isNotEmpty) {
      await repository.updateFinalMarkdown(widget.date, markdown);
    }
  }

  Future<void> _openSummary() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SummaryScreen(date: widget.date),
      ),
    );
    await _loadEntry();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final entry = _entry;
    final isReady = (entry?.aiSummary.trim().isNotEmpty ?? false) ||
        (entry?.roughDiary.trim().isNotEmpty ?? false);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Final markdown preview',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Preview',
            child: SelectableText(
              _markdown,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: isReady
                    ? () => _showMessage('GitHub sync in Milestone 7.')
                    : null,
                icon: const Icon(Icons.upload),
                label: const Text('Push to GitHub'),
              ),
              OutlinedButton.icon(
                onPressed: _openSummary,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Summary'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
