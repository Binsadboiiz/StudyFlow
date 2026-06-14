import '../../domain/entities/user_notification.dart';

/// Data model for user notifications.
class NotificationModel extends UserNotification {
  NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.isRead,
    required super.type,
  });

  static DateTime _parseUtcDateTime(String dateStr) {
    // If it's a date-only string (no time), parse it directly as local
    if (!dateStr.contains('T') && !dateStr.contains(' ') && !dateStr.contains(':')) {
      return DateTime.parse(dateStr);
    }

    if (dateStr.endsWith('Z')) {
      return DateTime.parse(dateStr).toLocal();
    }
    
    // Check if there is a timezone offset after the time part starts
    // Timezone offsets look like +HH:MM or -HH:MM
    final timeStartIndex = dateStr.contains('T') ? dateStr.indexOf('T') : dateStr.indexOf(' ');
    if (timeStartIndex != -1 && timeStartIndex < dateStr.length) {
      final timeAndOffsetPart = dateStr.substring(timeStartIndex);
      if (timeAndOffsetPart.contains('+') || timeAndOffsetPart.contains('-')) {
        return DateTime.parse(dateStr).toLocal();
      }
    }
    
    // Otherwise, assume it is in UTC (since our DB stores it as UTC without offset)
    return DateTime.parse('${dateStr}Z').toLocal();
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: _parseUtcDateTime(json['createdAt']),
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }
}
