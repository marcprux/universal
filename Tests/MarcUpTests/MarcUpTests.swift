/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
import XCTest
import MarcUp
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class JSumTests : XCTestCase {
    func testJSum() throws {
        let js: JSum = [
            "string": "hello",
            "number": 1.23,
            "null": nil,
            "array": [1, nil, "foo"],
            "object": [
                "x": "a",
                "y": 5,
                "z": [:]
            ]
        ]

        XCTAssertEqual(js["string"], "hello")
        XCTAssertEqual(js["string"]?.str, "hello")

        XCTAssertEqual(js["number"], 1.23)
        XCTAssertEqual(js["number"]?.num, 1.23)

        XCTAssertEqual(js["null"], JSum.nul)
        XCTAssertNotNil(js["null"]?.nul)

        XCTAssertEqual(js["array"], [1, nil, "foo"])
        XCTAssertEqual(js["array"]?.arr, [1, nil, "foo"])

        XCTAssertEqual(js["object"]?["x"], "a")
        XCTAssertEqual(js["object"]?["x"]?.str, "a")

        XCTAssertEqual(js["array"]?[0], 1)
        XCTAssertEqual(js["array"]?[1], .nul)
        XCTAssertEqual(js["array"]?[2], "foo")
        XCTAssertNil(js["array"]?[3])

        let data = try js.json()
        XCTAssertEqual(data.utf8String, """
        {"array":[1,null,"foo"],"null":null,"number":1.23,"object":{"x":"a","y":5,"z":{}},"string":"hello"}
        """)

        let js2 = try JSum(json: data)
        XCTAssertEqual(js, js2)
    }


    /// Create a seeded random JSum for deserialization performance testing.
    /// - Parameters:
    ///   - depth: how deep to make the graph
    ///   - breadth: how many elements each object/array level of the graph should contain
    ///   - seed: the random seed
    /// - Returns: a JSum object full of random junk
    func createSampleJSON(depth: Int, breadth: Int, rng: inout some RandomNumberGenerator) -> JSum {
        func coinFlip() -> Bool {
            .random(using: &rng)
        }

        /// Creates a UUID with the given generator
        func uuid() -> UUID {
            UUID(rnd: &rng)
        }

        var values: [JSum] = []
        for _ in 0..<breadth {
            if depth > 1 && coinFlip() {
                // create an object child
                let child = createSampleJSON(depth: depth - 1, breadth: breadth, rng: &rng)
                values.append(child)
            } else {
                // create a primitive child
                switch Int.random(in: 0...3, using: &rng) {
                case 0: values.append(JSum.bol(.random(using: &rng)))
                case 1: values.append(JSum.num(Double.random(in: -999999...999999, using: &rng)))
                case 2: values.append(JSum.str(uuid().uuidString))
                default: values.append(.nul)
                }
            }
        }


        if coinFlip() { // make the element an object
            var obj = JObj()
            for value in values {
                obj[uuid().uuidString] = value
            }
            return .obj(obj)
        } else { // !coinFlip: make the elements an array
            return .arr(values)
        }

    }

//    func testParseJSONPerformance() throws {
//        // DEBUG: 14K: measured [Time, seconds] average: 0.004, relative standard deviation: 20.388%, values: [0.006096, 0.003659, 0.003470, 0.003649, 0.003550, 0.003524, 0.003419, 0.003496, 0.003568, 0.003460]
//        // DEBUG: 136K: measured [Time, seconds] average: 0.031, relative standard deviation: 20.316%, values: [0.049674, 0.030524, 0.029786, 0.028808, 0.027710, 0.028118, 0.028606, 0.028499, 0.028976, 0.028782]
//        try measureParsing(kind: .json)
//    }
//
//    func testParseJSumPerformance() throws {
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
        XCTAssertNil(try JSum.codableComplete(data: #"{}"#.utf8Data).difference)
        XCTAssertNil(try JSum.codableComplete(data: #"[]"#.utf8Data).difference)
        XCTAssertNil(try JSum.codableComplete(data: #""x""#.utf8Data).difference)
        XCTAssertNil(try JSum.codableComplete(data: #"12.34"#.utf8Data).difference)
        XCTAssertNil(try JSum.codableComplete(data: #"false"#.utf8Data).difference)
        XCTAssertNil(try JSum.codableComplete(data: #"null"#.utf8Data).difference)

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

    func testJSumCoding() throws {
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

        XCTAssertEqual("xxx", try Simple(jsum: ["str": "xxx"]).str)
        XCTAssertEqual(nil, try Simple(jsum: [:]).int)
        XCTAssertEqual(1, try Simple(jsum: ["int": 1.2]).int)
        XCTAssertEqual(1.2, try Simple(jsum: ["obj": ["x": [ "dbl": 1.2 ]]]).obj?["x"]?.dbl)
        XCTAssertEqual(1.2, try Simple(jsum: ["obj": ["x": [ "dbl": 1.2 ]]]).obj?["x"]?.dbl)

        XCTAssertEqual("https://www.example.com", try Simple(jsum: ["str": "", "url": "https://www.example.com"]).url?.absoluteString)

        XCTAssertEqual([false, nil, true], try Simple(jsum: ["arr": [false, nil, true]]).arr)

//        XCTAssertEqual(0, try JSumDecoder(options: .init(dateDecodingStrategy: .iso8601)).decode(Simple.self, from: ["date": .str(Date(timeIntervalSinceReferenceDate: 0).ISO8601Format())]).date?.timeIntervalSinceReferenceDate)
        XCTAssertEqual(0, try JSumDecoder(options: .init(dateDecodingStrategy: .secondsSince1970)).decode(Simple.self, from: ["date": .num(Date(timeIntervalSinceReferenceDate: 0).timeIntervalSince1970)]).date?.timeIntervalSinceReferenceDate)
        XCTAssertEqual(0, try JSumDecoder(options: .init(dateDecodingStrategy: .millisecondsSince1970)).decode(Simple.self, from: ["date": .num(Date(timeIntervalSinceReferenceDate: 0).timeIntervalSince1970 * 1000)]).date?.timeIntervalSinceReferenceDate)

        XCTAssertEqual("abc".utf8Data, try JSumDecoder(options: .init(dataDecodingStrategy: .base64)).decode(Simple.self, from: ["data": .str("YWJj")]).data)

        // a custom decoder that takes an int and decodes a 0-filled Data of that size
        XCTAssertEqual(Data(repeating: 0, count: 123), try JSumDecoder(options: .init(dataDecodingStrategy: .custom({ decoder in
            Data(repeating: 0, count: Int(try decoder.singleValueContainer().decode(JSum.self).obj?[decoder.codingPath.last?.stringValue ?? ""]?.num ?? 0))
        }))).decode(Simple.self, from: ["data": .num(123)]).data)

        // MARK: Encoding

        //XCTAssertEqual("", try Simple(date: Date(timeIntervalSince1970: 0)).json(encoder: JSONEncoder()).utf8String)

        XCTAssertEqual(["str": "XXX"], try Simple(str: "XXX").jsum())

        XCTAssertEqual(["url": "https://www.example.org"], try Simple(url: URL(string: "https://www.example.org")!).jsum())

        XCTAssertEqual(["date": -978307200], try Simple(date: Date(timeIntervalSince1970: 0)).jsum())
        XCTAssertEqual(["date": 978307200], try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).jsum(options: JSumEncodingOptions(dateEncodingStrategy: .secondsSince1970)))
        XCTAssertEqual(["date": 978307200000], try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).jsum(options: JSumEncodingOptions(dateEncodingStrategy: .millisecondsSince1970)))
        XCTAssertEqual(["date": "2001-01-01T00:00:00Z"], try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).jsum(options: JSumEncodingOptions(dateEncodingStrategy: .iso8601)))

        XCTAssertEqual(["data": "CQ=="], try Simple(data: Data([9])).jsum())
        XCTAssertEqual(["data": "AQID"], try Simple(data: Data([1,2,3])).jsum(options: JSumEncodingOptions(dataEncodingStrategy: .base64)))
        XCTAssertEqual(["data": 3], try Simple(data: Data([1,2,3])).jsum(options: JSumEncodingOptions(dataEncodingStrategy: .custom({ data, encoder in
            // custom encoder that just converts the data into the count
            var container = encoder.singleValueContainer()
            try container.encode(data.count)
        }))))

        XCTAssertEqual(["str": "XXX", "int": 1, "obj": ["s1": ["str": "ZZZ"]], "date": 0.0, "dbl": 2.2, "arr": [false, true, nil], "data": "WFla"], try JSumEncoder().encode(Simple(str: "XXX", int: 1, dbl: 2.2, obj: ["s1": .init(str: "ZZZ")], arr: [false, true, nil], date: Date(timeIntervalSinceReferenceDate: 0), data: "XYZ".utf8Data)))
    }
}

extension UUID {
    /// Creates a UUID with the given random number generator.
    init<R: RandomNumberGenerator>(rnd: inout R) {
        self.init { UInt8.random(in: .min...(.max), using: &rnd) }
    }

    /// Creates a UUID by populating the bytes with the given block.
    init(bytes: () -> UInt8) {
        self.init(uuid: (bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes()))
    }
}
