import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          SectionCard(
            title: 'GitHub',
            child: Column(
              children: const [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Personal Access Token',
                    hintText: 'ghp_...'
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Repository',
                    hintText: 'open-devlog',
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Branch',
                    hintText: 'main',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'AI provider',
            child: Column(
              children: const [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Provider',
                    hintText: 'OpenAI / Gemini / Groq',
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'API key',
                    hintText: 'sk-...'
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Model',
                    hintText: 'gpt-4.1-mini',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Auto commit',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Auto commit enabled'),
                  subtitle: const Text('Only pushes when summary exists.'),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Commit time',
                    hintText: '23:30',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Appearance',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Dark theme'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export local data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
