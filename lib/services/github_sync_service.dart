import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../repositories/local_journal_entry_repository.dart';
import '../repositories/local_settings_repository.dart';
import 'github_api_service.dart';
import 'markdown_builder.dart';

class GitHubSyncException implements Exception {
  GitHubSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GitHubPushResult {
  const GitHubPushResult({
    required this.commitSha,
    required this.created,
    required this.path,
  });

  final String commitSha;
  final bool created;
  final String path;
}

class GitHubSyncService {
  GitHubSyncService({GitHubApiService? api, MarkdownBuilder? builder})
      : _api = api ?? GitHubApiService(),
        _builder = builder ?? MarkdownBuilder();

  final GitHubApiService _api;
  final MarkdownBuilder _builder;

  Future<GitHubPushResult> pushEntryForDate(
    DateTime date, {
    bool requireSummary = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsRepository = LocalSettingsRepository(prefs);
    final entryRepository = LocalJournalEntryRepository(prefs);
    final settings = await settingsRepository.getSettings();

    final token = settings.githubToken?.trim() ?? '';
    if (token.isEmpty) {
      throw GitHubSyncException('Missing GitHub token.');
    }

    final repo = settings.selectedRepo?.trim() ?? '';
    if (repo.isEmpty) {
      throw GitHubSyncException('Missing selected repo.');
    }

    final branch = settings.selectedBranch.isEmpty
        ? 'main'
        : settings.selectedBranch;

    var username = settings.githubUsername?.trim();
    if (username == null || username.isEmpty) {
      final user = await _api.getAuthenticatedUser(token);
      username = user.login;
      await settingsRepository
          .saveSettings(settings.copyWith(githubUsername: username));
    }

    final entry = await entryRepository.getEntryByDate(date) ??
        JournalEntry.empty(date);

    if (requireSummary && entry.aiSummary.trim().isEmpty) {
      throw GitHubSyncException('AI summary required before auto commit.');
    }

    final markdown = _builder.build(
      date: date,
      aiSummary: entry.aiSummary,
      roughDiary: entry.roughDiary,
    );

    final path = _buildPath(date);
    final message = _commitMessage(date, entry.isCommitted);

    final result = await _api.upsertFile(
      token: token,
      owner: username,
      repo: repo,
      path: path,
      content: markdown,
      message: message,
      branch: branch,
    );

    final now = DateTime.now();
    final updated = entry.copyWith(
      finalMarkdown: markdown,
      isCommitted: true,
      lastCommittedAt: now,
      githubCommitSha: result.commitSha,
      updatedAt: now,
    );

    await entryRepository.saveEntry(updated);

    return GitHubPushResult(
      commitSha: result.commitSha,
      created: result.created,
      path: path,
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
}
