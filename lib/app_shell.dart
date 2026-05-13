import 'package:flutter/material.dart';

import 'navigation/app_tabs.dart';
import 'screens/entries_screen.dart';
import 'screens/home_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/summary_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = AppTab.home});

  final AppTab initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _index = AppTab.values.indexOf(widget.initialTab);
    _pages = [
      HomeScreen(onNavigate: _handleTab),
      const EntriesScreen(),
      SummaryScreen(),
      PreviewScreen(),
      const SettingsScreen(),
    ];
  }

  void _handleTab(AppTab tab) {
    final index = AppTab.values.indexOf(tab);
    if (_index == index) {
      return;
    }
    setState(() {
      _index = index;
    });
  }

  void _handleIndex(int index) {
    if (_index == index) {
      return;
    }
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 960;
    final extendedRail = width >= 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open DevLog'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1112), Color(0xFF15191C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      extended: extendedRail,
                      labelType: extendedRail
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      onDestinationSelected: _handleIndex,
                      destinations: [
                        for (final tab in AppTab.values)
                          NavigationRailDestination(
                            icon: Icon(tab.icon),
                            label: Text(tab.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _buildContent()),
                  ],
                )
              : _buildContent(),
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: _index,
              onTap: _handleIndex,
              type: BottomNavigationBarType.fixed,
              items: [
                for (final tab in AppTab.values)
                  BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    label: tab.label,
                  ),
              ],
            ),
    );
  }

  Widget _buildContent() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _pages[_index],
        ),
      ),
    );
  }
}
