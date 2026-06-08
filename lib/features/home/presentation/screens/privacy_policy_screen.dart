import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Last Updated: June 2026',
                style: TextStyle(
                  fontSize: 13,
                  color: ext.subtext,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildIntroSection(context),
            const SizedBox(height: 20),
            Text(
              'Detailed Terms & Sections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildPolicySection(
              context,
              number: '1',
              title: 'Information We Collect',
              description: 'We collect personal information to provide and sync your study flows across devices. This includes:\n\n• Account Credentials: Full name, username, and email address collected via Firebase Authentication.\n• Study Analytics: Saved tasks, calendar events, focus duration logs, learning streaks, XP points, and pet growth records.\n• Device Properties: Diagnostic info and settings toggle selections (e.g. low performance mode) to deliver optimal interface responsiveness.',
            ),
            _buildPolicySection(
              context,
              number: '2',
              title: 'How We Use Your Data',
              description: 'Your information is processed for several essential purposes:\n\n• Service Delivery: Syncing your data securely between local storage and our cloud database.\n• Smart AI Coaching: Leveraging the Google Gemini API (with pgvector storage logic) to analyze learning patterns and generate recommendations.\n• Reminders & Alerts: Scheduling local and push notifications to prompt task lists and streak survival countdowns.',
            ),
            _buildPolicySection(
              context,
              number: '3',
              title: 'Data Security & Storage',
              description: 'We prioritize the safety of your information:\n\n• Security Standards: All server communication uses secure HTTPS protocols with authorized Firebase ID tokens.\n• Storage Protection: Relational databases are guarded behind standard EF Core filters and PostgreSQL secure instances.\n• Offline-First Integrity: Local records are maintained securely in isolated databases on your local hardware.',
            ),
            _buildPolicySection(
              context,
              number: '4',
              title: 'Third-Party Services',
              description: 'StudyFlow connects with specific third-party systems to operate smart features:\n\n• Firebase SDKs: Handles User Auth, Storage assets, and Notification routes.\n• Gemini AI engine: Generates task embeddings and scheduling suggestions. Your learning context is shared under strict security parameters solely for generating customized text outputs.',
            ),
            _buildPolicySection(
              context,
              number: '5',
              title: 'Your Rights & Choices',
              description: 'You have control over your personal data:\n\n• Profile Updates: Modify your name, avatar, and authentication details easily inside the Profile settings.\n• Account Deletion: You can request account deletion at any time, which permanently purges your cloud storage datasets.\n• Notification Preferences: Opt-out of reminders or alert popups directly through setting controls.',
            ),
            _buildPolicySection(
              context,
              number: '6',
              title: 'Contact Information',
              description: 'If you have questions, feedback, or concerns regarding this Privacy Policy document, feel free to reach out to our team:\n\nEmail: npcuonga24101@cusc.ctu.edu.vn\nWebsite: www.studyflow.com/support',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to StudyFlow',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We value your trust and are committed to protecting your personal information and privacy rights. This Privacy Policy details how we collect, process, and safeguard your data when using our mobile app and backend services.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: ext.subtext.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
