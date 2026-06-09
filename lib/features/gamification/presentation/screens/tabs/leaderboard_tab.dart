import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/auth/presentation/widgets/user_avatar.dart';
import 'package:studyflow/features/gamification/data/models/leaderboard_entry_model.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/widgets/featured_badge_tag.dart';

import 'package:studyflow/shared/widgets/loading/leaderboard_skeleton.dart';

/// Tab hiển thị bảng xếp hạng học sinh toàn cầu với các bộ lọc xếp hạng nâng cao.
class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final gamificationVm = context.watch<GamificationViewModel>();
    final authVm = context.watch<AuthViewmodel>();

    if (gamificationVm.isLoadingLeaderboard) {
      return const LeaderboardSkeleton();
    }

    final entries = gamificationVm.leaderboardEntries;
    final currentUserId = authVm.currentUser?.id;

    // Tách Top 3 ra để vẽ bục vinh quang riêng
    final top3 = entries.take(3).toList();
    final remainingEntries = entries.skip(3).toList();

    return Column(
      children: [
        // Thanh bộ lọc bảng xếp hạng ChoiceChips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSortChip(context, gamificationVm, 'Level', 'Level', Icons.trending_up_rounded),
              _buildSortChip(context, gamificationVm, 'Achievements', 'Achievements', Icons.emoji_events_rounded),
              _buildSortChip(context, gamificationVm, 'Pet', 'Pet', Icons.pets_rounded),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 16),

        if (entries.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No leaderboard data available yet. Start studying to climb the ranks!',
                    style: TextStyle(color: ext.subtext, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Vẽ bục vinh quang cho Top 3 nếu có
          if (top3.isNotEmpty)
            _buildPodium(context, top3, currentUserId, gamificationVm.currentSortBy),
          const SizedBox(height: 20),

          // Danh sách xếp hạng còn lại (từ hạng 4 trở đi)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
              itemCount: remainingEntries.length,
              itemBuilder: (context, index) {
                final entry = remainingEntries[index];
                final isMe = entry.userId == currentUserId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: isMe ? Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1.5) : null,
                    child: Row(
                      children: [
                        // Thứ hạng
                        SizedBox(
                          width: 30,
                          child: Text(
                            '#${entry.rank}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isMe ? AppColors.accent : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Avatar
                        UserAvatar(
                          photoUrl: entry.avatarUrl,
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        // Tên & Danh hiệu nổi bật
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    entry.fullName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (entry.featuredBadgeName != null)
                                    FeaturedBadgeTag(
                                      badgeName: entry.featuredBadgeName!,
                                      iconKey: entry.featuredBadgeIcon,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${entry.username}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ext.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cột chỉ số tương ứng theo tiêu chí sắp xếp
                        _buildRightMetric(entry, gamificationVm.currentSortBy, isMe, theme, ext),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Nút lọc lựa chọn tiêu chí xếp hạng.
  Widget _buildSortChip(BuildContext context, GamificationViewModel vm, String sortByValue, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = vm.currentSortBy == sortByValue;

    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(
        icon,
        color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        size: 16,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          vm.changeSortBy(sortByValue);
        }
      },
      selectedColor: AppColors.accent,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.05),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.accent : theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
    );
  }

  /// Cột chỉ số bên phải của mỗi dòng trong bảng xếp hạng.
  Widget _buildRightMetric(LeaderboardEntryModel entry, String sortBy, bool isMe, ThemeData theme, AppThemeExtension ext) {
    if (sortBy == 'Achievements') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.achievementsCount} Achievements',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Earned',
            style: TextStyle(
              fontSize: 11,
              color: ext.subtext,
            ),
          ),
        ],
      );
    } else if (sortBy == 'Pet') {
      final hasPet = entry.petLevel > 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasPet ? 'Pet LV ${entry.petLevel}' : 'No Pet',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: hasPet ? Colors.cyan : ext.subtext,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasPet ? entry.petName : 'Not Adopted',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isMe ? AppColors.accent : ext.subtext,
            ),
          ),
        ],
      );
    } else {
      // Mặc định: Cấp độ (Level)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'LV ${entry.level}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.expPoints.toInt()} XP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isMe ? AppColors.accent : ext.subtext,
            ),
          ),
        ],
      );
    }
  }

  /// Vẽ bục vinh quang cho Top 3 học sinh.
  Widget _buildPodium(BuildContext context, List<LeaderboardEntryModel> top3, String? currentUserId, String sortBy) {
    LeaderboardEntryModel? first = top3.isNotEmpty ? top3[0] : null;
    LeaderboardEntryModel? second = top3.length > 1 ? top3[1] : null;
    LeaderboardEntryModel? third = top3.length > 2 ? top3[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Hạng 2 (Trái)
        if (second != null)
          _buildPodiumAvatar(context, second, 2, Colors.blueGrey, 75, currentUserId == second.userId, sortBy),
        const SizedBox(width: 16),
        // Hạng 1 (Giữa - Cao nhất)
        if (first != null)
          _buildPodiumAvatar(context, first, 1, Colors.amber, 95, currentUserId == first.userId, sortBy),
        const SizedBox(width: 16),
        // Hạng 3 (Phải)
        if (third != null)
          _buildPodiumAvatar(context, third, 3, Colors.brown, 70, currentUserId == third.userId, sortBy),
      ],
    );
  }

  /// Avatar + Bục của từng thứ hạng trong Top 3.
  Widget _buildPodiumAvatar(BuildContext context, LeaderboardEntryModel entry, int rank, Color rankColor, double height, bool isMe, String sortBy) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Biểu tượng vương miện cho hạng 1
        if (rank == 1)
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.amber,
            size: 32,
          ),
        const SizedBox(height: 4),
        // Khung Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMe ? AppColors.accent : rankColor,
              width: rank == 1 ? 3 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isMe ? AppColors.accent : rankColor).withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: UserAvatar(
            photoUrl: entry.avatarUrl,
            radius: rank == 1 ? 36 : 28,
          ),
        ),
        const SizedBox(height: 8),
        // Tên hiển thị
        SizedBox(
          width: 90,
          child: Text(
            entry.fullName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        // Danh hiệu nổi bật bên dưới tên
        if (entry.featuredBadgeName != null) ...[
          const SizedBox(height: 4),
          FeaturedBadgeTag(
            badgeName: entry.featuredBadgeName!,
            iconKey: entry.featuredBadgeIcon,
            fontSize: 8,
            iconSize: 10,
          ),
        ],
        const SizedBox(height: 6),
        // Cột chỉ số tương ứng theo bộ lọc
        _buildPodiumMetricTop(entry, sortBy, ext),
        const SizedBox(height: 8),
        // Cột bục xếp hạng
        Container(
          width: 85,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (isMe ? AppColors.accent : rankColor).withValues(alpha: 0.25),
                (isMe ? AppColors.accent : rankColor).withValues(alpha: 0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: (isMe ? AppColors.accent : rankColor).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Highlight top border
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.accent : rankColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isMe ? AppColors.accent : rankColor,
                      ),
                    ),
                    _buildPodiumMetricBottom(entry, sortBy, theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Hiển thị nhãn chỉ số ở phần trên của cột bục vinh quang.
  Widget _buildPodiumMetricTop(LeaderboardEntryModel entry, String sortBy, AppThemeExtension ext) {
    if (sortBy == 'Achievements') {
      return Text(
        '${entry.achievementsCount} Achievements',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
      );
    } else if (sortBy == 'Pet') {
      return Text(
        entry.petLevel > 0 ? 'Pet LV ${entry.petLevel}' : 'No Pet',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: entry.petLevel > 0 ? Colors.cyan : ext.subtext,
        ),
      );
    } else {
      return Text(
        'LV ${entry.level}',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.purpleAccent,
        ),
      );
    }
  }

  /// Hiển thị nhãn chỉ số ở phần dưới của cột bục vinh quang (trong bục).
  Widget _buildPodiumMetricBottom(LeaderboardEntryModel entry, String sortBy, ThemeData theme) {
    if (sortBy == 'Achievements') {
      return Text(
        'Achievements',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    } else if (sortBy == 'Pet') {
      return Text(
        entry.petLevel > 0 ? entry.petName : 'No Pet',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    } else {
      return Text(
        '${entry.expPoints.toInt()} XP',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    }
  }
}
