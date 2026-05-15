import 'package:flutter/material.dart';

import 'app_messenger.dart';
import 'app_shell.dart';
import 'navigation/app_routes.dart';
import 'screens/boot_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';

class OpenDevLogApp extends StatelessWidget {
  const OpenDevLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open DevLog',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: AppMessenger.messengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.boot,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.boot:
            return MaterialPageRoute(
              builder: (_) => const BootScreen(),
              settings: settings,
            );
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
              builder: (_) => const BootScreen(),
              settings: settings,
            );
        }
      },
    );
  }
}
