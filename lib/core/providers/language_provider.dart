import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider responsible for managing the application's locale/language state.
/// It persists the user's choice in SharedPreferences and notifies the UI on change.
class LanguageProvider extends ChangeNotifier {
  // Default to English as the standard fallback
  Locale _locale = const Locale('en');

  /// The currently active [Locale].
  Locale get locale => _locale;

  /// Creates a [LanguageProvider] instance and automatically loads the saved locale.
  LanguageProvider() {
    _loadLanguage();
  }

  /// Updates the application's locale and persists the selection in local storage.
  /// Only supports 'en', 'vi', and 'de'.
  Future<void> setLocale(Locale locale) async {
    if (!['en', 'vi', 'de'].contains(locale.languageCode)) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    
    // Notify all listening consumers to rebuild the UI with the new locale.
    notifyListeners();
  }

  /// Reads the saved language code from SharedPreferences.
  /// Falls back to the device's system language if it is one of the supported ones; 
  /// otherwise, defaults to English.
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code');

    if (savedCode != null && ['en', 'vi', 'de'].contains(savedCode)) {
      _locale = Locale(savedCode);
    } else {
      final systemLocale = PlatformDispatcher.instance.locale;
      if (['en', 'vi', 'de'].contains(systemLocale.languageCode)) {
        _locale = Locale(systemLocale.languageCode);
      } else {
        _locale = const Locale('en');
      }
    }
    notifyListeners();
  }
}
