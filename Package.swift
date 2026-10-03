// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppStoreUpdateChecker",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppStoreUpdateChecker",
            targets: ["AppStoreUpdateChecker"]
        )
    ],
    targets: [
        .target(
            name: "AppStoreUpdateChecker",
            dependencies: []
        ),
        .testTarget(
            name: "AppStoreUpdateCheckerTests",
            dependencies: ["AppStoreUpdateChecker"]
        )
    ]
)
