import Foundation

/// Built-in macOS system sounds plus support for a user-supplied file.
enum SoundCatalog {
    /// Names of system sounds in /System/Library/Sounds (playable via NSSound(named:)).
    static let builtIn: [String] = [
        "Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero",
        "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"
    ]

    static let defaultSound = "Glass"

    /// True if the identifier refers to a custom file path rather than a built-in name.
    static func isCustomPath(_ identifier: String) -> Bool {
        identifier.hasPrefix("/")
    }

    /// Human-readable label for a stored sound identifier.
    static func displayName(for identifier: String) -> String {
        isCustomPath(identifier)
            ? (identifier as NSString).lastPathComponent
            : identifier
    }
}
