import Foundation

/// Represents a semantically versioned string (e.g. "1.2.3").
public struct SemanticVersion: Comparable, Equatable, Sendable {
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let rawString: String

    public init?(_ versionString: String) {
        self.rawString = versionString.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = rawString.split(separator: ".").compactMap { Int($0) }

        guard !components.isEmpty else { return nil }

        self.major = components[0]
        self.minor = components.count > 1 ? components[1] : 0
        self.patch = components.count > 2 ? components[2] : 0
    }

    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }
}
