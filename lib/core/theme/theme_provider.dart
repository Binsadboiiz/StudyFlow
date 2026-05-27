import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `ThemeProvider` manages the current user interface state of the application (Light/Dark/System).
/// It uses `ChangeNotifier` to notify the widget tree to update the UI whenever the theme changes.
class ThemeProvider extends ChangeNotifier {
  // Default to using the system theme.
  ThemeMode _themeMode = ThemeMode.system;

  /// Retrieves the current [ThemeMode].
  ThemeMode get themeMode => _themeMode;

  /// Creates a [ThemeProvider] instance.
  /// Automatically loads the theme saved in local storage upon initialization.
  ThemeProvider() {
    loadTheme();
  }

  /// Changes the theme mode and saves it to `SharedPreferences` to persist the state for future app launches.
  ///
  /// [mode] is the new [ThemeMode] to be applied.
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();

    // Store the selected theme mode as a string.
    if(mode == ThemeMode.light) {
      await prefs.setString('theme', 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString('theme', 'dark');
    } else {
      await prefs.setString('theme', 'system');
    }

    // Notify listening widgets (e.g., Consumers) to rebuild the UI with the new theme.
    notifyListeners();
  }

  /// Reads the stored theme state from the device's local storage and applies it.
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final theme = prefs.getString('theme');

    // Parse the stored string into the corresponding ThemeMode.
    switch(theme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;

      case 'dark':
        _themeMode = ThemeMode.dark;
        break;

      default:
        _themeMode = ThemeMode.system;
    }

    // Notify listeners after loading the theme to ensure the UI reflects the loaded state.
    notifyListeners();
  }
}