//
//  JSONTests.swift
//
//  Created by Marc Prud'hommeaux on 6/14/15.
//
import Testing
import Foundation
import JSON
import Either


@Suite struct JSONTests {
    @Test func testJSON() throws {
        #expect(nil == JSON.null)
        #expect("JSON.null" == JSON.null.description)
        #expect(false == JSON.false)
        #expect("JSON.boolean(false)" == JSON.false.description)
        #expect(true == JSON.true)
        #expect("JSON.boolean(true)" == JSON.true.description)

        #expect(1 == 1 as JSON)
        #expect("JSON.number(1.0)" == (1 as JSON).description)
        #expect("X" == "X" as JSON)
        #expect("JSON.string(\"X\")" == ("X" as JSON).description)

        #expect(false == false as JSON)
        #expect(nil == nil as JSON)

        #expect([nil] == [nil] as JSON)
        #expect("JSON.array([JSON.null])" == ([nil] as JSON).description)

        #expect(["X": nil] == ["X": nil] as JSON)
        #expect("JSON.object([\"X\": JSON.null])" == (["X": nil] as JSON).description)

        #expect(["X": [1, 2.3, true, nil, "Y", ["Z"]]] == ["X": [1, 2.3, true, nil, "Y", ["Z"]]] as JSON)
        #expect(#"JSON.object(["X": JSON.array([JSON.number(1.0), JSON.number(2.3), JSON.boolean(true), JSON.null, JSON.string("Y"), JSON.array([JSON.string("Z")])])])"# == (["X": [1, 2.3, true, nil, "Y", ["Z"]]] as JSON).description)

        #expect(JSON.object(["X": .array([.number(1.0), .number(2.3), .boolean(true), .null, .string("Y"), .array([.string("Z")])])]) == (["X": [1, 2.3, true, nil, "Y", ["Z"]]] as JSON))

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

        #expect(js["string"] == "hello")
        #expect(js["string"]?.string == "hello")

        #expect(js["number"] == 1.23)
        #expect(js["number"]?.number == 1.23)

        #expect(js["null"] == JSON.null)
        #expect(true == js["null"]?.isNull)

        #expect(js["array"] == [1, nil, "foo"])
        #expect(js["array"]?.array == [1, nil, "foo"])

        #expect(js["object"]?["x"] == "a")
        #expect(js["object"]?["x"]?.string == "a")

        #expect(js["array"]?[0] == 1)
        #expect(js["array"]?[1] == .null)
        #expect(js["array"]?[2] == "foo")

        #expect(try JSON(fromJSON: "null".utf8Data) == JSON.null)
        #expect(try JSON(fromJSON: "false".utf8Data) == JSON.false)
        #expect(try JSON(fromJSON: "true".utf8Data) == JSON.true)
        #expect(try JSON(fromJSON: "1.0".utf8Data) == 1.0)
        #expect(try JSON(fromJSON: "1.1".utf8Data) == 1.1)
        #expect(try JSON(fromJSON: #""abc""#.utf8Data) == "abc")
        #expect(try JSON(fromJSON: #"["abc"]"#.utf8Data) == ["abc"])

        let json = try js.canonicalJSON

        #expect(json == """
        {"array":[1,null,"foo"],"bool":false,"null":null,"number":1.23,"object":{"x":"a","y":5,"z":{}},"string":"hello"}
        """)

        try #expect(js.prettyJSON == """
        {
          "array" : [
            1,
            null,
            "foo"
          ],
          "bool" : false,
          "null" : null,
          "number" : 1.23,
          "object" : {
            "x" : "a",
            "y" : 5,
            "z" : {

            }
          },
          "string" : "hello"
        }
        """)

        let js2 = try JSON(fromJSON: json.utf8Data)
        #expect(js == js2)
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

    @Test func testCodableComplete() throws {
        #expect(try JSON.codableComplete(data: #"{}"#.utf8Data).difference == nil)
        #expect(try JSON.codableComplete(data: #"[]"#.utf8Data).difference == nil)
        #expect(try JSON.codableComplete(data: #""x""#.utf8Data).difference == nil)
        #expect(try JSON.codableComplete(data: #"12.34"#.utf8Data).difference == nil)
        #expect(try JSON.codableComplete(data: #"false"#.utf8Data).difference == nil)
        #expect(try JSON.codableComplete(data: #"null"#.utf8Data).difference == nil)

        struct Stuff : Codable {
            let str: String?
            let num: Int?
        }

        #expect(try Stuff.codableComplete(data: #"{ "str": "abc" }"#.utf8Data).difference == nil)
        #expect(try Stuff.codableComplete(data: #"{ "num": 1234 }"#.utf8Data).difference == nil)

        // missing properties
        #expect(try Stuff.codableComplete(data: #"{ "nux": 1234 }"#.utf8Data).difference != nil, "should have shown a difference for unrecognized property")
        #expect(try Stuff.codableComplete(data: #"{ "str": "abc", "q": false }"#.utf8Data).difference != nil, "should have shown a difference for unrecognized property")
    }

    @Test func testJSONCoding() throws {
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

        #expect(try Simple(json: ["str": "xxx"]).str == "xxx")
        #expect(try Simple(json: [:]).int == nil)
        #expect(try Simple(json: ["int": 1.2]).int == 1)
        #expect(try Simple(json: ["obj": ["x": [ "dbl": 1.2 ]]]).obj?["x"]?.dbl == 1.2)
        #expect(try Simple(json: ["obj": ["x": [ "dbl": 1.2 ]]]).obj?["x"]?.dbl == 1.2)

        #expect(try Simple(json: ["str": "", "url": "https://www.example.com"]).url?.absoluteString == "https://www.example.com")

        #expect(try Simple(json: ["arr": [false, nil, true]]).arr == [false, nil, true])

        // MARK: Encoding

        #expect(try Simple(str: "XXX").json() == ["str": "XXX"])

        #expect(try Simple(url: URL(string: "https://www.example.org")!).json() == ["url": "https://www.example.org"])

        #expect(try Simple(date: Date(timeIntervalSince1970: 0)).json() == ["date": -978307200])
        #expect(try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).json(options: JSONEncodingOptions(dateEncodingStrategy: .secondsSince1970)) == ["date": 978307200])
        // watchOS: Tests/JSONTests/JSONTests.swift:222:33: error: integer literal '978307200000' overflows when stored into 'JSON'
        //#expect(try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).json(options: JSONEncodingOptions(dateEncodingStrategy: .millisecondsSince1970)) == ["date": 978307200000])
        #expect(try Simple(date: Date(timeIntervalSinceReferenceDate: 0)).json(options: JSONEncodingOptions(dateEncodingStrategy: .iso8601)) == ["date": "2001-01-01T00:00:00Z"])

        #expect(try Simple(data: Data([9])).json() == ["data": "CQ=="])
        #expect(try Simple(data: Data([1,2,3])).json(options: JSONEncodingOptions(dataEncodingStrategy: .base64)) == ["data": "AQID"])
        #expect(try Simple(data: Data([1,2,3])).json(options: JSONEncodingOptions(dataEncodingStrategy: .custom({ data, encoder in
            // custom encoder that just converts the data into the count
            var container = encoder.singleValueContainer()
            try container.encode(data.count)
        }))) == ["data": 3])
    }
}
