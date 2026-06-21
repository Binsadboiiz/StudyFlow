import 'package:isar_community/isar.dart';
import 'package:studyflow/features/focus/data/models/focus_session_model.dart';

part 'focus_session_isar_model.g.dart';

@collection
class FocusSessionIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String userId;
  late DateTime startTime;
  late DateTime endTime;
  late int durationMinutes;
  late String mode;
  late DateTime createdAt;

  // Trạng thái đồng bộ: 'synced', 'pending_insert'
  late String syncStatus;

  late DateTime updatedAt;

  FocusSessionModel toDomain() {
    return FocusSessionModel(
      id: uuid,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      mode: mode,
      createdAt: createdAt,
    );
  }

  static FocusSessionIsarModel fromDomain(FocusSessionModel model, {required String syncStatus, DateTime? updatedAt}) {
    final isarModel = FocusSessionIsarModel();
    isarModel.uuid = model.id;
    isarModel.userId = model.userId;
    isarModel.startTime = model.startTime;
    isarModel.endTime = model.endTime;
    isarModel.durationMinutes = model.durationMinutes;
    isarModel.mode = model.mode;
    isarModel.createdAt = model.createdAt;
    isarModel.syncStatus = syncStatus;
    isarModel.updatedAt = updatedAt ?? DateTime.now();
    return isarModel;
  }
}
