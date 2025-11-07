import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for managing theme mode (light/dark)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier for managing theme mode state and persistence
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _storage = FlutterSecureStorage();
  static const _themeModeKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  /// Load saved theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final savedMode = await _storage.read(key: _themeModeKey);
      if (savedMode != null) {
        switch (savedMode) {
          case 'light':
            state = ThemeMode.light;
            break;
          case 'dark':
            state = ThemeMode.dark;
            break;
          case 'system':
            state = ThemeMode.system;
            break;
        }
      }
    } catch (e) {
      // If loading fails, stick with default dark mode
      state = ThemeMode.dark;
    }
  }

  /// Set theme mode and save to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    
    try {
      await _storage.write(key: _themeModeKey, value: modeString);
    } catch (e) {
      // Silently fail if storage fails
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

