import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:intl/intl.dart';

/// Widget hiển thị thẻ tài liệu đã quét trong danh sách.
/// Bao gồm: thumbnail, tiêu đề, preview nội dung, ngày tạo, kích thước file.
class DocumentCard extends StatelessWidget {
  /// Entity containing document data.
  final ScannedDocumentEntity document;

  /// Callback when user taps the card.
  final VoidCallback? onTap;

  /// Callback when user long presses the card.
  final VoidCallback? onLongPress;

  /// Flag indicating if the list is in selection mode.
  final bool isSelectionMode;

  /// Flag indicating if this specific card is selected.
  final bool isSelected;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ext = theme.extension<AppThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: GlassCard(
        borderRadius: 20,
        padding: EdgeInsets.zero,
        border: isSelected 
          ? Border.all(color: AppColors.accent, width: 2)
          : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Selection Checkbox
              if (isSelectionMode) ...[
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.accent : ext.subtext.withValues(alpha: 0.5),
                  size: 24,
                ),
                const SizedBox(width: 14),
              ],
              
              // Thumbnail image or default icon
              _buildThumbnail(isDark),
              const SizedBox(width: 14),

              // Main content: title, preview, metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề tài liệu
                    Text(
                      document.title.isNotEmpty ? document.title : 'Không có tiêu đề',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Preview nội dung OCR
                    Text(
                      document.extractedText.isNotEmpty
                          ? document.extractedText
                          : 'Không có nội dung',
                      style: TextStyle(
                        fontSize: 12,
                        color: ext.subtext,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Metadata: ngày tạo + kích thước
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: ext.subtext,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(document.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: ext.subtext,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.storage_rounded,
                          size: 12,
                          color: ext.subtext,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          document.formattedSize,
                          style: TextStyle(
                            fontSize: 11,
                            color: ext.subtext,
                          ),
                        ),
                        const Spacer(),
                        // Badge độ tin cậy OCR
                        if (document.confidenceScore > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(document.confidenceScore)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(document.confidenceScore * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getConfidenceColor(document.confidenceScore),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build thumbnail image or default icon.
  Widget _buildThumbnail(bool isDark) {
    if (document.originalImageUrl != null && document.originalImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          document.originalImageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(isDark),
        ),
      );
    }
    return _buildDefaultIcon(isDark);
  }

  /// Default icon when there is no image.
  Widget _buildDefaultIcon(bool isDark) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.document_scanner_rounded,
        color: AppColors.accent,
        size: 28,
      ),
    );
  }

  /// Get color based on OCR confidence.
  Color _getConfidenceColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
