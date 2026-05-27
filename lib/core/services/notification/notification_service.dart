import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';

/// A singleton service to manage application-wide notifications.
/// It uses a broadcast stream to push notifications that can be picked up by a global listener.
class NotificationService {
  /// Private constructor for the singleton pattern.
  NotificationService._private();

  /// The single instance of [NotificationService].
  static final NotificationService instance = NotificationService._private();

  /// Global key used to access the ScaffoldMessengerState directly if needed.
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Stream controller to broadcast notifications throughout the app.
  final StreamController<AppNotification> _controller =
      StreamController<AppNotification>.broadcast();

  /// The stream of notifications to listen to.
  Stream<AppNotification> get notificationStream => _controller.stream;

  /// Shows a notification.
  /// If a [ScaffoldMessenger] is currently attached, it shows a SnackBar immediately.
  /// Otherwise, it adds the notification to the stream to be handled globally.
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

  /// Returns the corresponding background color for a given [NotificationType].
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
