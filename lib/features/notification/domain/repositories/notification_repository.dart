import '../entities/user_notification.dart';

/// Repository interface for notification actions.
abstract class NotificationRepository {
  Future<List<UserNotification>> getNotifications();
  Future<void> deleteNotification(String id);
  Future<void> clearAllNotifications();
}
