import '../../domain/entities/user_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasource/notification_remote_datasource.dart';

/// Implementation of [NotificationRepository] that bridges with the remote data source.
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<UserNotification>> getNotifications() async {
    return await remoteDatasource.getNotifications();
  }

  @override
  Future<void> deleteNotification(String id) async {
    await remoteDatasource.deleteNotification(id);
  }

  @override
  Future<void> clearAllNotifications() async {
    await remoteDatasource.clearAllNotifications();
  }
}
