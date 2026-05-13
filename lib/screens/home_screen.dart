import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../navigation/app_tabs.dart';
import '../widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<AppTab> onNavigate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final editorHeight = math.max(320.0, screenHeight * 0.45);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('May 13, 2026', style: textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text('Streak: 7 days', style: textTheme.bodyMedium),
                  ],
                ),
              ),
              _SaveStatusChip(),
            ],
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: 'Rough diary',
            trailing: Text(
              'Autosave on pause',
              style: textTheme.bodySmall,
            ),
            child: SizedBox(
              height: editorHeight,
              child: TextField(
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Start writing your devlog...'
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => onNavigate(AppTab.summary),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Summary'),
              ),
              OutlinedButton.icon(
                onPressed: () => onNavigate(AppTab.preview),
                icon: const Icon(Icons.preview),
                label: const Text('Preview Markdown'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload),
                label: const Text('Push to GitHub'),
              ),
              TextButton.icon(
                onPressed: () => onNavigate(AppTab.entries),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Previous Entries'),
              ),
              TextButton.icon(
                onPressed: () => onNavigate(AppTab.settings),
                icon: const Icon(Icons.tune),
                label: const Text('Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveStatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Saved locally 5 sec ago'),
        ],
      ),
    );
  }
}
