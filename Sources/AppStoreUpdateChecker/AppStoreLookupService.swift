import Foundation

/// Encapsulates version differential details returned from the App Store.
public struct UpdateInfo: Sendable, Equatable {
    public let currentVersion: String
    public let storeVersion: String
    public let isUpdateAvailable: Bool
    public let releaseNotes: String?
    public let trackViewURL: URL?

    public init(
        currentVersion: String,
        storeVersion: String,
        isUpdateAvailable: Bool,
        releaseNotes: String?,
        trackViewURL: URL?
    ) {
        self.currentVersion = currentVersion
        self.storeVersion = storeVersion
        self.isUpdateAvailable = isUpdateAvailable
        self.releaseNotes = releaseNotes
        self.trackViewURL = trackViewURL
    }
}

public enum UpdateCheckerError: LocalizedError, Sendable {
    case invalidBundleIdentifier
    case invalidResponse
    case appNotFound
    case parsingError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidBundleIdentifier:
            return "Unable to resolve a valid bundle identifier."
        case .invalidResponse:
            return "Unexpected response from App Store lookup service."
        case .appNotFound:
            return "Application was not found on the App Store."
        case .parsingError(let msg):
            return "Failed to parse App Store response: \(msg)"
        }
    }
}

/// Service querying Apple's iTunes Search API to inspect live App Store version data.
public actor AppStoreLookupService {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Checks the App Store for a newer version of the specified bundle ID.
    public func checkForUpdate(
        bundleIdentifier: String? = Bundle.main.bundleIdentifier,
        currentVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
        countryCode: String? = nil
    ) async throws -> UpdateInfo {
        guard let bundleId = bundleIdentifier, !bundleId.isEmpty else {
            throw UpdateCheckerError.invalidBundleIdentifier
        }

        let installedVersionStr = currentVersion ?? "1.0.0"
        guard let installedVersion = SemanticVersion(installedVersionStr) else {
            throw UpdateCheckerError.parsingError("Invalid installed version format: \(installedVersionStr)")
        }

        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        var queryItems = [URLQueryItem(name: "bundleId", value: bundleId)]
        if let country = countryCode {
            queryItems.append(URLQueryItem(name: "country", value: country))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw UpdateCheckerError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw UpdateCheckerError.invalidResponse
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let firstResult = results.first else {
            throw UpdateCheckerError.appNotFound
        }

        guard let storeVersionStr = firstResult["version"] as? String,
              let storeVersion = SemanticVersion(storeVersionStr) else {
            throw UpdateCheckerError.parsingError("Missing version field in store response")
        }

        let isUpdateAvailable = installedVersion < storeVersion
        let releaseNotes = firstResult["releaseNotes"] as? String
        let trackViewURLStr = firstResult["trackViewUrl"] as? String
        let trackViewURL = trackViewURLStr.flatMap { URL(string: $0) }

        return UpdateInfo(
            currentVersion: installedVersionStr,
            storeVersion: storeVersionStr,
            isUpdateAvailable: isUpdateAvailable,
            releaseNotes: releaseNotes,
            trackViewURL: trackViewURL
        )
    }
}
