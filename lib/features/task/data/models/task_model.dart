/// Represents the priority level of a task.
enum TaskPriority {
  low,
  medium,
  high,
}

/// Represents the current status of a task.
enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

/// Model representing a task in the application.
class TaskModel {
  /// The unique identifier of the task.
  final String id;
  
  /// The ID of the user who owns the task.
  final String userId;

  /// The title of the task.
  final String title;
  
  /// The description of the task.
  final String description;

  /// The date of the task.
  final DateTime date;

  /// The optional starting time of the task.
  final DateTime? startTime;
  
  /// The optional ending time of the task.
  final DateTime? endTime;

  /// Whether the task is completed.
  final bool isCompleted;

  /// The priority level of the task.
  final TaskPriority priority;
  
  /// The current status of the task.
  final TaskStatus status;

  /// The category of the task.
  final String category;

  /// Indicates if the task has a reminder set.
  final bool hasReminder;
  
  /// The time when the reminder should trigger.
  final DateTime? reminderTime;

  /// Indicates if the task repeats.
  final bool isRepeated;
  
  /// The type of repetition (e.g., daily, weekly).
  final String? repeatType;

  /// The estimated minutes of focus required for the task.
  final int focusMinutes;

  /// The timestamp when the task was created.
  final DateTime createdAt;
  
  /// The timestamp when the task was last updated.
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

  /// Creates a [TaskModel] from a Map structure.
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

  /// Converts the [TaskModel] to a Map structure.
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