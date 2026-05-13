import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import 'settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._prefs);

  static const _settingsKey = 'app_settings_v1';
  final SharedPreferences _prefs;

  @override
  Future<AppSettings> getSettings() async {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return AppSettings.initial();
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return AppSettings.fromJson(decoded);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final payload = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, payload);
  }
}
