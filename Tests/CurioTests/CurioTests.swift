//
//  CurioTests.swift
//  CurioTests
//
//  Created by Marc Prud'hommeaux on 7/18/15.
//  Copyright © 2010-2020 io.glimpse. All rights reserved.
//

import XCTest
import BricBrac
import Curio
import CurioDemoModels

class CurioTests: XCTestCase {
    /// This is a sample schema file
    func testSampleSchema() throws {
        let schemaBric: Bric = [
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": [
                "list": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "required": ["prop"],
                        "properties": [
                            "prop": [ "type": "string", "enum": ["value"] ]
                        ]
                    ]
                ],
                "nested1": [
                    "type": "object",
                    "required": ["nested2"],
                    "properties": [
                        "nested2": [
                            "type": "object",
                            "required": ["nested3"],
                            "properties": [
                                "nested3": [
                                    "type": "object",
                                    "required": ["nested4"],
                                    "properties": [
                                        "nested4": [
                                            "type": "object",
                                            "required": ["nested5"],
                                            "properties": [
                                                "nested5": [
                                                    "type": "object",
                                                    "required": ["single"],
                                                    "properties": [
                                                        "single": [ "type": "string", "enum": ["value"] ]
                                                    ]
                                                ],
                                            ],
                                        ],
                                    ],
                                ],
                            ],
                        ],
                    ],
                    ],
                "allOfField": [
                    "type": "object",
                    "allOf": [
                        [
                            "title": "FirstAll",
                            "type": "object",
                            "additionalProperties": true,
                            "properties": [
                                "a1": [ "type": "integer" ],
                                "a2": [ "type": "string" ]
                            ],
                            "required": ["a1", "a2"]
                        ],
                        [
                            "title": "SecondAll",
                            "type": "object",
                            "additionalProperties": true,
                            "properties": [
                                "a3": [ "type": "boolean" ],
                                "a4": [ "type": "number" ]
                            ],
                            "required": ["a3", "a4"]
                        ]
                    ]
                ],
                "anyOfField": [
                    "type": "object",
                    "additionalProperties": true,
                    "anyOf": [
                        [
                            "title": "FirstAny",
                            "type": "object",
                            "additionalProperties": true,
                            "properties": [
                                "b1": [ "type": "integer" ],
                                "b2": [ "type": "string" ]
                            ],
                            "required": ["b1", "b2"]
                        ],
                        [
                            "title": "SecondAny",
                            "type": "object",
                            "additionalProperties": true,
                            "properties": [
                                "b3": [ "type": "boolean" ],
                                "b4": [ "type": "number" ]
                            ],
                            "required": ["b3", "b4"]
                        ]
                    ]
                ],
                "oneOfField": [
                    "type": "object",
                    "oneOf": [
                        [
                            "title": "FirstOne",
                            "type": "object",
                            "properties": [
                                "c1": [ "type": "integer" ],
                                "c2": [ "type": "string" ]
                            ],
                            "required": ["c1", "c2"]
                        ],
                        [
                            "title": "SecondOne",
                            "type": "object",
                            "properties": [
                                "c3": [ "type": "boolean" ],
                                "c4": [ "type": "number" ]
                            ],
                            "required": ["c3", "c4"]
                        ]
                    ]
                ],
//                "notField": [ // the "notField" is a string that is anything but "illegal"
//                    "type": "object",
//                    "allOf": [
//                        [
//                            "type": "object",
//                            "properties": [
//                                "str": [ "type": "string" ]
//                            ],
//                            "additionalProperties": false,
//                            "required": ["str"]
//                        ],
//                        [
//                            "not": [
//                                "type": "object",
//                                "properties": [
//                                    "str": [ "type": "string", "enum": ["illegal"] ]
//                                ],
//                                "additionalProperties": false,
//                                "required": ["str"]
//                            ]
//                        ]
//                    ]
//                ],
                "keywordFields": [
                    "description": "Should not escape keyword arguments",
                    "type": "object",
                    "properties": [
                        "in": [ "type": "string" ],
                        "for": [ "type": "string" ],
                        "while": [ "type": "string" ],
                        "var": [ "type": "string" ],
                        "let": [ "type": "string" ],
                        "inout": [ "type": "string" ],
                        "case": [ "type": "string" ],
                    ]
                ],
                "simpleOneOf": [
                    "description": "Should generate a simple OneOf enum",
                    "oneOf": [
                        [ "type": "string" ], [ "type": "number" ]
                    ]
                ]
            ],
            "additionalProperties": false,
            "required": ["allOfField", "anyOfField", "oneOfField"] // , "notField"]
        ]

        do {
            let schema = try JSONSchema.bracDecoded(bric: schemaBric)
            let gen = Curio()
            let code = try gen.reify(schema, id: "SampleModel", parents: [])
            let module = CodeModule()
            module.types.append(code)
            let _ = try gen.emit(module, name: "SampleModel.swift", dir: (#file as NSString).deletingLastPathComponent)
        }
    }

    func testSchemaFiles() throws {
        let fm = FileManager.default
        guard let folder = CurioDemoModels.schemasFolder else {
            return XCTFail("no schemas folder")
        }

        for file in try fm.contentsOfDirectory(atPath: folder) {
            do {
                if !file.hasSuffix(".jsonschema") && !file.hasSuffix(".json.schema") {
                    continue
                }

                let fullPath = (folder as NSString).appendingPathComponent(file)
                let bric = try Bric.parse(String(contentsOfFile: fullPath))

                var curio = Curio()
                curio.accessor = { _ in .public }

                if file == "JSONSchema.jsonschema" || file == "JSONSchema.json.schema" {
                    // no point in making the annoteted method, since the JSON Schema doesn't contains descriptions of properties
                    curio.keyDescriptionMethod = false
                    curio.anyOfAsOneOf = true

                    curio.renamer = { (_, id) in
                        if id == "#" {
                            return "JSONSchemaOrBool"
                        }
                        if id == ("JSONSchemaOrBool" + curio.objectChoiceSuffix) {
                            return "JSONSchema"
                        }
                        return nil
                    }
                }

                let module = CodeModule()

                var refschema : [String : JSONSchema] = [:]
                for (key, value) in try bric.resolve() {
                    var subschema = try JSONSchema.bracDecoded(bric: value)

                    if file == "JSONSchema.jsonschema" ||
                        file == "JSONSchema.json.schema" {
                        if key == "#" {
                            // hack in the proposed `propertyOrder` for JSON Schema until there is some native solution:
                            // see: https://github.com/json-schema/json-schema/issues/119
                            // other impl: https://github.com/quicktype/quicktype/pull/1340
                            var propertyOrder = JSONSchema(type: .init(.array))
                            propertyOrder.items = .init(.init(.init(type: .init(.string))))
                            subschema.properties.faulted["propertyOrder"] = .init(propertyOrder)
                        }
                    }

                    refschema[key] = subschema
                    let code = try curio.reify(subschema, id: key, parents: [])
                    module.types.append(code)
                }

                let id = (file as NSString).deletingPathExtension
                let _ = try curio.emit(module, name: id + ".swift", dir: (#file as NSString).deletingLastPathComponent)
            } catch {
                XCTFail("schema «\(file)» failed: \(error)")
            }
        }
    }
}

public class TestSampleModel : XCTestCase {

    @discardableResult func assertBracable(bric: Bric, line: UInt = #line) -> Error? {
        do {
//            let sample = try SampleModel.brac(bric: bric)
            let sample = try SampleModel.bracDecoded(bric: bric)
            XCTAssertEqual(bric, try sample.bricEncoded(), line: line)
            return nil
        } catch {
            XCTFail(String(describing: error), line: line)
            return error
        }
    }

    @discardableResult func assertNOTBracable(bric: Bric, line: UInt = #line) -> Error? {
        do {
            _ = try SampleModel.bracDecoded(bric: bric)
            XCTFail("should not have bracd", line: line)
            return nil
        } catch {
            return error
        }
    }

    func testAnyOfField() {
        var bric: Bric = [
            "allOfField": [
                "a1": 1,
                "a2": "a2",
                "a3": true,
                "a4": 1.2
            ],
            "oneOfField": [
                "c1": 1,
                "c2": "b2",
            ],
//            "notField": [
//                "str": "str"
//            ]
        ]

        
        bric["anyOfField"] = [:]
        assertNOTBracable(bric: bric)

        bric["anyOfField"] = [ "b1": 1, "b2": "b2" ]
        assertBracable(bric: bric)

        bric["anyOfField"] = [ "b3": true, "b4": 1.2 ]
        assertBracable(bric: bric)

        bric["anyOfField"] = [ "b3": true ]
        assertNOTBracable(bric: bric)

        bric["anyOfField"] = [ "b3": true, "b4": 1.2 ]
        assertBracable(bric: bric)

        bric["simpleOneOf"] = 1
        assertBracable(bric: bric)

        bric["simpleOneOf"] = true
        assertNOTBracable(bric: bric)

        bric["simpleOneOf"] = "x"
        assertBracable(bric: bric)
    }

    func testForbidAdditionalProperties() {
        var bric: Bric = [
            "anyOfField": [ "b1": 1, "b2": "b2" ],
            "allOfField": [ "a1": 1, "a2": "a2", "a3": true, "a4": 1.2 ],
            "oneOfField": [ "c1": 1, "c2": "b2", ],
            "XXX": "YYY"
        ]

        assertNOTBracable(bric: bric)

        bric["XXX"] = nil
        assertBracable(bric: bric)
    }

    func testArrayField() {
        var bric: Bric = [
            "anyOfField": [ "b1": 1, "b2": "b2" ],
            "allOfField": [ "a1": 1, "a2": "a2", "a3": true, "a4": 1.2 ],
            "oneOfField": [ "c1": 1, "c2": "b2", ],
//            "notField": [ "str": "str" ]
        ]

        assertBracable(bric: bric)

        bric["list"] = []
        assertBracable(bric: bric)

        bric["list"] = [["prop": "value"], ["prop": "value"], ["prop": "value"]]
        assertBracable(bric: bric)

        bric["list"] = [["prop": "value"], ["prop": "BAD"], ["prop": "value"]]
        if let err = assertNOTBracable(bric: bric) {
//            XCTAssertEqual("Invalid value “BAD” at #/list/1/prop of type CurioTests.SampleModel.ListItem.Prop", String(describing: err))
            XCTAssertTrue(String(describing: err).contains("invalid String value BAD"), String(describing: err))
        }

        bric["list"] = [["prop": "value"], ["prop": "value"], [:]]
        if let err = assertNOTBracable(bric: bric) {
//            XCTAssertEqual("Missing required property «prop» of type CurioTests.SampleModel.ListItem.Prop at #/list/2", String(describing: err))
            XCTAssertTrue(String(describing: err).contains("\"prop\""), String(describing: err))

        }

        bric["list"] = [["prop": "value"], ["prop": "value"], ["x"]]
        if let err = assertNOTBracable(bric: bric) {
//            XCTAssertEqual("Object key «prop» requested in non-object at #/list/2", String(describing: err))
            XCTAssertTrue(String(describing: err).contains("Expected to decode Dictionary"), String(describing: err))
        }
    }

    func testNestedFields() {
        var bric: Bric = [
            "anyOfField": [ "b1": 1, "b2": "b2" ],
            "allOfField": [ "a1": 1, "a2": "a2", "a3": true, "a4": 1.2 ],
            "oneOfField": [ "c1": 1, "c2": "b2", ],
//            "notField": [ "str": "str" ]
        ]

        assertBracable(bric: bric)

        bric["nested1"] = [:]
        if let err = assertNOTBracable(bric: bric) {
//            XCTAssertEqual("Missing required property «nested2» of type CurioTests.SampleModel.Nested1.Nested2 at #/nested1", String(describing: err))
            XCTAssertTrue(String(describing: err).contains("\"nested2\""), String(describing: err))
        }

        bric["nested1"]?["nested2"] = [:]
        if let err = assertNOTBracable(bric: bric) {
//            XCTAssertEqual("Missing required property «nested3» of type CurioTests.SampleModel.Nested1.Nested2.Nested3 at #/nested1/nested2", String(describing: err))
            XCTAssertTrue(String(describing: err).contains("\"nested3\""), String(describing: err))
        }

        bric["nested1"]?["nested2"]?["nested3"] = [:]
        assertNOTBracable(bric: bric)

        bric["nested1"]?["nested2"]?["nested3"]?["nested4"] = [:]
        assertNOTBracable(bric: bric)

        bric["nested1"]?["nested2"]?["nested3"]?["nested4"]?["nested5"] = [:]
        assertNOTBracable(bric: bric)

//        bric["nested1"]?["nested2"]?["nested3"]?["nested4"]?["nested5"]?["single"] = "bad"
//        if let err = assertNOTBracable(bric: bric) {
//            XCTAssertEqual("Invalid value “bad” at #/nested1/nested2/nested3/nested4/nested5/single of type CurioTests.SampleModel.Nested1.Nested2.Nested3.Nested4.Nested5.Single", String(describing: err))
//        }
//        bric["nested1"]?["nested2"]?["nested3"]?["nested4"]?["nested5"]?["single"] = "value"
//        assertBracable(bric: bric)
    }

    func testVerifyNotFieldFiles() throws {
        let bric: Bric = [
            "allOfField": [
                "a1": 1,
                "a2": "a2",
                "a3": true,
                "a4": 1.2
            ],
            "anyOfField": [
                "b1": 1,
                "b2": "b2",
                "b3": true,
                "b4": 1.2
            ],
            "oneOfField": [
                "c1": 1,
                "c2": "b2",
            ],
//            "notField": [
//                "str": "str"
//            ]
        ]

        do {
            let sample = try SampleModel.bracDecoded(bric: bric)
//            XCTAssertTrue(sample.allOfField.breq(sample.allOfField))
//            XCTAssertTrue(sample.anyOfField.breq(sample.anyOfField))
//            XCTAssertTrue(sample.oneOfField.breq(sample.oneOfField))
//            XCTAssertTrue(sample.notField.breq(sample.notField))
            XCTAssertTrue(sample == sample)
        }

        do {
//            let badbric = bric.alter { return $0 == ["allOfField", "a1"] ? "illegal" : $1 }
            if let badbric = bric.update("illegal", pointer: "allOfField", "a1") {
                print(String(describing: badbric))
                _ = try SampleModel.bracDecoded(bric: badbric)
                XCTFail("should not have been able to parse invalid schema")
            }
        } catch {
            // validation should fail
        }

//        do {
//            let badbric = bric.alter { return $0 == ["notField", "str"] ? "illegal" : $1 }
//            print(String(describing: badbric))
//            _ = try SampleModel.bracDecoded(bric: badbric)
//            XCTFail("should not have been able to parse invalid schema")
//        } catch {
//            // validation should fail
//            print(error)
//        }

    }
}
