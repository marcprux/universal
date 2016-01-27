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
                ]
            ],
            "additionalProperties": false,
            "required": ["allOfField", "anyOfField", "oneOfField", "notField"]
        ]

        do {
            let schema = try Schema.brac(schemaBric)
            let gen = Curio()
            let code = try gen.reify(schema, id: "SampleModel", parents: [])
            let module = CodeModule()
            module.types.append(code)
            try gen.createSwiftModule(module, name: "SampleModel.swift", dir: (__FILE__ as NSString).stringByDeletingLastPathComponent)
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
//                            try curio.createSwiftModule(module, name: id + ".swift", dir: (__FILE__ as NSString).stringByDeletingLastPathComponent)
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
        do {
            try SampleModel.brac(bric)
            XCTFail("should not have bracd")
        } catch {
        }

        bric["anyOfField"] = [
            "b1": 1,
            "b2": "b2",
        ]
        do {
            let sample = try SampleModel.brac(bric)
            XCTAssertEqual(bric, sample.bric())
        } catch {
            XCTFail(String(error))
        }

        bric["anyOfField"] = [
            "b3": true,
            "b4": 1.2
        ]
        do {
            let sample = try SampleModel.brac(bric)
            XCTAssertEqual(bric, sample.bric())
        } catch {
            XCTFail(String(error))
        }

        bric["anyOfField"] = [
            "b3": true,
        ]
        do {
            try SampleModel.brac(bric)
            XCTFail("should not have bracd")
        } catch {
        }


//        bric["anyOfField"] = [
//            "b1": 1,
//            "b2": "b2",
//            "b3": true,
//            "b4": 1.2
//        ]
//        do {
//            let sample = try SampleModel.brac(bric)
//            // this is where we need NonEmptyCollection in order to maintain fidelity
//            XCTAssertEqual(bric, sample.bric())
//        } catch {
//            XCTFail(String(error))
//        }

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
            try SampleModel.brac(bric)
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
        }

    }
}
