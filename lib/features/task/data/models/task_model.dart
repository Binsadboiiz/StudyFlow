enum TaskPriority {
  low,
  medium,
  high,
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

class TaskModel {
  final String id;
  final String userId;

  final String title;
  final String description;

  final DateTime date;

  final DateTime? startTime;
  final DateTime? endTime;

  final bool isCompleted;

  final TaskPriority priority;
  final TaskStatus status;

  final String category;

  final bool hasReminder;
  final DateTime? reminderTime;

  final bool isRepeated;
  final String? repeatType;

  final int focusMinutes;

  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = 'General',
    this.hasReminder = false,
    this.reminderTime,
    this.isRepeated = false,
    this.repeatType,
    this.focusMinutes = 25,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TaskModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'])
          : null,
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      category: map['category'] ?? 'General',
      hasReminder: map['hasReminder'] ?? false,
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'])
          : null,
      isRepeated: map['isRepeated'] ?? false,
      repeatType: map['repeatType'],
      focusMinutes: map['focusMinutes'] ?? 25,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority.name,
      'status': status.name,
      'category': category,
      'hasReminder': hasReminder,
      'reminderTime': reminderTime?.toIso8601String(),
      'isRepeated': isRepeated,
      'repeatType': repeatType,
      'focusMinutes': focusMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}