import 'package:flutter/material.dart';

/// Lớp `AppColors` chứa toàn bộ các mã màu (Color Constants) được sử dụng trong ứng dụng.
/// Việc tập trung các màu vào một file giúp dễ dàng thay đổi và quản lý thiết kế (Design System).
class AppColors {
  // Brand / Accent (Màu thương hiệu - dùng chung cho cả theme sáng và tối)
  static const Color accent = Color(0xFF2E7D32);
  static const Color accentLight = Color(0xFF4CAF50);

  // ============ LIGHT ============
  static const Color primaryLight = Color.fromARGB(255, 255, 255, 255);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF1A1A1A);
  static const Color subtextLight = Color(0xFF757575);
  static const Color btnLight = Color(0xFF4CAF50);
  static const Color inputFillLight = Color(0xFFF5F5F5);   // grey.shade100
  static const Color dividerLight = Color(0xFFE0E0E0);     // grey.shade300
  static const Color iconLight = Color(0xFF424242);         // grey.shade800

  // ============ DARK ============
  static const Color primaryDark = Color(0xFF4CAF50);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF2A2A2A);
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color subtextDark = Color(0xFF9E9E9E);
  static const Color inputFillDark = Color(0xFF2A2A2A);
  static const Color dividerDark = Color(0xFF3A3A3A);
  static const Color iconDark = Color(0xFFBDBDBD);
}
