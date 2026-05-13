import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import 'journal_entry_repository.dart';

class LocalJournalEntryRepository implements JournalEntryRepository {
  LocalJournalEntryRepository(this._prefs);

  static const _entriesKey = 'journal_entries_v1';
  final SharedPreferences _prefs;

  @override
  Future<JournalEntry?> getEntryByDate(DateTime date) async {
    final entries = await _loadEntries();
    final targetKey = JournalEntry.dateKey(date);

    for (final entry in entries) {
      if (JournalEntry.dateKey(entry.date) == targetKey) {
        return entry;
      }
    }

    return null;
  }

  @override
  Future<void> saveEntry(JournalEntry entry) async {
    final entries = await _loadEntries();
    final targetKey = JournalEntry.dateKey(entry.date);
    final index = entries.indexWhere(
      (existing) => JournalEntry.dateKey(existing.date) == targetKey,
    );
    final now = DateTime.now();

    if (index == -1) {
      entries.add(
        entry.copyWith(
          id: entry.id.isEmpty ? targetKey : entry.id,
          createdAt: entry.createdAt,
          updatedAt: now,
        ),
      );
    } else {
      final existing = entries[index];
      entries[index] = entry.copyWith(
        id: existing.id,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    }

    await _saveEntries(entries);
  }

  @override
  Future<void> updateRoughDiary(DateTime date, String text) async {
    await _updateEntry(date, (entry, now) {
      return entry.copyWith(
        roughDiary: text,
        lastSavedAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<void> updateAiSummary(DateTime date, String text) async {
    await _updateEntry(date, (entry, now) {
      return entry.copyWith(
        aiSummary: text,
        updatedAt: now,
      );
    });
  }

  @override
  Future<void> updateFinalMarkdown(DateTime date, String markdown) async {
    await _updateEntry(date, (entry, now) {
      return entry.copyWith(
        finalMarkdown: markdown,
        updatedAt: now,
      );
    });
  }

  @override
  Future<List<JournalEntry>> listEntries() async {
    final entries = await _loadEntries();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> _updateEntry(
    DateTime date,
    JournalEntry Function(JournalEntry entry, DateTime now) update,
  ) async {
    final entries = await _loadEntries();
    final targetKey = JournalEntry.dateKey(date);
    final index = entries.indexWhere(
      (existing) => JournalEntry.dateKey(existing.date) == targetKey,
    );
    final now = DateTime.now();

    if (index == -1) {
      final entry = JournalEntry.empty(date);
      entries.add(update(entry, now));
    } else {
      final entry = entries[index];
      entries[index] = update(entry, now);
    }

    await _saveEntries(entries);
  }

  Future<List<JournalEntry>> _loadEntries() async {
    final raw = _prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => JournalEntry.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveEntries(List<JournalEntry> entries) async {
    final payload = jsonEncode(
      entries.map((entry) => entry.toJson()).toList(),
    );
    await _prefs.setString(_entriesKey, payload);
  }
}
