import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';

class GlobalSnackbar extends StatefulWidget {
  final Widget child;

  const GlobalSnackbar({
    super.key,
    required this.child,
  });

  @override
  State<GlobalSnackbar> createState() => _GlobalSnackbarState();
}

class _GlobalSnackbarState extends State<GlobalSnackbar> {
  late final Stream<AppNotification> _stream;
  StreamSubscription<AppNotification>? _subscription;

  @override
  void initState() {
    super.initState();

    _stream = NotificationService.instance.notificationStream;

    _subscription = _stream.listen((notification) {
      _showNotification(notification);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showNotification(AppNotification notification) {
    Color backgroundColor;

    switch(notification.type) {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        notification.message
        ),
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