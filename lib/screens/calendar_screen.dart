import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity Log',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Commit Graph', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    // Mock GitHub-style commit graph
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: List.generate(
                        100,
                        (index) => Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getHeatmapColor(index),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GlassCard(
                  child: ListView.separated(
                    itemCount: 10,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.borderSubtle),
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Oct ${24 - index}, 2023'),
                        subtitle: Text('12 entries • 2 AI Summaries • Synced'),
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getHeatmapColor(int index) {
    if (index % 7 == 0) return AppTheme.accentMint;
    if (index % 5 == 0) return AppTheme.accentMint.withOpacity(0.7);
    if (index % 3 == 0) return AppTheme.accentMint.withOpacity(0.4);
    return AppTheme.borderSubtle;
  }
}
