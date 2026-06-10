/// Đại diện cho thông tin sử dụng bộ nhớ lưu trữ tài liệu quét.
/// Entity này độc lập với framework, chỉ chứa dữ liệu thuần túy.
class StorageUsageEntity {
  /// Số bytes đã sử dụng.
  final int usedBytes;

  /// Tổng dung lượng được phép (quota) tính bằng bytes.
  final int quotaBytes;

  /// Phần trăm dung lượng đã sử dụng (0.0 - 100.0).
  final double usedPercentage;

  /// Tổng số tài liệu đã quét.
  final int documentCount;

  /// Constructor yêu cầu các thông tin cơ bản về dung lượng.
  const StorageUsageEntity({
    required this.usedBytes,
    required this.quotaBytes,
    required this.usedPercentage,
    required this.documentCount,
  });

  /// Định dạng dung lượng đã dùng thành chuỗi dễ đọc (KB, MB, GB).
  String get formattedUsed => _formatBytes(usedBytes);

  /// Định dạng tổng dung lượng (quota) thành chuỗi dễ đọc.
  String get formattedQuota => _formatBytes(quotaBytes);

  /// Chuỗi hiển thị tổng hợp (vd: "45 MB / 200 MB").
  String get formattedUsageText => '$formattedUsed / $formattedQuota';

  /// Hàm tiện ích chuyển đổi bytes sang chuỗi dễ đọc.
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
