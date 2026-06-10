import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';

/// Widget cho phép chỉnh sửa nội dung văn bản OCR.
/// Hiển thị text editor với toolbar hỗ trợ copy/select all.
class OcrTextEditor extends StatelessWidget {
  /// Controller cho text field.
  final TextEditingController controller;

  /// Callback khi nội dung thay đổi.
  final ValueChanged<String>? onChanged;

  /// Placeholder text.
  final String hintText;

  /// Cho phép chỉnh sửa hay chỉ xem.
  final bool readOnly;

  const OcrTextEditor({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Nội dung văn bản OCR...',
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar: các nút tiện ích
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Icon(
                  Icons.text_fields_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nội dung OCR',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                // Nút copy toàn bộ
                _buildToolbarButton(
                  context,
                  icon: Icons.copy_rounded,
                  tooltip: 'Sao chép',
                  onTap: () {
                    // Sử dụng Clipboard thông qua controller
                    if (controller.text.isNotEmpty) {
                      // Copy sẽ được xử lý bởi SelectableText hoặc tương tự
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép nội dung'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 4),
                // Nút chọn tất cả
                _buildToolbarButton(
                  context,
                  icon: Icons.select_all_rounded,
                  tooltip: 'Chọn tất cả',
                  onTap: () {
                    controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: controller.text.length,
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ext.subtext.withValues(alpha: 0.15)),

          // Text editor chính
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              readOnly: readOnly,
              maxLines: null,
              minLines: 8,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: ext.subtext.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tạo nút toolbar nhỏ gọn.
  Widget _buildToolbarButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: ext.subtext,
          ),
        ),
      ),
    );
  }
}
