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
    let plist = { (str: String) in try PLIST.parse(str.utf8Data) }
    let xml = { (str: String) in try XML.parse(str.utf8Data) }

    func testUniversalExample() throws {
        // JSON Parsing
        let json: JSON = try JSON.parse(Data("""
            {"parent": {"child": 1}}
            """.utf8))

        assert(json["parent"]?["child"] == 1)
        assert(json["parent"]?["child"] == JSON.number(1.0)) // JSON's only number is Double


        // YAML Parsing
        let yaml: YAML = try YAML.parse(Data("""
            parent:
              child: 1
            """.utf8))

        assert(yaml["parent"]?["child"] == 1)
        assert(yaml["parent"]?["child"] == YAML.integer(1)) // YAML can parse integers
        assert(yaml["parent"]?["child"] != 1.0) // not the same as a double

        let yamlJSON: JSON = try yaml.json() // convert YAML to JSON struct
        assert(yamlJSON == json)


        // XML Parsing
        let xml: XML = try XML.parse(Data("""
            <parent><child>1</child></parent>
            """.utf8))

        let xmlJSON: JSON = try xml.json() // convert XML to JSON struct

        assert(xml["parent"]?["child"] == XML.string("1")) // XML parses everything as strings

        // fixup the XML by changing the JSON to match
        assert(json["parent"]?["child"] == 1)
        var jsonEdit = json
        jsonEdit["parent"]?["child"] = JSON.string("1") // update the JSON to match
        assert(jsonEdit["parent"]?["child"] == "1") // now the JSON matches

        assert(xmlJSON == jsonEdit)
    }

    func testDecodingExample() throws {
        struct Coded : Decodable, Equatable {
            let person: Person

            struct Person : Decodable, Equatable {
                let firstName: String
                let lastName: String
                let astrologicalSign: String
            }
        }

        let decodedFromJSON = try Coded(json: JSON.parse(Data("""
            {
              "person": {
                "firstName": "Marc",
                "lastName": "Prud'hommeaux",
                "astrologicalSign": "Sagittarius"
              }
            }
            """.utf8)))

        let decodedFromYAML = try Coded(json: YAML.parse(Data("""
            # A YAML version of a Person
            person:
              firstName: Marc
              lastName: Prud'hommeaux
              astrologicalSign: Sagittarius # what's your sign?
            """.utf8)).json())
        assert(decodedFromJSON == decodedFromYAML)

        let decodedFromXML = try Coded(json: XML.parse(Data("""
            <!-- An XML version of a Person -->
            <person>
              <firstName>Marc</firstName>
              <!-- escaping and stuff -->
              <lastName>Prud&apos;hommeaux</lastName>
              <astrologicalSign>Sagittarius</astrologicalSign>
            </person>
            """.utf8)).json())
        assert(decodedFromYAML == decodedFromXML)

        let decodedFromPLISTXML = try Coded(json: PLIST.parse(Data("""
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>person</key>
                <dict>
                    <key>firstName</key>
                    <string>Marc</string>
                    <key>lastName</key>
                    <string>Prud&apos;hommeaux</string>
                    <key>astrologicalSign</key>
                    <string>Sagittarius</string>
                </dict>
            </dict>
            </plist>
            """.utf8)).json())
        assert(decodedFromXML == decodedFromPLISTXML)

        let decodedFromPLISTOpenStep = try Coded(json: PLIST.parse(Data("""
            {
                person = {
                    firstName = Marc;
                    lastName = "Prud'hommeaux";
                    astrologicalSign = Sagittarius;
                };
            }
            """.utf8)).json())
        assert(decodedFromPLISTOpenStep == decodedFromPLISTXML)

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

    func testMergeJSON() throws {
        XCTAssertEqual(2, try (1 as JSON).merged(with: 2))
        XCTAssertEqual("Y", try ("X" as JSON).merged(with: "Y"))
        XCTAssertEqual("Y", try (1 as JSON).merged(with: "Y"))

        XCTAssertEqual(["A": 1, "B": true], try (["A": 1] as JSON).merged(with: ["B": true]))
        XCTAssertEqual(["A": true], try (["A": 1] as JSON).merged(with: ["A": true]))

        XCTAssertEqual([1, 2, 3], try ([1] as JSON).merged(with: [2, 3]))
        XCTAssertEqual(["A": [1, 2, 1, 2]], try (["A": [1, 2]] as JSON).merged(with: ["A": [1, 2]]))
    }

    func testMergeXML() throws {
        try XCTAssertEqual(XML.parse(Data("""
        <abc x="1" y="z"/>
        """.utf8)), XML.parse(Data("""
        <abc x="1"/>
        """.utf8)).merged(with: XML.parse(Data("""
        <abc y="z"/>
        """.utf8))))
    }

    func testMergeYAML() throws {
        try XCTAssertEqual(YAML.parse(Data("""
        root:
            a: x
            c: d
            values:
                - 1
                - dict:
                    q: z
                - 2
                - dict:
                    z: q
        """.utf8)), YAML.parse(Data("""
        root:
            a: b
            values:
                - 1
                - dict:
                    q: z
        """.utf8)).merged(with: YAML.parse(Data("""
        root:
            c: d
            a: x
            values:
                - 2
                - dict:
                    z: q
        """.utf8))))
    }

}

