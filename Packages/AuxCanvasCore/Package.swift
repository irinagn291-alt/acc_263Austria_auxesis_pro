// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AuxCanvasCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AuxCanvasCore", targets: ["AuxCanvasCore"]),
    ],
    targets: [
        .target(name: "AuxCanvasCore"),
        .testTarget(name: "AuxCanvasCoreTests", dependencies: ["AuxCanvasCore"]),
    ],
    swiftLanguageModes: [.v6]
)
