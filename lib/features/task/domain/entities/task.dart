/// Represents a daily goal/task (Entity in Clean Architecture).
/// This is the core data class, independent of any framework or UI.
class Task {
  /// Unique ID of the task (String for Firebase compatibility).
  final String id; 
  
  /// A brief title for the task.
  final String title; 
  
  /// Detailed description for additional context, if needed.
  final String description; 
  
  /// The specific date the task is scheduled for.
  final DateTime date; 
  
  /// The starting time (hour:minute) - nullable as it is not mandatory.
  final DateTime? startTime; 
  
  /// The ending time (hour:minute) - nullable as it is not mandatory.
  final DateTime? endTime; 
  
  /// The completion status (true means completed, false means pending).
  final bool isCompleted; 

  /// Custom reminder time for this task.
  final DateTime? reminderTime;

  /// Constructor requires basic information, defaults to uncompleted (isCompleted = false).
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.reminderTime,
  });

  /// Helper function to create a copy of the current Task with some updated properties.
  /// This is very useful when modifying the state (e.g., updating isCompleted to true)
  /// without changing the original object (Ensures immutability - Immutable state).
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    DateTime? reminderTime,
  }) {
    return Task(
      // Keep the old value if no new value is provided
      id: id ?? this.id, 
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  /// Checks if the task has a specific time slot (used for Scheduling).
  bool get hasTimeSlot => startTime != null;
}
