Bric-à-brac
=======

[![Build Status](https://github.com/glimpseio/BricBrac/workflows/BricBrac%20CI/badge.svg?branch=main)](https://github.com/glimpseio/BricBrac/actions)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/Platforms-macOS%20|%20Linux%20|%20Windows%20|%20iOS%20|%20tvOS%20|%20watchOS-lightgray.svg)](https://github.com/glimpseio/MisMisc)

**Bric-à-brac** is a Swift toolkit for JSON. It facilitates working with efficient in-memory representations of JSON types and includes features for working with JSON Schema (Draft 7): utilities for parsing and validating generated ".schema.json" files, as well as data structures to support common schema idioms (such as "oneOf"/"anyOf"/"allOf" types).

## Features

- Integrates with Swift's built-in Codable features
- Generate Swift value types from JSON Schema (Draft 7)
- A simple immutable value model for JSON language elements
- Type-based (de)serialization of custom objects (no reflection, no intrusion)
- No dependencies other than `Foundation` 
- A efficient streaming & key-order-preserving JSON parser (optional)
- [Supported and tested](https://github.com/glimpseio/BricBrac/actions) on Linux, Windows, and Apple Platforms.

## Modules

**Bric-à-brac** consists of two separate components: the `BricBrac` runtime library and the `Curio` JSON Schema-to-Swift generation tool.

## BricBrac

BricBrac is a support library that contains convenience features for serializing instances to an intermediate JSON `Bric` type. Swift's `Codable` feature supports serializing and de-serializing instances to JSON Data, **BricBrac** allows these types to be represented in an intermediate form so they can be examined and manipulated.

### BricBrac API

A `Bric` acts as a fluent API for creating JSON instances using very similar syntax. It is implemented using an enum with cases for each of JSON's basic types:

```swift
public enum Bric {
    case arr([Bric]) // Array
    case obj([String: Bric]) // Dictionary
    case str(String) // String
    case num(Double) // Number
    case bol(Bool) // Boolean
    case nul // Null
}
```

`Bric` includes extensions to permit the creation of instances using the various `ExpressibleBy*Literal` protocol implementations of `String`, `Double`, `Array`, and `Dictionary`:

```swift
let num: Bric = 1 // or: let num = Bric.num(1)
let bol: Bric = true // or: let bol = Bric.bol(true)
let arr: Bric = [1, 2, 3] // or: let arr = Bric.arr([Bric.num(1), Bric.num(2), Bric.num(3)])
let het: Bric = [1, true, "x"] // or: let het = Bric.arr([Bric.num(1), Bric.bol(true), Bric.str("x")])
let obj: Bric = [ "x": true, "y": 1.3, "z": [true, "F", null] ] //  note: braces instead of curly for JSON objects
```

Any instance that supports `Encodable` automatically has a `bricEncoded()` function added to it which will return a `Bric` instance. This allows the conversion to a Swift `Codable` instance into a generic in-memory JSON representation, which can be useful for debugging, conversion between types, or unit testing:
    
````swift
  let obj = MyInstance(tint: Color(value: "blue"))
  XCTAssertEqual(["tint":["color":["value":"blue"]]], try obj.bricEncoded())
````

### Bricolage

## Curio

Curio is a tool that generates swift value types (structs and enums) from a valid JSON Schema (Draft 5) file. Note that the Curio tool may generate code that has a dependency on the **BricBrac** library, but **Curio** itself never needs to be included as a runtime dependency.

### Example

For the following `Food.jsonschema` file:
    
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

Curio will generate the following `Food.swift` code:

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

### Real-world example

A very large (5MB, ~50K SLOC) real-world example of a generated schema can be seen at (https://raw.githubusercontent.com/glimpseio/GGSpec/main/Sources/GGSpec/GGSchema.swift). It is generated from (https://vega.github.io/schema/vega-lite/v5.json)
 using the `generateGGSchema` at (https://github.com/glimpseio/GGSpec/blob/main/Tests/GGSpecTests/GGSpecTests.swift). Since that project is the *raison d'être* for Curio, it can be used as a fairly complete guide to what sorts of customizations of the schema are possible: conditional renaming, selective boxing, injection of additional properties, optional conformance to `Identifiable`, etc.

## BricBrac & Curio Additions

In addition to providing the core `Bric` functionality.

### JSON Schema

A `JSONSchema` struct is included, which permits the parsing of JSON Schema (Draft 7) instances. This is used by Curio for generating Swift Codable structs from JSON Schema definitions, and can also be used at runtime by clients who need to support JSON Schema.

### oneOf

JSON APIs (especially ones based on JSON Schema) frequently permit a property to be one of a list of types. For example, a property might contain either a `string` or a `number`. This works well in JavaScript's untyped environment, but can be challenging to represent in a strongly typed language like Swift. 

Since Swift does not include a generic `Either` type, `BricBrac.OneOf<A>.Or<B>` (which is an alias to `BricBrac.OneOf2<A, B>`) can be used to represent either of two types. Similarly, `BricBrac.OneOf<A>.Or<B>.Or<C>` (which is an alias to `BricBrac.OneOf3<A, B, C>`) can be used to represent either of three types. The types go all the way to `OneOf10<A, B, …, ∆>`.

Since there is no notion of a type discriminator in JSON Schema (or JSON itself), decoding of the `OneOfX<…>` types is done via brute-force: it first tries to decode `A` from the data, and if it fails, tries to decode `B`, then `C`, etc. Since Swift's error throwing mechanism is lighter-weight than in other high-level languages, this tends to not impact performance considerably, but custom decoding logic can be mixed in when needed.

Note: A more pernicious issue can arise from ambiguously-encoded types. For example, `OneOf2<Int, Double>(1.0)` will encode the `Double` to JSON as "1.0", but when decoded, it will be decoded in the `Int` side. Care must be taken to ensure that types in a `oneOf` cannot be encoded in an ambiguous way. Using a discriminator enum value for each possible complex type is the standard way of dealing with this issue.


### Indirect Recursive Types 

JSON schemas can have properties that optionally contain themselves, which is not permitted with Swift `Optional`s.  **Curio** handles this by permitting the declaration of fields that should be wrapped by an `BricBrac.Indirect`, which is simply defined as:

```swift
@propertyWrapper public indirect enum Indirect<Wrapped> : WrapperType, RawIsomorphism {
    case some(Wrapped)
}
```

The indirect nature of the enum is now generated as:

```swift
public struct MyCurioGeneratedStruct : Codable {
    public var someField: String
    
    // public var anotherMe: MyCurioGeneratedStruct? // this would be illegal
    
    public var anotherMe: MyCurioGeneratedStruct? {
        get { _anotherMe.wrappedValue }
        set { _anotherMe.wrappedValue = newValue }
    }
    
    private var _anotherMe: Indirect<MyCurioGeneratedStruct>?
    
    public enum CodingKeys : String, CodingKey, Hashable, CaseIterable {
        case someField
        case _anotherMe = "anotherMe" // serialization-compatible with the schema
    }
}
```

#### Stack Limits

Indirect can also be conditionally opted-into on a per-property basis. This can be useful for keeping down the stack size of a large network of structs so they can be loaded in environments with small stack capacity. 

This is specifically useful for loading from JSON on background queues on Apple platforms that have a fixed 512K stack size (as opposed to the main thread's 8MB of stack size). If your code runs fine on the main thread but is crashing on background queues, marking some of your heavier properties as `Indirect` may help work around the issue. See https://developer.apple.com/forums/thread/111128.


### Identifiable

Curio can optionally synthesize conformance to `Identifiable` for a JSON schema, even when the schema item itself does not have any notion of identifiability.

## Brac (Deprecated)

The `Brac` type enables custom creation of `Bric` instances from a network of types. It was created before Swift had any `Codable` support and is currently obsolete. It is deprecated and will be removed in the future.


### Curio Build Integration

You can automatically generate `Codable` swift structs from your JSON schema files at build time, which is useful when you are frequently changing you schema and need to have an up-to-date serialization-compatable represenation in swift.

Steps:

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

Now any file with the suffix ".jsonschema" will automatically have a Swift file generated in the ${SRCDIR}. After the first time this is run you will need to manually add the subsequently generated files to your project's source files, but any changes to the JSON Schema files will then be reflected in the generated sources as part of the build process.



## Installation

### Swift Package Manager (SPM)

The Swift Package Manager is a dependency manager integrated with the Swift build system. To learn how to use the Swift Package Manager for your project, please read the [official documentation](https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md).

Add BricBrac to the `dependencies` of your `Package.swift` file and refer to that dependency in your `target`.

```swift
// swift-tools-version:5.0
import PackageDescription
let package = Package(
    name: "<Your Product Name>",
    dependencies: [
        .package(url: "https://github.com/glimpseio/BricBrac.git", .upToNextMajor(from: "2"))
    ],
    targets: [
        .target(name: "<Your Target Name>", dependencies: ["BricBrac"])
    ]
)
```

## Alternatives

There are many libraries in Swift for working with JSON. Most of them were obsolesced by the introduction of Swift 4's `Codable` protocol, and persist in a moribund state. 

Since Bric-à-Brac aims to augment Swift's `Codable` features rather than re-implement them, it generally inter-operates seamlessly with other popular frameworks, such as:

• https://github.com/SwiftyJSON/SwiftyJSON
• https://github.com/thoughtbot/Argo


