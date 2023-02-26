// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MarcUp",
    products: [
        .library(name: "Either", targets: ["Either"]),
        .library(name: "Cluster", targets: ["Cluster"]),
        .library(name: "XML", targets: ["XML"]),
        .library(name: "YAML", targets: ["YAML"]),
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "MarcUp", targets: ["MarcUp"]),
        ],
    dependencies: [
    ],
    targets: [
        .target(name: "Either"),
        .testTarget(name: "EitherTests", dependencies: ["Either"], resources: []),
        .target(name: "Cluster", dependencies: ["Either"]),
        .testTarget(name: "ClusterTests", dependencies: ["Cluster"], resources: []),
        .target(name: "XML", dependencies: ["Cluster"]),
        .testTarget(name: "XMLTests", dependencies: ["XML"], resources: []),
        .target(name: "YAML", dependencies: ["Cluster"]),
        .testTarget(name: "YAMLTests", dependencies: ["YAML"], resources: []),
        .target(name: "JSON", dependencies: ["Cluster"]),
        .testTarget(name: "JSONTests", dependencies: ["JSON"], resources: []),
        .target(name: "MarcUp", dependencies: ["XML", "YAML", "JSON"]),
        .testTarget(name: "MarcUpTests", dependencies: ["MarcUp"], resources: [.copy("testdata/")]),
        ]
)

