# Pomodoro 🍅

A lightweight native macOS **menu-bar** Pomodoro timer, built with SwiftUI's `MenuBarExtra`.
No dock icon, no window clutter — it lives entirely in your menu bar.

## Features

- **Focus / Short Break / Long Break** cycle with automatic transitions
- Live countdown shown in the menu bar while running
- Circular progress ring with the current session color
- Cycle dots showing focus sessions completed before the next long break
- Start / Pause / Reset / Skip controls
- Local notification + sound (`Glass`) when a session ends
- Configurable durations, cycle length, auto-start, and sound
- Settings persisted via `UserDefaults`
- Drift-free timing (uses a wall-clock deadline, not tick accumulation)

## Requirements

- macOS 14 (Sonoma) or later
- Swift 6 toolchain / Xcode 16+

## Build & Run

```bash
./scripts/build-app.sh release
open Pomodoro.app
```

This produces a self-contained, ad-hoc-signed `Pomodoro.app`. To launch automatically
at login, add it under **System Settings → General → Login Items**.

For quick iteration during development:

```bash
swift build && swift run
```

## Project Layout

```
Sources/Pomodoro/
├── PomodoroApp.swift          # @main App + MenuBarExtra + menu-bar label
├── Models/
│   ├── SessionType.swift      # focus / shortBreak / longBreak + styling
│   └── PomodoroSettings.swift # persisted user preferences
├── Timer/
│   └── PomodoroTimer.swift    # countdown engine + session transitions
├── Services/
│   └── NotificationService.swift  # local notifications + sound
└── Views/
    ├── MenuContentView.swift  # popover UI (ring, controls, footer)
    └── SettingsView.swift     # durations & behavior sheet
```

## Notes

- The first run prompts for notification permission. Sound plays regardless via `NSSound`.
- If the menu bar is full, the icon may hide behind the `›` overflow chevron — standard macOS behavior.
