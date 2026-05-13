import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../repositories/journal_entry_repository.dart';
import '../repositories/local_journal_entry_repository.dart';

enum SaveState { idle, saving, saved, unsaved, failed }

class JournalEditorController extends ChangeNotifier {
  JournalEditorController({
    required this.repository,
    required this.date,
  });

  final JournalEntryRepository repository;
  final DateTime date;

  JournalEntry? _entry;
  String _draftText = '';
  String _lastSavedText = '';
  SaveState _saveState = SaveState.idle;
  DateTime? _lastSavedAt;
  bool _isSaving = false;
  Timer? _debounceTimer;
  Timer? _periodicTimer;
  Timer? _statusTimer;

  static Future<JournalEditorController> create(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalJournalEntryRepository(prefs);
    final controller = JournalEditorController(
      repository: repository,
      date: date,
    );
    await controller.load();
    controller._startTimers();
    return controller;
  }

  String get draftText => _draftText;
  SaveState get saveState => _saveState;
  DateTime? get lastSavedAt => _lastSavedAt;

  Future<void> load() async {
    final entry = await repository.getEntryByDate(date) ??
        JournalEntry.empty(date);
    _entry = entry;
    _draftText = entry.roughDiary;
    _lastSavedText = entry.roughDiary;
    _lastSavedAt = entry.lastSavedAt;
    _saveState = SaveState.saved;
    notifyListeners();
  }

  void updateText(String value) {
    _draftText = value;
    if (_draftText == _lastSavedText) {
      return;
    }
    _saveState = SaveState.unsaved;
    notifyListeners();
    _scheduleDebounce();
  }

  Future<void> saveIfNeeded() async {
    if (_isSaving) {
      return;
    }
    if (_draftText == _lastSavedText) {
      return;
    }

    _isSaving = true;
    _saveState = SaveState.saving;
    notifyListeners();

    try {
      await repository.updateRoughDiary(date, _draftText);
      _lastSavedText = _draftText;
      _lastSavedAt = DateTime.now();
      _saveState = SaveState.saved;
    } catch (_) {
      _saveState = SaveState.failed;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> forceSave() async {
    await saveIfNeeded();
  }

  String get statusLabel {
    switch (_saveState) {
      case SaveState.saving:
        return 'Saving...';
      case SaveState.unsaved:
        return 'Unsaved changes';
      case SaveState.failed:
        return 'Save failed';
      case SaveState.saved:
        if (_lastSavedAt == null) {
          return 'Saved locally';
        }
        return 'Saved locally ${_formatElapsed(_lastSavedAt!)}';
      case SaveState.idle:
        return 'Ready to write';
    }
  }

  void _scheduleDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      saveIfNeeded();
    });
  }

  void _startTimers() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_draftText != _lastSavedText) {
        saveIfNeeded();
      }
    });

    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_saveState == SaveState.saved && _lastSavedAt != null) {
        notifyListeners();
      }
    });
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
    return '${diff.inHours} hr ago';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _periodicTimer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }
}
