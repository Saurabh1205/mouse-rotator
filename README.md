# Windows Auto Mouse Rotator (Flutter + Win32 FFI)

An automated Windows utility built with Flutter and Win32 FFI that detects physical user inactivity and automatically rotates the mouse cursor in a smooth circular motion after **4 minutes 30 seconds** (270 seconds).

---

## Key Features

- **Accurate System-Wide Inactivity Detection**: Uses Windows Win32 API (`GetLastInputInfo` and `GetTickCount`) to track real physical user activity (mouse moves, clicks, keyboard strokes).
- **Auto Mouse Rotation**: When no physical user input is detected for 4 minutes 30 seconds, smoothly rotates the mouse cursor in a natural parametric circular orbit and safely restores it.
- **Auto-Reset on Touch**: As soon as you move your physical mouse or press any key, the idle timer immediately resets back to `04:30`.
- **Anti-Sleep / Display Awake**: Calls `SetThreadExecutionState` to prevent Windows from locking the screen, dimming the display, or entering sleep mode.
- **Real-Time Desktop UI**:
  - Circular progress countdown timer displaying time remaining.
  - Live system inactivity duration meter.
  - "Test Rotate Now" button to preview the mouse rotation motion at any time.
  - Start / Pause monitor toggle.
  - Customizable inactivity presets (4m 30s default, 1m, 2m, 5m, 10m).
  - Rotation radius slider (20px – 120px) and speed slider (300ms – 1500ms).
  - Activity log history recording each rotation cycle.

---

## Project Structure

```
mouse_rotator/
├── bin/
│   └── cli_rotator.dart            # Standalone terminal/background runner
├── lib/
│   ├── main.dart                   # Desktop Flutter UI entry point & theme
│   ├── services/
│   │   ├── windows_mouse_service.dart # Win32 FFI bindings (user32 & kernel32)
│   │   └── idle_monitor_service.dart  # Inactivity monitoring & state engine
│   └── widgets/
│       ├── countdown_card.dart     # Circular countdown display & live idle badge
│       ├── controls_card.dart      # Start/stop, test rotate, radius & speed sliders
│       └── stats_card.dart         # Rotation count, timestamps & activity logs
├── test/
│   └── widget_test.dart            # Flutter widget & smoke tests
└── mouse_rotator.exe               # Standalone pre-compiled executable (ready to run)
```

---

## Option 1: Run the Standalone Executable (Ready Now)

A standalone Windows executable has been pre-compiled using Dart's native compiler and is ready to run immediately without needing Visual Studio:

```powershell
cd C:\Users\pinda\.gemini\antigravity\scratch\mouse_rotator
.\mouse_rotator.exe
```

Or you can double-click `mouse_rotator.exe` directly in Windows File Explorer. You can also specify a custom inactivity duration in seconds:
```powershell
.\mouse_rotator.exe 270    # 270 seconds = 4 min 30 sec
```

---

## Option 2: Run the Flutter Desktop UI App

To launch the full graphical Flutter application:

```powershell
cd C:\Users\pinda\.gemini\antigravity\scratch\mouse_rotator
flutter run -d windows
```

### Visual Studio C++ Requirement for Flutter Desktop:
Flutter requires the C++ desktop toolchain to compile native Windows apps. If `flutter run -d windows` prompts for Visual Studio components:
1. Open **Visual Studio Installer** from your Windows Start Menu.
2. Click **Modify** on your Visual Studio 2022 installation.
3. Check **"Desktop development with C++"**.
4. Click **Modify** (bottom right) to install.
5. Run `flutter run -d windows`.

---

## Running Widget Tests

To verify all widgets and state:
```powershell
flutter test
```
