//
//  JSONTests.swift
//
//  Created by Marc Prud'hommeaux on 6/14/15.
//
import XCTest
import JSON
import Either


final class JSONTests : XCTestCase {
    func testJSON() throws {
        XCTAssertEqual(nil, JSON.null)
        XCTAssertEqual("JSON.null", JSON.null.description)
        XCTAssertEqual(false, JSON.false)
        XCTAssertEqual("JSON.boolean(false)", JSON.false.description)
        XCTAssertEqual(true, JSON.true)
        XCTAssertEqual("JSON.boolean(true)", JSON.true.description)

        XCTAssertEqual(1, 1 as JSON)
        XCTAssertEqual("JSON.number(1.0)", (1 as JSON).description)
        XCTAssertEqual("X", "X" as JSON)
        XCTAssertEqual("JSON.string(\"X\")", ("X" as JSON).description)

        XCTAssertEqual(false, false as JSON)
        XCTAssertEqual(nil, nil as JSON)

        XCTAssertEqual([nil], [nil] as JSON)
        XCTAssertEqual("JSON.array([JSON.null])", ([nil] as JSON).description)

        XCTAssertEqual(["X": nil], ["X": nil] as JSON)
        XCTAssertEqual("JSON.object([\"X\": JSON.null])", (["X": nil] as JSON).description)

        XCTAssertEqual(["X": [1, 2.3, true, nil, "Y", ["Z"]]], ["X": [1, 2.3, true, nil, "Y", ["Z"]]] as JSON)
        XCTAssertEqual(#"JSON.object(["X": JSON.array([JSON.number(1.0), JSON.number(2.3), JSON.boolean(true), JSON.null, JSON.string("Y"), JSON.array([JSON.string("Z")])])])"#, (["X": [1, 2.3, true, nil, "Y", ["Z"]]] as JSON).description)

        XCTAssertEqual(JSON.object(["X": .array([.number(1.0), .number(2.3), .boolean(true), .null, .string("Y"), .array([.string("Z")])])]), (["X": [1, 2.3, true, nil, "Y", ["Z"]]] as JSON))

        let js: JSON = [
            "string": "hello",
            "number": 1.23,
            "null": nil,
            "bool": .false,
            "array": [1, .null, "foo"],
            "object": [
                "x": "a",
                "y": 5,
                "z": [:]
            ]
        ]

        XCTAssertEqual(js["string"], "hello")
        XCTAssertEqual(js["string"]?.string, "hello")

        XCTAssertEqual(js["number"], 1.23)
        XCTAssertEqual(js["number"]?.number, 1.23)

        XCTAssertEqual(js["null"], JSON.null)
        XCTAssertEqual(true, js["null"]?.isNull)

        XCTAssertEqual(js["array"], [1, nil, "foo"])
        XCTAssertEqual(js["array"]?.array, [1, nil, "foo"])

        XCTAssertEqual(js["object"]?["x"], "a")
        XCTAssertEqual(js["object"]?["x"]?.string, "a")

        XCTAssertEqual(js["array"]?[0], 1)
        XCTAssertEqual(js["array"]?[1], .null)
        XCTAssertEqual(js["array"]?[2], "foo")

        XCTAssertEqual(JSON.null, try JSON(fromJSON: "null".utf8Data))
        XCTAssertEqual(JSON.false, try JSON(fromJSON: "false".utf8Data))
        XCTAssertEqual(JSON.true, try JSON(fromJSON: "true".utf8Data))
        XCTAssertEqual(1.0, try JSON(fromJSON: "1.0".utf8Data))
        XCTAssertEqual(1.1, try JSON(fromJSON: "1.1".utf8Data))
        XCTAssertEqual("abc", try JSON(fromJSON: #""abc""#.utf8Data))
        XCTAssertEqual(["abc"], try JSON(fromJSON: #"["abc"]"#.utf8Data))

        let json = try js.canonicalJSON

        XCTAssertEqual(json, """
        {"array":[1,null,"foo"],"bool":false,"null":null,"number":1.23,"object":{"x":"a","y":5,"z":{}},"string":"hello"}
        """)


        let js2 = try JSON(fromJSON: json.utf8Data)
        XCTAssertEqual(js, js2)
    }


    /// Create a seeded random JSum for deserialization performance testing.
    /// - Parameters:
    ///   - depth: how deep to make the graph
    ///   - breadth: how many elements each object/array level of the graph should contain
    ///   - seed: the random seed
    /// - Returns: a JSum object full of random junk
    func createSampleJSON(depth: Int, breadth: Int, rng: inout some RandomNumberGenerator) -> JSON {
        func coinFlip() -> Bool {
            .random(using: &rng)
        }

        /// Creates a UUID with the given generator
        func uuid() -> UUID {
            UUID(rnd: &rng)
        }

        var values: [JSON] = []
        for _ in 0..<breadth {
            if depth > 1 && coinFlip() {
                // create an object child
                let child = createSampleJSON(depth: depth - 1, breadth: breadth, rng: &rng)
                values.append(child)
            } else {
                // create a primitive child
                switch Int.random(in: 0...3, using: &rng) {
                case 0: values.append(JSON.boolean(.random(using: &rng)))
                case 1: values.append(JSON.number(Double.random(in: -999999...999999, using: &rng)))
                case 2: values.append(JSON.string(uuid().uuidString))
                default: values.append(.null)
                }
            }
        }


        if coinFlip() { // make the element an object
            var obj = JSON.Object()
            for value in values {
                obj[uuid().uuidString] = value
            }
            return .object(obj)
        } else { // !coinFlip: make the elements an array
            return .array(values)
        }

    }

//    func testParseJSONPerformance() throws {
//        // DEBUG: 14K: measured [Time, seconds] average: 0.004, relative standard deviation: 20.388%, values: [0.006096, 0.003659, 0.003470, 0.003649, 0.003550, 0.003524, 0.003419, 0.003496, 0.003568, 0.003460]
//        // DEBUG: 136K: measured [Time, seconds] average: 0.031, relative standard deviation: 20.316%, values: [0.049674, 0.030524, 0.029786, 0.028808, 0.027710, 0.028118, 0.028606, 0.028499, 0.028976, 0.028782]
//        try measureParsing(kind: .json)
//    }
//
//    func testParseJSONPerformance() throws {
//        // DEBUG: 14K: measured [Time, seconds] average: 0.002, relative standard deviation: 4.282%, values: [0.002516, 0.002369, 0.002197, 0.002189, 0.002437, 0.002381, 0.002297, 0.002350, 0.002295, 0.002236]
//        // DEBUG: 136K: measured [Time, seconds] average: 0.021, relative standard deviation: 5.877%, values: [0.023745, 0.022153, 0.020028, 0.020618, 0.019954, 0.020540, 0.019805, 0.020610, 0.019882, 0.019749]
//        try measureParsing(kind: .jsum)
//    }
//
//    func testParseYamlPerformance() throws {
//        // DEBUG: 14K: measured [Time, seconds] average: 0.081, relative standard deviation: 3.798%, values: [0.090366, 0.079533, 0.079839, 0.080473, 0.080046, 0.080640, 0.080295, 0.080028, 0.081053, 0.079762]
//        // DEBUG: 136K: measured [Time, seconds] average: 4.393, relative standard deviation: 0.629%, values: [4.334819, 4.388781, 4.414601, 4.410179, 4.348408, 4.410852, 4.417285, 4.416433, 4.397261, 4.394936]
//        try measureParsing(kind: .yaml)
//    }

    func testCodableComplete() throws {
        XCTAssertNil(try JSON.codableComplete(data: #"{}"#.utf8Data).difference)
        XCTAssertNil(try JSON.codableComplete(data: #"[]"#.utf8Data).difference)
        XCTAssertNil(try JSON.codableComplete(data: #""x""#.utf8Data).difference)
        XCTAssertNil(try JSON.codableComplete(data: #"12.34"#.utf8Data).difference)
        XCTAssertNil(try JSON.codableComplete(data: #"false"#.utf8Data).difference)
        XCTAssertNil(try JSON.codableComplete(data: #"null"#.utf8Data).difference)

        struct Stuff : Codable {
            let str: String?
            let num: Int?
        }

        XCTAssertNil(try Stuff.codableComplete(data: #"{ "str": "abc" }"#.utf8Data).difference)
        XCTAssertNil(try Stuff.codableComplete(data: #"{ "num": 1234 }"#.utf8Data).difference)

        // missing properties
        XCTAssertNotNil(try Stuff.codableComplete(data: #"{ "nux": 1234 }"#.utf8Data).difference, "should have shown a difference for unrecognized property")
        XCTAssertNotNil(try Stuff.codableComplete(data: #"{ "str": "abc", "q": false }"#.utf8Data).difference, "should have shown a difference for unrecognized property")
    }

    func testJSONCoding() throws {
        struct Simple : Codable {
            var str: String?
            var int: Int?
            var dbl: Double?
            var obj: [String: Simple]?
            var arr: [Bool?]?
            var date: Date?
            var data: Data?
            var url: URL?
        }

        // MARK: Decoding

        XCTAssertEqual("xxx", try Simple(json: ["str": "xxx"]).str)
        XCTAssertEqual(nil, try Simple(json: [:]).int)
        XCTAssertEqual(1, try Simple(json: ["int": 1.2]).int)
        XCTAssertEqual(1.2, try Simple(json: ["obj": ["x": [ "dbl": 1.2 ]]]).obj?["x"]?.dbl)
        XCTAssertEqual(1.2, try Simple(json: ["obj": ["x": [ "dbl": 1.2 ]]]).obj?["x"]?.dbl)

        XCTAssertEqual("https://www.example.com", try Simple(json: ["str": "", "url": "https://www.example.com"]).url?.absoluteString)

        XCTAssertEqual([false, nil, true], try Simple(json: ["arr": [false, nil, true]]).arr)

//        XCTAssertEqual(0, try JSumDecoder(options: .init(dateDecodingStrategy: .iso8601)).decode(Simple.self, from: ["date": .str(Date(timeIntervalSinceReferenceDate: 0).ISO8601Format())]).date?.timeIntervalSinceReferenceDate)
//        XCTAssertEqual(0, try JSumDecoder(options: .init(dateDecodingStrategy: .secondsSince1970)).decode(Simple.self, from: ["date": JSON.num(Date(timeIntervalSinceReferenceDate: 0).timeIntervalSince1970)]).date?.timeIntervalSinceReferenceDate)
//        XCTAssertEqual(0, try JSumDecoder(options: .init(dateDecodingStrategy: .millisecondsSince1970)).decode(Simple.self, from: ["date": JSON.num(Date(timeIntervalSinceReferenceDate: 0).timeIntervalSince1970 * 1000)]).date?.timeIntervalSinceReferenceDate)

//        XCTAssertEqual("abc".utf8Data, try JSumDecoder(options: .init(dataDecodingStrategy: .base64)).decode(Simple.self, from: ["data": JSON.str("YWJj")]).data)

        // a custom decoder that takes an int and decodes a 0-filled Data of that size
//        XCTAssertEqual(Data(repeating: 0, count: 123), try JSumDecoder(options: .init(dataDecodingStrategy: .custom({ decoder in
//            Data(repeating: 0, count: Int(try decoder.singleValueContainer().decode(JSum.self).obj?[decoder.codingPath.last?.stringValue ?? ""]?.num ?? 0))
//        }))).decode(Simple.self, from: ["data": .num(123)]).data)

        // MARK: Encoding

        //XCTAssertEqual("", try Simple(date: Date(timeIntervalSince1970: 0)).json(encoder: JSONEncoder()).utf8String)

        XCTAssertEqual(["str": "XXX"], try Simple(str: "XXX").json())

        XCTAssertEqual(["url": "https://www.example.org"], try Simple(url: URL(string: "https://www.example.org")!).json())

        XCTAssertEqual(["date": -978307200], try Simple(date: Date(timeIntervalSince1970: 0)).json())
        XCTAssertEqual(["date": 978307200], try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).json(options: JSONEncodingOptions(dateEncodingStrategy: .secondsSince1970)))
        // watchOS: Tests/JSONTests/JSONTests.swift:222:33: error: integer literal '978307200000' overflows when stored into 'JSON'
        //XCTAssertEqual(["date": 978307200000], try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).json(options: JSONEncodingOptions(dateEncodingStrategy: .millisecondsSince1970)))
        XCTAssertEqual(["date": "2001-01-01T00:00:00Z"], try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).json(options: JSONEncodingOptions(dateEncodingStrategy: .iso8601)))

        XCTAssertEqual(["data": "CQ=="], try Simple(data: Data([9])).json())
        XCTAssertEqual(["data": "AQID"], try Simple(data: Data([1,2,3])).json(options: JSONEncodingOptions(dataEncodingStrategy: .base64)))
        XCTAssertEqual(["data": 3], try Simple(data: Data([1,2,3])).json(options: JSONEncodingOptions(dataEncodingStrategy: .custom({ data, encoder in
            // custom encoder that just converts the data into the count
            var container = encoder.singleValueContainer()
            try container.encode(data.count)
        }))))

//        XCTAssertEqual(["str": "XXX", "int": 1, "obj": ["s1": ["str": "ZZZ"]], "date": 0.0, "dbl": 2.2, "arr": [false, true, nil], "data": "WFla"], try JSONEncoder().encode(Simple(str: "XXX", int: 1, dbl: 2.2, obj: ["s1": .init(str: "ZZZ")], arr: [false, true, nil], date: Date(timeIntervalSinceReferenceDate: 0), data: "XYZ".utf8Data)))
    }
}
