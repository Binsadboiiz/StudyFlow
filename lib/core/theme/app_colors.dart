import 'package:flutter/material.dart';

/// `AppColors` class contains all the color codes (Color Constants) used in the application.
/// Centralizing colors in one file makes it easy to change and manage the design (Design System).
class AppColors {
  // Brand / Accent (Vibrant electric emerald - premium iOS style)
  /// The primary accent color.
  static const Color accent = Color(0xFF10B981);
  /// The lighter version of the accent color.
  static const Color accentLight = Color(0xFF34D399);

  // ============ LIGHT THEME ============
  /// Primary color for the light theme.
  static const Color primaryLight = Color(0xFF10B981);
  /// Background color for the light theme.
  static const Color backgroundLight = Color(0xFFF3F4F6);
  /// Card background color for the light theme.
  static const Color cardLight = Color(0xFFFFFFFF);
  /// Main text color for the light theme.
  static const Color textLight = Color(0xFF111827);
  /// Subtext color for the light theme.
  static const Color subtextLight = Color(0xFF6B7280);
  /// Button background color for the light theme.
  static const Color btnLight = Color(0xFF10B981);
  /// Input fill color for the light theme.
  static const Color inputFillLight = Color(0xFFF3F4F6);
  /// Divider color for the light theme.
  static const Color dividerLight = Color(0xFFE5E7EB);
  /// Icon color for the light theme.
  static const Color iconLight = Color(0xFF4B5563);

  // ============ DARK THEME ============
  /// Primary color for the dark theme.
  static const Color primaryDark = Color(0xFF10B981);
  /// Background color for the dark theme (deep premium glass black).
  static const Color backgroundDark = Color(0xFF090D10);
  /// Card background color for the dark theme.
  static const Color cardDark = Color(0xFF151D24);
  /// Surface color for the dark theme.
  static const Color surfaceDark = Color(0xFF1F2937);
  /// Main text color for the dark theme.
  static const Color textDark = Color(0xFFF3F4F6);
  /// Subtext color for the dark theme.
  static const Color subtextDark = Color.fromARGB(255, 208, 210, 213);
  /// Input fill color for the dark theme.
  static const Color inputFillDark = Color(0xFF1F2937);
  /// Divider color for the dark theme.
  static const Color dividerDark = Color(0xFF374151);
  /// Icon color for the dark theme.
  static const Color iconDark = Color(0xFFD1D5DB);
}
