import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../repositories/local_journal_entry_repository.dart';
import '../repositories/local_settings_repository.dart';
import '../services/github_api_service.dart';
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
  final _githubService = GitHubApiService();
  String _markdown = '';
  bool _isLoading = true;
  bool _isPushing = false;
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

  Future<void> _pushToGitHub() async {
    if (_isPushing) {
      return;
    }

    final repository = _repository;
    if (repository == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final settingsRepo = LocalSettingsRepository(prefs);
    final settings = await settingsRepo.getSettings();
    final token = settings.githubToken?.trim() ?? '';
    final repo = settings.selectedRepo?.trim() ?? '';

    if (token.isEmpty) {
      _showMessage('Add a GitHub token in Settings.');
      return;
    }
    if (repo.isEmpty) {
      _showMessage('Select a GitHub repo in Settings.');
      return;
    }

    setState(() {
      _isPushing = true;
    });

    try {
      var username = settings.githubUsername?.trim();
      if (username == null || username.isEmpty) {
        final user = await _githubService.getAuthenticatedUser(token);
        username = user.login;
        await settingsRepo.saveSettings(
          settings.copyWith(githubUsername: username),
        );
      }

      final branch = settings.selectedBranch.isEmpty
          ? 'main'
          : settings.selectedBranch;
      final path = _buildPath(widget.date);
      final message = _commitMessage(widget.date, _entry?.isCommitted ?? false);

      final result = await _githubService.upsertFile(
        token: token,
        owner: username,
        repo: repo,
        path: path,
        content: _markdown,
        message: message,
        branch: branch,
      );

      final now = DateTime.now();
      final updated = (await repository.getEntryByDate(widget.date) ??
              JournalEntry.empty(widget.date))
          .copyWith(
        finalMarkdown: _markdown,
        isCommitted: true,
        lastCommittedAt: now,
        githubCommitSha: result.commitSha,
      );

      await repository.saveEntry(updated);
      if (!mounted) {
        return;
      }

      setState(() {
        _entry = updated;
      });
      _showMessage(result.created
          ? 'Devlog pushed to GitHub.'
          : 'Devlog updated on GitHub.');
    } catch (error) {
      _showMessage('GitHub push failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPushing = false;
        });
      }
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

  String _buildPath(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final monthNum = date.month.toString().padLeft(2, '0');
    final monthName = _monthName(date.month);
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$monthNum-$monthName/$day-$monthNum-$year.md';
  }

  String _commitMessage(DateTime date, bool wasCommitted) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final label = '$day-$month-$year';
    return wasCommitted ? 'Update devlog for $label' : 'Add devlog for $label';
  }

  String _monthName(int month) {
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
    return months[month - 1];
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
                onPressed: isReady && !_isPushing ? _pushToGitHub : null,
                icon: const Icon(Icons.upload),
                label: Text(_isPushing ? 'Pushing...' : 'Push to GitHub'),
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
