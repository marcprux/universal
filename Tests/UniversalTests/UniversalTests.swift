//
//  UniversalTests.swift
//
//  Created by Marc Prud'hommeaux on 6/14/15.
//

import XCTest
import Universal

class UniversalTests : XCTestCase {
    func testCompareFormats() throws {
        let json = { (str: String) in try JSON.parse(str.utf8Data) }

        do {
            try XCTAssertEqual(json(#""abc""#), json(#""abc""#).json())
        }

        let yaml = { (str: String) in try YAML.parse(str.utf8Data) }

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

        let xml = { (str: String) in try XML.parse(str.utf8Data) }

        do {
            try XCTAssertEqual(json(#"{"node": "abc"}"#), xml("<node>abc</node>").json())
            try XCTAssertEqual(json(#"{"node": "1"}"#), xml("<node>1</node>").json())
            try XCTAssertEqual(json(#"{"node": {"node": "1"}}"#), xml("<node><node>1</node></node>").json())
        }
    }

    func testFluentComparisons() {
        XCTAssertEqual([""], try ([""] as YAML).json())
        XCTAssertEqual([1], try ([1] as YAML).json())
        XCTAssertEqual([1.1], try ([1.1] as YAML).json())
        XCTAssertEqual([1.1, nil, "abc", []], try ([1.1, nil, "abc", []] as YAML).json())
        XCTAssertEqual([1.1, nil, "abc", [nil]], try ([1.1, nil, "abc", [nil]] as YAML).json())
    }
}

