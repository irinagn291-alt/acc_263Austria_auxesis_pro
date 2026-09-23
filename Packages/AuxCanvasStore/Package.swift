// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AuxCanvasStore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AuxCanvasStore", targets: ["AuxCanvasStore"]),
    ],
    dependencies: [
        .package(path: "../AuxCanvasCore"),
    ],
    targets: [
        .target(name: "AuxCanvasStore", dependencies: ["AuxCanvasCore"]),
        .testTarget(name: "AuxCanvasStoreTests", dependencies: ["AuxCanvasStore", "AuxCanvasCore"]),
    ],
    swiftLanguageModes: [.v6]
)
