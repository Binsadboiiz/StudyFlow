import 'package:studyflow/core/services/notification/notification_type.dart';

/// Represents a notification model containing the message and its type.
class AppNotification {
  /// The text message to be displayed.
  final String message;
  
  /// The type of the notification (e.g., success, error) which determines its styling.
  final NotificationType type;

  /// Constructor for creating an [AppNotification].
  AppNotification({
    required this.message,
    required this.type
  });
}