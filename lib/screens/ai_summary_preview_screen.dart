import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_border.dart';

class AiSummaryPreviewScreen extends StatelessWidget {
  const AiSummaryPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Summary Preview'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generated Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, color: AppTheme.accentCyan),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GlowingBorder(
                  glowColor: AppTheme.accentCyan,
                  child: GlassCard(
                    child: SingleChildScrollView(
                      child: Text(
                        '''## Daily Developer Log - Oct 24

### 🚀 Key Accomplishments
- Refactored the core authentication flow.
- Resolved memory leak in the WebSocket service.
- Initialized the new Flutter project for Open DevLog.

### 🐛 Blockers & Challenges
- Encountered a weird layout bug on Android devices with the new soft keyboard behavior. Needs investigation tomorrow.

### 💡 Ideas
- Consider using Riverpod for state management in the new project instead of Provider.

### 📝 Raw Notes Summary
The developer spent most of the morning debugging the WebSocket issue. Afternoon was highly productive, focusing on setting up the new Flutter application and planning the UI architecture.''',
                        style: AppTheme.editorStyle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      child: const Text('Regenerate', style: TextStyle(color: AppTheme.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCyan,
                        foregroundColor: AppTheme.background,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save & Sync', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
