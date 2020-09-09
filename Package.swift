// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "BricBrac",
    products: [
        .library(name: "BricBrac", targets: ["BricBrac"]),
        //.library(name: "Curio", targets: ["Curio"]),
        //.executable(name: "CurioTool", targets: ["CurioTool"]),
        ],
    targets: [
        .target(name: "BricBrac"),
        .testTarget(name: "BricBracTests", dependencies: ["BricBrac"]),
        //.target(name: "Curio", dependencies: ["BricBrac"]),
        //.target(name: "CurioTool", dependencies: ["Curio"]),
        //.testTarget(name: "CurioTests", dependencies: ["BricBrac", "Curio"]), // this relies on running the curiotool on the schemas; how do do that?
        ]
)
