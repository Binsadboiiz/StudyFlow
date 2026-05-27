import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Defers [notifyListeners] to the next frame when called during build/layout
/// or pointer device updates, preventing mouse_tracker assertion failures.
mixin SafeChangeNotifier on ChangeNotifier {
  /// Safely notifies listeners without causing assertion errors during the build phase.
  /// 
  /// If the current scheduler phase is idle, it immediately calls [notifyListeners].
  /// Otherwise, it defers the call to the next frame using a post-frame callback.
  @protected
  void notifyListenersSafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    
    // If the scheduler is idle, it is safe to notify listeners immediately.
    if (phase == SchedulerPhase.idle) {
      notifyListeners();
      return;
    }

    // Defer the notification to the next frame to avoid build-phase exceptions.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }
}
