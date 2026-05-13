import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class VersionHistoryScreen extends StatelessWidget {
  const VersionHistoryScreen({super.key});

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
                'Version History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Locally saved versions of today\'s log',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        if (index < 4)
                          Positioned(
                            left: 24,
                            top: 48,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: index == 0 ? AppTheme.accentCyan : AppTheme.borderSubtle, width: 2),
                                ),
                                child: Icon(
                                  LucideIcons.save,
                                  color: index == 0 ? AppTheme.accentCyan : AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.borderSubtle),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        index == 0 ? 'Latest Auto-save' : 'Manual Save',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: index == 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Today at ${14 - index}:${index * 12} PM',
                                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                      ),
                                      if (index != 0) ...[
                                        const SizedBox(height: 12),
                                        OutlinedButton(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            side: const BorderSide(color: AppTheme.borderSubtle),
                                          ),
                                          child: const Text('Restore Version', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
