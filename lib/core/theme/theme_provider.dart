import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `ThemeProvider` quản lý trạng thái giao diện hiện tại của ứng dụng (Light/Dark/System).
/// Sử dụng `ChangeNotifier` để thông báo cho widget tree cập nhật UI mỗi khi theme thay đổi.
class ThemeProvider extends ChangeNotifier {
  // Mặc định sử dụng theme theo hệ thống máy
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    // Tự động load theme đã lưu trong local storage khi app khởi động
    loadTheme();
  }

  /// Hàm thay đổi chế độ theme và lưu vào `SharedPreferences` để giữ trạng thái cho lần mở app sau.
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();

    if(mode == ThemeMode.light) {
      await prefs.setString('theme', 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString('theme', 'dark');
    } else {
      await prefs.setString('theme', 'system');
    }

    // Báo cho các widget đang lắng nghe (Consumer) biết để build lại UI
    notifyListeners();
  }

  /// Hàm đọc trạng thái theme đã lưu trữ từ thiết bị (local storage).
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final theme = prefs.getString('theme');

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

    notifyListeners();
  }
}