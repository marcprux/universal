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
            try XCTAssertEqual(json(#"{"node": "1"}"#), xml("<node>1</node>").json())
            try XCTAssertEqual(json(#"{"node": {"node": "1"}}"#), xml("<node><node>1</node></node>").json())
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

