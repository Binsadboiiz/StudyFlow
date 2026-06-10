import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studyflow/core/services/notification/local_notification_helper.dart';
import 'package:studyflow/core/widgets/permission_explanation_dialog.dart';
import 'package:studyflow/features/home/presentation/screens/home_screen.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/screens/gamification_hub_screen.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/home/presentation/screens/task_schedule_hub_screen.dart';
import 'package:studyflow/features/home/presentation/screens/settings_screen.dart';
import 'package:studyflow/features/task/presentation/widgets/task_form_modal.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/notification/presentation/viewmodels/notification_viewmodel.dart';
import 'package:studyflow/features/focus/presentation/screens/focus_screen.dart';
import 'package:studyflow/features/scan/presentation/screens/scan_home_screen.dart';
import 'package:studyflow/features/scan/presentation/viewmodels/scan_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyflow/features/home/presentation/widgets/tutorial_overlay.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/core/widgets/initial_loading_screen.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// `MainScreen` is the root screen containing the bottom navigation bar
/// and managing navigation between the main screens of the app.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showTutorial = false;
  
  // Cache screens in RAM to avoid re-constructing them on every build
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      FocusScreen(),
      ScanHomeScreen(),
      TaskScheduleHubScreen(),
      GamificationHubScreen(),
      SettingsScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationViewModel>().fetchNotifications();
      _checkTutorialStatus();
    });
  }

  void _checkTutorialStatus() async {
    final authViewModel = context.read<AuthViewmodel>();
    final userId = authViewModel.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final tutorialShown = prefs.getBool('tutorial_shown_$userId') ?? false;

    if (!tutorialShown && mounted) {
      setState(() {
        _showTutorial = true;
      });
    } else {
      _checkReminderPermissions();
    }
  }

  void _dismissTutorial() async {
    final authViewModel = context.read<AuthViewmodel>();
    final userId = authViewModel.currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_shown_$userId', true);
    }
    if (mounted) {
      setState(() {
        _showTutorial = false;
        _currentIndex = 0; // Return to Home tab
      });
      _checkReminderPermissions();
    }
  }

  void _checkReminderPermissions() async {
    final authViewModel = context.read<AuthViewmodel>();
    final userId = authViewModel.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final explained = prefs.getBool('timezone_permission_explained_$userId') ?? false;
    if (explained) return;

    final isNotificationGranted = await Permission.notification.isGranted;
    bool isAlarmGranted = true;
    if (Platform.isAndroid) {
      isAlarmGranted = await Permission.scheduleExactAlarm.isGranted;
    }

    if ((!isNotificationGranted || !isAlarmGranted) && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionExplanationDialog(
          onGrant: () async {
            Navigator.pop(context);
            await LocalNotificationHelper.requestPermissions();
            if (Platform.isAndroid) {
              await Permission.scheduleExactAlarm.request();
            }
            final p = await SharedPreferences.getInstance();
            await p.setBool('timezone_permission_explained_$userId', true);
          },
          onDismiss: () async {
            Navigator.pop(context);
            final p = await SharedPreferences.getInstance();
            await p.setBool('timezone_permission_explained_$userId', true);
          },
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex.clamp(0, _screens.length - 1);
    final homeViewModel = context.watch<HomeViewModel>();

    return Scaffold(
      extendBody: true, // Content flows behind the floating dock
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          if (_showTutorial)
            TutorialOverlay(
              onComplete: _dismissTutorial,
              onStepChanged: (step) {
                if (mounted) {
                  setState(() {
                    _currentIndex = step;
                  });
                }
              },
            ),
          if (homeViewModel.isLoading)
            const InitialLoadingScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 14.0),
          child: GlassCard(
            borderRadius: 32,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  // Left icon group
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(icon: Icons.grid_view_rounded, label: AppLocalizations.of(context)!.home, index: 0),
                        _buildNavItem(icon: Icons.hourglass_empty_rounded, label: AppLocalizations.of(context)!.focus, index: 1),
                        _buildNavItem(icon: Icons.document_scanner_rounded, label: AppLocalizations.of(context)!.scanTitle, index: 2),
                      ],
                    ),
                  ),
                  
                  // Center Floating Action Button (integrated in dock)
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const TaskFormModal(),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),

                  // Right icon group
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(icon: Icons.assignment_rounded, label: AppLocalizations.of(context)!.tasks, index: 3),
                        _buildNavItem(icon: Icons.emoji_events_rounded, label: AppLocalizations.of(context)!.quest, index: 4),
                        _buildNavItem(icon: Icons.settings_rounded, label: AppLocalizations.of(context)!.settings, index: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to create each button in the dock with a modern scale animation
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unselectedColor = isDark ? Colors.grey.shade500 : const Color.fromARGB(255, 51, 51, 51);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_currentIndex == index) return;
          setState(() {
            _currentIndex = index;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _reloadTabData(index);
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with zoom effect when selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scaleByDouble(isSelected ? 1.2 : 1.0, isSelected ? 1.2 : 1.0, 1.0, 1.0),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accent : unselectedColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            // Tab subtitle
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.accent : unselectedColor,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reloads data for the newly selected tab to ensure synchronization
  void _reloadTabData(int tabIndex) {
    switch (tabIndex) {
      case 0: // Home
        context.read<HomeViewModel>().refreshTasks();
        break;
      case 2: // Scan
        context.read<ScanViewModel>().loadDocuments();
        break;
      case 3: // Tasks & Schedule Hub
        context.read<TaskViewmodel>().loadTask(
          context.read<TaskViewmodel>().selectedDate,
        );
        context.read<ScheduleViewmodel>().loadWeekTasks();
        break;
      case 4: // Quest Hub
        context.read<GamificationViewModel>().refreshAll();
        break;
      case 5: // Settings
        break;
    }
  }
}


