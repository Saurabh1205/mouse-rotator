import 'dart:async';
import 'package:flutter/foundation.dart';
import 'windows_mouse_service.dart';

class RotationLogEntry {
  final DateTime timestamp;
  final Duration idleDuration;
  final bool isManualTest;

  RotationLogEntry({
    required this.timestamp,
    required this.idleDuration,
    this.isManualTest = false,
  });
}

class IdleMonitorService extends ChangeNotifier {
  final WindowsMouseService _mouseService;

  Timer? _ticker;
  bool _isMonitoring = true;
  bool _isRotating = false;

  // Settings
  Duration _threshold = const Duration(minutes: 4, seconds: 30); // 4 min 30 sec
  int _circleRadius = 45; // pixels
  int _rotationSpeedMs = 650; // duration in ms
  bool _preventSleep = true;

  // Real-time State
  Duration _currentSystemIdle = Duration.zero;
  int _remainingSeconds = 270;
  int _totalRotations = 0;
  DateTime? _lastRotatedAt;
  final List<RotationLogEntry> _recentLogs = [];

  IdleMonitorService({WindowsMouseService? mouseService})
      : _mouseService = mouseService ?? WindowsMouseService() {
    _mouseService.setPreventSleep(_preventSleep);
    _startTicker();
  }

  // Getters
  bool get isMonitoring => _isMonitoring;
  bool get isRotating => _isRotating;
  Duration get threshold => _threshold;
  int get circleRadius => _circleRadius;
  int get rotationSpeedMs => _rotationSpeedMs;
  bool get preventSleep => _preventSleep;
  Duration get currentSystemIdle => _currentSystemIdle;
  int get remainingSeconds => _remainingSeconds;
  int get totalRotations => _totalRotations;
  DateTime? get lastRotatedAt => _lastRotatedAt;
  List<RotationLogEntry> get recentLogs => List.unmodifiable(_recentLogs);

  double get progress {
    final total = _threshold.inSeconds;
    if (total == 0) return 0.0;
    final elapsed = total - _remainingSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  String get formattedRemainingTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedIdleTime {
    final secs = _currentSystemIdle.inSeconds;
    if (secs < 60) {
      return '${secs}s';
    }
    final mins = secs ~/ 60;
    final remSecs = secs % 60;
    return '${mins}m ${remSecs}s';
  }

  void setThreshold(Duration duration) {
    _threshold = duration;
    notifyListeners();
  }

  void setCircleRadius(int radius) {
    _circleRadius = radius;
    notifyListeners();
  }

  void setRotationSpeedMs(int speedMs) {
    _rotationSpeedMs = speedMs;
    notifyListeners();
  }

  void setPreventSleep(bool enable) {
    _preventSleep = enable;
    _mouseService.setPreventSleep(enable);
    notifyListeners();
  }

  void toggleMonitoring() {
    _isMonitoring = !_isMonitoring;
    if (!_isMonitoring) {
      _remainingSeconds = _threshold.inSeconds;
    }
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (!_isMonitoring) {
      return;
    }

    _currentSystemIdle = _mouseService.getSystemIdleDuration();
    final thresholdSecs = _threshold.inSeconds;
    final idleSecs = _currentSystemIdle.inSeconds;

    if (idleSecs < thresholdSecs) {
      // User has been active recently. Remaining time is threshold minus idle time.
      _remainingSeconds = thresholdSecs - idleSecs;
    } else {
      // User is idle beyond threshold!
      final now = DateTime.now();
      if (_lastRotatedAt == null) {
        // First time hitting threshold
        _triggerAutoRotation();
      } else {
        final secondsSinceLastRotation = now.difference(_lastRotatedAt!).inSeconds;
        if (secondsSinceLastRotation >= thresholdSecs) {
          // Trigger subsequent periodic rotation
          _triggerAutoRotation();
        } else {
          // Countdown until next periodic rotation while user remains idle
          _remainingSeconds = thresholdSecs - secondsSinceLastRotation;
        }
      }
    }

    notifyListeners();
  }

  Future<void> _triggerAutoRotation() async {
    if (_isRotating) return;

    _isRotating = true;
    _remainingSeconds = 0;
    notifyListeners();

    try {
      await _mouseService.rotateMouse(
        radius: _circleRadius,
        turns: 1,
        durationMs: _rotationSpeedMs,
      );

      _totalRotations++;
      _lastRotatedAt = DateTime.now();
      _recentLogs.insert(
        0,
        RotationLogEntry(
          timestamp: _lastRotatedAt!,
          idleDuration: _currentSystemIdle,
          isManualTest: false,
        ),
      );
      if (_recentLogs.length > 20) {
        _recentLogs.removeLast();
      }
    } finally {
      _isRotating = false;
      _remainingSeconds = _threshold.inSeconds;
      notifyListeners();
    }
  }

  /// Manually tests mouse rotation immediately (without waiting for idle timer).
  Future<void> testRotateNow() async {
    if (_isRotating) return;

    _isRotating = true;
    notifyListeners();

    try {
      await _mouseService.rotateMouse(
        radius: _circleRadius,
        turns: 1,
        durationMs: _rotationSpeedMs,
      );

      _recentLogs.insert(
        0,
        RotationLogEntry(
          timestamp: DateTime.now(),
          idleDuration: _currentSystemIdle,
          isManualTest: true,
        ),
      );
      if (_recentLogs.length > 20) {
        _recentLogs.removeLast();
      }
    } finally {
      _isRotating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _mouseService.setPreventSleep(false);
    super.dispose();
  }
}
