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
        .library(name: "Bricolage", targets: ["Bricolage"]),
        .library(name: "MarcUp", targets: ["MarcUp"]),
        ],
    dependencies: [
//        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
    ],
    targets: [
        .target(name: "XOr"),
        .testTarget(name: "XOrTests", dependencies: ["XOr"], resources: []),
        .target(name: "JSum"),
        .testTarget(name: "JSumTests", dependencies: ["JSum"], resources: []),
        .target(name: "XML", dependencies: ["JSum"]),
        .testTarget(name: "XMLTests", dependencies: ["XML"], resources: []),
        .target(name: "YAML", dependencies: ["JSum"]),
        .testTarget(name: "YAMLTests", dependencies: ["YAML"], resources: []),
        .target(name: "JSON", dependencies: ["JSum", "Bricolage"]),
        .testTarget(name: "JSONTests", dependencies: ["JSON", "MarcUp"], resources: []),
        .target(name: "Bricolage", dependencies: ["XOr"]),
        .testTarget(name: "BricolageTests", dependencies: ["Bricolage"], resources: []),
        .target(name: "MarcUp", dependencies: ["XML", "YAML", "JSON"]),
        .testTarget(name: "MarcUpTests", dependencies: ["MarcUp"], resources: [.copy("testdata/")]),
        ]
)

