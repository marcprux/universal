// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "BricBrac",
    products: [
        .library(name: "BricBrac", targets: ["BricBrac"]),
        .library(name: "Curio", targets: ["Curio"]),
        // disabled because if breaks the i/watch/tvOS builds
        //.executable(name: "CurioTool", targets: ["CurioTool"]),
        ],
    targets: [
        .target(name: "BricBrac"),
        .testTarget(name: "BricBracTests", dependencies: ["BricBrac"]),
        .target(name: "Curio", dependencies: ["BricBrac"]),
        .testTarget(name: "CurioTests", dependencies: ["BricBrac", "Curio"]),
        //.target(name: "CurioTool", dependencies: ["Curio"]),
        ]
)
