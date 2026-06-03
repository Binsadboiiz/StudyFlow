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

  /// Factory constructor to create a TaskModel from JSON (returned by .NET API)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isCompleted: json['isCompleted'] ?? false,
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
    );
  }

  /// Convert to JSON (used for sending POST/PUT requests to .NET API)
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Usually ignored by API on create
      'userId': userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }
}