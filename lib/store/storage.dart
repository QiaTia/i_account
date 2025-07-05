import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:i_account/themes/multiple_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/utils.dart';


const String _themeModeKey = 'theme_mode';
const String _themeNameKey = 'theme_name';
const String _languageKey = 'language';


class Storage {
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
  /// Saves the theme mode as a string in shared preferences.
  static Future<void> saveTheme(MultipleThemeMode mode) async {
    log('Saving theme: ${mode.toString()}');
    await saveString(_themeNameKey, mode.toString());
  }
  /// Retrieves the theme mode from shared preferences.
  static Future<MultipleThemeMode?> getTheme() async {
    final modeString = await getString(_themeNameKey);
    // Default to system mode if not set
    if (modeString == null) {
      return MultipleThemeMode.kDefault;
    }
    return MultipleThemeMode.values.firstWhere(
      (e) => e.toString() == modeString,
      orElse: () => MultipleThemeMode.kDefault
    );
  }
  /// Removes the theme mode from shared preferences.
  static Future<void> removeTheme() async {
    await remove(_themeNameKey);
  }

  /// Saves the theme mode as a string in shared preferences.
  static Future<void> saveThemeMode(ThemeMode mode) async {
    log('Saving theme mode: ${mode.toString()}');
    await saveString(_themeModeKey, mode.toString());
  }
  /// Retrieves the theme mode from shared preferences.
  static Future<ThemeMode> getThemeMode() async {
    final modeString = await getString(_themeModeKey);
    // Default to system mode if not set
    if (modeString == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == modeString,
      orElse: () => ThemeMode.system
    );
  }
  /// Removes the theme mode from shared preferences.
  static Future<void> removeThemeMode() async {
    await remove(_themeModeKey);
  }
  /// Saves the locale as a string in shared preferences.
  static Future<void> saveLocale(Locale? locale) async {
    log('Saving locale: ${locale.toString()}');
    if (locale == null) {
      await remove(_languageKey);
      return;
    }
    final language = '${locale.languageCode}_${locale.scriptCode}';
    await saveString(_languageKey, language);
  }
  /// Retrieves the locale from shared preferences.
  static Future<Locale?> getLocale() async {
    final language = await getString(_languageKey);
    if (language == null) return null;
    try {
      final parts = language.split('_');
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    } catch (e) {
      log('Error parsing locale: $e');
      return null;
    }
  }
}

