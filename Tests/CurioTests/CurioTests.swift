//
//  CurioTests.swift
//  CurioTests
//
//  Created by Marc Prud'hommeaux on 7/18/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

import XCTest
import BricBrac
import Curio
import CurioDemoModels

class CurioTests: XCTestCase {
    
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
            let schema = try Schema.bracDecoded(bric: schemaBric)
            let gen = Curio()
            let code = try gen.reify(schema, id: "SampleModel", parents: [])
            let module = CodeModule()
            module.types.append(code)
            try gen.emit(module, name: "SampleModel.swift", dir: (#file as NSString).deletingLastPathComponent)
        }
    }

//    func testDerivedSchemas() {
//        do {
//            // Food-schema.json
//            let x = Food(title: "gruel", calories: 120, type: .carbohydrate)
//            XCTAssertEqual(x.bric(), ["title": "gruel", "type": "carbohydrate", "calories": 120])
//        }
//
//        do {
//            // Products-schema.json
//            let x = ProductsItem(id: 10, name: "Stuff", price: 12.34, tags: ["thingy", "stuffy"], dimensions: ProductsItem.Dimensions(length: 11, width: 12, height: 13), warehouseLocation: nil)
//            XCTAssertEqual(x.bric(), ["price":12.34,"dimensions":["length":11,"width":12,"height":13],"tags":["thingy","stuffy"],"id":10,"name":"Stuff"])
//        }
//    }

