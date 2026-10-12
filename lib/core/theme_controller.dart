import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  static const String _prefsKey = 'app_theme_mode';
  static final ThemeController instance = ThemeController._();

  ThemeController._() : super(ThemeMode.light);

  String get currentId {
    switch (value) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKey) ?? 'light';
    value = _fromId(id);
  }

  Future<void> setModeById(String id) async {
    value = _fromId(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, id);
  }

  Future<void> setThemeById(String id) => setModeById(id);

  ThemeMode _fromId(String id) {
    switch (id) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}
