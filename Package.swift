// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HoloBubbleApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "HoloBubbleApp", targets: ["HoloBubbleApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "HoloBubbleApp",
            path: "Sources"
        )
    ]
)
