import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionHeader('Application'),
                    _buildSettingTile(LucideIcons.moon, 'Theme', 'Dark Mode', true),
                    _buildSettingTile(LucideIcons.type, 'Typography', 'JetBrains Mono', true),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('AI Configuration'),
                    _buildSettingTile(LucideIcons.cpu, 'AI Model', 'Gemini Pro', true),
                    _buildSettingTile(LucideIcons.key, 'API Key', '••••••••••••', true),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('Sync & Backup'),
                    _buildSettingTile(LucideIcons.save, 'Auto-save Interval', '30 seconds', true),
                    _buildSettingTile(LucideIcons.github, 'GitHub Sync', 'On App Close', true),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('Data Management'),
                    _buildSettingTile(LucideIcons.download, 'Export Data', 'JSON, Markdown', false),
                    _buildSettingTile(LucideIcons.trash2, 'Clear Local Cache', '1.2 MB', false, isDestructive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, bool showChevron, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (showChevron)
              const Icon(LucideIcons.chevronRight, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
