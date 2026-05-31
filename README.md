Universal
=========

[![Build Status](https://github.com/marcprux/universal/workflows/universal%20ci/badge.svg)](https://github.com/marcprux/universal/actions)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarcprux%2Funiversal%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/marcprux/universal)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarcprux%2Funiversal%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/marcprux/universal)

A zero-dependency cross-platform Swift parser for JSON, XML, YAML, and property lists.

All public value types conform to `Sendable`. Parsing is synchronous and free of actor isolation.

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/marcprux/universal.git", from: "6.0.0")
```

Then depend on one or more of the modules below, or on `Universal` to re-export them all.

## Modules

### Universal

[API documentation](https://swiftpackageindex.com/marcprux/universal/main/documentation/universal)

Umbrella module that re-exports `Either`, `JSON`, `XML`, `YAML`, and `PLIST`, and adds a common `merged(with:)` operation for combining two values of the same type.

```swift
import Universal

let json = try JSON.parse(Data(#"{"a": 1}"#.utf8))
let yaml = try YAML.parse(Data("a: 1".utf8))
let xml  = try XML.parse(Data("<a>1</a>".utf8))

// All four formats convert to a JSON struct for cross-format comparison
let yamlAsJSON: JSON = try yaml.json()
```

### JSON

[API documentation](https://swiftpackageindex.com/marcprux/universal/main/documentation/json/json)

A JSON value tree (`null`, `Bool`, `Double`, `String`, array, or object), with subscript access, `Codable` integration, and pretty/canonical serialization.

```swift
import JSON

let json = try JSON.parse(Data(#"{"name": "Ada", "age": 36}"#.utf8))
let name: String? = json["name"]?.string

struct Person: Codable { let name: String; let age: Int }
let person = try Person(json: json)

let pretty = try person.prettyJSON
```

### XML

[API documentation](https://swiftpackageindex.com/marcprux/universal/main/documentation/xml/xml)

An XML tree built on `XMLParser`, with optional HTML tidying on platforms where `XMLDocument` is available. The lower-level `XMLNode` type preserves elements, attributes, CDATA, comments, and processing instructions; `XML` exposes a JSON-shaped view.

```swift
import XML

let xml = try XML.parse(Data("<root><child attr=\"v\">text</child></root>".utf8))
let childText = xml["root"]?["child"]?[""]?.string

// Lower-level node tree with full fidelity
let node = try XMLNode.parse(data: Data("<a><b/></a>".utf8))
let serialized = node.xmlString()
```

### YAML

[API documentation](https://swiftpackageindex.com/marcprux/universal/main/documentation/yaml/yaml)

A YAML 1.2 parser. Scalars preserve their YAML type (`Int`, `Double`, `Bool`, `String`, or null), and multi-document streams are supported via `YAML.parse(yamls:)`.

```swift
import YAML

let yaml = try YAML.parse(Data("""
    items:
      - name: apple
        count: 3
      - name: pear
        count: 1
    """.utf8))

let firstCount: Int? = yaml["items"]?[0]?["count"]?.integer
```

### PLIST

[API documentation](https://swiftpackageindex.com/marcprux/universal/main/documentation/plist/plist)

A property list parser accepting both the XML and OpenStep textual formats, with scalar types for `Date`, `Data`, `String`, `Int`, `Double`, and `Bool`.

```swift
import PLIST

let plist = try PLIST.parse(Data("""
    { name = "Ada"; age = 36; }
    """.utf8))

let name: String? = plist["name"]?.string
```

### Either

[API documentation](https://swiftpackageindex.com/marcprux/universal/main/documentation/either/either)

A sum type — `Either<A>.Or<B>` — used internally to model the heterogeneous scalars of JSON, YAML, and PLIST, and exposed for general use. Conformance to `Codable`, `Equatable`, `Hashable`, and `Sendable` is conditional on the wrapped types.

```swift
import Either

typealias StringOrInt = Either<String>.Or<Int>

let a: StringOrInt = .init("hello")
let b: StringOrInt = .init(42)

let encoded = try JSONEncoder().encode([a, b]) // [ "hello", 42 ]
```

## Cross-format decoding

`YAML`, `XML`, and `PLIST` values convert to `JSON` via `.json()`, and any `Decodable` type can then be initialized from a `JSON` value. The same Swift type can be loaded from any of the four formats:

```swift
import Universal

struct Container: Decodable, Equatable {
    let person: Person
    struct Person: Decodable, Equatable {
        let firstName: String
        let lastName: String
    }
}

let fromJSON = try Container(json: JSON.parse(Data("""
    { "person": { "firstName": "Ada", "lastName": "Lovelace" } }
    """.utf8)))

let fromYAML = try Container(json: YAML.parse(Data("""
    person:
      firstName: Ada
      lastName: Lovelace
    """.utf8)).json())

let fromXML = try Container(json: XML.parse(Data("""
    <person>
      <firstName>Ada</firstName>
      <lastName>Lovelace</lastName>
    </person>
    """.utf8)).json())

assert(fromJSON == fromYAML)
assert(fromYAML == fromXML)
```

[Swift Package Manager]: https://swift.org/package-manager
