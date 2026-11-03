// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:ffi/ffi.dart';

final class LASTINPUTINFO extends Struct {
  @Uint32()
  external int cbSize;

  @Uint32()
  external int dwTime;
}

final class POINT extends Struct {
  @Int32()
  external int x;

  @Int32()
  external int y;
}

void main(List<String> args) async {
  print('====================================================');
  print('          Windows Auto Mouse Rotator               ');
  print('====================================================');

  // Inactivity threshold: default 4 min 30 sec (270 seconds)
  int thresholdSeconds = 270;
  if (args.isNotEmpty) {
    final parsed = int.tryParse(args[0]);
    if (parsed != null && parsed > 0) {
      thresholdSeconds = parsed;
    }
  }

  print('Threshold: $thresholdSeconds seconds (${thresholdSeconds ~/ 60}m ${thresholdSeconds % 60}s)');
  print('Monitoring physical mouse/keyboard activity...');
  print('Press Ctrl+C to exit.\n');

  final user32 = DynamicLibrary.open('user32.dll');
  final kernel32 = DynamicLibrary.open('kernel32.dll');

  final getLastInputInfo = user32.lookupFunction<
      Int32 Function(Pointer<LASTINPUTINFO>),
      int Function(Pointer<LASTINPUTINFO>)>('GetLastInputInfo');

  final getTickCount = kernel32.lookupFunction<
      Uint32 Function(),
      int Function()>('GetTickCount');

  final getCursorPos = user32.lookupFunction<
      Int32 Function(Pointer<POINT>),
      int Function(Pointer<POINT>)>('GetCursorPos');

  final setCursorPos = user32.lookupFunction<
      Int32 Function(Int32, Int32),
      int Function(int, int)>('SetCursorPos');

  final mouseEvent = user32.lookupFunction<
      Void Function(Uint32, Uint32, Uint32, Uint32, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');

  final setThreadExecutionState = kernel32.lookupFunction<
      Uint32 Function(Uint32),
      int Function(int)>('SetThreadExecutionState');

  // Prevent sleep / screensaver while running
  setThreadExecutionState(0x80000000 | 0x00000001 | 0x00000002);

  int rotationsCount = 0;
  DateTime? lastRotation;
  bool isRotating = false;

  final lii = calloc<LASTINPUTINFO>();
  lii.ref.cbSize = sizeOf<LASTINPUTINFO>();

  final pt = calloc<POINT>();

  Timer.periodic(const Duration(milliseconds: 500), (timer) async {
    if (isRotating) return;

    getLastInputInfo(lii);
    final currentTick = getTickCount();
    final lastInput = lii.ref.dwTime;

    final idleMs = (currentTick >= lastInput)
        ? (currentTick - lastInput)
        : (0xFFFFFFFF - lastInput + currentTick);

    final idleSecs = idleMs ~/ 1000;
    int remainingSecs = max(0, thresholdSeconds - idleSecs);

    final now = DateTime.now();

    if (idleSecs >= thresholdSeconds) {
      if (lastRotation == null ||
          now.difference(lastRotation!).inSeconds >= thresholdSeconds) {
        // Trigger smooth circular rotation!
        isRotating = true;
        rotationsCount++;
        stdout.write('\r[ACTION] Rotating mouse cursor (Cycle #$rotationsCount)...          \n');

        getCursorPos(pt);
        final originX = pt.ref.x;
        final originY = pt.ref.y;
        const radius = 50;
        const steps = 30;

        for (int i = 0; i <= steps; i++) {
          final angle = (i / steps) * 2 * pi;
          final x = (originX + radius * sin(angle)).round();
          final y = (originY - radius * cos(angle) + radius).round();
          setCursorPos(x, y);
          mouseEvent(0x0001, 0, 0, 0, 0); // MOUSEEVENTF_MOVE
          await Future.delayed(const Duration(milliseconds: 15));
        }

        setCursorPos(originX, originY);
        mouseEvent(0x0001, 0, 0, 0, 0);

        lastRotation = DateTime.now();
        isRotating = false;
        remainingSecs = thresholdSeconds;
      } else {
        remainingSecs = thresholdSeconds - now.difference(lastRotation!).inSeconds;
      }
    }

    final remMin = (remainingSecs ~/ 60).toString().padLeft(2, '0');
    final remSec = (remainingSecs % 60).toString().padLeft(2, '0');

    stdout.write(
      '\r[STATUS] Idle: ${idleSecs}s | Next Rotate in: $remMin:$remSec | Rotations: $rotationsCount  ',
    );
  });
}
