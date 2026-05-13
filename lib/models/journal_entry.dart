class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.date,
    required this.roughDiary,
    required this.aiSummary,
    required this.finalMarkdown,
    required this.lastSavedAt,
    required this.lastCommittedAt,
    required this.githubCommitSha,
    required this.isCommitted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime date;
  final String roughDiary;
  final String aiSummary;
  final String finalMarkdown;
  final DateTime? lastSavedAt;
  final DateTime? lastCommittedAt;
  final String? githubCommitSha;
  final bool isCommitted;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory JournalEntry.empty(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    return JournalEntry(
      id: _dateKey(normalized),
      date: normalized,
      roughDiary: '',
      aiSummary: '',
      finalMarkdown: '',
      lastSavedAt: now,
      lastCommittedAt: null,
      githubCommitSha: null,
      isCommitted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    String? roughDiary,
    String? aiSummary,
    String? finalMarkdown,
    DateTime? lastSavedAt,
    DateTime? lastCommittedAt,
    String? githubCommitSha,
    bool? isCommitted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      roughDiary: roughDiary ?? this.roughDiary,
      aiSummary: aiSummary ?? this.aiSummary,
      finalMarkdown: finalMarkdown ?? this.finalMarkdown,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      lastCommittedAt: lastCommittedAt ?? this.lastCommittedAt,
      githubCommitSha: githubCommitSha ?? this.githubCommitSha,
      isCommitted: isCommitted ?? this.isCommitted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'roughDiary': roughDiary,
      'aiSummary': aiSummary,
      'finalMarkdown': finalMarkdown,
      'lastSavedAt': lastSavedAt?.toIso8601String(),
      'lastCommittedAt': lastCommittedAt?.toIso8601String(),
      'githubCommitSha': githubCommitSha,
      'isCommitted': isCommitted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      roughDiary: json['roughDiary'] as String? ?? '',
      aiSummary: json['aiSummary'] as String? ?? '',
      finalMarkdown: json['finalMarkdown'] as String? ?? '',
      lastSavedAt: _parseDate(json['lastSavedAt'] as String?),
      lastCommittedAt: _parseDate(json['lastCommittedAt'] as String?),
      githubCommitSha: json['githubCommitSha'] as String?,
      isCommitted: json['isCommitted'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt'] as String?) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt'] as String?) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }

  static String dateKey(DateTime date) => _dateKey(date);
}
