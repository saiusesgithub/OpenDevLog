import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final cardHeight = isWide ? 320.0 : 260.0;

        final roughDiaryCard = SizedBox(
          height: cardHeight,
          child: SectionCard(
            title: 'Rough diary',
            child: TextField(
              expands: true,
              maxLines: null,
              minLines: null,
              readOnly: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Today: shaped the structure and flow...'
              ),
            ),
          ),
        );

        final summaryCard = SizedBox(
          height: cardHeight,
          child: SectionCard(
            title: 'AI summary (editable)',
            child: TextField(
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'One-line summary, wins, and time allocation...'
              ),
            ),
          ),
        );

        final content = isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: roughDiaryCard),
                  const SizedBox(width: 16),
                  Expanded(child: summaryCard),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  roughDiaryCard,
                  const SizedBox(height: 16),
                  summaryCard,
                ],
              );

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI summary',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              content,
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
          ),
        );
      },
    );
  }
}
