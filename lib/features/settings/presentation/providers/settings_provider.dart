import 'package:caffenio/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider de configuración de apariencia y preferencias.
///
/// Persiste el modo de tema (claro / oscuro / sistema) en SharedPreferences.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences {
    _loadSettings();
  }

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;

  // ── Getters ───────────────────────────────────────────────────────────────

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Label legible del modo actual.
  String get themeModeLabel => switch (_themeMode) {
        ThemeMode.dark => 'Oscuro',
        ThemeMode.light => 'Claro',
        ThemeMode.system => 'Sistema',
      };

  // ── Métodos ───────────────────────────────────────────────────────────────

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.prefKeyTheme, value);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> resetToSystem() async {
    await setThemeMode(ThemeMode.system);
  }

  // ── Privado ───────────────────────────────────────────────────────────────

  void _loadSettings() {
    final saved = _prefs.getString(AppConstants.prefKeyTheme);
    _themeMode = switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }
}
