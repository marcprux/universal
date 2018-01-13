// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Bric-à-brac",
    products: [
        .library(name: "BricBrac", targets: ["BricBrac"]),
        ],
    targets: [
        .target(name: "BricBrac"),
        .testTarget(name: "BricBracTests", dependencies: ["BricBrac"]),
        ]
)
