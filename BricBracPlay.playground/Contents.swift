import BricBrac

//: The core element of the Bric-a-Brac framework is the `Bric` type, which is an enumeration that represents a piece of valid JSON. 

//: ### Reading from a JSON String
//: A bit of `Bric` can be created from a Swift String with the `parse` function, which will throw an error if the JSON is malformed.
let parsed: Bric = try Bric.parse("[1, 2.3, true, false, null, {\"key\": \"value\"}]") // parsing a string

//: You can also create a bit of `Bric` manually using a Swift-fluent API, where literal strings, numbers, booleans, arrays, and dictionaries are specified inline.
var bric: Bric = [1, 2.3, true, false, nil, ["key": "value"]] // fluent API for building the same as above

assert(bric == parsed)

//: Elements of `Bric` arrays and objects can be accessed via their numeric and string keys, respectively.
let e0: Int? = bric[0] // 1

//: Note that accessing an array index that is out-of-bounds returns `nil` rather than raising an error
let missingElement: Bric? = bric[999] // nil (not an error when index out of bounds)

let e1: Double? = bric[1] // 2.3

let e2: Bool? = bric[2] // true
let e3: Bool? = bric[3] // false

let e4: String? = bric[4] // nil

let e5: [String: Bric]? = bric[5] // ["key": "value"]

let missingKey: String? = bric[5]?["XXX"] // nil

let keyValue: String? = bric[5]?["key"] // "value"

bric[5]?["key"] = "newValue" // same API can be used to modify Bric

let keyValue2: String? = bric[5]?["key"] // "newValue"

//: ### Writing to a JSON String
//: A bit of `Bric` can be saved out to a JSON-compliant string with the `stringify` function, outputting:
//: `[1,2.3,true,false,null,{"key":"newValue"}]`

let compact: String = bric.stringify() // compact: "[1,2.3,true,false,null,{"key":"newValue"}]"
let compact2 = String(bric) // same as above (Bric conforms to Streamable)

/*:
You can also pretty-print the bric with the `space` parameter.
*/
let pretty: String = bric.stringify(space: 2) // pretty-printed


/*:
Collections and Optionals are automatically wrapped when parsing `Bric`.
*/

let arrayOfOptionalNumbers = try Array<Optional<UInt8>>.brac(Bric.parse("[1, 2, null]"))
let arrayOfOptionalNumbers2 = try [UInt8?].brac(Bric.parse("[1, 2, null]")) // same as above

/*:
Optionality must be explicitly included in the type, or else an error will be thrown.
*/
do {
    let arrayOfNonOptionalNumbers = try [UInt8].brac(Bric.parse("[1, 2, null]"))
} catch {
    String(error) // "Invalid type: expected Int8, found nil"
}

/*:
When a numeric type is out of range, it will throw an error.
*/
do {
    let arrayOfUnsignedInts = try [UInt8].brac(Bric.parse("[-2]"))
} catch {
    String(error) // "Numeric overflow: UInt8 cannot contain -2.0"
}

/*:
Automatic rounding, however, is performed:
*/
let arrayOfRoundedUInts = try [UInt8].brac(Bric.parse("[2.345]")) // [2]


/*:
### Serializing custom types

Many of the built-in Swift types can be read/written to/from Bric via the framework adopting
the `Bricable` and `Bracable` protocols for raw types (`String`, `Int`, `Bool`, etc.)

User-defined types can also handle JSON (de-)serialization by adopting these protocols. No
requirements are made about the optionality or mutability of the given properties.
*/
/// A custom struct; no requirements about optionality or mutability of properties
struct Product : BricBrac {
    let name: String
    let weight: Double
    var description: String?
    var tags: Set<String>

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
    error // Missing key for Double: «y»
}

do {
    try CGPoint.brac(["x": 1, "y": false])
} catch {
    error // Invalid type: expected Double, found Bool at /y
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
    String(error) // Error Domain=NSCocoaErrorDomain Code=2048 "The value “2015-13-14T99:31:20-04:00” is invalid." UserInfo={NSInvalidValue=2015-13-14T99:31:20-04:00}
}


let dates = [
    "past": [NSDate(timeIntervalSinceNow: -600), NSDate(timeIntervalSinceNow: -60)],
    "present": [NSDate()],
    "future": [NSDate(timeIntervalSinceNow: +60), NSDate(timeIntervalSinceNow: +600)]
]

/*:
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


let orders = try [OrderType?].brac(["direct", "web", nil]) // direct, web, nil

do {
    let badOrder = try [OrderType?].brac(["phone", "fax", nil])
} catch let error as BracError {
    String(error) // error: "Invalid value for OrderType: fax"
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

// {"args":{},"origin":"61.46.1.98","headers":{"Accept-Encoding":"gzip, deflate","Accept-Language":"en-us","Accept":"*/*","User-Agent":"BricBracPlay/1 CFNetwork/760.0.5 Darwin/15.0.0 (x86_64)","Host":"httpbin.org"},"url":"http://httpbin.org/get"}
let rest = try Bric.parse(String(contentsOfURL: NSURL(string: "http://httpbin.org/get")!, encoding: NSUTF8StringEncoding))

