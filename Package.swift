// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MarcUp",
    products: [
        .library(name: "Either", targets: ["Either"]),
        .library(name: "JSum", targets: ["JSum"]),
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
        .target(name: "JSum", dependencies: ["Either"]),
        .testTarget(name: "JSumTests", dependencies: ["JSum"], resources: []),
        .target(name: "XML", dependencies: ["JSum"]),
        .testTarget(name: "XMLTests", dependencies: ["XML"], resources: []),
        .target(name: "YAML", dependencies: ["JSum"]),
        .testTarget(name: "YAMLTests", dependencies: ["YAML"], resources: []),
        .target(name: "JSON", dependencies: ["JSum"]),
        .testTarget(name: "JSONTests", dependencies: ["JSON", "BricBrac"], resources: []),
        .target(name: "BricBrac", dependencies: ["XML", "YAML", "JSON"]),
        .testTarget(name: "BricBracTests", dependencies: ["BricBrac"], resources: [.copy("testdata/")]),
        ]
)

