import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../repositories/local_journal_entry_repository.dart';
import '../services/ai_summary_service.dart';
import '../widgets/section_card.dart';

class SummaryScreen extends StatefulWidget {
  SummaryScreen({super.key, DateTime? date})
      : date = date ?? DateTime.now();

  final DateTime date;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _summaryController = TextEditingController();
  final _roughController = TextEditingController();
  final _summaryService = AiSummaryService();

  LocalJournalEntryRepository? _repository;
  JournalEntry? _entry;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isSaving = false;

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

    if (!mounted) {
      return;
    }

    _repository = repository;
    _entry = entry;
    _roughController.text = entry.roughDiary;
    _summaryController.text = entry.aiSummary;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _roughController.dispose();
    super.dispose();
  }

  Future<void> _generateSummary() async {
    final roughDiary = _roughController.text.trim();
    if (roughDiary.isEmpty) {
      _showMessage('Write a rough diary entry first.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final result =
          await _summaryService.generate(roughDiary: roughDiary);
      _summaryController.text = result;
      _showMessage('Summary generated. Review before saving.');
    } catch (_) {
      _showMessage('Summary generation failed. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveSummary() async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    final summary = _summaryController.text.trim();
    if (summary.isEmpty) {
      _showMessage('Summary is empty.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await repository.updateAiSummary(widget.date, summary);
      _showMessage('Summary saved locally.');
    } catch (_) {
      _showMessage('Could not save summary.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final cardHeight = isWide ? 320.0 : 260.0;

        final roughDiaryCard = SizedBox(
          height: cardHeight,
          child: SectionCard(
            title: 'Rough diary',
            child: TextField(
              controller: _roughController,
              expands: true,
              maxLines: null,
              minLines: null,
              readOnly: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Today: shaped the structure and flow...'
              ),
            ),
          ),
        );

        final summaryCard = SizedBox(
          height: cardHeight,
          child: SectionCard(
            title: 'AI summary (editable)',
            child: TextField(
              controller: _summaryController,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'One-line summary, wins, and time allocation...'
              ),
            ),
          ),
        );

        final content = isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: roughDiaryCard),
                  const SizedBox(width: 16),
                  Expanded(child: summaryCard),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  roughDiaryCard,
                  const SizedBox(height: 16),
                  summaryCard,
                ],
              );

        final hasSummary = _summaryController.text.trim().isNotEmpty;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI summary',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _isGenerating ? null : _generateSummary,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(hasSummary ? 'Regenerate' : 'Generate Summary'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : _saveSummary,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Summary'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showMessage('Preview in Milestone 6.'),
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview Markdown'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showMessage('GitHub sync in Milestone 7.'),
                    icon: const Icon(Icons.upload),
                    label: const Text('Push to GitHub'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
