import 'package:studyflow/features/task/domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    super.isCompleted,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id, 
      title: task.title, 
      description: task.description, 
      date: task.date,
      isCompleted: task.isCompleted
      );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'],
    );
  }
}