import SwiftUI
import AppKit

// Hidden preview-render mode: `Pomodoro --render <dir>` writes PNGs of the UI
// and exits. Used for visual verification during development.
if CommandLine.arguments.contains("--render") {
    PreviewRenderer.run()
} else {
    PomodoroApp.main()
}
