class AiSummaryService {
  Future<String> generate({required String roughDiary}) async {
    final cleaned = roughDiary.trim();
    final lead = _firstSentence(cleaned);
    final summary = lead.isEmpty ? 'Drafted the daily devlog entry.' : lead;

    return '''One-Line Summary:
$summary

Detailed Summary:
- ${_truncate(cleaned, 220)}

Timeline:
- Morning: $summary
- Afternoon: Continued focus areas.
- Evening: Wrapped up and noted next steps.

Time Allocation:
| Category | Time |
| --- | ---: |
| Coding | 2h |
| Planning | 1h |
| Learning | 1h |
| Wasted Time | 0.5h |

Wins:
- Progressed the core devlog flow.

Wasted Time / Distractions:
- None logged.

Improvements For Tomorrow:
- Clarify top priority early.
- Keep the editor focused.

Tags:
- #devlog
- #progress
''';
  }

  String _firstSentence(String text) {
    if (text.isEmpty) {
      return '';
    }
    final normalized = text.replaceAll('\n', ' ');
    final match = RegExp(r'[.!?]').firstMatch(normalized);
    if (match == null) {
      return _truncate(normalized, 140);
    }
    return normalized.substring(0, match.end).trim();
  }

  String _truncate(String text, int maxChars) {
    if (text.isEmpty) {
      return 'No rough diary text yet.';
    }
    if (text.length <= maxChars) {
      return text;
    }
    return '${text.substring(0, maxChars).trim()}...';
  }
}
