class MarkdownBuilder {
  String build({
    required DateTime date,
    required String aiSummary,
    required String roughDiary,
  }) {
    final dateLabel = _formatDate(date);
    final summaryText = aiSummary.trim().isEmpty
        ? 'No AI summary yet.'
        : aiSummary.trim();
    final roughText = roughDiary.trim().isEmpty
        ? 'No rough diary yet.'
        : roughDiary.trim();

    return '''# Daily DevLog — $dateLabel

## AI Summary

$summaryText

---

## Rough Diary

$roughText
''';
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
