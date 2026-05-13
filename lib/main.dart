import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(const OpenDevLogApp());
}

class OpenDevLogApp extends StatelessWidget {
  const OpenDevLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open DevLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
    );
  }
}
