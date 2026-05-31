import 'package:flutter/material.dart';

/// `AppColors` class contains all the color codes (Color Constants) used in the application.
/// Centralizing colors in one file makes it easy to change and manage the design (Design System).
class AppColors {
  // Brand / Accent (Brand color - shared between light and dark themes)
  /// The primary accent color.
  static const Color accent = Color(0xFF2E7D32);
  /// The lighter version of the accent color.
  static const Color accentLight = Color(0xFF4CAF50);

  // ============ LIGHT THEME ============
  /// Primary color for the light theme.
  static const Color primaryLight = Color.fromARGB(255, 255, 255, 255);
  /// Background color for the light theme.
  static const Color backgroundLight = Color(0xFFF5F7FA);
  /// Card background color for the light theme.
  static const Color cardLight = Color(0xFFFFFFFF);
  /// Main text color for the light theme.
  static const Color textLight = Color(0xFF1A1A1A);
  /// Subtext color for the light theme.
  static const Color subtextLight = Color(0xFF757575);
  /// Button background color for the light theme.
  static const Color btnLight = Color(0xFF4CAF50);
  /// Input fill color for the light theme (grey.shade100).
  static const Color inputFillLight = Color(0xFFF5F5F5);
  /// Divider color for the light theme (grey.shade300).
  static const Color dividerLight = Color(0xFFE0E0E0);
  /// Icon color for the light theme (grey.shade800).
  static const Color iconLight = Color(0xFF424242);

  // ============ DARK THEME ============
  /// Primary color for the dark theme.
  static const Color primaryDark = Color(0xFF4CAF50);
  /// Background color for the dark theme.
  static const Color backgroundDark = Color(0xFF0F1A13);
  /// Card background color for the dark theme.
  static const Color cardDark = Color(0xFF162419);
  /// Surface color for the dark theme.
  static const Color surfaceDark = Color(0xFF2A2A2A);
  /// Main text color for the dark theme.
  static const Color textDark = Color(0xFFE0E0E0);
  /// Subtext color for the dark theme.
  static const Color subtextDark = Color(0xFF9E9E9E);
  /// Input fill color for the dark theme.
  static const Color inputFillDark = Color(0xFF2A2A2A);
  /// Divider color for the dark theme.
  static const Color dividerDark = Color(0xFF3A3A3A);
  /// Icon color for the dark theme.
  static const Color iconDark = Color(0xFFBDBDBD);
}
