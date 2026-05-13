import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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
                'Insights Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    GlassCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Most Productive Time', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text('10:00 AM - 2:00 PM', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.accentViolet)),
                        ],
                      ),
                    ),
                    GlassCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total Words Logged', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text('45,291', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.accentCyan)),
                        ],
                      ),
                    ),
                    GlassCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Common Topics', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ['Flutter', 'Bugs', 'UI/UX'].map((t) => Chip(
                              label: Text(t),
                              backgroundColor: AppTheme.borderSubtle,
                              side: BorderSide.none,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
