import 'package:studyflow/core/services/notification/notification_type.dart';

class AppNotification {
  final String message;
  final NotificationType type;

  AppNotification({
    required this.message,
    required this.type
  });
}