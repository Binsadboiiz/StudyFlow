import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:studyflow/features/scan/presentation/viewmodels/scan_viewmodel.dart';
import 'package:studyflow/l10n/app_localizations.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';
import 'package:studyflow/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:studyflow/features/flashcard/presentation/screens/flashcard_study_screen.dart';

/// Màn hình chi tiết tài liệu đã quét.
/// Hiển thị: ảnh đầy đủ, nội dung OCR (copyable), metadata, nút xóa/chỉnh sửa.
class DocumentDetailScreen extends StatefulWidget {
  /// ID tài liệu cần hiển thị.
  final String documentId;

  const DocumentDetailScreen({
    super.key,
    required this.documentId,
  });

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final scanVm = context.watch<ScanViewModel>();

    // Tìm tài liệu trong danh sách hiện tại
    final document = scanVm.documents.where((d) => d.id == widget.documentId).firstOrNull;

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.scanDetailTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: ext.subtext),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.scanNotFound,
                style: TextStyle(fontSize: 16, color: ext.subtext),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          document.title.isNotEmpty ? document.title : AppLocalizations.of(context)!.scanDetailTitle,
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          // Nút xóa
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _showDeleteDialog(context, document),
            tooltip: AppLocalizations.of(context)!.scanDeleteConfirmTitle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh tài liệu (nếu có)
            if (document.originalImageUrl != null &&
                document.originalImageUrl!.isNotEmpty)
              GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    document.originalImageUrl!,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppColors.accent,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_rounded, size: 48, color: ext.subtext),
                            const SizedBox(height: 8),
                            Text(AppLocalizations.of(context)!.scanLoadImageFailed,
                                style: TextStyle(color: ext.subtext)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (document.originalImageUrl != null) const SizedBox(height: 16),

            // 2. Metadata tài liệu
            _buildMetadataSection(document, theme, ext),
            const SizedBox(height: 16),

            // 2.5 Sinh Flashcard bằng AI Button
            if (document.extractedText.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () => _generateFlashcards(context, document),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(AppLocalizations.of(context)!.flashcardGenerateAI, style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 3. Nội dung văn bản OCR
            _buildTextSection(document, theme, ext),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Section hiển thị metadata tài liệu.
  Widget _buildMetadataSection(
    ScannedDocumentEntity document,
    ThemeData theme,
    AppThemeExtension ext,
  ) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề section
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.scanInfoTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Các dòng metadata
          _buildMetadataRow(
            icon: Icons.calendar_today_rounded,
            label: AppLocalizations.of(context)!.scanCreatedAt,
            value: DateFormat('dd/MM/yyyy HH:mm').format(document.createdAt),
            ext: ext,
          ),
          const SizedBox(height: 8),
          _buildMetadataRow(
            icon: Icons.update_rounded,
            label: AppLocalizations.of(context)!.scanUpdatedAt,
            value: DateFormat('dd/MM/yyyy HH:mm').format(document.updatedAt),
            ext: ext,
          ),
          const SizedBox(height: 8),
          _buildMetadataRow(
            icon: Icons.storage_rounded,
            label: AppLocalizations.of(context)!.scanSize,
            value: document.formattedSize,
            ext: ext,
          ),
          const SizedBox(height: 8),
          _buildMetadataRow(
            icon: Icons.language_rounded,
            label: AppLocalizations.of(context)!.scanLanguage,
            value: _getLanguageName(document.detectedLanguage),
            ext: ext,
          ),
          const SizedBox(height: 8),
          _buildMetadataRow(
            icon: Icons.verified_rounded,
            label: AppLocalizations.of(context)!.scanConfidence,
            value: '${(document.confidenceScore * 100).toStringAsFixed(1)}%',
            ext: ext,
            valueColor: _getConfidenceColor(document.confidenceScore),
          ),
        ],
      ),
    );
  }

  /// Dòng metadata đơn.
  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
    required AppThemeExtension ext,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ext.subtext),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 13, color: ext.subtext),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Section hiển thị nội dung OCR (copyable).
  Widget _buildTextSection(
    ScannedDocumentEntity document,
    ThemeData theme,
    AppThemeExtension ext,
  ) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với nút copy
          Row(
            children: [
              const Icon(Icons.text_fields_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.scanTextContentTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              // Nút copy toàn bộ
              IconButton(
                icon: Icon(Icons.copy_rounded, size: 18, color: ext.subtext),
                tooltip: AppLocalizations.of(context)!.scanCopyAll,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: document.extractedText));
                  NotificationService.instance.show(
                    AppNotification(
                      message: AppLocalizations.of(context)!.scanCopySuccess,
                      type: NotificationType.success,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: ext.subtext.withValues(alpha: 0.15)),
          const SizedBox(height: 12),

          // Nội dung text (có thể chọn & copy)
          SelectableText(
            document.extractedText.isNotEmpty
                ? document.extractedText
                : AppLocalizations.of(context)!.scanEmptyText,
            style: TextStyle(
              fontSize: 14,
              color: document.extractedText.isNotEmpty
                  ? theme.colorScheme.onSurface
                  : ext.subtext,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog xác nhận xóa tài liệu.
  void _showDeleteDialog(BuildContext context, ScannedDocumentEntity document) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.scanDeleteConfirmTitle),
        content: Text(
          AppLocalizations.of(context)!.scanDeleteConfirmDesc(document.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.scanDeleteCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final scanVm = context.read<ScanViewModel>();
              final navigator = Navigator.of(context);
              final successMsg = AppLocalizations.of(context)!.scanDeleteSuccess;
              final success = await scanVm.deleteDocument(document.id);
              if (success && mounted) {
                NotificationService.instance.show(
                  AppNotification(
                    message: successMsg,
                    type: NotificationType.success,
                  ),
                );
                navigator.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.scanDeleteConfirm),
          ),
        ],
      ),
    );
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

  /// Lấy màu dựa trên độ tin cậy.
  Color _getConfidenceColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Future<void> _generateFlashcards(BuildContext context, ScannedDocumentEntity document) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(AppLocalizations.of(context)!.flashcardGenerating)),
          ],
        ),
      ),
    );

    final provider = context.read<FlashcardProvider>();
    final result = await provider.generateFromDocument(document.id);

    if (context.mounted) {
      Navigator.pop(context); // Pop loading dialog
    }

    if (result != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.flashcardGenerateSuccess), backgroundColor: Colors.green),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashcardStudyScreen(flashcardSet: result),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? AppLocalizations.of(context)!.aiChatDailyLimitReached),
            backgroundColor: Colors.redAccent,
          ),
        );
        provider.clearError();
      }
    }
  }
}
