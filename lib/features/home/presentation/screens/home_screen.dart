import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/auth/presentation/widgets/user_avatar.dart';
import '../widgets/home_calendar.dart';
import '../widgets/daily_goal_list.dart';
import 'package:studyflow/features/streak/presentation/screens/streak_screen.dart';
import 'package:studyflow/features/notification/presentation/screens/notification_screen.dart';
import 'package:studyflow/features/notification/presentation/viewmodels/notification_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/widgets/featured_badge_tag.dart';

/// The main screen of the application (View in MVVM).
/// Its only responsibility is to compose smaller widgets together
/// to form a complete screen, without containing complex business logic here.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewmodel>().currentUser;
    final displayName = user?.fullName ?? 'Guest';
    final streak = user?.streak ?? 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch gamification summary to show featured badge
    final gamificationVm = context.watch<GamificationViewModel>();
    final summary = gamificationVm.summary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar:
          true, // Allows the background to extend behind the AppBar
      // Modern AppBar with Glassmorphism effect
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.2),
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: UserAvatar(
                photoUrl: user?.photoUrl,
                radius: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have a good day,',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        '$displayName 👋',
                        style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (summary?.featuredBadgeName != null)
                        FeaturedBadgeTag(
                          badgeName: summary!.featuredBadgeName!,
                          iconKey: summary.featuredBadgeIcon,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StreakScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer<NotificationViewModel>(
              builder: (context, notificationVm, child) {
                final hasNotifications = notificationVm.notifications.isNotEmpty;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_none_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    if (hasNotifications)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.black : Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // Main content: Entire scrollable screen (Calendar + Task list)
      body: Container(
        color: Colors.transparent,
        child: SafeArea(
          bottom:
              false, // No need to set SafeArea for bottom because extendBody is true
          child: CustomScrollView(
            slivers: [
              // Spacer to push content down below the AppBar
              const SliverToBoxAdapter(child: SizedBox(height: 70)),
              // 1. Calendar display widget
              const SliverToBoxAdapter(child: HomeCalendar()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              // 2. Daily goal list display widget
              // Use SliverFillRemaining with hasScrollBody: false so DailyGoalList
              // occupies the remaining space and scrolls with the Calendar
              const SliverToBoxAdapter(child: DailyGoalList()),
            ],
          ),
        ),
      ),
    );
  }
}
