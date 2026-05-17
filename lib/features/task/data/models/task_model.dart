import 'package:isar/isar.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';

part 'task_model.g.dart';

@collection
class TaskModel {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;
  late DateTime date;
  DateTime? startTime; // Thời gian bắt đầu (nullable)
  DateTime? endTime; // Thời gian kết thúc (nullable)
  late bool isCompleted;

  TaskModel();

  factory TaskModel.fromEntity(Task task) {
    return TaskModel()
      ..id = (task.id == -1 || task.id > 100000000000) ? Isar.autoIncrement : task.id
      ..title = task.title
      ..description = task.description
      ..date = task.date
      ..startTime = task.startTime
      ..endTime = task.endTime
      ..isCompleted = task.isCompleted;
  }

  Task toEntity() {
    return Task(
      id: id == Isar.autoIncrement ? -1 : id,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isCompleted: isCompleted,
    );
  }
}