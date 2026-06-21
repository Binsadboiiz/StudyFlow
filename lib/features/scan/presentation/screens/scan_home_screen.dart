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
import 'package:studyflow/features/scan/presentation/screens/trash_screen.dart';
import 'package:studyflow/l10n/app_localizations.dart';
import 'package:studyflow/core/services/network_connection_service.dart';
import 'package:studyflow/core/widgets/offline_feature_blocker.dart';

/// Main screen for the OCR scanning feature.
/// Displays document list, storage indicator, search, and selection mode.
class ScanHomeScreen extends StatefulWidget {
  const ScanHomeScreen({super.key});

  @override
  State<ScanHomeScreen> createState() => _ScanHomeScreenState();
}

class _ScanHomeScreenState extends State<ScanHomeScreen> {
  /// Controller for search field.
  final TextEditingController _searchController = TextEditingController();

  /// Flag to show search field.
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
    final connectionService = context.watch<NetworkConnectionService>();

    if (!connectionService.isOnline) {
      return OfflineFeatureBlocker(
        featureName: AppLocalizations.of(context)!.scanTitle,
        child: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      // AppBar with Glassmorphism effect
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
        leading: scanVm.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => scanVm.clearSelection(),
              )
            : null,
        title: scanVm.isSelectionMode
            ? Text(
                AppLocalizations.of(context)!.scanSelectedCount(scanVm.selectedIds.length),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : (_showSearch
                ? _buildSearchField(ext)
                : Text(
                    AppLocalizations.of(context)!.scanTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
        actions: scanVm.isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  onPressed: () => scanVm.selectAll(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                  onPressed: () => _confirmBatchDelete(context, scanVm),
                ),
                const SizedBox(width: 8),
              ]
            : [
                // Search toggle button
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
                // Popup menu for Filter, Select, and Trash
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'filter') {
                      _showFilterBottomSheet(context, scanVm);
                    } else if (value == 'select') {
                      scanVm.toggleSelectionMode();
                    } else if (value == 'trash') {
                      _openTrashScreen(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'filter',
                      child: Row(
                        children: [
                          Icon(Icons.filter_list_rounded, color: ext.subtext, size: 20),
                          const SizedBox(width: 12),
                          Text(AppLocalizations.of(context)!.scanFilter),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: [
                          Icon(Icons.check_box_outlined, color: ext.subtext, size: 20),
                          const SizedBox(width: 12),
                          Text(AppLocalizations.of(context)!.scanSelect),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'trash',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: ext.subtext, size: 20),
                          const SizedBox(width: 12),
                          Text(AppLocalizations.of(context)!.scanTrash),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
      ),

      // Main content: document list
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

                // Document List
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = scanVm.documents[index];
                          final isSelected = scanVm.selectedIds.contains(doc.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DocumentCard(
                              document: doc,
                              isSelectionMode: scanVm.isSelectionMode,
                              isSelected: isSelected,
                              onTap: () {
                                if (scanVm.isSelectionMode) {
                                  scanVm.toggleSelection(doc.id);
                                } else {
                                  _openDocumentDetail(context, doc.id);
                                }
                              },
                              onLongPress: () {
                                if (!scanVm.isSelectionMode) {
                                  scanVm.toggleSelectionMode();
                                  scanVm.toggleSelection(doc.id);
                                }
                              },
                            ),
                          );
                        },
                        childCount: scanVm.documents.length,
                      ),
                    ),
                  ),

                // Bottom padding for nav bar
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),

      // FAB to scan new document (hidden in selection mode)
      floatingActionButton: scanVm.isSelectionMode
          ? null
          : Padding(
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

  /// Build search field.
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

  /// Empty state: no documents.
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

  /// Error state.
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
              AppLocalizations.of(context)!.scanErrorOccurred,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ext.subtext,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.scanLoadListFailed(scanVm.errorMessage ?? ''),
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
              label: Text(AppLocalizations.of(context)!.scanRetry),
            ),
          ],
        ),
      ),
    );
  }

  /// Open document detail screen.
  void _openDocumentDetail(BuildContext context, String documentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailScreen(documentId: documentId),
      ),
    );
  }

  /// Open camera scan screen.
  void _openCameraScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScanScreen(),
      ),
    );
  }

  /// Open trash screen.
  void _openTrashScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrashScreen(),
      ),
    );
  }

  /// Show batch delete confirmation dialog.
  void _confirmBatchDelete(BuildContext context, ScanViewModel scanVm) {
    final count = scanVm.selectedIds.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.scanDeleteConfirmTitle),
        content: Text(AppLocalizations.of(context)!.scanBatchDeleteConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.scanDeleteCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await scanVm.batchDeleteSelected();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.scanDeleteSuccess)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(AppLocalizations.of(context)!.scanDeleteConfirm),
          ),
        ],
      ),
    );
  }

  /// Show filter bottom sheet.
  void _showFilterBottomSheet(BuildContext context, ScanViewModel scanVm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.scanFilter,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Filter Options
            ListTile(
              leading: const Icon(Icons.all_inclusive_rounded),
              title: Text(AppLocalizations.of(context)!.scanFilterAllTime),
              trailing: scanVm.currentFilterDays == null
                  ? const Icon(Icons.check_rounded, color: AppColors.accent)
                  : null,
              onTap: () {
                scanVm.filterDocuments(daysAgo: null);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_week_rounded),
              title: Text(AppLocalizations.of(context)!.scanFilterLast7Days),
              trailing: scanVm.currentFilterDays == 7
                  ? const Icon(Icons.check_rounded, color: AppColors.accent)
                  : null,
              onTap: () {
                scanVm.filterDocuments(daysAgo: 7);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(AppLocalizations.of(context)!.scanFilterLast30Days),
              trailing: scanVm.currentFilterDays == 30
                  ? const Icon(Icons.check_rounded, color: AppColors.accent)
                  : null,
              onTap: () {
                scanVm.filterDocuments(daysAgo: 30);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
