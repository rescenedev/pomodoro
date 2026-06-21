import AppKit
import AVFoundation

/// Plays completion sounds, resolving built-in names or custom file paths.
/// Built-in system sounds use NSSound; custom files use AVAudioPlayer so that
/// any common format (mp3, m4a, wav, aiff, caf…) previews and plays reliably.
@MainActor
final class SoundPlayer {
    private var systemSound: NSSound?
    private var filePlayer: AVAudioPlayer?

    @discardableResult
    func play(_ identifier: String) -> Bool {
        stop()
        if SoundCatalog.isCustomPath(identifier) {
            return playFile(URL(fileURLWithPath: identifier))
        }
        return playBuiltIn(identifier)
    }

    private func playBuiltIn(_ name: String) -> Bool {
        let sound = NSSound(named: name) ?? NSSound(named: SoundCatalog.defaultSound)
        systemSound = sound
        return sound?.play() ?? false
    }

    private func playFile(_ url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return playBuiltIn(SoundCatalog.defaultSound)
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            filePlayer = player
            player.prepareToPlay()
            return player.play()
        } catch {
            // Fallback to NSSound for anything AVAudioPlayer rejects.
            if let sound = NSSound(contentsOf: url, byReference: true) {
                systemSound = sound
                return sound.play()
            }
            return false
        }
    }

    private func stop() {
        systemSound?.stop()
        filePlayer?.stop()
    }
}
