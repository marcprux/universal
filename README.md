Bric-à-brac
=======

[![Build Status](https://github.com/glimpseio/BricBrac/workflows/BricBrac%20CI/badge.svg?branch=main)](https://github.com/glimpseio/BricBrac/actions)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20Linux-lightgrey.svg)](https://github.com/glimpseio/MisMisc)

**Bric-à-brac** Data structures and JSON utilities for **Swift 5**.

## Features

- [x] Integrates with Swift 4's built-in Codable features
- [x] Generate Swift value types from JSON Schema (Draft 5)
- [x] A simple immutable model for JSON language elements
- [x] An efficient streaming JSON parser (optional)
- [x] Type-based (de)serialization of custom objects (no reflection, no intrusion)
- [x] No dependencies on `Foundation` or any other external framework
- [x] 100% Pure Swift

**Bric-à-brac** consists of two separate components: the **BricBrac** runtime library and the **Curio** Schema-to-Swift generation tool.

## BricBrac

BricBrac is a support library that contains convenience feautres for serializing instances to an intermediate JSON **Bric** type. Swift's **Codable** feature supports serializing and de-serializing instances to JSON Data, **BricBrac** allows these types to be represented in an intermeidate form so they can be examined and manipulated.

Any instance that supports **Encodable** automatically has a **bricEncoded()** function added to it which will return a **Bric** instance. One use for this is unit testing, where you can check to see if the encoded form of an instance is as you expect it:
    
````swift
  XCTAssertEqual(["encoding":["color":["value":"blue"]]], try encoding.bricEncoded())
````


## Installation

### Swift Package Manager (SPM)

The Swift Package Manager is a dependency manager integrated with the Swift build system. To learn how to use the Swift Package Manager for your project, please read the [official documentation](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md).

Add BricBrac to the `dependencies` of your `Package.swift` file and refer to that dependency in your `target`.

```swift
// swift-tools-version:5.0
import PackageDescription
let package = Package(
    name: "<Your Product Name>",
    dependencies: [
        .package(url: "https://github.com/glimpseio/BricBrac.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(name: "<Your Target Name>", dependencies: ["BricBrac"])
    ]
)
```

## Curio

Curio is a tool that generates swift value types (structs and enums) from a valid JSON Schema (Draft 5) file. Note that the Curio tool may generate code that has a dependency on the **BricBrac** library, but **Curio** itself never needs to be included as a runtime dependency.

### Example

For the following **Food.jsonschema** file:
    
````json
{
    "$schema": "http://json-schema.org/draft-05/schema#",
    "title": "Food",
    "type": "object",
    "required": ["title", "type"],
    "properties": {
      "title": {
        "type": "string"
      },
      "calories": {
        "type": "integer"
      },
      "type": {
        "enum": ["protein", "carbohydrate", "fat"]
      }
    }
}
````

Curio will generate the following **Food.swift** code:
    
````swift
public struct Food : Equatable, Hashable, Codable {
    public var title: String
    public var type: `Type`
    public var calories: Int?
      
    public init(title: String, type: `Type`, calories: Int? = .none) {
        self.title = title
        self.type = type
        self.calories = calories
    } 
      
    public enum CodingKeys : String, CodingKey, CaseIterable {
        case title
        case type
        case calories
    }

    public enum `Type` : String, Equatable, Hashable, Codable, CaseIterable {
        case protein
        case carbohydrate
        case fat
    }
}
````
    
### Build Integration

 * Add a Build Rule
 * Set the name to "JSON Schema Compiler"
 * From the "Process" menu, select "Source files with names matching:"
 * Next to the menu, enter "*.jsonschema"
 * From the "Using" menu, select "Custom script"
 * In the text area below, paste the following script:
````sh
cat ${INPUT_FILE_PATH} | ${BUILT_PRODUCTS_DIR}/curio -name ${INPUT_FILE_BASE} > ${SRCDIR}/${INPUT_FILE_BASE}.swift
````

 * Under the "Output Files" section, click the plus sign to add a new output file, and then enter: `$(BUILT_PRODUCTS_DIR)/$(INPUT_FILE_BASE).swift`

Now any file with the suffix ".jsonschema" will automatiucally have a Swift file generated in the ${SRCDIR}. After the first time this is run you will need to manually add the subsequently generated files to your project's source files, but any changes to the JSON Schema files will then be reflected in the generated sources as part of the build process.
