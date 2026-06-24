import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/theme/theme_provider.dart';
import 'package:studyflow/features/auth/presentation/screens/login_screen.dart';
import 'package:studyflow/features/auth/presentation/screens/register_screen.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/focus/presentation/screens/focus_heatmap_screen.dart';
import 'package:studyflow/features/notification/presentation/screens/notification_screen.dart';
import 'package:studyflow/features/auth/presentation/screens/profile_screen.dart';
import 'package:studyflow/features/auth/presentation/widgets/user_avatar.dart';
import 'package:studyflow/core/providers/performance_provider.dart';
import 'package:studyflow/features/gamification/data/models/gamification_summary_model.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/widgets/featured_badge_tag.dart';
import 'package:studyflow/features/home/presentation/screens/about_screen.dart';
import 'package:studyflow/features/home/presentation/screens/privacy_policy_screen.dart';
import 'package:studyflow/l10n/app_localizations.dart';
import 'package:studyflow/core/providers/language_provider.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/notification/presentation/viewmodels/notification_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/pet_viewmodel.dart';
import 'package:studyflow/features/scan/presentation/viewmodels/scan_viewmodel.dart';
import 'package:studyflow/features/flashcard/presentation/providers/flashcard_provider.dart';

/// `SettingsScreen` is the settings screen of the application.
/// It allows users to view account information, log out, toggle Light/Dark Mode, 
/// and manage various other system settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewmodel>();
    final user = authViewModel.currentUser;
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch gamification summary to show featured badge
    final gamificationVm = context.watch<GamificationViewModel>();
    final summary = gamificationVm.summary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: 100.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user == null) _buildGuestSection(context, theme) else _buildProfileSection(context, user, summary, theme, ext, isDark),
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.generalSettings,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (user != null)
              _buildSettingItem(
                context: context,
                icon: Icons.person_outline_rounded,
                title: AppLocalizations.of(context)!.editProfile,
                subtitle: AppLocalizations.of(context)!.customizeProfileSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            _buildSettingItem(
              context: context,
              icon: Icons.notifications_none_outlined,
              title: AppLocalizations.of(context)!.notifications,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
            _buildSettingItem(
              context: context,
              icon: Icons.bar_chart_rounded,
              title: AppLocalizations.of(context)!.focusHistoryCharts,
              subtitle: AppLocalizations.of(context)!.focusHistorySubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FocusHeatmapScreen()),
                );
              },
            ),
            _buildThemeSettingItem(context),
            _buildPerformanceSettingItem(context),
            _buildLanguageSettingItem(context),
            _buildSettingItem(
              context: context,
              icon: Icons.info_outline_rounded,
              title: AppLocalizations.of(context)!.about,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            _buildSettingItem(
              context: context,
              icon: Icons.policy_outlined,
              title: AppLocalizations.of(context)!.privacyPolicy,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),
            if (user != null) ...[
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await context.read<AuthViewmodel>().logout();

                    if (navigator.mounted) {
                      navigator.context.read<HomeViewModel>().clear();
                      navigator.context.read<TaskViewmodel>().clear();
                      navigator.context.read<ScheduleViewmodel>().clear();
                      navigator.context.read<NotificationViewModel>().clear();
                      navigator.context.read<GamificationViewModel>().clear();
                      navigator.context.read<PetViewModel>().clear();
                      navigator.context.read<ScanViewModel>().clear();
                      navigator.context.read<FlashcardProvider>().clear();
                    }

                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: Text(
                    AppLocalizations.of(context)!.logout,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.account_circle, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'Join StudyFlow',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sync your tasks across devices\nand track your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, dynamic user, GamificationSummaryModel? summary, ThemeData theme, AppThemeExtension ext, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Row(
          children: [
            UserAvatar(
              photoUrl: user.photoUrl,
              radius: 36,
              borderColor: AppColors.accent,
              borderWidth: 2,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (summary?.featuredBadgeName != null)
                        FeaturedBadgeTag(
                          badgeName: summary!.featuredBadgeName!,
                          iconKey: summary.featuredBadgeIcon,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: ext.subtext,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pro Member',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: ext.subtext),
          ],
        ),
      ),
    );
  }

  /// Theme setting item with current mode display and bottom sheet picker
  Widget _buildThemeSettingItem(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    String currentThemeLabel;
    switch (themeProvider.themeMode) {
      case ThemeMode.light:
        currentThemeLabel = AppLocalizations.of(context)!.light;
        break;
      case ThemeMode.dark:
        currentThemeLabel = AppLocalizations.of(context)!.dark;
        break;
      default:
        currentThemeLabel = AppLocalizations.of(context)!.system;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.theme,
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          currentThemeLabel,
          style: TextStyle(fontSize: 13, color: ext.subtext),
        ),
        trailing: Icon(Icons.chevron_right, color: ext.subtext),
        onTap: () => _showThemePicker(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      ),
      ),
      );
  }

  /// Language setting item with current locale display and bottom sheet picker
  Widget _buildLanguageSettingItem(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    String currentLanguageLabel;
    switch (languageProvider.locale.languageCode) {
      case 'vi':
        currentLanguageLabel = 'Tiếng Việt';
        break;
      case 'de':
        currentLanguageLabel = 'Deutsch';
        break;
      default:
        currentLanguageLabel = 'English';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language_outlined,
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
            ),
            title: Text(
              AppLocalizations.of(context)!.language,
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              currentLanguageLabel,
              style: TextStyle(fontSize: 13, color: ext.subtext),
            ),
            trailing: Icon(Icons.chevron_right, color: ext.subtext),
            onTap: () => _showLanguagePicker(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet to pick language
  void _showLanguagePicker(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ext.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.chooseLanguage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                context: context,
                flag: '🇻🇳',
                title: 'Tiếng Việt',
                subtitle: 'Vietnamese',
                locale: const Locale('vi'),
                currentLocale: languageProvider.locale,
                onTap: () {
                  languageProvider.setLocale(const Locale('vi'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                context: context,
                flag: '🇬🇧',
                title: 'English',
                subtitle: 'English',
                locale: const Locale('en'),
                currentLocale: languageProvider.locale,
                onTap: () {
                  languageProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                context: context,
                flag: '🇩🇪',
                title: 'Deutsch',
                subtitle: 'German',
                locale: const Locale('de'),
                currentLocale: languageProvider.locale,
                onTap: () {
                  languageProvider.setLocale(const Locale('de'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String flag,
    required String title,
    required String subtitle,
    required Locale locale,
    required Locale currentLocale,
    required VoidCallback onTap,
  }) {
    final isSelected = locale.languageCode == currentLocale.languageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ext = theme.extension<AppThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.1)
              : isDark ? AppColors.surfaceDark : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : isDark ? AppColors.cardDark : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                flag,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.accent : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: ext.subtext,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet to pick theme mode
  void _showThemePicker(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ext.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.chooseTheme,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context: context,
                icon: Icons.light_mode_rounded,
                title: AppLocalizations.of(context)!.light,
                subtitle: AppLocalizations.of(context)!.lightThemeSubtitle,
                mode: ThemeMode.light,
                currentMode: themeProvider.themeMode,
                onTap: () {
                  themeProvider.setTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context: context,
                icon: Icons.dark_mode_rounded,
                title: AppLocalizations.of(context)!.dark,
                subtitle: AppLocalizations.of(context)!.darkThemeSubtitle,
                mode: ThemeMode.dark,
                currentMode: themeProvider.themeMode,
                onTap: () {
                  themeProvider.setTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context: context,
                icon: Icons.settings_suggest_rounded,
                title: AppLocalizations.of(context)!.system,
                subtitle: AppLocalizations.of(context)!.systemThemeSubtitle,
                mode: ThemeMode.system,
                currentMode: themeProvider.themeMode,
                onTap: () {
                  themeProvider.setTheme(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ext = theme.extension<AppThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.1)
              : isDark ? AppColors.surfaceDark : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : isDark ? AppColors.cardDark : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accent : ext.subtext,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.accent : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: ext.subtext,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.onSurface, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: ext.subtext),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: ext.subtext),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      ),
      ),
      );
  }

  /// Toggle setting item for Low Performance Mode (smooth rendering for older devices)
  Widget _buildPerformanceSettingItem(BuildContext context) {
    final perfProvider = context.watch<PerformanceProvider>();
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.speed_rounded,
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
            ),
            title: Text(
              AppLocalizations.of(context)!.lowPerformanceMode,
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.lowPerformanceSubtitle,
              style: TextStyle(fontSize: 13, color: ext.subtext),
            ),
            value: perfProvider.isLowPerformance,
            activeThumbColor: AppColors.accent,
            onChanged: (bool value) {
              perfProvider.setLowPerformanceMode(value);
            },
          ),
        ),
      ),
    );
  }
}
