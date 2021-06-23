// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "BricBrac",
    products: [
        .library(name: "BricBrac", targets: ["BricBrac"]),
        .library(name: "Curio", targets: ["Curio"]),
        .executable(name: "CurioTool", targets: ["CurioTool"]), // SR-1954
        ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.3")),
    ],
    targets: [
        .target(name: "BricBrac"),
        .testTarget(name: "BricBracTests", dependencies: ["BricBrac"], resources: [.copy("testdata/")]),
        .target(name: "Curio", dependencies: ["BricBrac"]),
        .testTarget(name: "CurioTests", dependencies: ["BricBrac", "Curio"], resources: [.copy("schemas/")]),
        .target(name: "CurioTool", dependencies: ["Curio", .product(name: "ArgumentParser", package: "swift-argument-parser")]), // SR-1954
        ]
)

