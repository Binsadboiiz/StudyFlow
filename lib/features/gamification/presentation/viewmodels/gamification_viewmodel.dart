import 'package:flutter/material.dart';
import 'package:studyflow/features/gamification/data/models/badge_model.dart';
import 'package:studyflow/features/gamification/data/models/gamification_summary_model.dart';
import 'package:studyflow/features/gamification/data/models/leaderboard_entry_model.dart';
import 'package:studyflow/features/gamification/data/repositories/gamification_repository.dart';

/// ViewModel quản lý dữ liệu và trạng thái UI cho các tính năng điểm số, huy hiệu, bảng xếp hạng.
class GamificationViewModel extends ChangeNotifier {
  final GamificationRepository gamificationRepository;

  GamificationSummaryModel? _summary;
  List<BadgeModel> _badges = [];
  List<LeaderboardEntryModel> _leaderboardEntries = [];
  int _userRank = 0;

  // Tiêu chí xếp hạng hiện tại của Leaderboard (mặc định: Cấp độ 'Level')
  String _currentSortBy = 'Level'; 

  bool _isLoadingSummary = false;
  bool _isLoadingBadges = false;
  bool _isLoadingLeaderboard = false;
  bool _isActionInProgress = false;

  GamificationViewModel({required this.gamificationRepository});

  // --- Getters ---
  GamificationSummaryModel? get summary => _summary;
  List<BadgeModel> get badges => _badges;
  List<LeaderboardEntryModel> get leaderboardEntries => _leaderboardEntries;
  int get userRank => _userRank;
  String get currentSortBy => _currentSortBy;

  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingBadges => _isLoadingBadges;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  bool get isActionInProgress => _isActionInProgress;

  bool get isLoading => _isLoadingSummary || _isLoadingBadges || _isLoadingLeaderboard;

  /// Tải thông tin tóm tắt điểm (Level, XP, Coins, Streak, Huy hiệu nổi bật).
  Future<void> fetchSummary() async {
    _isLoadingSummary = true;
    notifyListeners();

    final result = await gamificationRepository.getSummary();
    if (result != null) {
      _summary = result;
    }

    _isLoadingSummary = false;
    notifyListeners();
  }

  /// Tải danh sách huy hiệu thành tích.
  Future<void> fetchBadges() async {
    _isLoadingBadges = true;
    notifyListeners();

    final result = await gamificationRepository.getBadges();
    _badges = result;

    _isLoadingBadges = false;
    notifyListeners();
  }

  /// Tải bảng xếp hạng người dùng toàn cầu dựa trên tiêu chí sắp xếp hiện tại.
  Future<void> fetchLeaderboard() async {
    _isLoadingLeaderboard = true;
    notifyListeners();

    final result = await gamificationRepository.getLeaderboard(_currentSortBy);
    if (result != null) {
      _leaderboardEntries = result['entries'] ?? [];
      _userRank = result['userRank'] ?? 0;
    } else {
      _leaderboardEntries = [];
      _userRank = 0;
    }

    _isLoadingLeaderboard = false;
    notifyListeners();
  }

  /// Thay đổi tiêu chí xếp hạng và tải lại dữ liệu.
  Future<void> changeSortBy(String newSortBy) async {
    if (_currentSortBy == newSortBy) return;
    _currentSortBy = newSortBy;
    notifyListeners();
    await fetchLeaderboard();
  }

  /// Thiết lập danh hiệu nổi bật (Huy hiệu nổi bật).
  Future<bool> setFeaturedBadge(String? badgeId) async {
    _isActionInProgress = true;
    notifyListeners();

    final success = await gamificationRepository.setFeaturedBadge(badgeId);
    _isActionInProgress = false;

    if (success) {
      // Refresh summary & badges list to reflect changes
      await fetchSummary();
      await fetchBadges();
      return true;
    }
    notifyListeners();
    return false;
  }

  /// Làm mới toàn bộ dữ liệu trong Gamification Hub.
  Future<void> refreshAll() async {
    await Future.wait([
      fetchSummary(),
      fetchBadges(),
      fetchLeaderboard(),
    ]);
  }
}
