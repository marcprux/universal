// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MarcUp",
    products: [
        .library(name: "XOr", targets: ["XOr"]),
        .library(name: "JSum", targets: ["JSum"]),
        .library(name: "XML", targets: ["XML"]),
        .library(name: "YAML", targets: ["YAML"]),
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "BricBrac", targets: ["BricBrac"]),
        ],
    dependencies: [
    ],
    targets: [
        .target(name: "XOr"),
        .testTarget(name: "XOrTests", dependencies: ["XOr"], resources: []),
        .target(name: "JSum", dependencies: ["XOr"]),
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

