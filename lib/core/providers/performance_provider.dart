import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider responsible for managing application rendering and execution performance modes.
/// It defaults to `true` (Low Performance Mode enabled) on the first app launch to support low-end devices out of the box.
class PerformanceProvider extends ChangeNotifier {
  bool _isLowPerformance = true;

  /// Whether the app is currently running in low performance mode (no blurs, static backgrounds).
  bool get isLowPerformance => _isLowPerformance;

  PerformanceProvider() {
    _loadSettings();
  }

  /// Sets the low performance mode value and persists it in SharedPreferences.
  Future<void> setLowPerformanceMode(bool value) async {
    _isLowPerformance = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('low_performance_mode', value);
    notifyListeners();
  }

  /// Loads the setting from SharedPreferences. Defaults to `true` if null (first run).
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isLowPerformance = prefs.getBool('low_performance_mode') ?? true;
    notifyListeners();
  }
}
