import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_border.dart';
import 'ai_summary_preview_screen.dart';

class TodayJournalScreen extends StatelessWidget {
  const TodayJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning, Developer',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oct 24, 2023 · 14 entries today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.accentCyan,
                            ),
                      ),
                    ],
                  ),
                  _buildStatusPill(),
                ],
              ),
              const SizedBox(height: 24),

              // Streak & Stats Row
              Row(
                children: [
                  _buildStatCard(LucideIcons.flame, '12 Day Streak', AppTheme.accentMint),
                  const SizedBox(width: 16),
                  _buildStatCard(LucideIcons.cloudOff, '3 Unsynced', AppTheme.accentViolet),
                ],
              ),
              const SizedBox(height: 24),

              // Main Editor
              Expanded(
                child: GlowingBorder(
                  glowColor: AppTheme.accentCyan,
                  child: GlassCard(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        // Editor Toolbar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.hash, size: 18, color: AppTheme.textSecondary),
                              const SizedBox(width: 16),
                              Icon(LucideIcons.list, size: 18, color: AppTheme.textSecondary),
                              const SizedBox(width: 16),
                              Icon(LucideIcons.code, size: 18, color: AppTheme.textSecondary),
                              const Spacer(),
                              Text('Markdown Supported', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        // Text Area
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              maxLines: null,
                              expands: true,
                              style: AppTheme.editorStyle,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Start typing your rough thoughts, code snippets, or frustrations...\n\nEverything is auto-saved locally.',
                                hintStyle: AppTheme.editorStyle.copyWith(color: AppTheme.textSecondary.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AiSummaryPreviewScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCyan.withOpacity(0.1),
                        foregroundColor: AppTheme.accentCyan,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.accentCyan.withOpacity(0.5)),
                        ),
                      ),
                      icon: const Icon(LucideIcons.sparkles),
                      label: const Text('Generate Summary'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      icon: const Icon(LucideIcons.eye),
                      label: const Text('Preview Markdown'),
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

  Widget _buildStatusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentMint.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentMint.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.accentMint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'All changes safe · Saved locally 2 sec ago',
            style: TextStyle(
              color: AppTheme.accentMint,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
