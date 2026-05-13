import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'today_journal_screen.dart';
import 'calendar_screen.dart';
import 'insights_screen.dart';
import 'github_sync_screen.dart';
import 'version_history_screen.dart';
import 'settings_screen.dart';
import '../core/theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodayJournalScreen(),
    const CalendarScreen(),
    const InsightsScreen(),
    const GithubSyncScreen(),
    const VersionHistoryScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(icon: Icon(LucideIcons.penTool), label: 'Journal'),
    NavigationDestination(icon: Icon(LucideIcons.calendar), label: 'Calendar'),
    NavigationDestination(icon: Icon(LucideIcons.barChart2), label: 'Insights'),
    NavigationDestination(icon: Icon(LucideIcons.github), label: 'Sync'),
    NavigationDestination(icon: Icon(LucideIcons.history), label: 'History'),
    NavigationDestination(icon: Icon(LucideIcons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              backgroundColor: AppTheme.cardColor,
              indicatorColor: AppTheme.accentCyan.withOpacity(0.2),
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: _destinations.map((dest) => NavigationRailDestination(
                icon: dest.icon,
                label: Text(dest.label),
              )).toList(),
            ),
          if (isDesktop)
            const VerticalDivider(thickness: 1, width: 1, color: AppTheme.borderSubtle),
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              backgroundColor: AppTheme.cardColor,
              indicatorColor: AppTheme.accentCyan.withOpacity(0.2),
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: _destinations,
            ),
    );
  }
}
