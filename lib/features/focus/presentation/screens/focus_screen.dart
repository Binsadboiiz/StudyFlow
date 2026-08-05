import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/focus/data/repositories/focus_repository.dart';
import 'package:studyflow/features/focus/data/models/focus_session_model.dart';
import 'package:studyflow/features/focus/presentation/screens/focus_heatmap_screen.dart';
import 'package:studyflow/l10n/app_localizations.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  static bool isTimerActive = false;
  static VoidCallback? onResetTimer;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FocusRepository _repository = FocusRepository();

  // Custom Timer State
  int _customMinutes = 30;

  // Pomodoro State (Default 25-5)
  final int _pomodoroWorkMinutes = 25;
  final int _pomodoroRestMinutes = 5;

  bool _isRunning = false;
  bool _isResting = false;
  int _secondsRemaining = 0;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  DateTime? _startTime;
  int _previousTabIndex = 0;
  bool _isReverting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _secondsRemaining = _customMinutes * 60;
    _previousTabIndex = _tabController.index;
    FocusScreen.onResetTimer = _resetTimer;
  }

  /// Triggers when the user switches between "Custom" and "Pomodoro" timer tabs.
  /// Sets initial remaining seconds depending on the selected tab.
  void _onTabChanged() {
    if (_isReverting) {
      return;
    }

    if (_tabController.index == _previousTabIndex) return;

    if (_isRunning) {
      final targetIndex = _tabController.index;

      // Revert immediately to keep UI in sync while the dialog is open
      _isReverting = true;
      _tabController.index = _previousTabIndex;
      _isReverting = false;

      // Show confirmation dialog
      _showTabSwitchConfirmationDialog(targetIndex);
    } else {
      setState(() {
        _previousTabIndex = _tabController.index;
        _isResting = false;
        if (_tabController.index == 0) {
          _secondsRemaining = _customMinutes * 60;
        } else {
          _secondsRemaining = _pomodoroWorkMinutes * 60;
        }
      });
    }
  }

  void _showTabSwitchConfirmationDialog(int targetIndex) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.focusChangeModeTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(localizations.focusChangeModeDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.cancel,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
              setState(() {
                _previousTabIndex = targetIndex;
                _isReverting = true;
                _tabController.index = targetIndex;
                _isReverting = false;

                _isResting = false;
                if (targetIndex == 0) {
                  _secondsRemaining = _customMinutes * 60;
                } else {
                  _secondsRemaining = _pomodoroWorkMinutes * 60;
                }
              });
            },
            child: Text(
              localizations.yes,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Toggles the timer state between running and stopped.
  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  /// Starts the focus session timer.
  /// Spawns a periodic 1-second interval Timer that decrements remaining seconds.
  void _startTimer() {
    setState(() {
      _isRunning = true;
      FocusScreen.isTimerActive = true;
      _startTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _onTimerComplete();
        }
      });
    });
  }

  /// Stops the active timer and cancels the periodic tick task.
  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      FocusScreen.isTimerActive = false;
    });
    // In a real app, you might want to log this interrupted session to the backend here
  }

  /// Resets the timer and stops it if running.
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      FocusScreen.isTimerActive = false;
      if (_tabController.index == 0) {
        _secondsRemaining = _customMinutes * 60;
      } else {
        _isResting = false;
        _secondsRemaining = _pomodoroWorkMinutes * 60;
      }
    });
  }

  /// Triggers when the timer successfully runs down to zero.
  /// If it was a work/focus session (not rest), it saves the completed focus session metadata to the backend.
  /// For Pomodoro tab, it switches state between Focus and Rest; for Custom tab, it resets to original custom duration.
  void _onTimerComplete() async {
    setState(() {
      _isRunning = false;
      FocusScreen.isTimerActive = false;
    });

    // Play completed sound effect
    try {
      await _audioPlayer.play(AssetSource('sounds/complete.wav'));
    } catch (e) {
      debugPrint('Error playing completion sound: $e');
    }

    if (!_isResting && _startTime != null) {
      final duration = _tabController.index == 0
          ? _customMinutes
          : _pomodoroWorkMinutes;
      final mode = _tabController.index == 0 ? "Custom" : "Pomodoro";

      final session = FocusSessionModel(
        id: '', // Generated by backend
        userId: '', // Set by backend based on token
        startTime: _startTime!,
        endTime: DateTime.now(),
        durationMinutes: duration,
        mode: mode,
        createdAt: DateTime.now(),
      );

      await _repository.saveFocusSession(session);
    }

    if (!mounted) return;

    if (_tabController.index == 1) {
      // Pomodoro Mode
      setState(() {
        if (_isResting) {
          _isResting = false;
          _secondsRemaining = _pomodoroWorkMinutes * 60;
        } else {
          _isResting = true;
          _secondsRemaining = _pomodoroRestMinutes * 60;
        }
      });
    } else {
      // Custom Mode
      setState(() {
        _secondsRemaining = _customMinutes * 60;
      });
    }
  }

  /// Format seconds remaining to standard MM:SS string representation.
  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    int totalSeconds;
    if (_tabController.index == 0) {
      totalSeconds = _customMinutes * 60;
    } else {
      totalSeconds = _isResting
          ? _pomodoroRestMinutes * 60
          : _pomodoroWorkMinutes * 60;
    }
    return 1.0 - (_secondsRemaining / totalSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _audioPlayer.dispose();
    FocusScreen.isTimerActive = false;
    if (FocusScreen.onResetTimer == _resetTimer) {
      FocusScreen.onResetTimer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    Widget content = Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48), // Balance for centering
              Text(
                AppLocalizations.of(context)!.focusMode,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.bar_chart_rounded,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: AppLocalizations.of(context)!.focusAnalytics,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FocusHeatmapScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: GlassCard(
            padding: const EdgeInsets.all(4),
            borderRadius: 30,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.accent,
              ),
              splashBorderRadius: BorderRadius.circular(30),
              labelColor: Colors.white,
              unselectedLabelColor: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.85),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.custom),
                Tab(text: AppLocalizations.of(context)!.pomodoro),
              ],
            ),
          ),
        ),

        if (isLandscape) const SizedBox(height: 30) else const Spacer(),

        // Timer Display
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer animated glow ring
            if (_isRunning)
              Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds,
                  )
                  .fade(begin: 0.5, end: 1.0, duration: 1.seconds)
                  .then()
                  .scale(
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(0.9, 0.9),
                    duration: 2.seconds,
                  )
                  .fade(begin: 1.0, end: 0.5, duration: 1.seconds),

            // Circular Progress Indicator
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 12,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.15,
                ),
                color: _isResting ? Colors.blueAccent : AppColors.accent,
                strokeCap: StrokeCap.round,
              ),
            ),

            // Time Text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formattedTime,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (_tabController.index == 1)
                  Text(
                    _isResting
                        ? AppLocalizations.of(context)!.rest
                        : AppLocalizations.of(context)!.focusLabel,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: _isResting
                          ? Colors.blueAccent
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),

        if (isLandscape) const SizedBox(height: 30) else const Spacer(),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Minus Button or Spacer
            if (_tabController.index == 0)
              (!_isRunning
                  ? IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: theme.colorScheme.onSurface,
                        size: 32,
                      ),
                      onPressed: () {
                        if (_customMinutes > 5) {
                          setState(() {
                            _customMinutes -= 5;
                            _secondsRemaining = _customMinutes * 60;
                          });
                        }
                      },
                    )
                  : const SizedBox(width: 48))
            else
              const SizedBox(width: 48),

            const SizedBox(width: 16),

            // 2. Reset Button or Spacer
            // Show when timer is running or has been modified/paused
            ((_isRunning ||
                    _secondsRemaining !=
                        (_tabController.index == 0
                            ? _customMinutes * 60
                            : (_isResting
                                  ? _pomodoroRestMinutes * 60
                                  : _pomodoroWorkMinutes * 60)))
                ? IconButton(
                    icon: Icon(
                      Icons.replay_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 32,
                    ),
                    tooltip: "Reset",
                    onPressed: _resetTimer,
                  )
                : const SizedBox(width: 48)),

            const SizedBox(width: 16),

            // 3. Play/Stop Button
            GestureDetector(
              onTap: _toggleTimer,
              child: GlassCard(
                borderRadius: 40,
                padding: const EdgeInsets.all(20),
                color: _isRunning ? Colors.red.shade600 : AppColors.accent,
                opacity:
                    0.95, // High opacity to prevent it from looking washed out
                child: Icon(
                  _isRunning
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 4. Spacer to balance the Reset button on the left (so Play remains centered)
            const SizedBox(width: 48),

            const SizedBox(width: 16),

            // 5. Plus Button or Spacer
            if (_tabController.index == 0)
              (!_isRunning
                  ? IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: theme.colorScheme.onSurface,
                        size: 32,
                      ),
                      onPressed: () {
                        if (_customMinutes < 120) {
                          setState(() {
                            _customMinutes += 5;
                            _secondsRemaining = _customMinutes * 60;
                          });
                        }
                      },
                    )
                  : const SizedBox(width: 48))
            else
              const SizedBox(width: 48),
          ],
        ),

        SizedBox(height: isLandscape ? 20 : 100),
      ],
    );

    if (isLandscape) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: content,
      ),
    );
  }
}
