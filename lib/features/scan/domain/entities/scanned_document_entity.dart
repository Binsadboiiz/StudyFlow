/// Đại diện cho một tài liệu đã quét (Entity trong Clean Architecture).
/// Đây là lớp dữ liệu cốt lõi, độc lập với mọi framework hay UI.
class ScannedDocumentEntity {
  /// ID duy nhất của tài liệu.
  final String id;

  /// Tiêu đề tài liệu do người dùng đặt.
  final String title;

  /// Nội dung văn bản được trích xuất từ OCR.
  final String extractedText;

  /// URL ảnh gốc đã upload lên Firebase Storage (nullable nếu chưa upload).
  final String? originalImageUrl;

  /// Đường dẫn lưu trữ trên Firebase Storage (nullable).
  final String? storagePath;

  /// Kích thước ảnh gốc tính bằng bytes.
  final int imageSizeBytes;

  /// Kích thước văn bản trích xuất tính bằng bytes.
  final int textSizeBytes;

  /// Ngôn ngữ được phát hiện từ OCR (vd: 'vi', 'en').
  final String detectedLanguage;

  /// Độ tin cậy của kết quả OCR (0.0 - 1.0).
  final double confidenceScore;

  /// Thời gian tạo tài liệu.
  final DateTime createdAt;

  /// Thời gian cập nhật tài liệu lần cuối.
  final DateTime updatedAt;

  /// Đánh dấu tài liệu đã bị xóa tạm thời (nằm trong thùng rác).
  final bool isDeleted;

  /// Thời gian tài liệu bị xóa tạm thời (null nếu chưa xóa).
  final DateTime? deletedAt;

  /// Constructor yêu cầu các thông tin cơ bản của tài liệu.
  const ScannedDocumentEntity({
    required this.id,
    required this.title,
    required this.extractedText,
    this.originalImageUrl,
    this.storagePath,
    this.imageSizeBytes = 0,
    this.textSizeBytes = 0,
    this.detectedLanguage = 'vi',
    this.confidenceScore = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  /// Tạo bản sao của tài liệu hiện tại với một số thuộc tính được cập nhật.
  /// Đảm bảo tính bất biến (Immutability) của entity.
  ScannedDocumentEntity copyWith({
    String? id,
    String? title,
    String? extractedText,
    String? originalImageUrl,
    String? storagePath,
    int? imageSizeBytes,
    int? textSizeBytes,
    String? detectedLanguage,
    double? confidenceScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return ScannedDocumentEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      extractedText: extractedText ?? this.extractedText,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      storagePath: storagePath ?? this.storagePath,
      imageSizeBytes: imageSizeBytes ?? this.imageSizeBytes,
      textSizeBytes: textSizeBytes ?? this.textSizeBytes,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Tổng kích thước lưu trữ (ảnh + văn bản) tính bằng bytes.
  int get totalSizeBytes => imageSizeBytes + textSizeBytes;

  /// Định dạng kích thước file thành chuỗi dễ đọc (KB, MB).
  String get formattedSize {
    final totalBytes = totalSizeBytes;
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
