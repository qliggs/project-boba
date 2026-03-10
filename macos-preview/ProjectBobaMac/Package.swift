// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProjectBobaMac",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "ProjectBobaMac",
            targets: ["ProjectBobaMac"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "ProjectBobaMac"
        ),
    ]
)
