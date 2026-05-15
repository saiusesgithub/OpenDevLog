import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../navigation/app_routes.dart';
import '../repositories/local_settings_repository.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalSettingsRepository(prefs);
      final settings = await repository.getSettings();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(
        settings.isSetupComplete ? AppRoutes.app : AppRoutes.setup,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.setup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
