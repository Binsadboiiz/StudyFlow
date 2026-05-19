import 'dart:async';

import 'package:studyflow/core/services/notification/app_notification.dart';

class NotificationService {
  NotificationService._private();

  static final NotificationService instance = 
    NotificationService._private();

  final StreamController<AppNotification> _controller = 
    StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get notificationStream =>
    _controller.stream;

  void show(AppNotification notification) {
    _controller.add(notification);
  }
}