    func testSchemaFiles() {
        let fm = FileManager.default
        do {
            guard let folder = CurioDemoModels.schemasFolder else { return XCTFail("no schemas folder") }

            for file in try fm.contentsOfDirectory(atPath: folder) {
                do {
                    if !file.hasSuffix(".jsonschema") { continue }

                    let fullPath = (folder as NSString).appendingPathComponent(file)
                    let bric = try Bric.parse(String(contentsOfFile: fullPath))

                    var curio = Curio()
                    curio.accessor = { _ in .public }
                    curio.renamer = { (_, id) in
                        if id == "#" { return "Schema" }
                        return nil
                    }

                    let module = CodeModule()

                    var refschema : [String : Schema] = [:]
                    for (key, value) in try bric.resolve() {
                        let subschema = try Schema.bracDecoded(bric: value)
                        refschema[key] = subschema
                        let code = try curio.reify(subschema, id: key, parents: [])
                        module.types.append(code)
                    }

                    // TODO: schema doesn't compile yet
                    if file == "schema.jsonschema" { continue }

                    let id = (file as NSString).deletingPathExtension
                    try curio.emit(module, name: id + ".swift", dir: (#file as NSString).deletingLastPathComponent)
                } catch {
                    XCTFail("schema «\(file)» failed: \(error)")
                }
            }
        } catch {
            XCTFail("unexpected error when loading schemas: \(error)")
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
        return

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
            let badbric = bric.update("illegal", pointer: "allOfField", "a1")

            print(String(describing: badbric))
            _ = try SampleModel.bracDecoded(bric: badbric)
            XCTFail("should not have been able to parse invalid schema")
        } catch {
            // validation should fail
        }

        do {
            let badbric = bric.alter { return $0 == ["notField", "str"] ? "illegal" : $1 }
            print(String(describing: badbric))
            _ = try SampleModel.bracDecoded(bric: badbric)
            XCTFail("should not have been able to parse invalid schema")
        } catch {
            // validation should fail
            print(error)
        }

    }
}



//// Vega-lite schema hand-generated from v2.5.2.json
//
//public protocol MarkPropFieldDef { }
//public typealias Color = String
//public typealias Font = String
//public typealias Field = String
//public enum LabelOverlap : String, Codable, Equatable { case parity, greedy }
//
//public typealias Aggregate = AggregateOp
//
//public enum AggregateOp : String, Codable, Equatable { case argmax, argmin, average, count, distinct, max, mean, median, min, missing, q1, q3, ci0, ci1, stderr, stdev, stdevp, sum, valid, values, variance, variancep }
//
//public struct AggregateTransform : Codable, Equatable {
//    public var aggregate: [AggregatedFieldDef]
//    public var groupby: [String]?
//}
//
//public struct AggregatedFieldDef : Codable, Equatable {
//    public var `as`: Field
//    public var field: Field?
//    public var op: AggregateOp
//}
//
//public enum Anchor : String, Codable, Equatable { case start, middle, end }
//public enum StrokeCap : String, Codable, Equatable { case butt, round, square }
//public enum Cursor : String, Codable, Equatable {
//    case auto = "auto", `default` = "default", none = "none", contextmenu = "context-menu", help = "help", pointer = "pointer", progress = "progress", wait = "wait", cell = "cell", crosshair = "crosshair", text = "text", verticaltext = "vertical-text", alias = "alias", copy = "copy", move = "move", nodrop = "no-drop", notallowed = "not-allowed", eresize = "e-resize", nresize = "n-resize", neresize = "ne-resize", nwresize = "nw-resize", sresize = "s-resize", seresize = "se-resize", swresize = "sw-resize", wresize = "w-resize", ewresize = "ew-resize", nsresize = "ns-resize", neswresize = "nesw-resize", nwseresize = "nwse-resize", colresize = "col-resize", rowresize = "row-resize", allscroll = "all-scroll", zoomin = "zoom-in", zoomout = "zoom-out", grab = "grab", grabbing = "grabbing"
//}
//
//public typealias AnyMark = OneOf2<Mark, MarkDef>
//
//public struct AreaConfig : Codable, Equatable {
//    public var align: HorizontalAlign?
//    public var angle: Double?
//    public var baseline: VerticalAlign?
//    public var color: Color?
//    public var cursor: Cursor?
//    public var dx: Double?
//    public var dy: Double?
//    public var fill: Color?
//    public var fillOpacity: Double?
//    public var filled: Bool?
//    public var font: Font?
//    public var fontSize: Double?
//    public var fontStyle: FontStyle?
//    public var fontWeight: FontWeight?
//    public var href: URL?
//    public var interpolate: Interpolate?
//    public var limit: Double?
//    public var line: OneOf2<Bool, MarkConfig>?
//    public var opacity: Double?
//    public var orient: Orient?
//    public var point: OneOf3<Bool, MarkConfig, Transparent>?
//    public enum Transparent : String, Codable, Equatable { case transparent }
//    public var radius: Double?
//    public var shape: String?
//    public var size: Double?
//    public var stroke: Color?
//    public var strokeCap: StrokeCap?
//    public var strokeDash: [Double]?
//    public var strokeDashOffset: Double?
//    public var strokeOpacity: Double?
//    public var strokeWidth: Double?
//    public var tension: Double?
//    public var text: String?
//    public var theta: Double?
//}
//
//public struct AutoSizeParams : Codable, Equatable {
//    public var contains: Contains?
//    public enum Contains : String, Codable, Equatable { case content, padding }
//    public var resize: Bool?
//    public var `type`: AutosizeType?
//}
//
//public enum AutosizeType : String, Codable, Equatable { case pad, fit, none }
//
//public struct Axis : Codable, Equatable {
//    public var domain: Bool?
//    public var format: String?
//    public var grid: Bool?
//    public var labelAngle: Double?
//    public var labelBound: OneOf2<Bool, Double>?
//    public var labelFlush: OneOf2<Bool, Double>?
//    public var labelOverlap: OneOf2<Bool, LabelOverlap>?
//    public var labelPadding: Double?
//    public var labels: Bool?
//    public var maxExtent: Double?
//    public var minExtent: Double?
//    public var offset: Double?
//    public var orient: AxisOrient?
//    public var position: Double?
//    public var tickCount: Int?
//    public var tickSize: Double?
//    public var ticks: Bool?
//    public var title: String?
//    public var titleMaxLength: Double?
//    public var titlePadding: Double?
//    public var values: OneOf2<Array<Double>, Array<DateTime>>?
//    public var zindex: Double?
//}
//
//public struct AxisConfig : Codable, Equatable {
//    public var bandPosition: Double?
//    public var domain: Bool?
//    public var domainColor: Color?
//    public var domainWidth: Double?
//    public var grid: Bool?
//    public var gridColor: Color?
//    public var gridDash: Array<Double>?
//    public var gridOpacity: Double?
//    public var gridWidth: Double?
//    public var labelAngle: Double?
//    public var labelBound: OneOf2<Bool, Double>?
//    public var labelColor: Color?
//    public var labelFlush: OneOf2<Bool, Double>?
//    public var labelFont: Font?
//    public var labelFontSize: Double?
//    public var labelLimit: Double?
//    public var labelOverlap: OneOf2<Bool, LabelOverlap>?
//    public var labelPadding: Double?
//    public var labels: Bool?
//    public var maxExtent: Double?
//    public var minExtent: Double?
//    public var shortTimeLabels: Bool?
//    public var tickColor: Color?
//    public var tickRound: Bool?
//    public var tickSize: Double?
//    public var tickWidth: Double?
//    public var ticks: Bool?
//    public var titleAlign: String?
//    public var titleAngle: Double?
//    public var titleBaseline: String?
//    public var titleColor: Color?
//    public var titleFont: Font?
//    public var titleFontSize: Double
//    public var titleFontWeight: FontWeight?
//    public var titleLimit: Double?
//    public var titleMaxLength: Double?
//    public var titlePadding: Double?
//    public var titleX: Double?
//    public var titleY: Double?
//}
//
//public enum AxisOrient : String, Codable, Equatable { case top, left, right, bottom }
//
//public struct AxisResolveMap : Codable, Equatable {
//    public var x: ResolveMode?
//    public var y: ResolveMode?
//}
//
//public struct BarConfig : Codable, Equatable {
//    public var align: HorizontalAlign?
//    public var angle: Double?
//    public var baseline: VerticalAlign?
//    public var binSpacing: Double?
//    public var color: Color?
//    public var continuousBandSize: Double?
//    public var cursor: Cursor?
//    public var discreteBandSize: Double?
//    public var dx: Double?
//    public var dy: Double?
//    public var fill: Color?
//    public var fillOpacity: Double?
//    public var filled: Bool?
//    public var font: Font?
//    public var fontSize: Double?
//    public var fontStyle: FontStyle?
//    public var fontWeight: FontWeight?
//    public var href: URL?
//    public var interpolate: Interpolate?
//    public var limit: Double?
//    public var opacity: Double?
//    public var orient: Orient?
//    public var radius: Double?
//    public var shape: String?
//    public var size: Double?
//    public var stroke: Color?
//    public var strokeCap: StrokeCap?
//    public var strokeDash: [Double]?
//    public var strokeDashOffset: Double?
//    public var strokeOpacity: Double?
//    public var strokeWidth: Double?
//    public var tension: Double?
//    public var text: String?
//    public var theta: Double?
//}
//
//public enum BasicType : String, Codable, Equatable { case quantitative, ordinal, temporal, nominal }
//
//public struct BinParams : Codable, Equatable {
//    public var base: Int?
//    public var divide: Array<Int>?
//    public var extent: Array<Double>?
//    public var maxbins: Int?
//    public var minstep: Int?
//    public var nice: Int?
//    public var step: Int?
//    public var steps: Int?
//}
//
//public struct BinTransform : Codable, Equatable {
//    public var `as`: Field
//    public var bin: OneOf2<Bool, BinParams>
//    public var field: Field
//}
//
//public struct BrushConfig : Codable, Equatable {
//    public var fill: Color?
//    public var fillOpacity: Double?
//    public var stroke: Color?
//    public var strokeDash: [Double]?
//    public var strokeDashOffset: Double?
//    public var strokeOpacity: Double?
//    public var strokeWidth: Double?
//}
//
//public struct CalculateTransform : Codable, Equatable {
//    public var `as`: Field
//    public var calculate: String
//}
//
//public typealias CompositeUnitSpec = CompositeUnitSpecAlias
//
//public typealias ConditionalFieldDef = OneOf2<ConditionalPredicate<FieldDef>, ConditionalSelection<FieldDef>>
//
//public typealias ConditionalMarkPropFieldDef = OneOf2<ConditionalPredicate<MarkPropFieldDef>, ConditionalSelection<MarkPropFieldDef>>
//
//public typealias ConditionalTextFieldDef = OneOf2<ConditionalPredicate<TextFieldDef>, ConditionalSelection<TextFieldDef>>
//
//public typealias ConditionalValueDef = OneOf2<ConditionalPredicate<ValueDef>, ConditionalSelection<ValueDef>>
//
//// TODO: implement
//public struct ConditionalPredicate<T> : Codable, Equatable { }
////    public struct ConditionalPredicate<FieldDef> : Codable, Equatable { }
////    public struct ConditionalPredicate<MarkPropFieldDef> : Codable, Equatable { }
////    public struct ConditionalPredicate<TextFieldDef> : Codable, Equatable { }
////    public struct ConditionalPredicate<ValueDef> : Codable, Equatable { }
//
//// TODO: implement
//public struct ConditionalSelection<T> : Codable, Equatable { }
////    public struct ConditionalSelection<FieldDef> : Codable, Equatable { }
////    public struct ConditionalSelection<MarkPropFieldDef> : Codable, Equatable { }
////    public struct ConditionalSelection<TextFieldDef> : Codable, Equatable { }
////    public struct ConditionalSelection<ValueDef> : Codable, Equatable { }
//
//public struct Config : Codable, Equatable {
//    public var area: AreaConfig?
//    public var autosize: OneOf2<AutosizeType, AutoSizeParams>?
//    public var axis: AxisConfig?
//    public var axisBand: VgAxisConfig?
//    public var axisBottom: VgAxisConfig?
//    public var axisLeft: VgAxisConfig?
//    public var axisRight: VgAxisConfig?
//    public var axisTop: VgAxisConfig?
//    public var axisX: VgAxisConfig?
//    public var axisY: VgAxisConfig?
//    public var background: Color?
//    public var bar: BarConfig?
//    public var circle: MarkConfig?
//    public var countTitle: String?
//    public var datasets: Datasets?
//    public var fieldTitle: FieldTitle?
//    public enum FieldTitle : String, Codable, Equatable { case verbal, functional, plain }
//    public var geoshape: MarkConfig?
//    public var invalidValues: InvalidValues?
//    public enum InvalidValues : String, Codable, Equatable { case filter }
//    public var legend: LegendConfig?
//    public var line: LineConfig?
//    public var mark: MarkConfig?
//    public var numberFormat: String?
//    public var padding: Padding?
//    public var point: MarkConfig?
//    public var projection: ProjectionConfig?
//    public var range: RangeConfig?
//    public var rect: MarkConfig?
//    public var rule: MarkConfig?
//    public var scale: ScaleConfig?
//    public var selection: SelectionConfig?
//    public var square: MarkConfig?
//    public var stack: StackOffset?
//    public var style: StyleConfigIndex?
//    public var text: TextConfig?
//    public var tick: TickConfig?
//    public var timeFormat: String?
//    public var title: VgTitleConfig?
//    public var trail: LineConfig?
//    public var view: ViewConfig?
//}
//
//public struct CsvDataFormat : Codable, Equatable { }
//public struct Data : Codable, Equatable { }
//public struct DataFormat : Codable, Equatable { }
//public struct Datasets : Codable, Equatable { }
//public struct DateTime : Codable, Equatable { }
//public struct Day : Codable, Equatable { }
//public struct Dict<InlineDataset> : Codable, Equatable { }
//public struct DsvDataFormat : Codable, Equatable { }
//public struct Encoding : Codable, Equatable { }
//public struct EncodingSortField : Codable, Equatable { }
//public struct EncodingWithFacet : Codable, Equatable { }
//public struct LayerSpec : Codable, Equatable { }
//public struct FacetFieldDef : Codable, Equatable { }
//public struct FacetMapping : Codable, Equatable { }
//public struct FieldDef : Codable, Equatable { }
//public struct FieldDefWithCondition : Codable, Equatable { }
//public struct MarkPropFieldDefWithCondition : Codable, Equatable { }
//public struct TextFieldDefWithCondition : Codable, Equatable { }
//public struct FieldEqualPredicate : Codable, Equatable { }
//public struct FieldGTEPredicate : Codable, Equatable { }
//public struct FieldGTPredicate : Codable, Equatable { }
//public struct FieldLTEPredicate : Codable, Equatable { }
//public struct FieldLTPredicate : Codable, Equatable { }
//public struct FieldOneOfPredicate : Codable, Equatable { }
//public struct FieldRangePredicate : Codable, Equatable { }
//public struct FilterTransform : Codable, Equatable { }
//public struct FontStyle : Codable, Equatable { }
//public struct FontWeight : Codable, Equatable { }
//public struct FontWeightNumber : Codable, Equatable { }
//public struct FontWeightString : Codable, Equatable { }
//public struct FacetSpec : Codable, Equatable { }
//public struct HConcatSpec : Codable, Equatable { }
//public struct RepeatSpec : Codable, Equatable { }
//public struct Spec : Codable, Equatable { }
//public struct CompositeUnitSpecAlias : Codable, Equatable { }
//public struct FacetedCompositeUnitSpecAlias : Codable, Equatable { }
//public struct VConcatSpec : Codable, Equatable { }
//public struct GeoType : Codable, Equatable { }
//public struct Header : Codable, Equatable { }
//public struct HorizontalAlign : Codable, Equatable { }
//public struct InlineData : Codable, Equatable { }
//public struct InlineDataset : Codable, Equatable { }
//public struct Interpolate : Codable, Equatable { }
//public struct IntervalSelection : Codable, Equatable { }
//public struct IntervalSelectionConfig : Codable, Equatable { }
//public struct JsonDataFormat : Codable, Equatable { }
//public struct Legend : Codable, Equatable { }
//public struct LegendConfig : Codable, Equatable { }
//public struct LegendOrient : Codable, Equatable { }
//public struct LegendResolveMap : Codable, Equatable { }
//public struct LineConfig : Codable, Equatable { }
//public struct LocalMultiTimeUnit : Codable, Equatable { }
//public struct LocalSingleTimeUnit : Codable, Equatable { }
//public struct LogicalAnd<Predicate> : Codable, Equatable { }
//public struct SelectionAnd : Codable, Equatable { }
//public struct LogicalNot<Predicate> : Codable, Equatable { }
//public struct SelectionNot : Codable, Equatable { }
//public struct LogicalOperand<Predicate> : Codable, Equatable { }
//public struct SelectionOperand : Codable, Equatable { }
//public struct LogicalOr<Predicate> : Codable, Equatable { }
//public struct SelectionOr : Codable, Equatable { }
//public struct LookupData : Codable, Equatable { }
//public struct LookupTransform : Codable, Equatable { }
//public struct Mark : Codable, Equatable { }
//public struct MarkConfig : Codable, Equatable { }
//public struct MarkDef : Codable, Equatable { }
//public struct Month : Codable, Equatable { }
//public struct MultiSelection : Codable, Equatable { }
//public struct MultiSelectionConfig : Codable, Equatable { }
//public struct MultiTimeUnit : Codable, Equatable { }
//public struct NamedData : Codable, Equatable { }
//public struct NiceTime : Codable, Equatable { }
//public struct OrderFieldDef : Codable, Equatable { }
//public struct Orient : Codable, Equatable { }
//public struct Padding : Codable, Equatable { }
//public struct Parse : Codable, Equatable { }
//public struct PositionFieldDef : Codable, Equatable { }
//public struct Predicate : Codable, Equatable { }
//public struct Projection : Codable, Equatable { }
//public struct ProjectionConfig : Codable, Equatable { }
//public struct ProjectionType : Codable, Equatable { }
//public struct RangeConfig : Codable, Equatable { }
//public struct RangeConfigValue : Codable, Equatable { }
//public struct Repeat : Codable, Equatable { }
//public struct RepeatRef : Codable, Equatable { }
//public struct Resolve : Codable, Equatable { }
//public struct ResolveMode : Codable, Equatable { }
//public struct Scale : Codable, Equatable { }
//public struct ScaleConfig : Codable, Equatable { }
//public struct ScaleInterpolate : Codable, Equatable { }
//public struct ScaleInterpolateParams : Codable, Equatable { }
//public struct ScaleResolveMap : Codable, Equatable { }
//public struct ScaleType : Codable, Equatable { }
//public struct SchemeParams : Codable, Equatable { }
//public struct SelectionConfig : Codable, Equatable { }
//public struct SelectionDef : Codable, Equatable { }
//public struct SelectionDomain : Codable, Equatable { }
//public struct SelectionPredicate : Codable, Equatable { }
//public struct SelectionResolution : Codable, Equatable { }
//public struct SingleDefChannel : Codable, Equatable { }
//public struct SingleSelection : Codable, Equatable { }
//public struct SingleSelectionConfig : Codable, Equatable { }
//public struct SingleTimeUnit : Codable, Equatable { }
//public struct SortField : Codable, Equatable { }
//public struct SortOrder : Codable, Equatable { }
//public struct StackOffset : Codable, Equatable { }
//public struct StyleConfigIndex : Codable, Equatable { }
//public struct TextConfig : Codable, Equatable { }
//public struct TextFieldDef : Codable, Equatable { }
//public struct TickConfig : Codable, Equatable { }
//public struct TimeUnit : Codable, Equatable { }
//public struct TimeUnitTransform : Codable, Equatable { }
//public struct TitleOrient : Codable, Equatable { }
//public struct TitleParams : Codable, Equatable { }
//public struct TopLevelLayerSpec : Codable, Equatable { }
//public struct TopLevelHConcatSpec : Codable, Equatable { }
//public struct TopLevelRepeatSpec : Codable, Equatable { }
//public struct TopLevelVConcatSpec : Codable, Equatable { }
//public struct TopLevelFacetSpec : Codable, Equatable { }
//public struct TopLevelFacetedUnitSpec : Codable, Equatable { }
//public struct TopLevelSpec : Codable, Equatable { }
//public struct TopoDataFormat : Codable, Equatable { }
//public struct Transform : Codable, Equatable { }
//public struct `Type` : Codable, Equatable { }
//public struct UrlData : Codable, Equatable { }
//public struct UtcMultiTimeUnit : Codable, Equatable { }
//public struct UtcSingleTimeUnit : Codable, Equatable { }
//public struct ValueDef : Codable, Equatable { }
//public struct ValueDefWithCondition : Codable, Equatable { }
//public struct MarkPropValueDefWithCondition : Codable, Equatable { }
//public struct TextValueDefWithCondition : Codable, Equatable { }
//public struct VerticalAlign : Codable, Equatable { }
//public struct VgAxisConfig : Codable, Equatable { }
//public struct VgBinding : Codable, Equatable { }
//public struct VgCheckboxBinding : Codable, Equatable { }
//public struct VgComparatorOrder : Codable, Equatable { }
//public struct VgEventStream : Codable, Equatable { }
//public struct VgGenericBinding : Codable, Equatable { }
//public struct VgMarkConfig : Codable, Equatable { }
//public struct VgProjectionType : Codable, Equatable { }
//public struct VgRadioBinding : Codable, Equatable { }
//public struct VgRangeBinding : Codable, Equatable { }
//public struct VgScheme : Codable, Equatable { }
//public struct VgSelectBinding : Codable, Equatable { }
//public struct VgTitleConfig : Codable, Equatable { }
//public struct ViewConfig : Codable, Equatable { }
//public struct WindowFieldDef : Codable, Equatable { }
//public struct WindowOnlyOp : Codable, Equatable { }
//public struct WindowTransform : Codable, Equatable { }
