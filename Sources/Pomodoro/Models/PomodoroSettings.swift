import Foundation
import Combine

/// User-configurable durations and behavior, persisted in UserDefaults.
final class PomodoroSettings: ObservableObject {
    @Published var focusMinutes: Int {
        didSet { persist(focusMinutes, for: .focusMinutes) }
    }
    @Published var shortBreakMinutes: Int {
        didSet { persist(shortBreakMinutes, for: .shortBreakMinutes) }
    }
    @Published var longBreakMinutes: Int {
        didSet { persist(longBreakMinutes, for: .longBreakMinutes) }
    }
    @Published var sessionsUntilLongBreak: Int {
        didSet { persist(sessionsUntilLongBreak, for: .sessionsUntilLongBreak) }
    }
    @Published var autoStartNext: Bool {
        didSet { persist(autoStartNext, for: .autoStartNext) }
    }
    @Published var playSound: Bool {
        didSet { persist(playSound, for: .playSound) }
    }
    /// Built-in sound name (e.g. "Glass") or an absolute path to a custom file.
    @Published var soundName: String {
        didSet { defaults.set(soundName, forKey: Key.soundName.rawValue) }
    }

    fileprivate enum Key: String {
        case focusMinutes, shortBreakMinutes, longBreakMinutes
        case sessionsUntilLongBreak, autoStartNext, playSound, soundName
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.focusMinutes = defaults.intOr(.focusMinutes, default: 25)
        self.shortBreakMinutes = defaults.intOr(.shortBreakMinutes, default: 5)
        self.longBreakMinutes = defaults.intOr(.longBreakMinutes, default: 15)
        self.sessionsUntilLongBreak = defaults.intOr(.sessionsUntilLongBreak, default: 4)
        self.autoStartNext = defaults.boolOr(.autoStartNext, default: false)
        self.playSound = defaults.boolOr(.playSound, default: true)
        self.soundName = defaults.string(forKey: Key.soundName.rawValue) ?? SoundCatalog.defaultSound
    }

    /// Duration in seconds for a given session type.
    func duration(for session: SessionType) -> Int {
        switch session {
        case .focus: return focusMinutes * 60
        case .shortBreak: return shortBreakMinutes * 60
        case .longBreak: return longBreakMinutes * 60
        }
    }

    private func persist(_ value: Int, for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }

    private func persist(_ value: Bool, for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }
}

private extension UserDefaults {
    func intOr(_ key: PomodoroSettings.Key, default fallback: Int) -> Int {
        object(forKey: key.rawValue) == nil ? fallback : integer(forKey: key.rawValue)
    }

    func boolOr(_ key: PomodoroSettings.Key, default fallback: Bool) -> Bool {
        object(forKey: key.rawValue) == nil ? fallback : bool(forKey: key.rawValue)
    }
}
