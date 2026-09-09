import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _locale = 'en';

  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final savedTheme = p.getString('theme_mode');
    final savedLocale = p.getString('locale');
    _themeMode = savedTheme == 'dark'
        ? ThemeMode.dark
        : savedTheme == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    _locale = savedLocale ?? 'en';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('theme_mode',
        mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system');
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('locale', locale);
  }
}
