import 'package:isar_community/isar.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';

part 'task_isar_model.g.dart';

@collection
class TaskIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;
  late String description;
  late DateTime date;
  DateTime? startTime;
  DateTime? endTime;
  late bool isCompleted;
  DateTime? reminderTime;

  // Trạng thái đồng bộ: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  late String syncStatus;

  // Thời gian cập nhật gần nhất
  late DateTime updatedAt;

  /// Chuyển đổi sang thực thể Domain Task
  Task toDomain() {
    return Task(
      id: uuid,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isCompleted: isCompleted,
      reminderTime: reminderTime,
    );
  }

  /// Khởi tạo Isar model từ thực thể Domain Task
  static TaskIsarModel fromDomain(Task task, {required String syncStatus, DateTime? updatedAt}) {
    final model = TaskIsarModel();
    model.uuid = task.id;
    model.title = task.title;
    model.description = task.description;
    model.date = task.date;
    model.startTime = task.startTime;
    model.endTime = task.endTime;
    model.isCompleted = task.isCompleted;
    model.reminderTime = task.reminderTime;
    model.syncStatus = syncStatus;
    model.updatedAt = updatedAt ?? DateTime.now();
    return model;
  }
}
