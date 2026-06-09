import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';

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

  /// Global navigator key used to access the root overlay above modal routes.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Stream controller to broadcast notifications throughout the app.
  final StreamController<AppNotification> _controller =
      StreamController<AppNotification>.broadcast();

  /// The stream of notifications to listen to.
  Stream<AppNotification> get notificationStream => _controller.stream;

  /// Shows a notification.
  /// Adds the notification to the stream so it can be rendered by the global
  /// overlay above modals and forms.
  void show(AppNotification notification) {
    _controller.add(notification);
  }
}
