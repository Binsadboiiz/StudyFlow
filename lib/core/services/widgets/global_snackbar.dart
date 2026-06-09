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
  static const double _headerOffset = 88;
  static const Duration _displayDuration = Duration(seconds: 3);

  late final Stream<AppNotification> _stream;
  StreamSubscription<AppNotification>? _subscription;
  OverlayEntry? _notificationEntry;
  Timer? _dismissTimer;

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
    _dismissTimer?.cancel();
    _removeCurrentNotification();
    super.dispose();
  }

  /// Function to display the notification on the root overlay, above modals.
  void _showNotification(AppNotification notification) {
    final overlay =
        NotificationService.instance.navigatorKey.currentState?.overlay ??
        Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _dismissTimer?.cancel();
    _removeCurrentNotification();

    _notificationEntry = OverlayEntry(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final top = mediaQuery.padding.top + _headerOffset;

        return Positioned(
          top: top,
          left: 16,
          right: 16,
          child: SafeArea(
            top: false,
            bottom: false,
            child: _NotificationBanner(notification: notification),
          ),
        );
      },
    );

    overlay.insert(_notificationEntry!);
    _dismissTimer = Timer(_displayDuration, _removeCurrentNotification);
  }

  void _removeCurrentNotification() {
    _notificationEntry?.remove();
    _notificationEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _NotificationBanner extends StatelessWidget {
  final AppNotification notification;

  const _NotificationBanner({required this.notification});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _backgroundColor(notification.type);

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            notification.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
