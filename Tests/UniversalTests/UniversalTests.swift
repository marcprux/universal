//
//  UniversalTests.swift
//
//  Created by Marc Prud'hommeaux on 6/14/15.
//

import XCTest
import Universal


class UniversalTests : XCTestCase {
    let json = { (str: String) in try JSON.parse(str.utf8Data) }
    let yaml = { (str: String) in try YAML.parse(str.utf8Data) }
    let xml = { (str: String) in try XML.parse(str.utf8Data) }

    func testUniversalExample() throws {
        // JSON Parsing
        let json: JSON = try JSON.parse("""
            {"parent": {"child": 1}}
            """.data(using: .utf8)!)

        assert(json["parent"]?["child"] == 1)
        assert(json["parent"]?["child"] == JSON.number(1.0)) // JSON's only number is Double


        // YAML Parsing
        let yaml: YAML = try YAML.parse("""
            parent:
              child: 1
            """.data(using: .utf8)!)

        assert(yaml["parent"]?["child"] == 1)
        assert(yaml["parent"]?["child"] == YAML.integer(1)) // YAML can parse integers
        assert(yaml["parent"]?["child"] != 1.0) // not the same as a double

        let yamlJSON: JSON = try yaml.json() // convert YAML to JSON struct
        assert(yamlJSON == json)


        // XML Parsing
        let xml: XML = try XML.parse("""
            <parent><child>1</child></parent>
            """.data(using: .utf8)!)

        let xmlJSON: JSON = try xml.json() // convert XML to JSON struct

        assert(xml["parent"]?["child"] == XML.string("1")) // XML parses everything as strings

        // fixup the XML by changing the JSON to match
        assert(json["parent"]?["child"] == 1)
        var jsonEdit = json
        jsonEdit["parent"]?["child"] = JSON.string("1") // update the JSON to match
        assert(jsonEdit["parent"]?["child"] == "1") // now the JSON matches

        assert(xmlJSON == jsonEdit)

    }

    func testCompareFormats() throws {

        do {
            try XCTAssertEqual(json(#""abc""#), json(#""abc""#).json())
        }

        do {
            try XCTAssertEqual(json(#""abc""#), yaml("abc").json())
            try XCTAssertEqual(json(#"1"#), yaml("1").json())
            try XCTAssertEqual(json(#"1.1"#), yaml("1.1").json())
            try XCTAssertEqual(json(#"true"#), yaml("true").json())
            try XCTAssertEqual(json(#"false"#), yaml("false").json())
            try XCTAssertEqual(json(#"null"#), yaml("null").json())
            try XCTAssertEqual(json(#"[null]"#), yaml("[null]").json())
            try XCTAssertEqual(json(#"[null]"#), yaml("- null").json())

            try XCTAssertEqual(json(#"[1, 2]"#), yaml("- 1\n- 2").json())
            try XCTAssertEqual(json(#"["a", 2.0]"#), yaml("- a\n- 2").json())
            try XCTAssertEqual(json(#"[["q"], 2.0]"#), yaml("- - q\n- 2.000000000000").json())
            try XCTAssertEqual(json(#"[false, 2.2]"#), yaml("- false\n- 2.2").json())
        }

        do {
            try XCTAssertEqual(json(#"{"node": "abc"}"#), xml("<node>abc</node>").json())
            try XCTAssertEqual(json(#"{"node": "abc"}"#), xml("<node>abc</node>").json())
            try XCTAssertEqual(json(#"{"node": "1"}"#), xml("<node>1</node>").json())
            try XCTAssertEqual(json(#"{"node": {"node": "1"}}"#), xml("<node><node>1</node></node>").json())
            try XCTAssertEqual(json(#"{"node": {"node": "2"}}"#), xml("<node><node>2</node></node>").json())
            try XCTAssertEqual(json(#"{"node": {"node": ["1", "2"]}}"#), xml("<node><node>1</node><node>2</node></node>").json())
        }
    }

    func testFluentComparisons() throws {
        XCTAssertEqual(nil, try (nil as YAML).json())
        XCTAssertEqual(true, try (true as YAML).json())
        XCTAssertEqual(false, try (false as YAML).json())
        XCTAssertEqual(1, try (1 as YAML).json())
        XCTAssertEqual(1.1, try (1.1 as YAML).json())

        XCTAssertEqual([""], try ([""] as YAML).json())
        XCTAssertEqual([1], try ([1] as YAML).json())
        XCTAssertEqual([1.1], try ([1.1] as YAML).json())
        XCTAssertEqual([1.1, nil, "abc", []], try ([1.1, nil, "abc", []] as YAML).json())
        XCTAssertEqual([1.1, nil, "abc", [nil]], try ([1.1, nil, "abc", [nil]] as YAML).json())

        XCTAssertEqual(["x": "1"], try (["x": "1"] as YAML).json())
    }

    func testYAMLJSON() throws {
        XCTAssertEqual(try yaml(#"x: 1"#), ["x":1])
        XCTAssertEqual(try yaml(#"x: 1"#).json(), ["x":1])
    }

    func testDeserialize() throws {
        struct SomeCodable : Equatable, Decodable {
            let int: Int
        }

        func check<T: Equatable>(_ values: T...) throws {
            for v in values {
                XCTAssertEqual(values.first, v)
            }
        }

        try check([SomeCodable(int: 1)], json(#"[{"int":1.1}]"#).decode(), yaml(#"[{"int":1}]"#).json().decode())
        try check(SomeCodable(int: 1), json(#"{"int":1.1}"#).decode()) // yaml(#"{"int":1.1}"#).json().decode())
    }
}

