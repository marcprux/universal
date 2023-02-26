// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MarcUp",
    products: [
        .library(name: "Either", targets: ["Either"]),
        .library(name: "MarcUp", targets: ["MarcUp"]),
        .library(name: "XML", targets: ["XML"]),
        .library(name: "YAML", targets: ["YAML"]),
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "BricBrac", targets: ["BricBrac"]),
        ],
    dependencies: [
    ],
    targets: [
        .target(name: "Either"),
        .testTarget(name: "EitherTests", dependencies: ["Either"], resources: []),
        .target(name: "MarcUp", dependencies: ["Either"]),
        .testTarget(name: "MarcUpTests", dependencies: ["MarcUp"], resources: []),
        .target(name: "XML", dependencies: ["MarcUp"]),
        .testTarget(name: "XMLTests", dependencies: ["XML"], resources: []),
        .target(name: "YAML", dependencies: ["MarcUp"]),
        .testTarget(name: "YAMLTests", dependencies: ["YAML"], resources: []),
        .target(name: "JSON", dependencies: ["MarcUp"]),
        .testTarget(name: "JSONTests", dependencies: ["JSON", "BricBrac"], resources: []),
        .target(name: "BricBrac", dependencies: ["XML", "YAML", "JSON"]),
        .testTarget(name: "BricBracTests", dependencies: ["BricBrac"], resources: [.copy("testdata/")]),
        ]
)

