import '../models/journal_entry.dart';

abstract class JournalEntryRepository {
  Future<JournalEntry?> getEntryByDate(DateTime date);
  Future<void> saveEntry(JournalEntry entry);
  Future<void> updateRoughDiary(DateTime date, String text);
  Future<void> updateAiSummary(DateTime date, String text);
  Future<void> updateFinalMarkdown(DateTime date, String markdown);
  Future<List<JournalEntry>> listEntries();
}
