class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final DateTime? reminderTime;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.reminderTime,
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

  /// Factory constructor to create a TaskModel from JSON (returned by .NET API)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: _parseUtcDateTime(json['date']),
      startTime: json['startTime'] != null ? _parseUtcDateTime(json['startTime']) : null,
      endTime: json['endTime'] != null ? _parseUtcDateTime(json['endTime']) : null,
      isCompleted: json['isCompleted'] ?? false,
      reminderTime: json['reminderTime'] != null ? _parseUtcDateTime(json['reminderTime']) : null,
    );
  }

  /// Convert to JSON (used for sending POST/PUT requests to .NET API)
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Usually ignored by API on create
      'userId': userId,
      'title': title,
      'description': description,
      'date': date.toUtc().toIso8601String(),
      'startTime': startTime?.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
      'isCompleted': isCompleted,
      'reminderTime': reminderTime?.toUtc().toIso8601String(),
    };
  }
}