// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "universal",
    products: [
        .library(name: "Either", targets: ["Either"]),
        .library(name: "XML", targets: ["XML"]),
        .library(name: "YAML", targets: ["YAML"]),
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "PLIST", targets: ["PLIST"]),
        .library(name: "Universal", targets: ["Universal"]),
        ],
    dependencies: [
    ],
    targets: [
        .target(name: "Either"),
        .testTarget(name: "EitherTests", dependencies: ["Either"], resources: []),
        .target(name: "XML", dependencies: ["Either"]),
        .testTarget(name: "XMLTests", dependencies: ["XML"], resources: []),
        .target(name: "YAML", dependencies: ["Either"]),
        .testTarget(name: "YAMLTests", dependencies: ["YAML"], resources: []),
        .target(name: "JSON", dependencies: ["Either"]),
        .testTarget(name: "JSONTests", dependencies: ["JSON"], resources: [.copy("testdata/")]),
        .target(name: "PLIST", dependencies: ["Either"]),
        .testTarget(name: "PLISTTests", dependencies: ["PLIST"]),
        .target(name: "Universal", dependencies: ["XML", "YAML", "JSON", "PLIST"]),
        .testTarget(name: "UniversalTests", dependencies: ["Universal"]),
        ]
)

