import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const previewMarkdown = '''# Daily DevLog — May 13, 2026

## AI Summary

- One-line summary
- Wins and time allocation
- Improvements for tomorrow

---

## Rough Diary

Finished the milestone layout, added theme polish, and mapped the flow.''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Final markdown preview',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Preview',
          child: SelectableText(
            previewMarkdown,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload),
              label: const Text('Push to GitHub'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Edit Summary'),
            ),
          ],
        ),
      ],
    );
  }
}
