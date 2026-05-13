import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class EntriesScreen extends StatelessWidget {
  const EntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      _EntryPreview(
        date: 'May 13, 2026',
        status: 'Not committed',
        summary: 'Built the layout skeleton and theme polish.',
        lastSaved: 'Saved 2 min ago',
      ),
      _EntryPreview(
        date: 'May 12, 2026',
        status: 'Committed',
        summary: 'Refined autosave behavior and markdown template.',
        lastSaved: 'Saved 1 day ago',
      ),
      _EntryPreview(
        date: 'May 11, 2026',
        status: 'Modified after commit',
        summary: 'Backfilled notes from debugging and fixes.',
        lastSaved: 'Saved 2 days ago',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Previous entries',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Column(
          children: entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      title: entry.date,
                      trailing: _StatusPill(label: entry.status),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.summary),
                          const SizedBox(height: 8),
                          Text(
                            entry.lastSaved,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _EntryPreview {
  const _EntryPreview({
    required this.date,
    required this.status,
    required this.summary,
    required this.lastSaved,
  });

  final String date;
  final String status;
  final String summary;
  final String lastSaved;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.4)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
