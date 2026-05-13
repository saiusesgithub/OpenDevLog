import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../app_messenger.dart';
import '../models/journal_entry.dart';
import '../repositories/local_journal_entry_repository.dart';
import '../repositories/local_settings_repository.dart';
import 'github_sync_service.dart';

class AutoCommitScheduler {
  AutoCommitScheduler({GitHubSyncService? syncService})
      : _syncService = syncService ?? GitHubSyncService();

  final GitHubSyncService _syncService;
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _lastAttemptAt;
  DateTime? _lastReminderDate;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _tick();
    });
    _tick();
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _tick() async {
    if (_isRunning) {
      return;
    }

    _isRunning = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsRepo = LocalSettingsRepository(prefs);
      final entryRepo = LocalJournalEntryRepository(prefs);
      final settings = await settingsRepo.getSettings();

      if (!settings.autoCommitEnabled) {
        return;
      }

      final now = DateTime.now();
      final target = _targetTime(now, settings.autoCommitTime);
      if (now.isBefore(target)) {
        return;
      }

      if (_lastAttemptAt != null &&
          now.difference(_lastAttemptAt!).inMinutes < 5) {
        return;
      }
      _lastAttemptAt = now;

      final entry = await entryRepo.getEntryByDate(now) ??
          JournalEntry.empty(now);
      if (entry.isCommitted) {
        return;
      }

      final hasSummary = entry.aiSummary.trim().isNotEmpty;
      if (!hasSummary) {
        _showReminderOnce(now, 'Auto-commit pending: add AI summary.');
        return;
      }

      await _syncService.pushEntryForDate(now, requireSummary: true);
      AppMessenger.show('Auto-committed today\'s devlog.');
    } catch (error) {
      AppMessenger.show('Auto-commit failed: $error');
    } finally {
      _isRunning = false;
    }
  }

  void _showReminderOnce(DateTime now, String message) {
    if (_lastReminderDate != null && _isSameDay(_lastReminderDate!, now)) {
      return;
    }
    _lastReminderDate = now;
    AppMessenger.show(message);
  }

  DateTime _targetTime(DateTime now, String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      return DateTime(now.year, now.month, now.day, 23, 30);
    }
    final hour = int.tryParse(parts[0]) ?? 23;
    final minute = int.tryParse(parts[1]) ?? 30;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
