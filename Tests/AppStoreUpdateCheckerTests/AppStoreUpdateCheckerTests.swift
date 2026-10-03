import XCTest
@testable import AppStoreUpdateChecker

final class AppStoreUpdateCheckerTests: XCTestCase {
    func testSemanticVersionParsing() {
        let v1 = SemanticVersion("1.2.3")
        XCTAssertNotNil(v1)
        XCTAssertEqual(v1?.major, 1)
        XCTAssertEqual(v1?.minor, 2)
        XCTAssertEqual(v1?.patch, 3)

        let v2 = SemanticVersion("2.0")
        XCTAssertNotNil(v2)
        XCTAssertEqual(v2?.major, 2)
        XCTAssertEqual(v2?.minor, 0)
        XCTAssertEqual(v2?.patch, 0)
    }

    func testSemanticVersionComparison() {
        let older = SemanticVersion("1.0.0")!
        let newer = SemanticVersion("1.0.1")!
        let minorBump = SemanticVersion("1.1.0")!
        let majorBump = SemanticVersion("2.0.0")!

        XCTAssertTrue(older < newer)
        XCTAssertTrue(newer < minorBump)
        XCTAssertTrue(minorBump < majorBump)
        XCTAssertFalse(newer < older)
    }

    func testUpdateInfoModel() {
        let info = UpdateInfo(
            currentVersion: "1.0.0",
            storeVersion: "1.1.0",
            isUpdateAvailable: true,
            releaseNotes: "Bug fixes and performance improvements.",
            trackViewURL: URL(string: "https://apps.apple.com/app/id123456789")
        )

        XCTAssertTrue(info.isUpdateAvailable)
        XCTAssertEqual(info.storeVersion, "1.1.0")
        XCTAssertNotNil(info.trackViewURL)
    }
}
