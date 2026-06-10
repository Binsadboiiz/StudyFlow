import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/scan/presentation/viewmodels/scan_viewmodel.dart';
import 'package:studyflow/features/scan/presentation/widgets/ocr_text_editor.dart';
import 'package:studyflow/l10n/app_localizations.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';

/// Màn hình xem lại và chỉnh sửa kết quả OCR trước khi lưu.
/// Hiển thị: ảnh preview, text OCR (chỉnh sửa được), tiêu đề, độ tin cậy.
class OcrReviewScreen extends StatefulWidget {
  /// Nội dung văn bản được trích xuất từ OCR.
  final String extractedText;

  /// Điểm tin cậy của kết quả OCR (0.0 - 1.0).
  final double confidenceScore;

  /// Ngôn ngữ được phát hiện.
  final String detectedLanguage;

  /// Kích thước ảnh nén (bytes).
  final int imageSizeBytes;

  /// Dữ liệu ảnh nén (bytes) để upload.
  final Uint8List imageBytes;

  const OcrReviewScreen({
    super.key,
    required this.extractedText,
    required this.confidenceScore,
    required this.detectedLanguage,
    required this.imageSizeBytes,
    required this.imageBytes,
  });

  @override
  State<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends State<OcrReviewScreen> {
  /// Controller cho tiêu đề tài liệu.
  late final TextEditingController _titleController;

  /// Controller cho nội dung OCR.
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _textController = TextEditingController(text: widget.extractedText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final scanVm = context.watch<ScanViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanReviewTitle),
        centerTitle: true,
        actions: [
          // Nút lưu
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: scanVm.isSaving ? null : _saveDocument,
              icon: scanVm.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(scanVm.isSaving ? AppLocalizations.of(context)!.scanSaving : AppLocalizations.of(context)!.scanSave),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Preview ảnh tài liệu
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  widget.imageBytes,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Thông tin OCR: độ tin cậy + ngôn ngữ + kích thước
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.verified_rounded,
                    label: AppLocalizations.of(context)!.scanConfidence,
                    value: '${(widget.confidenceScore * 100).toStringAsFixed(0)}%',
                    color: _getConfidenceColor(widget.confidenceScore),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoChip(
                    icon: Icons.language_rounded,
                    label: AppLocalizations.of(context)!.scanLanguage,
                    value: _getLanguageName(widget.detectedLanguage),
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoChip(
                    icon: Icons.photo_size_select_large_rounded,
                    label: AppLocalizations.of(context)!.scanSize,
                    value: _formatBytes(widget.imageSizeBytes),
                    color: ext.subtext,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Ô nhập tiêu đề tài liệu
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.scanTitleHint,
                  hintStyle: TextStyle(
                    color: ext.subtext.withValues(alpha: 0.5),
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: const Icon(
                    Icons.title_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Editor nội dung OCR (chỉnh sửa được)
            OcrTextEditor(
              controller: _textController,
              onChanged: (_) {},
            ),
            const SizedBox(height: 24),

            // 5. Nút lưu lớn ở cuối
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: scanVm.isSaving ? null : _saveDocument,
                icon: scanVm.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(
                  scanVm.isSaving ? AppLocalizations.of(context)!.scanSavingUpload : AppLocalizations.of(context)!.scanSaveButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Chip hiển thị thông tin OCR (độ tin cậy, ngôn ngữ, kích thước).
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).extension<AppThemeExtension>()!.subtext,
            ),
          ),
        ],
      ),
    );
  }

  /// Lưu tài liệu: upload ảnh → gọi API.
  Future<void> _saveDocument() async {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();

    // Validate dữ liệu
    if (title.isEmpty) {
      NotificationService.instance.show(
        AppNotification(
          message: AppLocalizations.of(context)!.scanEmptyTitleError,
          type: NotificationType.warning,
        ),
      );
      return;
    }

    if (text.isEmpty) {
      NotificationService.instance.show(
        AppNotification(
          message: AppLocalizations.of(context)!.scanEmptyTextError,
          type: NotificationType.warning,
        ),
      );
      return;
    }

    final scanVm = context.read<ScanViewModel>();
    final result = await scanVm.saveDocument(
      title: title,
      extractedText: text,
      imageBytes: widget.imageBytes,
      imageSizeBytes: widget.imageSizeBytes,
      detectedLanguage: widget.detectedLanguage,
      confidenceScore: widget.confidenceScore,
    );

    if (!mounted) return;

    if (result != null) {
      NotificationService.instance.show(
        AppNotification(
          message: AppLocalizations.of(context)!.scanSaveSuccess,
          type: NotificationType.success,
        ),
      );
      // Quay về màn hình danh sách
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      NotificationService.instance.show(
        AppNotification(
          message: scanVm.errorMessage ?? AppLocalizations.of(context)!.scanSaveFailed,
          type: NotificationType.error,
        ),
      );
    }
  }

  /// Lấy màu dựa trên độ tin cậy.
  Color _getConfidenceColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }

  /// Lấy tên ngôn ngữ đầy đủ.
  String _getLanguageName(String code) {
    switch (code) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      default:
        return code.toUpperCase();
    }
  }

  /// Định dạng bytes thành chuỗi dễ đọc.
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
