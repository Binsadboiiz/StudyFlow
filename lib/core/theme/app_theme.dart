import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_colors.dart';

/// `AppThemeExtension` is a custom ThemeExtension to store app-specific colors
/// that are not available in the standard `ColorScheme` of Material Design.
/// This allows easy access to colors via `Theme.of(context).extension<AppThemeExtension>()!`.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  /// The fill color for input fields.
  final Color inputFill;
  /// The color for subtext elements.
  final Color subtext;
  /// The default color for icons.
  final Color icon;
  /// The background color for cards.
  final Color cardBackground;
  /// The color for surface elements.
  final Color surface;

  /// Constructor for [AppThemeExtension].
  const AppThemeExtension({
    required this.inputFill,
    required this.subtext,
    required this.icon,
    required this.cardBackground,
    required this.surface,
  });

  @override
  AppThemeExtension copyWith({
    Color? inputFill,
    Color? subtext,
    Color? icon,
    Color? cardBackground,
    Color? surface,
  }) {
    return AppThemeExtension(
      inputFill: inputFill ?? this.inputFill,
      subtext: subtext ?? this.subtext,
      icon: icon ?? this.icon,
      cardBackground: cardBackground ?? this.cardBackground,
      surface: surface ?? this.surface,
    );
  }

  /// `lerp` (linear interpolation) function creates a smooth transition effect 
  /// between colors when changing themes (from Light to Dark and vice versa).
  @override
  AppThemeExtension lerp(covariant ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      subtext: Color.lerp(subtext, other.subtext, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}

/// The `AppTheme` class defines the overall appearance (ThemeData) of the application.
/// It provides 2 main themes: `lightTheme` (Light UI) and `darkTheme` (Dark UI).
class AppTheme {
  /// Default Light UI configuration of the application.
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,

    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.cardLight,
      onSurface: AppColors.textLight,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textLight,
      elevation: 0,
    ),

    cardTheme: const CardThemeData(color: AppColors.cardLight),
    cardColor: AppColors.cardLight,
    dividerColor: AppColors.dividerLight,

    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black45,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFillLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textLight),
    ),

    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(
        inputFill: AppColors.inputFillLight,
        subtext: AppColors.subtextLight,
        icon: AppColors.iconLight,
        cardBackground: AppColors.cardLight,
        surface: AppColors.backgroundLight,
      ),
    ],
  );

  /// Default Dark UI configuration of the application.
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.cardDark,
      onSurface: AppColors.textDark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardDark,
      foregroundColor: AppColors.textDark,
      elevation: 0,
    ),

    cardTheme: const CardThemeData(color: AppColors.cardDark),
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.dividerDark,

    bottomAppBarTheme: const BottomAppBarThemeData(
      color: AppColors.cardDark,
      elevation: 10,
      shadowColor: Colors.black87,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFillDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.subtextDark),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textDark),
    ),

    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(
        inputFill: AppColors.inputFillDark,
        subtext: AppColors.subtextDark,
        icon: AppColors.iconDark,
        cardBackground: AppColors.cardDark,
        surface: AppColors.surfaceDark,
      ),
    ],
  );
}