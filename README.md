Bric-à-brac
=======

[![Swift 2.0](https://img.shields.io/badge/Swift-2.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X | iOS](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20iOS%20%7C%20Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-Compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/glimpseio/BricBrac.svg?branch=master)](https://travis-ci.org/glimpseio/BricBrac)
[![Join the chat at https://gitter.im/glimpseio/BricBrac](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/glimpseio/BricBrac?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![codecov.io](http://codecov.io/github/glimpseio/BricBrac/coverage.svg?branch=master)](http://codecov.io/github/glimpseio/BricBrac?branch=master)

**Bric-à-brac** is a lightweight, clean and efficient JSON toolkit for **Swift 2**.

## Features

- [x] A simple immutable model of the JSON language elements
- [x] An efficient streaming JSON parser
- [x] Type-based (de)serialization of custom objects (no reflection, no intrusion)
- [x] No dependencies on `Foundation` or any other external framework (**Linux ready**)
- [x] 100% Pure Swift


## Quick Tour

````swift
import BricBrac

let parsed: Bric = try Bric.parse("[1, 2.3, true, false, null, {\"key\": \"value\"}]") // parsing a string
var bric: Bric = [1, 2.3, true, false, nil, ["key": "value"]] // fluent API for building the same as above

assert(bric == parsed)

let e0: Int? = bric[0] // 1

let e1: Double? = bric[1] // 2.3

let e2: Bool? = bric[2] // true
let e3: Bool? = bric[3] // false

let e4: String? = bric[4] // nil

let e5: [String: Bric]? = bric[5] // ["key": "value"]

let missingKey: String? = bric[5]?["XXX"] // nil

let keyValue: String? = bric[5]?["key"] // "value"

bric[5]?["key"] = "newValue" // same API can be used to modify Bric

let keyValue2: String? = bric[5]?["key"] // "newValue"

let missingElement: Bric? = bric[6] // nil (not an error when index out of bounds)


let compact: String = bric.stringify() // compact: "[1,2.3,true,false,null,{"key":"value"}]"
let compact2 = String(bric) // same as above (Bric conforms to Streamable)

let pretty: String = bric.stringify(space: 2) // pretty-printed


/// A custom struct; no requirements about optionality or mutability of properties
struct Product {
    let name: String
    let weight: Double
    var description: String?
    var tags: Set<String>
}

/// Endowing the struct with BricBrac: just implement bric() and brac()
extension Product : BricBrac {
    func bric() -> Bric {
        return ["name": name.bric(), "weight": weight.bric(), "description": description.bric(), "tags": tags.bric()]
    }

    static func brac(bric: Bric) throws -> Product {
        return try Product(name: bric.bracKey("name"), weight: bric.bracKey("weight"), description: bric.bracKey("description"), tags: bric.bracKey("tags"))
    }
}

// Create an instance from some Bric
let macbook = try Product.brac(["name": "MacBook", "weight": 2.0, "description": "A Nice Laptop", "tags": ["laptop", "computer"]])

var newMacbook = macbook // copying the stuct makes a new instance
assert(newMacbook == macbook) // equatability comes for free by adopting BricBrac

newMacbook.tags.insert("fanless")
assert(newMacbook != macbook) // no longer the same data

newMacbook.bric().stringify() // "{"name":"MacBook","weight":2,"tags":["fanless","laptop","computer"],"description":"A Nice Laptop"}"


import CoreGraphics

/// Extending an existing struct provides serialization capabilities
extension CGPoint : Bricable, Bracable {
    public func bric() -> Bric {
        return ["x": Bric(x.native), "y": Bric(y.native)]
    }

    public static func brac(bric: Bric) throws -> CGPoint {
        return try CGPoint(x: bric.bracKey("x") as CGFloat.NativeType, y: bric.bracKey("y") as CGFloat.NativeType)
    }
}

let points = ["first": [CGPoint(x: 1, y: 2), CGPoint(x: 4, y: 5)], "second": [CGPoint(x: 9, y: 10)]]

// Collections, Dictionaries, & Optional wrapping come for free with BricBrac
points.bric().stringify() // {"first":[{"y":2,"x":1},{"y":5,"x":4}],"second":[{"y":10,"x":9}]}

do {
    try CGPoint.brac(["x": 1])
} catch {
    print(error) // Missing key for Double: «y»
}

do {
    try CGPoint.brac(["x": 1, "y": false])
} catch {
    print(error) // Invalid type: expected Double, found Bool at /y
}

import Foundation

/// Example of conferring JSON serialization on an existing non-final class
extension NSDate : Bricable, Bracable {
    /// ISO-8601 is the de-facto date format for JSON
    private static let ISO8601Formatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
        }()

    /// NSDate will be saved as a ISO-8601 string
    public func bric() -> Bric {
        return Bric.Str(NSDate.ISO8601Formatter.stringFromDate(self) as String)
    }

    /// Restore an NSDate from a "time" field
    public static func brac(bric: Bric) throws -> Self {
        var parsed: AnyObject?
        try ISO8601Formatter.getObjectValue(&parsed, forString: bric.bracStr(), range: nil)
        if let parsed = parsed as? NSDate {
            return self.init(timeIntervalSinceReferenceDate: parsed.timeIntervalSinceReferenceDate)
        } else {
            throw BracError.InvalidType(type: NSDate.self, actual: String(parsed), path: [])
        }
    }
}

try NSDate.brac("2015-09-14T13:31:20-04:00") // "Sep 14, 2015, 1:31 PM"

do {
    try NSDate.brac("2015-13-14T99:31:20-04:00")
} catch {
    print(String(error)) // Error Domain=NSCocoaErrorDomain Code=2048 "The value “2015-13-14T99:31:20-04:00” is invalid." UserInfo={NSInvalidValue=2015-13-14T99:31:20-04:00}
}


let dates = [
    "past": [NSDate(timeIntervalSinceNow: -600), NSDate(timeIntervalSinceNow: -60)],
    "present": [NSDate()],
    "future": [NSDate(timeIntervalSinceNow: +60), NSDate(timeIntervalSinceNow: +600)]
]

/*
{
  "future": [
    "2015-09-14T13:31:20-04:00",
    "2015-09-14T13:40:20-04:00"
  ],
  "present": [
    "2015-09-14T13:30:20-04:00"
  ],
  "past": [
    "2015-09-14T13:20:20-04:00",
    "2015-09-14T13:29:20-04:00"
  ]
}
*/
dates.bric().stringify(space: 2)



enum OrderType : String { case direct, web, phone }


/// BricBrac is automatically implemented for simple String & primitive enums
extension OrderType : BricBrac { }


let directOrder = try OrderType.brac("direct")

do {
    let badOrder = try OrderType.brac("fax")
} catch let error as BracError {
    // error: "Invalid value for OrderType: fax"
}

struct Order {
    var date: NSDate
    let type: OrderType
    var products: [Product]
    var location: CGPoint?
}

extension Order : BricBrac {
    func bric() -> Bric {
        return ["date": date.bric(), "type": type.bric(), "products": products.bric(), "location": location.bric()]
    }

    static func brac(bric: Bric) throws -> Order {
        return try Order(date: bric.bracKey("date"), type: bric.bracKey("type"), products: bric.bracKey("products"), location: bric.bracKey("location"))
    }
}

var order = Order(date: NSDate(), type: .direct, products: [], location: nil)


order.bric() // {"type":"direct","location":null,"date":"2015-09-14T13:31:15-04:00","products":[]}

order.products += [macbook]
order.bric() // {"type":"direct","location":null,"date":"2015-09-14T13:31:40-04:00","products":[{"name":"MacBook","weight":2,"tags":["laptop","computer"],"description":"A Nice Laptop"}]}

order.location = CGPoint(x: 1043, y: 433)
order.bric() // {"type":"direct","location":{"y":433,"x":1043},"date":"2015-09-14T13:33:16-04:00","products":[{"name":"MacBook","weight":2,"tags":["laptop","computer"],"description":"A Nice Laptop"}]}

````

### Integrating Curio into the Build process

 * Build Rules
 * Change the name to "JSON Schema Compiler"
 * From the "Process" menu, select "Source files with names matching:"
 * Next to the menu, enter "*.jsonschema"
 * From the "Using" menu, select "Custom script"
 * In the text area below, paste the following script:
````sh
cat ${INPUT_FILE_PATH} | ${BUILT_PRODUCTS_DIR}/curio -name ${INPUT_FILE_BASE} > ${SRCDIR}/${INPUT_FILE_BASE}.swift
````

 * Under the "Output Files" section, click the plus sign to add a new output file, and then enter: `$(BUILT_PRODUCTS_DIR)/$(INPUT_FILE_BASE).swift`


Now any file with the suffix ".jsonschema" will automatiucally have a Swift file generated in the ${SRCDIR}. After the first time this is run you will need to manually add the subsequently generated files to your project's source files, but any changes to the JSON Schema files will then be reflected in the generated sources as part of the build process.



##Installation

###[Carthage](https://github.com/Carthage/Carthage#installing-carthage)

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

````
github "glimpseio/BricBrac"
````

Then do `carthage update`. After that, add the framework to your project.

###Manually

`BricBrac` is a single cross-platform iOS & Mac Framework. To set it up in your project, simply add it as a github submodule, drag the `BricBrac.xcodeproj` into your own project file, add `BricBrac.framework` to your target's dependencies, and `import BricBrac` from any Swift file that should use it.

**Set up Git submodule**

1. Open a Terminal window
1. Change to your projects directory `cd /path/to/MyProject`
1. If this is a new project, initialize Git: `git init`
1. Add the submodule: `git submodule add https://github.com/glimpseio/BricBrac.git BricBrac`.

**Set up Xcode**

1. Find the `BricBrac.xcodeproj` file inside of the cloned BricBrac project directory.
1. Drag & Drop it into the `Project Navigator` (⌘+1).
1. Select your project in the `Project Navigator` (⌘+1).
1. Select your target.
1. Select the tab `Build Phases`.
1. Expand `Link Binary With Libraries`.
1. Add `BricBrac.framework`
1. Add `import BricBrac` to the top of your Swift source files.

