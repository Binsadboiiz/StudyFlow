import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final ValueChanged<int> onStepChanged;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
    required this.onStepChanged,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;

  // Total steps in the tutorial
  static const int _totalSteps = 8;

  // Content for each tutorial step
  final List<TutorialStepData> _steps = [
    const TutorialStepData(
      tabIndex: 0,
      title: 'Welcome to StudyFlow! 🚀',
      description: 'Your ultimate companion for smart time management, habits tracking, and learning analytics. Let us take a quick 1-minute tour of your new workspace.',
      icon: Icons.school_rounded,
      highlightMessage: 'Press Next to begin the tour',
    ),
    const TutorialStepData(
      tabIndex: 0,
      title: 'Smart Dashboard 📊',
      description: 'Keep track of your learning streak (fire icon), check notifications, plan daily goals, and view calendar tasks all in one unified visual space.',
      icon: Icons.dashboard_rounded,
      highlightMessage: 'Daily targets are shown at the bottom of Home',
    ),
    const TutorialStepData(
      tabIndex: 1,
      title: 'Focus Pomodoro Timer ⏱️',
      description: 'Block out distractions using customized Pomodoro countdown timers. Run focus sessions to level up your habits and generate detailed productivity heatmaps.',
      icon: Icons.hourglass_empty_rounded,
      highlightMessage: 'Start a session to block notifications',
    ),
    const TutorialStepData(
      tabIndex: 2,
      title: 'Task Manager 📝',
      description: 'Create, edit, and organize study tasks, class assignments, and personal checklists. Check off items as you complete them to sync with our database.',
      icon: Icons.assignment_rounded,
      highlightMessage: 'Click the "+" button in the dock to add tasks instantly',
    ),
    const TutorialStepData(
      tabIndex: 3,
      title: 'Weekly Schedule 📅',
      description: 'View your weekly classes and deadlines in a structured timeline. Stay ahead of your curriculum with clear scheduling and auto-syncing calendar routes.',
      icon: Icons.event_note_rounded,
      highlightMessage: 'Drag or swipe to view different dates of the week',
    ),
    const TutorialStepData(
      tabIndex: 4,
      title: 'Quest Hub & Study Pet 🏆',
      description: 'Earn Experience Points (XP) for completing tasks, grow your cute Study Pet, level up, and unlock prestigious achievement badges as milestones.',
      icon: Icons.emoji_events_rounded,
      highlightMessage: 'Check daily and weekly quests for bonus XP!',
    ),
    const TutorialStepData(
      tabIndex: 5,
      title: 'Settings & Customization ⚙️',
      description: 'Customize light/dark visual themes, toggle Low Performance mode (smoother for older devices), review the About page, and access our Privacy Policy documents.',
      icon: Icons.settings_rounded,
      highlightMessage: 'Find the new About and Privacy Policy screens here',
    ),
    const TutorialStepData(
      tabIndex: 0,
      title: 'All Set & Ready! 🎉',
      description: 'You are completely set to establish your learning flow! Complete tasks, maintain your streak, and see your productivity soar with StudyFlow.',
      icon: Icons.auto_awesome_rounded,
      highlightMessage: 'Tap Let\'s Go! to begin your journey',
    ),
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      widget.onStepChanged(_steps[_currentStep].tabIndex);
    } else {
      widget.onComplete();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      widget.onStepChanged(_steps[_currentStep].tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    final currentData = _steps[_currentStep];

    return Material(
      color: Colors.black.withValues(alpha: 0.65), // Dark overlay backdrop
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Overlay content centered
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Interactive Pointer or Highlight Indicator
                  if (_currentStep > 0 && _currentStep < _totalSteps - 1)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                currentData.highlightMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(key: ValueKey('info_tag_$_currentStep'))
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                        const SizedBox(height: 10),
                        const Icon(
                          Icons.arrow_downward_rounded,
                          color: AppColors.accent,
                          size: 32,
                        )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .slideY(begin: 0, end: 0.15, duration: 600.ms, curve: Curves.easeInOut),
                      ],
                    ),
                  const SizedBox(height: 20),
                  
                  // Main Glass Card
                  GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Steps Indicator / Progress bar
                        Row(
                          children: List.generate(
                            _totalSteps,
                            (index) => Expanded(
                              child: Container(
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: index <= _currentStep
                                      ? AppColors.accent
                                      : (isDark ? Colors.white24 : Colors.black12),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Animated icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            currentData.icon,
                            color: AppColors.accent,
                            size: 40,
                          ),
                        )
                        .animate(key: ValueKey('icon_$_currentStep'))
                        .scale(duration: 350.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          currentData.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        )
                        .animate(key: ValueKey('title_$_currentStep'))
                        .fade(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          currentData.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        )
                        .animate(key: ValueKey('desc_$_currentStep'))
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 28),

                        // Navigation Buttons
                        Row(
                          children: [
                            // Skip button (visible on early steps)
                            if (_currentStep < _totalSteps - 1)
                              TextButton(
                                onPressed: widget.onComplete,
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: ext.subtext,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            
                            // Back button (visible after step 0)
                            if (_currentStep > 0) ...[
                              OutlinedButton(
                                onPressed: _prevStep,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: ext.subtext.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Next/Get Started Button
                            ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: AppColors.accent,
                                elevation: 0,
                              ),
                              child: Text(
                                _currentStep == _totalSteps - 1 ? 'Let\'s Go!' : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate(key: ValueKey('card_$_currentStep'))
                  .fade(duration: 300.ms)
                  .slideY(begin: 0.05, end: 0),
                  
                  const Spacer(),
                  // Highlight description for footer navigation bar
                  if (_currentStep > 0 && _currentStep < _totalSteps - 1)
                    Container(
                      margin: const EdgeInsets.only(bottom: 80),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        'Dock switches to relevant section automatically 🪄',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                    .animate()
                    .fade(delay: 500.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialStepData {
  final int tabIndex;
  final String title;
  final String description;
  final IconData icon;
  final String highlightMessage;

  const TutorialStepData({
    required this.tabIndex,
    required this.title,
    required this.description,
    required this.icon,
    required this.highlightMessage,
  });
}
