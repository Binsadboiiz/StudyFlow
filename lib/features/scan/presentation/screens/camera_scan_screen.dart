import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/scan/presentation/viewmodels/scan_viewmodel.dart';
import 'package:studyflow/features/scan/presentation/screens/ocr_review_screen.dart';
import 'package:studyflow/l10n/app_localizations.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';

/// Màn hình chụp/chọn ảnh tài liệu để quét OCR.
/// Quy trình: Chọn ảnh (Camera/Gallery) → Cắt/Xoay → Nén → OCR → Review.
class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ext = theme.extension<AppThemeExtension>()!;
    final scanVm = context.watch<ScanViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanTitle),
        centerTitle: true,
      ),
      body: scanVm.isProcessingOcr
          ? _buildProcessingState(theme, ext)
          : _buildSelectionState(theme, isDark, ext),
    );
  }

  /// Giao diện đang xử lý OCR.
  Widget _buildProcessingState(ThemeData theme, AppThemeExtension ext) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vòng tải với animation
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.scanProcessingText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện chọn nguồn ảnh (Camera / Gallery).
  Widget _buildSelectionState(ThemeData theme, bool isDark, AppThemeExtension ext) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Icon minh họa
          Icon(
            Icons.document_scanner_rounded,
            size: 100,
            color: AppColors.accent.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),

          Text(
            AppLocalizations.of(context)!.scanCameraOptionsTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 48),

          // Nút chụp ảnh từ Camera
          _buildSourceButton(
            context,
            icon: Icons.camera_alt_rounded,
            title: AppLocalizations.of(context)!.scanCamera,
            subtitle: '',
            onTap: () => _pickImage(ImageSource.camera),
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // Nút chọn từ Gallery
          _buildSourceButton(
            context,
            icon: Icons.photo_library_rounded,
            title: AppLocalizations.of(context)!.scanGallery,
            subtitle: '',
            onTap: () => _pickImage(ImageSource.gallery),
            isDark: isDark,
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  /// Widget nút chọn nguồn ảnh.
  Widget _buildSourceButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GlassCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon trong hình tròn
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),

              // Tiêu đề và mô tả
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).extension<AppThemeExtension>()!.subtext,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Mũi tên
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).extension<AppThemeExtension>()!.subtext,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Chọn ảnh từ nguồn (Camera hoặc Gallery), sau đó cắt/xoay và chạy OCR.
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Bước 1: Chọn ảnh
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 100, // Giữ chất lượng gốc, sẽ nén sau
      );

      if (pickedFile == null || !mounted) return;

      // Bước 2: Cắt/Xoay ảnh bằng image_cropper
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cắt ảnh tài liệu',
            toolbarColor: AppColors.accent,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.accent,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Cắt ảnh tài liệu',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile == null || !mounted) return;

      // Bước 3: Chạy OCR (nén + nhận diện chữ trong ViewModel)
      final scanVm = context.read<ScanViewModel>();
      final result = await scanVm.processOcr(File(croppedFile.path));

      if (result == null || !mounted) {
        if (mounted) {
          NotificationService.instance.show(
            AppNotification(
              message: scanVm.errorMessage ?? AppLocalizations.of(context)!.scanProcessFailed,
              type: NotificationType.error,
            ),
          );
        }
        return;
      }

      // Bước 4: Chuyển sang màn hình review kết quả OCR
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OcrReviewScreen(
            extractedText: result['text'] as String,
            confidenceScore: result['confidenceScore'] as double,
            detectedLanguage: result['detectedLanguage'] as String,
            imageSizeBytes: result['compressedSizeBytes'] as int,
            imageBytes: Uint8List.fromList(result['compressedImageBytes'] as List<int>),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        NotificationService.instance.show(
          AppNotification(
            message: '${AppLocalizations.of(context)!.scanProcessFailed}: $e',
            type: NotificationType.error,
          ),
        );
      }
    }
  }
}
