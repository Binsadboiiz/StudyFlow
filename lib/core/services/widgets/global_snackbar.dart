import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';

/// `GlobalSnackbar` là một widget bọc ngoài cùng (wrapper) của ứng dụng.
/// Nhiệm vụ của nó là lắng nghe các sự kiện thông báo từ `NotificationService`
/// và hiển thị `SnackBar` tương ứng ở bất kỳ đâu trong app mà không cần truyền `BuildContext` xuống sâu.
class GlobalSnackbar extends StatefulWidget {
  final Widget child;

  const GlobalSnackbar({super.key, required this.child});

  @override
  State<GlobalSnackbar> createState() => _GlobalSnackbarState();
}

class _GlobalSnackbarState extends State<GlobalSnackbar> {
  late final Stream<AppNotification> _stream;
  StreamSubscription<AppNotification>? _subscription;

  @override
  void initState() {
    super.initState();

    // Lấy luồng dữ liệu (stream) chứa các thông báo từ NotificationService (Singleton)
    _stream = NotificationService.instance.notificationStream;

    // Đăng ký lắng nghe: Mỗi khi có thông báo mới được push vào stream,
    // hàm _showNotification sẽ được gọi
    _subscription = _stream.listen((notification) {
      _showNotification(notification);
    });
  }

  @override
  void dispose() {
    // Hủy đăng ký lắng nghe khi widget bị hủy để tránh rò rỉ bộ nhớ (memory leak)
    _subscription?.cancel();
    super.dispose();
  }

  /// Hàm hiển thị SnackBar thực tế lên màn hình dựa vào loại thông báo
  void _showNotification(AppNotification notification) {
    Color backgroundColor;

    switch (notification.type) {
      case NotificationType.success:
        backgroundColor = Colors.green;
        break;

      case NotificationType.error:
        backgroundColor = Colors.red;
        break;

      case NotificationType.warning:
        backgroundColor = Colors.orange;
        break;

      case NotificationType.info:
        backgroundColor = Colors.blue;
        break;
    }

    NotificationService.instance.scaffoldMessengerKey.currentState
        ?.showSnackBar(
          SnackBar(
            content: Text(notification.message),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
