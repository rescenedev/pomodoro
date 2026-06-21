import SwiftUI
import UniformTypeIdentifiers

/// Sound selection: built-in picker, live preview, and custom-file chooser.
struct SoundSettingsSection: View {
    @ObservedObject var settings: PomodoroSettings
    let player: SoundPlayer
    let tint: Color

    private let customTag = "__custom__"

    var body: some View {
        VStack(spacing: 10) {
            ToggleRow(label: "Play sound on completion", isOn: $settings.playSound, tint: tint)

            Divider().opacity(0.4)

            HStack(spacing: 8) {
                Text("Sound")
                    .font(.system(size: 13))
                Spacer(minLength: 8)

                Picker("", selection: pickerSelection) {
                    ForEach(SoundCatalog.builtIn, id: \.self) { name in
                        Text(name).tag(name)
                    }
                    Divider()
                    Text(isCustom ? SoundCatalog.displayName(for: settings.soundName) : "Choose File…")
                        .tag(customTag)
                }
                .labelsHidden()
                .frame(maxWidth: 150)
                .disabled(!settings.playSound)

                previewButton
            }
        }
    }

    // MARK: - Preview

    private var previewButton: some View {
        Button {
            player.play(settings.soundName)
        } label: {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(settings.playSound ? tint : Color.secondary)
        }
        .buttonStyle(.plain)
        .disabled(!settings.playSound)
        .help("Preview sound")
    }

    // MARK: - Selection plumbing

    private var isCustom: Bool { SoundCatalog.isCustomPath(settings.soundName) }

    private var pickerSelection: Binding<String> {
        Binding(
            get: { isCustom ? customTag : settings.soundName },
            set: { newValue in
                if newValue == customTag {
                    chooseCustomFile()
                } else {
                    settings.soundName = newValue
                    player.play(newValue) // instant preview on selection
                }
            }
        )
    }

    private func chooseCustomFile() {
        let panel = NSOpenPanel()
        panel.title = "Choose a Sound"
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        NSApp.activate(ignoringOtherApps: true)

        if panel.runModal() == .OK, let url = panel.url {
            settings.soundName = url.path
            player.play(url.path)
        }
    }
}
