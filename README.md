# Windows Auto Mouse Rotator 🖱️🔄

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white)](https://github.com/Saurabh1205/mouse-rotator)
[![Flutter](https://img.shields.io/badge/Flutter-3.41%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![GitHub Release](https://img.shields.io/github/v/release/Saurabh1205/mouse-rotator?color=success&logo=github)](https://github.com/Saurabh1205/mouse-rotator/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An automated Windows utility built with **Flutter** and **Win32 FFI** that monitors physical user activity and automatically rotates the mouse cursor in a smooth circular motion after **4 minutes 30 seconds** (270 seconds) of inactivity.

---

## 🚀 Quick Download (No Installation Needed)

If you just want to run the application right away on Windows without installing Flutter or developer tools:

1. Download the latest standalone executable from **[GitHub Releases](https://github.com/Saurabh1205/mouse-rotator/releases/latest)**:
   - 📦 **[Download mouse_rotator.exe](https://github.com/Saurabh1205/mouse-rotator/releases/latest/download/mouse_rotator.exe)**
2. Double-click `mouse_rotator.exe` to run.

---

## ✨ Features

- **Accurate System-Wide Inactivity Detection**: Uses Windows Win32 APIs (`GetLastInputInfo` and `GetTickCount`) via `dart:ffi` to track real physical user activity (mouse moves, clicks, keyboard strokes across any app).
- **Auto Mouse Rotation**: If no physical user input occurs for 4 minutes 30 seconds (270s), the cursor automatically performs a smooth parametric 360° circular orbit and returns to its starting point.
- **Instant Reset on Touch**: As soon as you move your mouse physically or press any key, the timer immediately resets back to `04:30`.
- **Display & Screen Sleep Prevention**: Leverages Win32 `SetThreadExecutionState` to prevent Windows from locking, dimming the screen, or entering sleep mode.
- **Modern Desktop UI**:
  - Circular countdown timer displaying remaining time.
  - Live system inactivity duration meter.
  - **"Test Rotate Now"** button to preview cursor motion immediately.
  - Start / Pause monitoring toggle.
  - Customizable inactivity presets (`4m 30s` default, `1m`, `2m`, `5m`, `10m`).
  - Adjustable orbit radius (`20px` – `120px`) and animation speed sliders.
  - Real-time activity log tracking past rotation cycles with timestamps.

---

## 🛠️ Project Structure

```
mouse-rotator/
├── bin/
│   └── cli_rotator.dart            # Standalone background/CLI runner
├── lib/
│   ├── main.dart                   # Desktop Flutter UI entry point & dark theme
│   ├── services/
│   │   ├── windows_mouse_service.dart # Win32 FFI bindings (user32 & kernel32)
│   │   └── idle_monitor_service.dart  # Inactivity monitoring & state engine
│   └── widgets/
│       ├── countdown_card.dart     # Circular countdown & live user idle badge
│       ├── controls_card.dart      # Controls, test rotate, radius & speed sliders
│       └── stats_card.dart         # Rotation count, timestamps & activity logs
├── test/
│   └── widget_test.dart            # Flutter widget & smoke tests
├── mouse_rotator.exe               # Pre-compiled standalone executable
└── pubspec.yaml
```

---

## 💻 Building from Source

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (v3.24+ recommended)
- Windows 10 or Windows 11
- Visual Studio 2022 with the **"Desktop development with C++"** workload (required for Flutter Windows apps).

### 1. Clone the Repository

```bash
git clone https://github.com/Saurabh1205/mouse-rotator.git
cd mouse-rotator
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the Flutter Desktop App

```bash
flutter run -d windows
```

### 4. Build a Release Executable

```bash
flutter build windows --release
```
The compiled output will be generated in `build/windows/x64/runner/Release/`.

---

## ⚙️ Compiling the Standalone CLI Runner

You can also compile the standalone, single-file `.exe` directly using Dart:

```bash
dart compile exe bin/cli_rotator.dart -o mouse_rotator.exe
```

Run with custom threshold (in seconds):
```bash
./mouse_rotator.exe 270    # 270 seconds = 4 min 30 sec
```

---

## 🧪 Running Tests

```bash
flutter test
```

---

## 📄 License

This project is open-source and licensed under the [MIT License](LICENSE).
