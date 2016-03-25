//
//  CurioTests.swift
//  CurioTests
//
//  Created by Marc Prud'hommeaux on 7/18/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

import XCTest
import BricBrac
@testable import Curio

class CurioTests: XCTestCase {
    
    func testASampleSchema() {
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
                            "properties": [
                                "a1": [ "type": "integer" ],
                                "a2": [ "type": "string" ]
                            ],
                            "required": ["a1", "a2"]
                        ],
                        [
                            "title": "SecondAll",
                            "type": "object",
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
                    "anyOf": [
                        [
                            "title": "FirstAny",
                            "type": "object",
                            "properties": [
                                "b1": [ "type": "integer" ],
                                "b2": [ "type": "string" ]
                            ],
                            "required": ["b1", "b2"]
                        ],
                        [
                            "title": "SecondAny",
                            "type": "object",
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
                "notField": [ // the "notField" is a string that is anything but "illegal"
                    "type": "object",
                    "allOf": [
                        [
                            "type": "object",
                            "properties": [
                                "str": [ "type": "string" ]
                            ],
                            "additionalProperties": false,
                            "required": ["str"]
                        ],
                        [
                            "not": [
                                "type": "object",
                                "properties": [
                                    "str": [ "type": "string", "enum": ["illegal"] ]
                                ],
                                "additionalProperties": false,
                                "required": ["str"]
                            ]
                        ]
                    ]
                ],
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
            "required": ["allOfField", "anyOfField", "oneOfField", "notField"]
        ]

        do {
            let schema = try Schema.brac(schemaBric)
            var gen = Curio()
            gen.generateEquals = true
            let code = try gen.reify(schema, id: "SampleModel", parents: [])
            let module = CodeModule()
            module.types.append(code)
            try gen.emit(module, name: "SampleModel.swift", dir: (#file as NSString).stringByDeletingLastPathComponent)
        } catch {
            XCTFail(String(error))
        }
    }

    func testDerivedSchemas() {
        do {
            // Food-schema.json
            let x = Food(title: "gruel", calories: 120, type: .Carbohydrate)
            XCTAssertEqual(x.bric(), ["title": "gruel", "type": "carbohydrate", "calories": 120])
        }

        do {
            // Products-schema.json
            let x = ProductsItem(id: 10, name: "Stuff", price: 12.34, tags: ["thingy", "stuffy"], dimensions: ProductsItem.Dimensions(length: 11, width: 12, height: 13), warehouseLocation: nil)
            XCTAssertEqual(x.bric(), ["price":12.34,"dimensions":["length":11,"width":12,"height":13],"tags":["thingy","stuffy"],"id":10,"name":"Stuff"])
        }
    }

//    func testSchemaFiles() {
//        let fm = NSFileManager.defaultManager()
//        do {
//            guard let folder = NSBundle(forClass: CurioTests.self).pathForResource("schemas", ofType: "") else { return XCTFail("no schemas folder") }
//
//            for file in try fm.contentsOfDirectoryAtPath(folder) {
//                do {
//                    let fullPath = (folder as NSString).stringByAppendingPathComponent(file)
//                    if file.hasSuffix(".json") {
//                        let bric = try Bric.parse(String(contentsOfFile: fullPath))
//
//                        var curio = Curio()
//                        curio.indirectCountThreshold = 100
//                        curio.accessor = { _ in .Public }
//                        curio.renamer = { (_, id) in
//                            if id == "#" { return "Schema" }
//                            return nil
//                        }
//
//                        let module = CodeModule()
//
//                        var refschema : [String : Schema] = [:]
//                        for (key, value) in try bric.resolve() {
//                            let subschema = try Schema.brac(value)
//                            refschema[key] = subschema
//                            let code = try curio.reify(subschema, id: key, parents: [])
//                            module.types.append(code)
//                        }
//
//                        // TODO: schema doesn't compile yet
//                        if file != "schema.json" {
//                            let id = (file as NSString).stringByDeletingPathExtension
//                            try curio.emit(module, name: id + ".swift", dir: (#file as NSString).stringByDeletingLastPathComponent)
//                        }
//                    }
//                } catch {
//                    XCTFail("schema «\(file)» failed: \(error)")
//                }
//            }
//        } catch {
//            XCTFail("unexpected error when loading schemas: \(error)")
//        }
//    }
}


public class TestSampleModel : XCTestCase {

    func assertBracable(bric: Bric, line: UInt = #line) -> ErrorType? {
        do {
            let sample = try SampleModel.brac(bric)
            XCTAssertEqual(bric, sample.bric(), line: line)
            return nil
        } catch {
            XCTFail(String(error), line: line)
            return error
        }
    }

    func assertNOTBracable(bric: Bric, line: UInt = #line) -> ErrorType? {
        do {
            let _ = try SampleModel.brac(bric)
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
            "notField": [
                "str": "str"
            ]
        ]

        
        bric["anyOfField"] = [:]
        assertNOTBracable(bric)

        bric["anyOfField"] = [ "b1": 1, "b2": "b2" ]
        assertBracable(bric)

        bric["anyOfField"] = [ "b3": true, "b4": 1.2 ]
        assertBracable(bric)

        bric["anyOfField"] = [ "b3": true ]
        assertNOTBracable(bric)

        bric["anyOfField"] = [ "b3": true, "b4": 1.2 ]
        assertBracable(bric)

        bric["simpleOneOf"] = 1
        assertBracable(bric)

        bric["simpleOneOf"] = true
        assertNOTBracable(bric)

        bric["simpleOneOf"] = "x"
        assertBracable(bric)
    }

    func testArrayField() {
        var bric: Bric = [
            "anyOfField": [ "b1": 1, "b2": "b2" ],
            "allOfField": [ "a1": 1, "a2": "a2", "a3": true, "a4": 1.2 ],
            "oneOfField": [ "c1": 1, "c2": "b2", ],
            "notField": [ "str": "str" ]
        ]

        assertBracable(bric)

        bric["list"] = []
        assertBracable(bric)

        bric["list"] = [["prop": "value"], ["prop": "value"], ["prop": "value"]]
        assertBracable(bric)

        bric["list"] = [["prop": "value"], ["prop": "BAD"], ["prop": "value"]]
        if let err = assertNOTBracable(bric) {
            XCTAssertEqual("Invalid value “BAD” at #/list/1/prop of type CurioTests.SampleModel.ListItem.Prop", String(err))
        }

        bric["list"] = [["prop": "value"], ["prop": "value"], [:]]
        if let err = assertNOTBracable(bric) {
            XCTAssertEqual("Missing required property «prop» of type CurioTests.SampleModel.ListItem.Prop at #/list/2", String(err))
        }

        bric["list"] = [["prop": "value"], ["prop": "value"], ["x"]]
        if let err = assertNOTBracable(bric) {
            XCTAssertEqual("Object key «prop» requested in non-object at #/list/2", String(err))
        }
    }

    func testNestedFields() {
        var bric: Bric = [
            "anyOfField": [ "b1": 1, "b2": "b2" ],
            "allOfField": [ "a1": 1, "a2": "a2", "a3": true, "a4": 1.2 ],
            "oneOfField": [ "c1": 1, "c2": "b2", ],
            "notField": [ "str": "str" ]
        ]

        assertBracable(bric)

        bric["nested1"] = [:]
        if let err = assertNOTBracable(bric) {
            XCTAssertEqual("Missing required property «nested2» of type CurioTests.SampleModel.Nested1.Nested2 at #/nested1", String(err))
        }

        bric["nested1"]?["nested2"] = [:]
        if let err = assertNOTBracable(bric) {
            XCTAssertEqual("Missing required property «nested3» of type CurioTests.SampleModel.Nested1.Nested2.Nested3 at #/nested1/nested2", String(err))
        }

        bric["nested1"]?["nested2"]?["nested3"] = [:]
        assertNOTBracable(bric)

        bric["nested1"]?["nested2"]?["nested3"]?["nested4"] = [:]
        assertNOTBracable(bric)

        bric["nested1"]?["nested2"]?["nested3"]?["nested4"]?["nested5"] = [:]
        assertNOTBracable(bric)

        bric["nested1"]?["nested2"]?["nested3"]?["nested4"]?["nested5"]?["single"] = "bad"
        if let err = assertNOTBracable(bric) {
            XCTAssertEqual("Invalid value “bad” at #/nested1/nested2/nested3/nested4/nested5/single of type CurioTests.SampleModel.Nested1.Nested2.Nested3.Nested4.Nested5.Single", String(err))
        }
        bric["nested1"]?["nested2"]?["nested3"]?["nested4"]?["nested5"]?["single"] = "value"
        assertBracable(bric)
    }

    func testVerifyNotFieldFiles() {
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
            "notField": [
                "str": "str"
            ]
        ]

        do {
            let sample = try SampleModel.brac(bric)
            XCTAssertTrue(sample.allOfField.breq(sample.allOfField))
            XCTAssertTrue(sample.anyOfField.breq(sample.anyOfField))
            XCTAssertTrue(sample.oneOfField.breq(sample.oneOfField))
            XCTAssertTrue(sample.notField.breq(sample.notField))
            XCTAssertTrue(sample.simpleOneOf.breq(sample.simpleOneOf))
            XCTAssertTrue(sample.breq(sample))
            XCTAssertTrue(sample == sample)
        } catch {
            XCTFail(String(error))
        }

        do {
//            let badbric = bric.alter { return $0 == ["allOfField", "a1"] ? "illegal" : $1 }
            let badbric = bric.update("illegal", pointer: "allOfField", "a1")

            print(String(badbric))
            try SampleModel.brac(badbric)
            XCTFail("should not have been able to parse invalid schema")
        } catch {
            // validation should fail
        }

        do {
            let badbric = bric.alter { return $0 == ["notField", "str"] ? "illegal" : $1 }
            print(String(badbric))
            try SampleModel.brac(badbric)
            XCTFail("should not have been able to parse invalid schema")
        } catch {
            // validation should fail
            print(error)
        }

    }
}

