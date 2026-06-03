import 'package:flutter/material.dart';
import '../../domain/entities/user_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';

/// ViewModel responsible for notification states and calling repository APIs.
class NotificationViewModel extends ChangeNotifier with SafeChangeNotifier {
  final NotificationRepository repository;

  List<UserNotification> _notifications = [];
  List<UserNotification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NotificationViewModel({required this.repository});

  /// Fetches all notifications from the backend.
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListenersSafely();

    try {
      _notifications = await repository.getNotifications();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  /// Deletes a specific notification from both DB and local list.
  Future<void> deleteNotification(String id) async {
    try {
      await repository.deleteNotification(id);
      _notifications.removeWhere((n) => n.id == id);
      notifyListenersSafely();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Clears all notifications from both DB and local list.
  Future<void> clearAllNotifications() async {
    try {
      await repository.clearAllNotifications();
      _notifications.clear();
      notifyListenersSafely();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }
}
