import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open DevLog'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('First-time setup', style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Connect GitHub, add your AI key, and choose a repo. No data is sent until you push.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text('Step 1: Connect GitHub', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'GitHub Personal Access Token',
                    hintText: 'ghp_...'
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Default repo name',
                    hintText: 'open-devlog',
                  ),
                ),
                const SizedBox(height: 20),
                Text('Step 2: Add AI API key', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'AI provider',
                    hintText: 'OpenAI / Gemini / Groq',
                  ),
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'API key',
                    hintText: 'sk-...'
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Model name',
                    hintText: 'gpt-4.1-mini',
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.app);
                      },
                      child: const Text('Start journaling'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.app);
                      },
                      child: const Text('Skip for now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
