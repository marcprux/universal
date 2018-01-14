// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Bric-à-brac",
    products: [
        .library(name: "BricBrac", targets: ["BricBrac"]),
        .library(name: "Curio", targets: ["Curio"]),
        ],
    targets: [
        .target(name: "BricBrac"),
        .testTarget(name: "BricBracTests", dependencies: ["BricBrac"]),
        .target(name: "Curio", dependencies: ["BricBrac"]),
        //.testTarget(name: "CurioTests", dependencies: ["BricBrac", "Curio"]), // this relies on running the curiotool on the schemas; how do do that?
        ]
)
