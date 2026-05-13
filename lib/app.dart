import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'navigation/app_routes.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';

class OpenDevLogApp extends StatelessWidget {
  const OpenDevLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open DevLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.setup,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.setup:
            return MaterialPageRoute(
              builder: (_) => const SetupScreen(),
              settings: settings,
            );
          case AppRoutes.app:
            return MaterialPageRoute(
              builder: (_) => const AppShell(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SetupScreen(),
              settings: settings,
            );
        }
      },
    );
  }
}
