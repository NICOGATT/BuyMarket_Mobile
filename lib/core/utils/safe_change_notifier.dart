import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class SafeChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;
  bool _notificationQueued = false;

  @override
  void notifyListeners() {
    if (_isDisposed) return;

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (_notificationQueued) return;

      _notificationQueued = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _notificationQueued = false;
        if (!_isDisposed) {
          super.notifyListeners();
        }
      });
      return;
    }

    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
