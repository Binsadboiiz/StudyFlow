import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';

/// `GlobalSnackbar` is an outermost wrapper widget of the application.
/// Its responsibility is to listen to notification events from `NotificationService`
/// and display the corresponding `SnackBar` anywhere in the app without passing down `BuildContext`.
class GlobalSnackbar extends StatefulWidget {
  /// The child widget to be wrapped by the global snackbar.
  final Widget child;

  /// Constructor for [GlobalSnackbar].
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

    // Get the data stream containing notifications from NotificationService (Singleton).
    _stream = NotificationService.instance.notificationStream;

    // Register listener: Every time a new notification is pushed into the stream,
    // the _showNotification function will be called.
    _subscription = _stream.listen((notification) {
      _showNotification(notification);
    });
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed to prevent memory leaks.
    _subscription?.cancel();
    super.dispose();
  }

  /// Function to actually display the SnackBar on the screen based on the notification type.
  void _showNotification(AppNotification notification) {
    Color backgroundColor;

    // Determine the background color based on the notification type.
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

    // Display the SnackBar using the globally accessible scaffoldMessengerKey.
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
