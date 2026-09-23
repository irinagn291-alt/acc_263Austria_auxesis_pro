// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AuxRingKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AuxRingKit", targets: ["AuxRingKit"]),
    ],
    targets: [
        .target(name: "AuxRingKit"),
    ],
    swiftLanguageModes: [.v6]
)
