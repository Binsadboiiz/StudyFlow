import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/widgets/offline_feature_blocker.dart';
import 'package:studyflow/features/gamification/presentation/screens/tabs/streak_tab.dart';
import 'package:studyflow/features/gamification/presentation/screens/tabs/pet_tab.dart';
import 'package:studyflow/features/gamification/presentation/screens/tabs/badges_tab.dart';
import 'package:studyflow/features/gamification/presentation/screens/tabs/leaderboard_tab.dart';
import 'package:studyflow/features/gamification/presentation/screens/widgets/level_up_dialog.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/pet_viewmodel.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// Màn hình chính Gamification Hub chứa 4 Tab: Streak, Pet, Thành tích, Bảng xếp hạng.
class GamificationHubScreen extends StatefulWidget {
  const GamificationHubScreen({super.key});

  @override
  State<GamificationHubScreen> createState() => _GamificationHubScreenState();
}

class _GamificationHubScreenState extends State<GamificationHubScreen> with SingleTickerProviderStateMixin {
  int? _previousLevel;
  late TabController _tabController;
  GamificationViewModel? _gamificationVm;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _gamificationVm = context.read<GamificationViewModel>();
      _gamificationVm!.addListener(_handleVmTabChange);
      
      // Initialize controller index from VM
      _tabController.index = _gamificationVm!.activeSubTab;

      _gamificationVm!.refreshAll().then((_) {
        if (!mounted) return;
        final summary = _gamificationVm!.summary;
        if (summary != null) {
          setState(() {
            _previousLevel = summary.level;
          });
        }
      });
      context.read<PetViewModel>().fetchPet();
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    if (_gamificationVm != null && _gamificationVm!.activeSubTab != _tabController.index) {
      _gamificationVm!.changeSubTab(_tabController.index);
    }
  }

  void _handleVmTabChange() {
    if (_gamificationVm != null && _tabController.index != _gamificationVm!.activeSubTab) {
      _tabController.animateTo(_gamificationVm!.activeSubTab);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _gamificationVm?.removeListener(_handleVmTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gamificationVm = context.watch<GamificationViewModel>();
    final summary = gamificationVm.summary;

    // Kiểm tra và hiển thị Hộp thoại chúc mừng thăng cấp (Level Up)
    if (summary != null && _previousLevel != null && summary.level > _previousLevel!) {
      final newLevel = summary.level;
      _previousLevel = newLevel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => LevelUpDialog(newLevel: newLevel),
        );
      });
    } else if (summary != null && _previousLevel == null) {
      _previousLevel = summary.level;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? [
                  const Color(0xFF0F0C20), // Tím tối huyền bí
                  const Color(0xFF090D10), // Đen xám sâu thẳm
                ]
              : [
                  const Color(0xFFEEF2F6),
                  const Color(0xFFE2E8F0),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              // Thông tin Level của user ở góc trên trái
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Level ${summary?.level ?? 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 110,
                        height: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: summary != null ? (summary.xpPoints / summary.nextLevelXp) : 0.0,
                            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${summary?.xpPoints.round() ?? 0}/${summary?.nextLevelXp.round() ?? 100} XP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Tiền xu vàng (Coins) tích luỹ góc trên phải
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${summary?.coins ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(icon: const Icon(Icons.local_fire_department_rounded), text: AppLocalizations.of(context)!.streak),
              Tab(icon: const Icon(Icons.pets_rounded), text: AppLocalizations.of(context)!.pet),
              Tab(icon: const Icon(Icons.emoji_events_rounded), text: AppLocalizations.of(context)!.achievements),
              Tab(icon: const Icon(Icons.leaderboard_rounded), text: AppLocalizations.of(context)!.leaderboard),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa vuốt để tránh xung đột cử chỉ với Lịch
          children: [
            const StreakTab(),
            const PetTab(),
            OfflineFeatureBlocker(
              featureName: AppLocalizations.of(context)!.achievements,
              child: const BadgesTab(),
            ),
            OfflineFeatureBlocker(
              featureName: AppLocalizations.of(context)!.leaderboard,
              child: const LeaderboardTab(),
            ),
          ],
        ),
      ),
    );
  }
}
