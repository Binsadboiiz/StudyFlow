import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'About StudyFlow',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 16.0,
          bottom: 40.0,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Glowing App Logo Card
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: isDark ? 0.3 : 0.15),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'StudyFlow',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final versionText = snapshot.hasData
                    ? 'Version ${snapshot.data!.version} (Build ${snapshot.data!.buildNumber})'
                    : 'Version 1.0.0 (Build 1)';
                return Text(
                  versionText,
                  style: TextStyle(
                    fontSize: 14,
                    color: ext.subtext,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            
            // Description card
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'StudyFlow is designed to empower students and professionals to unlock their full potential. Through smart scheduling, structured Pomodoro focus sessions, interactive gamified quests, and advanced AI-driven recommendations, we help you master your time, build consistency, and enjoy your learning journey.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Key Features Section Title
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12),
                child: Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // Feature Grid / List
            _buildFeatureTile(
              context,
              icon: Icons.calendar_today_rounded,
              title: 'Smart Scheduler',
              description: 'Organize your classes, studies, tasks, and deadlines in a sleek, customizable view.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.hourglass_top_rounded,
              title: 'Focus Mode',
              description: 'Run customized Pomodoro countdown timers, track focus sessions, and view productivity heatmaps.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.emoji_events_rounded,
              title: 'Gamified Hub',
              description: 'Earn experience points (XP), keep up learning streaks, unlock badges, and level up your study pet companion.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.auto_awesome_rounded,
              title: 'AI Personal Assistant',
              description: 'Scan learning materials using smart OCR and get intelligent study schedules using Google Gemini API.',
            ),
            
            const SizedBox(height: 30),
            // Footer Info
            Text(
              'Made with ❤️ by the Ngnphcng',
              style: TextStyle(
                fontSize: 12,
                color: ext.subtext,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '© 2026 StudyFlow Inc. All rights reserved.',
              style: TextStyle(
                fontSize: 11,
                color: ext.subtext.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: ext.subtext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
