import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studyflow/features/task/data/models/task_isar_model.dart';

/// Service quản lý vòng đời và kết nối tới Isar local database.
class IsarService {
  static Isar? _isar;

  /// Getter để truy cập instance Isar đã khởi tạo
  static Isar get isar {
    if (_isar == null) {
      throw StateError('IsarService chưa được khởi tạo. Hãy gọi init() trước.');
    }
    return _isar!;
  }

  /// Khởi tạo Isar database
  static Future<void> init() async {
    if (_isar != null) return;

    // Lấy đường dẫn lưu trữ trên thiết bị
    final dir = await getApplicationDocumentsDirectory();

    // Mở cơ sở dữ liệu Isar với các Schema đã định nghĩa
    _isar = await Isar.open(
      [TaskIsarModelSchema],
      directory: dir.path,
    );
  }
}
