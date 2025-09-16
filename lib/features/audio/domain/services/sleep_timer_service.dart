import 'dart:async';

typedef SleepTimerCallback = void Function(int minutes);

class SleepTimerService {
  Timer? _timer;
  int? _minutes;

  bool get isActive => _timer != null;
  int? get minutes => _minutes;

  void startTimer({
    required int minutes,
    required SleepTimerCallback onTimerComplete,
  }) {
    cancelTimer();
    _minutes = minutes;
    _timer = Timer(Duration(minutes: minutes), () {
      final completedMinutes = _minutes ?? minutes;
      _timer = null;
      _minutes = null;
      onTimerComplete(completedMinutes);
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _minutes = null;
  }

  void dispose() {
    cancelTimer();
  }
}
