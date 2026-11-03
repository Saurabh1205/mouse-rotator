import 'dart:ffi';
import 'dart:math';
import 'package:ffi/ffi.dart';

/// Win32 LASTINPUTINFO structure to receive tick count of the last input event.
final class LASTINPUTINFO extends Struct {
  @Uint32()
  external int cbSize;

  @Uint32()
  external int dwTime;
}

/// Win32 POINT structure representing cursor coordinates (x, y).
final class POINT extends Struct {
  @Int32()
  external int x;

  @Int32()
  external int y;
}

/// Native Windows API service for detecting user inactivity and controlling mouse motion.
class WindowsMouseService {
  late final DynamicLibrary _user32;
  late final DynamicLibrary _kernel32;

  late final int Function(Pointer<LASTINPUTINFO>) _getLastInputInfo;
  late final int Function() _getTickCount;
  late final int Function(Pointer<POINT>) _getCursorPos;
  late final int Function(int x, int y) _setCursorPos;
  late final void Function(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo) _mouseEvent;
  late final int Function(int esFlags) _setThreadExecutionState;

  bool _initialized = false;

  // Win32 Constants
  static const int mouseEventMove = 0x0001;
  static const int esSystemRequired = 0x00000001;
  static const int esDisplayRequired = 0x00000002;
  static const int esContinuous = 0x80000000;

  WindowsMouseService() {
    _init();
  }

  void _init() {
    if (_initialized) return;

    try {
      _user32 = DynamicLibrary.open('user32.dll');
      _kernel32 = DynamicLibrary.open('kernel32.dll');

      _getLastInputInfo = _user32.lookupFunction<
          Int32 Function(Pointer<LASTINPUTINFO>),
          int Function(Pointer<LASTINPUTINFO>)>('GetLastInputInfo');

      _getTickCount = _kernel32.lookupFunction<
          Uint32 Function(),
          int Function()>('GetTickCount');

      _getCursorPos = _user32.lookupFunction<
          Int32 Function(Pointer<POINT>),
          int Function(Pointer<POINT>)>('GetCursorPos');

      _setCursorPos = _user32.lookupFunction<
          Int32 Function(Int32, Int32),
          int Function(int, int)>('SetCursorPos');

      _mouseEvent = _user32.lookupFunction<
          Void Function(Uint32, Uint32, Uint32, Uint32, IntPtr),
          void Function(int, int, int, int, int)>('mouse_event');

      _setThreadExecutionState = _kernel32.lookupFunction<
          Uint32 Function(Uint32),
          int Function(int)>('SetThreadExecutionState');

      _initialized = true;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to initialize Win32 APIs: $e');
    }
  }

  /// Returns the duration since the user last physically interacted with the system (mouse or keyboard).
  Duration getSystemIdleDuration() {
    if (!_initialized) return Duration.zero;

    final lii = calloc<LASTINPUTINFO>();
    try {
      lii.ref.cbSize = sizeOf<LASTINPUTINFO>();
      final success = _getLastInputInfo(lii);
      if (success == 0) {
        return Duration.zero;
      }

      final currentTick = _getTickCount();
      final lastInputTick = lii.ref.dwTime;

      // Handle 32-bit tick rollover
      final idleMs = (currentTick >= lastInputTick)
          ? (currentTick - lastInputTick)
          : (0xFFFFFFFF - lastInputTick + currentTick);

      return Duration(milliseconds: idleMs);
    } finally {
      calloc.free(lii);
    }
  }

  /// Gets the current cursor position on screen.
  Point<int> getCursorPosition() {
    if (!_initialized) return const Point(0, 0);

    final pt = calloc<POINT>();
    try {
      final success = _getCursorPos(pt);
      if (success != 0) {
        return Point(pt.ref.x, pt.ref.y);
      }
      return const Point(0, 0);
    } finally {
      calloc.free(pt);
    }
  }

  /// Sets cursor position directly.
  void setCursorPosition(int x, int y) {
    if (!_initialized) return;
    _setCursorPos(x, y);
  }

  /// Keeps the system and display awake, preventing sleep / screensaver.
  void setPreventSleep(bool enable) {
    if (!_initialized) return;
    if (enable) {
      _setThreadExecutionState(esContinuous | esSystemRequired | esDisplayRequired);
    } else {
      _setThreadExecutionState(esContinuous);
    }
  }

  /// Performs a smooth circular rotation of the mouse cursor.
  /// [radius]: Circle radius in pixels (default 50px).
  /// [turns]: How many complete 360-degree loops to make (default 1).
  /// [durationMs]: Total duration of the rotation in milliseconds (default 700ms).
  Future<void> rotateMouse({
    int radius = 50,
    int turns = 1,
    int durationMs = 700,
  }) async {
    if (!_initialized) return;

    final original = getCursorPosition();
    final centerX = original.x;
    final centerY = original.y;

    // Determine number of steps
    const int stepDelayMs = 15;
    final totalSteps = max(24, (durationMs / stepDelayMs).round());
    final totalAngle = 2 * pi * turns;
    final angleStep = totalAngle / totalSteps;

    for (int step = 0; step <= totalSteps; step++) {
      final angle = step * angleStep;
      // Parametric circle formula centered at (centerX, centerY)
      // Start at top (0, -radius) for natural circular motion
      final x = (centerX + radius * sin(angle)).round();
      final y = (centerY - radius * cos(angle) + radius).round();

      _setCursorPos(x, y);
      // Dispatch low-level mouse move event to signal activity to Windows OS
      _mouseEvent(mouseEventMove, 0, 0, 0, 0);

      await Future.delayed(const Duration(milliseconds: stepDelayMs));
    }

    // Smoothly return to original position
    _setCursorPos(centerX, centerY);
    _mouseEvent(mouseEventMove, 0, 0, 0, 0);
  }
}
