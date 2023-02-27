// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Universal",
    products: [
        .library(name: "Either", targets: ["Either"]),
        .library(name: "Quanta", targets: ["Quanta"]),
        .library(name: "XML", targets: ["XML"]),
        .library(name: "YAML", targets: ["YAML"]),
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "Universal", targets: ["Universal"]),
        ],
    dependencies: [
    ],
    targets: [
        .target(name: "Either"),
        .testTarget(name: "EitherTests", dependencies: ["Either"], resources: []),
        .target(name: "Quanta", dependencies: ["Either"]),
        .testTarget(name: "QuantaTests", dependencies: ["Quanta"], resources: []),
        .target(name: "XML", dependencies: ["Quanta"]),
        .testTarget(name: "XMLTests", dependencies: ["XML"], resources: []),
        .target(name: "YAML", dependencies: ["Quanta"]),
        .testTarget(name: "YAMLTests", dependencies: ["YAML"], resources: []),
        .target(name: "JSON", dependencies: ["Quanta"]),
        .testTarget(name: "JSONTests", dependencies: ["JSON"], resources: [.copy("testdata/")]),
        .target(name: "Universal", dependencies: ["XML", "YAML", "JSON"]),
        .testTarget(name: "UniversalTests", dependencies: ["Universal"]),
        ]
)

