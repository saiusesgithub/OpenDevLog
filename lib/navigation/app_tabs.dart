import 'package:flutter/material.dart';

enum AppTab { home, entries, summary, preview, settings }

extension AppTabX on AppTab {
  String get label {
    switch (this) {
      case AppTab.home:
        return 'Home';
      case AppTab.entries:
        return 'Entries';
      case AppTab.summary:
        return 'AI Summary';
      case AppTab.preview:
        return 'Preview';
      case AppTab.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.home:
        return Icons.edit_note;
      case AppTab.entries:
        return Icons.calendar_month;
      case AppTab.summary:
        return Icons.auto_awesome;
      case AppTab.preview:
        return Icons.preview;
      case AppTab.settings:
        return Icons.tune;
    }
  }
}
