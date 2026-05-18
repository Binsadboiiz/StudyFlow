import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Defers [notifyListeners] to the next frame when called during build/layout
/// or pointer device updates, preventing mouse_tracker assertion failures.
mixin SafeChangeNotifier on ChangeNotifier {
  @protected
  void notifyListenersSafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle) {
      notifyListeners();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }
}
