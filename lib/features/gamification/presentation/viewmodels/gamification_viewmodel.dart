import 'package:flutter/material.dart';
import 'package:studyflow/features/gamification/data/models/badge_model.dart';
import 'package:studyflow/features/gamification/data/models/gamification_summary_model.dart';
import 'package:studyflow/features/gamification/data/models/leaderboard_entry_model.dart';
import 'package:studyflow/features/gamification/data/repositories/gamification_repository.dart';

/// ViewModel managing data and UI state for gamification features such as points, badges, and leaderboards.
class GamificationViewModel extends ChangeNotifier {
  final GamificationRepository gamificationRepository;

  GamificationSummaryModel? _summary;
  List<BadgeModel> _badges = [];
  List<LeaderboardEntryModel> _leaderboardEntries = [];
  int _userRank = 0;

  // Current leaderboard sorting criterion (default: 'Level')
  String _currentSortBy = 'Level'; 

  // Active sub-tab in GamificationHubScreen (0: Streak, 1: Pet, 2: Badges, 3: Leaderboard)
  int _activeSubTab = 0;

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
  int get activeSubTab => _activeSubTab;

  void changeSubTab(int index) {
    if (_activeSubTab == index) return;
    _activeSubTab = index;
    notifyListeners();
  }

  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingBadges => _isLoadingBadges;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  bool get isActionInProgress => _isActionInProgress;

  bool get isLoading => _isLoadingSummary || _isLoadingBadges || _isLoadingLeaderboard;

  /// Fetches the gamification summary (Level, XP, Coins, Streak, Featured Badge).
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

  /// Fetches the list of achievement badges.
  Future<void> fetchBadges() async {
    _isLoadingBadges = true;
    notifyListeners();

    final result = await gamificationRepository.getBadges();
    _badges = result;

    _isLoadingBadges = false;
    notifyListeners();
  }

  /// Fetches the global leaderboard entries sorted by the current sort criterion.
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

  /// Changes the leaderboard sorting criterion and reloads the data.
  Future<void> changeSortBy(String newSortBy) async {
    if (_currentSortBy == newSortBy) return;
    _currentSortBy = newSortBy;
    notifyListeners();
    await fetchLeaderboard();
  }

  /// Sets the user's featured badge.
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

  /// Refreshes all gamification data in the hub.
  Future<void> refreshAll() async {
    await Future.wait([
      fetchSummary(),
      fetchBadges(),
      fetchLeaderboard(),
    ]);
  }
}
