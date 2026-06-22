import SwiftUI
import AppKit

/// Renders the UI to PNG files for visual verification (`--render` mode).
enum PreviewRenderer {
    @MainActor
    static func run() {
        let outDir = outputDirectory()
        let settings = PomodoroSettings()

        renderPopover(name: "popover-focus", settings: settings) {
            $0.applyPreview(session: .focus, remaining: 16 * 60 + 12, running: true, completedFocus: 1)
        }
        renderPopover(name: "popover-break", settings: settings) {
            $0.applyPreview(session: .shortBreak, remaining: 3 * 60 + 45, running: false, completedFocus: 2)
        }

        let settingsView = SettingsView(settings: settings, onChange: {})
        render(view: settingsView, name: "settings", into: outDir)

        // Floating always-on-top panel
        let floatTimer = PomodoroTimer(settings: settings, notifier: NotificationService())
        floatTimer.applyPreview(session: .focus, remaining: 18 * 60 + 30, running: true, completedFocus: 2)
        render(view: FloatingTimerView(timer: floatTimer), name: "floating", into: outDir)

        // Stats with sample data (isolated defaults so real data isn't touched)
        let sampleStats = StatsStore(defaults: UserDefaults(suiteName: "preview-stats")!)
        let cal = Calendar.current
        for offset in [0, 0, 0, 1, 2, 3, 3, 10, 15, 20] {
            let day = cal.date(byAdding: .day, value: -offset, to: Date())!
            sampleStats.recordFocus(minutes: 25, at: day)
        }
        render(view: StatsView(stats: sampleStats), name: "stats", into: outDir)
        UserDefaults.standard.removePersistentDomain(forName: "preview-stats")

        print("Rendered previews to \(outDir.path)")
        exit(0)
    }

    @MainActor
    private static func renderPopover(
        name: String,
        settings: PomodoroSettings,
        configure: (PomodoroTimer) -> Void
    ) {
        let timer = PomodoroTimer(settings: settings, notifier: NotificationService())
        configure(timer)
        let view = MenuContentView(timer: timer, settings: settings)
        render(view: view, name: name, into: outputDirectory())
    }

    @MainActor
    private static func render<V: View>(view: V, name: String, into dir: URL) {
        // Dark base stands in for the system's vibrant menu-bar material,
        // which ImageRenderer cannot rasterize.
        let wrapped = view
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
            .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: wrapped)
        renderer.scale = 2.0
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            print("Failed to render \(name)")
            return
        }
        let url = dir.appendingPathComponent("\(name).png")
        try? png.write(to: url)
    }

    private static func outputDirectory() -> URL {
        let args = CommandLine.arguments
        if let idx = args.firstIndex(of: "--render"), idx + 1 < args.count {
            return URL(fileURLWithPath: args[idx + 1], isDirectory: true)
        }
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
}
