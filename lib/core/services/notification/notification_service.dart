import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';

class NotificationService {
  NotificationService._private();

  static final NotificationService instance = NotificationService._private();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final StreamController<AppNotification> _controller =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get notificationStream => _controller.stream;

  void show(AppNotification notification) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      _controller.add(notification);
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(notification.message),
        backgroundColor: _backgroundColor(notification.type),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _backgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
    }
  }
}
