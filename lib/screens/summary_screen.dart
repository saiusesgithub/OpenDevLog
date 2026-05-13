import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final children = [
          Expanded(
            child: SectionCard(
              title: 'Rough diary',
              child: TextField(
                maxLines: 16,
                readOnly: true,
                decoration: const InputDecoration(
                  hintText: 'Today: shaped the structure and flow...'
                ),
              ),
            ),
          ),
          const SizedBox(width: 16, height: 16),
          Expanded(
            child: SectionCard(
              title: 'AI summary (editable)',
              child: TextField(
                maxLines: 16,
                decoration: const InputDecoration(
                  hintText: 'One-line summary, wins, and time allocation...'
                ),
              ),
            ),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI summary',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              )
            else
              Column(
                children: [
                  children[0],
                  const SizedBox(height: 16),
                  children[2],
                ],
              ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Regenerate'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save),
                  label: const Text('Save Summary'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.preview),
                  label: const Text('Preview Markdown'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text('Push to GitHub'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
