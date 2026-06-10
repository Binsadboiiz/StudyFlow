import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/scan/presentation/viewmodels/scan_viewmodel.dart';
import 'package:studyflow/features/scan/presentation/widgets/document_card.dart';
import 'package:studyflow/features/scan/presentation/widgets/storage_indicator.dart';
import 'package:studyflow/features/scan/presentation/screens/camera_scan_screen.dart';
import 'package:studyflow/features/scan/presentation/screens/document_detail_screen.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// Màn hình chính của tính năng quét tài liệu OCR.
/// Hiển thị danh sách tài liệu, thanh dung lượng, chức năng tìm kiếm.
class ScanHomeScreen extends StatefulWidget {
  const ScanHomeScreen({super.key});

  @override
  State<ScanHomeScreen> createState() => _ScanHomeScreenState();
}

class _ScanHomeScreenState extends State<ScanHomeScreen> {
  /// Controller cho ô tìm kiếm.
  final TextEditingController _searchController = TextEditingController();

  /// Cờ hiển thị ô tìm kiếm.
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ext = theme.extension<AppThemeExtension>()!;
    final scanVm = context.watch<ScanViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      // AppBar với Glassmorphism effect giống HomeScreen
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.2),
        elevation: 0,
        toolbarHeight: 64,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: _showSearch
            ? _buildSearchField(ext)
            : Text(
                AppLocalizations.of(context)!.scanTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          // Nút tìm kiếm / đóng tìm kiếm
          IconButton(
            icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  scanVm.clearSearch();
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Nội dung chính: danh sách tài liệu
      body: Container(
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () => scanVm.loadDocuments(),
            child: CustomScrollView(
              slivers: [
                // Khoảng cách cho AppBar
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Thanh dung lượng lưu trữ
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StorageIndicator(
                      storageUsage: scanVm.storageUsage,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Trạng thái loading
                if (scanVm.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    ),
                  )

                // Trạng thái lỗi
                else if (scanVm.errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(scanVm, ext),
                  )

                // Trạng thái trống
                else if (scanVm.documents.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(ext),
                  )

                // Danh sách tài liệu
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = scanVm.documents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DocumentCard(
                              document: doc,
                              onTap: () => _openDocumentDetail(context, doc.id),
                            ),
                          );
                        },
                        childCount: scanVm.documents.length,
                      ),
                    ),
                  ),

                // Padding dưới cùng cho bottom nav
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),

      // FAB để quét tài liệu mới
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _openCameraScan(context),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.document_scanner_rounded, size: 26),
        ),
      ),
    );
  }

  /// Xây dựng ô tìm kiếm.
  Widget _buildSearchField(AppThemeExtension ext) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.scanSearchHint,
        hintStyle: TextStyle(color: ext.subtext),
        border: InputBorder.none,
        filled: false,
      ),
      onChanged: (query) {
        context.read<ScanViewModel>().searchDocuments(query);
      },
    );
  }

  /// Trạng thái trống: chưa có tài liệu nào.
  Widget _buildEmptyState(AppThemeExtension ext) {
    final isSearching = context.read<ScanViewModel>().isSearching;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.document_scanner_outlined,
              size: 72,
              color: ext.subtext.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? AppLocalizations.of(context)!.scanNoSearchResults
                  : AppLocalizations.of(context)!.scanNoDocumentsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ext.subtext,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? AppLocalizations.of(context)!.scanNoSearchResultsSubtitle
                  : AppLocalizations.of(context)!.scanNoDocumentsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ext.subtext.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Trạng thái lỗi.
  Widget _buildErrorState(ScanViewModel scanVm, AppThemeExtension ext) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.redAccent.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ext.subtext,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scanVm.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: ext.subtext.withValues(alpha: 0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => scanVm.loadDocuments(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Mở màn hình chi tiết tài liệu.
  void _openDocumentDetail(BuildContext context, String documentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailScreen(documentId: documentId),
      ),
    );
  }

  /// Mở màn hình quét tài liệu mới.
  void _openCameraScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScanScreen(),
      ),
    );
  }
}
