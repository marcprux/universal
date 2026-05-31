//
//  UniversalTests.swift
//
//  Created by Marc Prud'hommeaux on 6/14/15.
//

import Testing
import Foundation
import Universal

@Suite struct UniversalTests {
    let json: (String) throws -> JSON = { (str: String) in try JSON.parse(str.utf8Data) }
    let yaml: (String) throws -> YAML = { (str: String) in try YAML.parse(str.utf8Data) }
    let plist: (String) throws -> PLIST = { (str: String) in try PLIST.parse(str.utf8Data) }
    let xml: (String) throws -> XML = { (str: String) in try XML.parse(str.utf8Data) }

    @Test func testUniversalExample() throws {
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

    @Test func testDecodingExample() throws {
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

    @Test func testCompareFormats() throws {

        do {
            let lhs = try json(#""abc""#)
            let rhs = try json(#""abc""#).json()
            #expect(lhs == rhs)
        }

        do {
            let cases: [(String, String)] = [
                (#""abc""#, "abc"),
                (#"1"#, "1"),
                (#"1.1"#, "1.1"),
                (#"true"#, "true"),
                (#"false"#, "false"),
                (#"null"#, "null"),
                (#"[null]"#, "[null]"),
                (#"[null]"#, "- null"),
                (#"[1, 2]"#, "- 1\n- 2"),
                (#"["a", 2.0]"#, "- a\n- 2"),
                (#"[["q"], 2.0]"#, "- - q\n- 2.000000000000"),
                (#"[false, 2.2]"#, "- false\n- 2.2"),
            ]
            for (jsonStr, yamlStr) in cases {
                let lhs = try json(jsonStr)
                let rhs = try yaml(yamlStr).json()
                #expect(lhs == rhs)
            }
        }

        do {
            let cases: [(String, String)] = [
                (#"{"node": "abc"}"#, "<node>abc</node>"),
                (#"{"node": "abc"}"#, "<node>abc</node>"),
                (#"{"node": "1"}"#, "<node>1</node>"),
                (#"{"node": {"node": "1"}}"#, "<node><node>1</node></node>"),
                (#"{"node": {"node": "2"}}"#, "<node><node>2</node></node>"),
                (#"{"node": {"node": ["1", "2"]}}"#, "<node><node>1</node><node>2</node></node>"),
            ]
            for (jsonStr, xmlStr) in cases {
                let lhs = try json(jsonStr)
                let rhs = try xml(xmlStr).json()
                #expect(lhs == rhs)
            }
        }
    }

    @Test func testFluentComparisons() throws {
        #expect(try (nil as YAML).json() == nil)
        #expect(try (true as YAML).json() == true)
        #expect(try (false as YAML).json() == false)
        #expect(try (1 as YAML).json() == 1)
        #expect(try (1.1 as YAML).json() == 1.1)

        #expect(try ([""] as YAML).json() == [""])
        #expect(try ([1] as YAML).json() == [1])
        #expect(try ([1.1] as YAML).json() == [1.1])
        #expect(try ([1.1, nil, "abc", []] as YAML).json() == [1.1, nil, "abc", []])
        #expect(try ([1.1, nil, "abc", [nil]] as YAML).json() == [1.1, nil, "abc", [nil]])

        #expect(try (["x": "1"] as YAML).json() == ["x": "1"])
    }

    @Test func testYAMLJSON() throws {
        #expect(try yaml(#"x: 1"#) == ["x":1])
        #expect(try yaml(#"x: 1"#).json() == ["x":1])
    }

    @Test func testDeserialize() throws {
        struct SomeCodable : Equatable, Decodable {
            let int: Int
        }

        func check<T: Equatable>(_ values: T...) throws {
            for v in values {
                #expect(values.first == v)
            }
        }

        try check([SomeCodable(int: 1)], json(#"[{"int":1.1}]"#).decode(), yaml(#"[{"int":1}]"#).json().decode())
        try check(SomeCodable(int: 1), json(#"{"int":1.1}"#).decode()) // yaml(#"{"int":1.1}"#).json().decode())
    }

    @Test func testMergeJSON() throws {
        #expect(try (1 as JSON).merged(with: 2) == 2)
        #expect(try ("X" as JSON).merged(with: "Y") == "Y")
        #expect(try (1 as JSON).merged(with: "Y") == "Y")

        #expect(try (["A": 1] as JSON).merged(with: ["B": true]) == ["A": 1, "B": true])
        #expect(try (["A": 1] as JSON).merged(with: ["A": true]) == ["A": true])

        #expect(try ([1] as JSON).merged(with: [2, 3]) == [1, 2, 3])
        #expect(try (["A": [1, 2]] as JSON).merged(with: ["A": [1, 2]]) == ["A": [1, 2, 1, 2]])
    }

    @Test func testMergeXML() throws {
        let lhs = try XML.parse(Data("""
        <abc x="1" y="z"/>
        """.utf8))
        let rhs = try XML.parse(Data("""
        <abc x="1"/>
        """.utf8)).merged(with: XML.parse(Data("""
        <abc y="z"/>
        """.utf8)))
        #expect(lhs == rhs)
    }

    @Test func testMergeYAML() throws {
        let lhs = try YAML.parse(Data("""
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
        """.utf8))
        let rhs = try YAML.parse(Data("""
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
        """.utf8)))
        #expect(lhs == rhs)
    }

}
