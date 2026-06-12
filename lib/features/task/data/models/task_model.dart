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
    if (!dateStr.endsWith('Z') && !dateStr.contains('+') && !dateStr.contains('-')) {
      return DateTime.parse('${dateStr}Z').toLocal();
    }
    return DateTime.parse(dateStr).toLocal();
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