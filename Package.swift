// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "BricBrac",
    products: [
        .library(name: "BricBrac", targets: ["BricBrac"]),
        .library(name: "Curio", targets: ["Curio"]),
        //.executable(name: "CurioTool", targets: ["CurioTool"]),
        ],
    targets: [
        .target(name: "BricBrac"),
        .testTarget(name: "BricBracTests", dependencies: ["BricBrac"], resources: [.copy("testdata/")]),
        .target(name: "Curio", dependencies: ["BricBrac"]),
        .testTarget(name: "CurioTests", dependencies: ["BricBrac", "Curio"], resources: [.copy("schemas/")]),
        //.target(name: "CurioTool", dependencies: ["Curio"]),
        ]
)

