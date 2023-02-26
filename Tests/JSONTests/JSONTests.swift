////
////  JSONTests.swift
////
////  Created by Marc Prud'hommeaux on 6/14/15.
////
//import XCTest
//import JSON
//import Cluster
//import Either
//
//class JSONParserTests : XCTestCase {
//
//    func expectFail(_ s: String, _ msg: String? = nil, options: JSONParser.Options = .Strict, file: StaticString = #file, line: UInt = #line) {
//        do {
//            _ = try JSum.parse(s, options: options)
//            XCTFail("Should have failed to parse", file: (file), line: line)
//        } catch {
//            if let m = msg {
//                XCTAssertEqual(m, String(describing: error), file: (file), line: line)
//            }
//        }
//    }
//
//    func expectPass(_ s: String, _ bric: JSum? = nil, options: JSONParser.Options = .Strict, file: StaticString = #file, line: UInt = #line) {
//        do {
//            let b = try JSum.parse(s, options: options)
//            if let bric = bric {
//                XCTAssertEqual(bric, b, file: (file), line: line)
//            } else {
//                // no comparison bric; just pass
//            }
//        } catch {
//            XCTFail("\(error)", file: (file), line: line)
//        }
//    }
//
//    func testDoubleOptionalEncoding() throws {
//        struct OStrings : Codable, Hashable {
//            let a: String?
//            let b: String??
//        }
//
////        XCTAssertEqual("{}", OStrings(a: .none, b: .none).jsonDebugDescription)
////        XCTAssertEqual("{\"b\":null}", OStrings(a: .none, b: .some(.none)).jsonDebugDescription)
////        XCTAssertEqual("{\"b\":\"X\"}", OStrings(a: .none, b: "X").jsonDebugDescription)
//
//        func dec(_ string: String) throws -> OStrings {
//            try JSONDecoder().decode(OStrings.self, from: Data(string.utf8))
//        }
//        XCTAssertEqual(try dec("{}"), OStrings(a: .none, b: .none))
//        XCTAssertEqual(try dec("{\"b\":null}"), OStrings(a: .none, b: .none)) // .some(.none))) // this is why we need Nullable: double-optional doesn't decode explicit nulls as a .some(.none)
//        XCTAssertEqual(try dec("{\"b\":\"X\"}"), OStrings(a: .none, b: "X"))
//
//    }
//
////    func testDecimalEncoding() throws {
////        #if !canImport(JavaScriptCore)
////        throw XCTSkip("Linux fail")
////        #endif
////
////        XCTAssertEqual("[12.800000000000001]", [Double(12.8)].jsonDebugDescription)
////        XCTAssertEqual("[12.8]", [Decimal(12.8)].jsonDebugDescription)
////
////        XCTAssertEqual("[12.800000000000001]", [OneOf<Double>.Or<Decimal>.v1(Double(12.8))].jsonDebugDescription)
////        XCTAssertEqual("[12.8]", [OneOf2<Double, Decimal>.v2(Decimal(12.8))].jsonDebugDescription)
////    }
//
//    func testMarcUpParsing() {
//        func q(_ s: String)->String { return "\"" + s + "\"" }
//
//        expectPass("1", 1)
//        expectPass("1.0", 1.0)
//        expectPass("1.1", 1.1)
//        expectPass("-1.00100", -1.001)
//        expectPass("1E+1", 10)
//        expectPass("1E-1", 0.1)
//        expectPass("1.0E+1", 10)
//        expectPass("1.0E-1", 0.1)
//        expectPass("1.2E+1", 12)
//        expectPass("1.2E-1", 0.12)
//        expectPass("1E+10", 1E+10)
//        expectPass("1e-100", 1e-100)
//
//        expectFail("-01234.56789", "Leading zero in number (line: 1 column: 12)")
//        expectPass("-01234.56789", -01234.56789, options: .AllowLeadingZeros)
//
//        expectFail("1 XXX", "Trailing content (line: 1 column: 3)")
//        expectPass("1 XXX", 1, options: .AllowTrailingContent)
//
//        expectFail("n")
//        expectFail("nu")
//        expectFail("nul")
//        expectPass("null", .nul)
//
//        expectFail("t")
//        expectFail("tr")
//        expectFail("tru")
//        expectPass("true", true)
//
//        expectFail("f")
//        expectFail("fa")
//        expectFail("fal")
//        expectFail("fals")
//        expectPass("false", false)
//        
//        expectFail("truefalse", "Trailing content (line: 1 column: 5)")
//
//        expectFail(",", "Comma found with no pending result (line: 1 column: 1)")
//        expectFail("]", "Unmatched close array brace (line: 1 column: 1)")
//        expectFail("}", "Unmatched close object brace (line: 1 column: 1)")
//        expectFail(":", "Object key assignment outside of an object (line: 1 column: 1)")
//        expectFail("[\"key\" :", "Object key assignment outside of an object (line: 1 column: 8)")
//
//
//        expectFail("[truefalse]", "Character found with pending result value (line: 1 column: 6)")
//        expectFail("[true1]", "Number found with pending result value (line: 1 column: 6)")
//        expectFail("[1true]", "Character found with pending result value (line: 1 column: 3)")
//        expectFail("[true\"ABC\"]", "String found with pending result value (line: 1 column: 6)")
//        expectFail("[\"ABC\" true]", "Character found with pending result value (line: 1 column: 8)")
//        expectFail("[\"a\"\"b\"]", "String found with pending result value (line: 1 column: 5)")
//        expectFail("[\"a\"1\"b\"]", "Number found with pending result value (line: 1 column: 5)")
//        expectFail("[\"a\"nu\"b\"]", "Character found with pending result value (line: 1 column: 5)")
//
//        expectFail("[true", "Unclosed container (line: 1 column: 5)")
//        expectFail("{", "Unclosed container (line: 1 column: 1)")
//        expectFail("{\"qqq\"", "Unclosed container (line: 1 column: 6)")
//
//        expectFail(q("abc\tdef"), "Strings may not contain tab characters (line: 1 column: 5)")
//        expectFail(q("\n"), "Strings may not contain newlines (line: 2 column: 0)")
//
//        expectPass("[\"abcéfg\", 123.4567]", ["abcéfg", 123.4567])
//        expectPass("[123.4567]", [123.4567])
//        expectPass("0", 0)
//        expectPass("0.1", 0.1)
//        expectPass("123.4567", 123.4567)
//        expectPass("123.4567 ", 123.4567)
//        expectPass("[[[[123.4567]]]]", [[[[123.4567]]]])
//        expectPass("{\"foo\": \"bar\"}", ["foo": "bar"])
//        expectPass("{\"foo\": 1}", ["foo": 1])
//        expectPass("{\"foo\": null}", ["foo": nil])
//        expectPass("{\"foo\": true}", ["foo": true])
//        expectPass("{\"foo\": false}", ["foo": false])
//        expectPass("{\"foo\": false, \"bar\": true}", ["foo": false, "bar": true])
//        expectPass("{\"foo\": false, \"bar\": {\"a\": \"bcd\"}}", ["foo": false, "bar": ["a": "bcd"]])
//        expectPass("{\"foo\": false, \"bar\": {\"a\": [\"bcd\"]}}", ["foo": false, "bar": ["a": ["bcd"]]])
//        expectPass("{\"foo\": false, \"bar\": {\"a\": [\"bcd\"],\"b\":[]},\"baz\": 2}", ["foo": false, "bar": ["a": ["bcd"], "b": []], "baz": 2])
//
//        expectPass("[1, \"a\", true]", [1, "a", true])
//        expectPass("[  \r\n  \n  1  \n  \n  ,  \n  \t\n  \"a\"  \n  \n  ,  \r\t\n  \n  true  \t\t\r\n  \n  ]", [1, "a", true])
//        expectFail("[1, \"a\", true,]", "Trailing comma (line: 1 column: 15)")
//
//        expectPass("{\"customers\":[{\"age\":41,\"male\":false,\"children\":null,\"name\":\"Emily\"}],\"employees\":[null],\"ceo\":null,\"name\":\"Apple\"}")
//
//        expectPass("{\"customers\":[{\"age\":41,\"male\":false,\"children\":[\"Bebe\"],\"name\":\"Emily\"}],\"employees\":[{\"age\":41,\"male\":true,\"children\":[\"Bebe\"],\"name\":\"Marc\"}],\"ceo\":{\"age\":50.01E+10,\"male\":true,\"children\":[],\"name\":\"Tim\"},\"name\":\"Apple\"}")
//
//        expectFail("{\"Missing colon\" null}", "Invalid character within object start (line: 1 column: 18)")
//        expectFail("{\"Extra colon\":: null}", "Object key assignment outside of an object (line: 1 column: 16)")
//        expectFail("{\"Extra colon\"::: null}", "Object key assignment outside of an object (line: 1 column: 16)")
//
//        expectFail("{{", "Object start within object start (line: 1 column: 2)")
//        expectFail("{[", "Array start within object start (line: 1 column: 2)")
//        expectFail("{x", "Invalid character within object start (line: 1 column: 2)")
//        expectFail("[x", "Unrecognized token: x (line: 1 column: 2)")
//
//        expectPass(q("a"), "a")
//        expectPass(q("abc"), "abc")
//
//        expectPass(q("/"), "/")
//        expectPass(q("\\/"), "/")
//        expectPass(q("http:\\/\\/prux.org\\/"), "http://prux.org/")
//
//        expectPass(q("\\n"), "\n")
//        expectPass(q("\\r"), "\r")
//        expectPass(q("\\t"), "\t")
//
//        expectPass(q("\\nX"), "\nX")
//        expectPass(q("\\rYY"), "\rYY")
//        expectPass(q("\\tZZZ"), "\tZZZ")
//
//        expectPass(q("A\\nX"), "A\nX")
//        expectPass(q("BB\\rYY"), "BB\rYY")
//        expectPass(q("CCC\\tZZZ"), "CCC\tZZZ")
//
//        expectPass(q("\\u002F"), "/")
//        expectPass(q("\\u002f"), "/")
//
//        expectPass(q("abc\\uD834\\uDD1Exyz"), "abc\u{0001D11E}xyz") // ECMA-404 section 9
//
//        for char in ["X", "é", "\u{003}", "😡"] {
//            expectPass(q(char), .str(char))
//        }
//    }
//
//    /// Verify that our serialization is compatible with NSJSONSerialization
////    func testMarcUpCocoaCompatNumbers() throws {
////        #if false
////        // FIXME: something broke around 5.1
////            compareCocoaParsing("1.2345678", msg: "fraction alone")
////            compareCocoaParsing("1.2345678 ", msg: "fraction with trailing space")
////            compareCocoaParsing("1.2345678\n", msg: "fraction with trailing newline")
////            compareCocoaParsing("1.2345678\n\n", msg: "fraction with trailing newlines")
////        #endif
////
////        #if canImport(CoreFoundation) // not Windows
////        #if !os(Linux)
////            compareCocoaParsing("1", msg: "number with no newline")
////            compareCocoaParsing("1 ", msg: "number with trailing space")
////            compareCocoaParsing("1\n", msg: "number with trailing newline")
////            compareCocoaParsing("1\n\n", msg: "number with trailing newlines")
////
////            compareCocoaParsing("0.1", msg: "fractional number with leading zero")
////            compareCocoaParsing("0.1", msg: "preceeding zero OK")
////        #endif
////        #endif
////
//////        compareCocoaParsing("1.234567890E+34", msg: "number with upper-case exponent")
//////        compareCocoaParsing("0.123456789e-12", msg: "number with lower-case exponent")
////
////        compareCocoaParsing("[0e]", msg: "number with trailing e at end of array")
////        compareCocoaParsing("[0e+]", msg: "number with trailing e+ at end of array")
////
////        compareCocoaParsing("01", msg: "preceeding zero should fail")
////        compareCocoaParsing("01.23", msg: "preceeding zero should fail")
////        compareCocoaParsing("01.01", msg: "preceeding zero should fail")
////        compareCocoaParsing("01.0", msg: "preceeding zero should fail")
////    }
//
//    #if canImport(CoreFoundation) // not Windows
//    #if !os(Linux)
////    func profileJSON(_ str: String, count: Int, validate: Bool, cocoa: Bool, cf: Bool) throws {
////        let scalars = Array((str as String).unicodeScalars)
////
////        if let data = str.data(using: String.Encoding.utf8) {
////
////            let js = CFAbsoluteTimeGetCurrent()
////            for _ in 1...count {
////                if cf {
////                    _ = try CoreFoundationBricolage.parseJSON(scalars, options: JSONParser.Options.Strict)
//////                    let nsobj = Unmanaged<NSObject>.fromOpaque(COpaquePointer(fbric.ptr)).takeRetainedValue()
////                } else if cocoa {
////                    let _: NSObject = try Bric.parseCocoa(scalars)
////                } else if validate {
////                    try Bric.validate(scalars, options: JSONParser.Options.Strict)
////                } else {
////                    _ = try Bric.parse(scalars)
////                }
////            }
////            let je = CFAbsoluteTimeGetCurrent()
////
////            let cs = CFAbsoluteTimeGetCurrent()
////            for _ in 1...count {
////                try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
////            }
////            let ce = CFAbsoluteTimeGetCurrent()
////
////            print((cf ? "CF" : cocoa ? "Cocoa" : validate ? "Validated" : "Fluent") + ": MarcUp: \(je-js) Cocoa: \(ce-cs) (\(Int(round((je-js)/(ce-cs))))x slower)")
////        }
////    }
//    #endif
//    #endif
//
////    #if canImport(JavaScriptCore)
////    @discardableResult func parsePath(_ path: String, strict: Bool, file: StaticString = #file, line: UInt = #line) throws -> Bric {
////        let str = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
////        let bric = try Bric.parse(str as String, options: strict ? .Strict : .Lenient)
////
////        // always check to ensure that our strinification matches that of JavaScriptCore
////        compareJSCStringification(bric, msg: (path as NSString).lastPathComponent, file: file, line: line)
////        return bric
////    }
////    #endif
////
////    func compareCocoaParsing(_ string: String, msg: String, file: StaticString = #file, line: UInt = #line) {
////        var cocoaBric: NSObject?
////        var bricError: Error?
////        var cocoa: NSObject?
////        var cocoaError: Error?
////
////        do {
////            // NSJSONSerialization doesn't always ignore trailing spaces: http://openradar.appspot.com/21472364
////            let str = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
////            cocoa = try JSONSerialization.jsonObject(with: str.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSObject
////        } catch {
////            cocoaError = error
////        }
////
////        do {
////            cocoaBric = try JSum.parseCocoa(string)
////        } catch {
////            bricError = error
////        }
////
////        switch (cocoaBric, cocoa, bricError, cocoaError) {
////        case (.some(let j), .some(let c), _, _):
////            if j != c {
//////                dump(j)
//////                dump(c)
////                print(j)
////                print(c)
//////                assert(j == c)
////            }
////            #if os(iOS)
////            // for some reason, iOS numbers do not equate true for some floats, so we just compare the strings
////            XCTAssertTrue(j.description == c.description, "Parsed contents differed for «\(msg)»", file: (file), line: line)
////            #else
////            XCTAssertTrue(j == c, "Parsed contents differed for «\(msg)»", file: (file), line: line)
////            #endif
////        case (_, _, .some(let je), .some(let ce)):
////            // for manual inspection of error messages, change equality to inequality
////            if String(describing: je) == String(describing: ce) {
////                print("Bric Error «\(msg)»: \(je)")
////                print("Cocoa Error «\(msg)»: \(ce)")
////            }
////            break
////        case (_, _, _, .some(let ce)):
////            XCTFail("Cocoa failed/MarcUp passed «\(msg)»: \(ce)", file: (file), line: line)
////        case (_, _, .some(let je), _):
////            XCTFail("MarcUp failed/Cocoa passed «\(msg)»: \(je)", file: (file), line: line)
////        default:
////            XCTFail("Unexpected scenario «\(msg)»", file: (file), line: line)
////        }
////    }
//
//    func testNulNilEquivalence() {
//        do {
//            let j1 = JSum.obj(["foo": "bar"])
//
//            let j2 = JSum.obj(["foo": "bar", "baz": nil])
//
//            // the two JSums are not the same...
//            XCTAssertNotEqual(j1, j2)
//
//            // ... and the two underlying dictionaries are the same ...
//            if case let .obj(d1) = j1, case let .obj(d2) = j2 {
//                XCTAssertNotEqual(d1, d2)
//            }
//
//            let j3 = JSum.obj(["foo": "bar", "baz": .nul])
//            // the two JSums are the same...
//            XCTAssertEqual(j2, j3)
//
//            // ... and the two underlying dictionaries are the same ...
//            if case .obj(let d2) = j2, case .obj(let d3) = j3 {
//                XCTAssertEqual(d2, d3)
//            }
//
////            print(j3.stringify())
//
//        }
//    }
//
//
////    func testKeyedSubscripting() {
////        let val: JSum = ["key": "foo"]
////        if let _: String = val["key"]?.str {
////        } else {
////            XCTFail()
////        }
////    }
//
////    func testBricAlter() {
////        XCTAssertEqual("Bar", JSum.str("Foo").alter { (_, _) in "Bar" })
////        XCTAssertEqual(123, JSum.str("Foo").alter { (_, _) in 123 })
////        XCTAssertEqual([:], JSum.arr([]).alter { (_, _) in [:] })
////
////        XCTAssertEqual(["foo": 1, "bar": "XXX"], JSum.obj(["foo": 1, "bar": 2]).alter {
////            return $0 == [.key("bar")] ? "XXX" : $1
////        })
////
////        do {
////            let b1: JSum = [["foo": 1, "bar": 2], ["foo": 1, "bar": 2]]
////            let b2: JSum = [["foo": 1, "bar": 2], ["foo": "XXX", "bar": "XXX"]]
////            let path: JSum.Pointer = [.index(1) ]
////            XCTAssertEqual(b2, b1.alter { return $0.starts(with: path) && $0 != path ? "XXX" : $1 })
////        }
////    }
//
////    func testMarcUpAround() {
////        do {
////            let x1: Array<String> = ["a", "b", "c"]
////            let x2 = try Array<String>.brac(x1.bric())
////            XCTAssertEqual(x1, x2)
////        } catch {
////            XCTFail("Round-trip error")
////        }
////    }
//
//    func testJSONFormatting() throws {
//        let json = "{\"abc\": 1.2233 , \"xyz\" :  \n\t\t[true,false, null]}  "
//        let compact = "{\"abc\":1.2233,\"xyz\":[true,false,null]}"
//        let pretty = "{\n  \"abc\" : 1.2233,\n  \"xyz\" : [\n    true,\n    false,\n    null\n  ]\n}"
//        do {
//            let p1 = try JSONParser.formatJSON(json)
//            XCTAssertEqual(p1, json)
//
//            let p2 = try JSONParser.formatJSON(json, indent: 0)
//            XCTAssertEqual(p2, compact)
//
//            let p3 = try JSONParser.formatJSON(json, indent: 2)
//            XCTAssertEqual(p3, pretty)
//        }
//    }
//
//    #if canImport(JavaScriptCore)
////    func testMarcUpCompatibility() throws {
////        let fm = FileManager.default
////        do {
////            let rsrc: String? = testResourcePath()
////            if let folder = rsrc {
////                let types = try fm.contentsOfDirectory(atPath: folder)
////                XCTAssertEqual(types.count, 5) // data, jsonchecker, profile, schema
////                for type in types {
////                    let dir = (folder as NSString).appendingPathComponent(type)
////                    let jsons = try fm.contentsOfDirectory(atPath: dir)
////                    for file in jsons {
////                        do {
////                            let fullPath = (dir as NSString).appendingPathComponent(file)
////
////                            // first check to ensure that NSJSONSerialization's results match MarcUp's
////
////                            if file.hasSuffix(".json") {
////
////                                // make sure our round-trip validing parser works
////                                let contents = try NSString(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue) as String
////
////
////                                do {
////                                    let scalars = contents.unicodeScalars // quite a bit slower than operating on the array
////                                    // let scalars = Array(contents.unicodeScalars)
////                                    let roundTripped = try roundTrip(scalars)
////                                    XCTAssertEqual(String(scalars), String(roundTripped))
////                                } catch {
////                                    // ignore parse errors, since this isn't where we are validating pass/fail
////                                }
////
////                                // dodge http://openradar.appspot.com/21472364
////                                if file != "caliper.json"
////                                    && file != "pass1.json"
////                                    && file != "test_basic_03.json"
////                                {
////                                    compareCocoaParsing(contents, msg: file)
////                                }
////
////
////                                if type == "profile" {
////                                    let count = 6
////                                    print("\nProfiling \((fullPath as NSString).lastPathComponent) \(count) times:")
////                                    let str = try NSString(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue) as String
////                                    try profileJSON(str, count: count, validate: true, cocoa: false, cf: false)
////                                    try profileJSON(str, count: count, validate: false, cocoa: false, cf: false)
////                                    try profileJSON(str, count: count, validate: false, cocoa: false, cf: true)
////                                    try profileJSON(str, count: count, validate: false, cocoa: true, cf: false)
////                                } else if type == "jsonschema" {
////                                    let bric = try JSum.parse(contents)
////
////                                    // the format of the tests in https://github.com/json-schema/JSON-Schema-Test-Suite are arrays of objects that contain a "schema" item
////                                    guard case let .arr(items) = bric else {
////                                        XCTFail("No top-level array in \(file)")
////                                        continue
////                                    }
////                                    for (_, item) in items.enumerated() {
////                                        guard case let .obj(def) = item else {
////                                            XCTFail("Array element was not an object: \(file)")
////                                            continue
////                                        }
////                                        guard case let .some(schem) = def["schema"] else {
////                                            XCTFail("Schema object did not contain a schema object key: \(file)")
////                                            continue
////                                        }
////                                        if schem == schem {
////
////                                        }
////
//////                                        do {
//////                                            let schema = try Schema.brac(schem)
//////                                            let reschema = try Schema.brac(schema.bric())
//////                                            XCTAssertEqual(schema, reschema)
//////                                        } catch {
//////                                            XCTFail("failed to load element #\(i) of \(file) error=\(error): \(schem.stringify())")
//////                                        }
////                                    }
////                                } else if type == "schemas" {
////                                    // try to codegen all the schemas
////                                    _ = try parsePath(fullPath, strict: true)
//////                                    _ = try Schema.brac(bric: bric)
//////                                    if false {
//////                                        let swift = try schema.generateType()
//////                                        print("##### swift for \(file):\n\(swift)")
//////                                    }
////                                } else {
////                                    try parsePath(fullPath, strict: type == "jsonchecker")
////                                    if file.hasPrefix("fail") {
////                                        if file == "fail1.json" {
////                                            // don't fail on the no root string test; the spec doesn't forbit it
////                                            // "A JSON payload should be an object or array, not a string."
////                                        } else if file == "fail18.json" {
////                                            // don't fail on the arbitrary depth limit test; the spec doesn't forbit it
////                                            // [[[[[[[[[[[[[[[[[[[["Too deep"]]]]]]]]]]]]]]]]]]]]
////                                        } else {
////                                            XCTFail("Should have failed test at: \(file)")
////                                        }
////                                    }
////                                }
////                            }
////                        } catch {
////                            if file.hasPrefix("fail") {
////                                // should fail
////                            } else {
////                                XCTFail("Should have passed test at: \(file) error: \(error)")
////                                dump(error)
////                            }
////                        }
////                    }
////                }
////            }
////        } catch {
////            XCTFail("unexpected error when loading tests: \(error)")
////        }
////    }
//    #endif
//
////    func testStringReplace() {
////        XCTAssertEqual("foo".replace(string: "oo", with: "X"), "fX")
////        XCTAssertEqual("foo".replace(string: "o", with: "X"), "fXX")
////        XCTAssertEqual("foo".replace(string: "o", with: "XXXX"), "fXXXXXXXX")
////        XCTAssertEqual("foo".replace(string: "ooo", with: "XXXX"), "foo")
////        XCTAssertEqual("123".replace(string: "3", with: ""), "12")
////        XCTAssertEqual("123".replace(string: "1", with: ""), "23")
////        XCTAssertEqual("123".replace(string: "2", with: ""), "13")
////        XCTAssertEqual("abcabcbcabcbcbc".replace(string: "bc", with: "XYZ"), "aXYZaXYZXYZaXYZXYZXYZ")
////    }
//
////    func testJSONPointers() {
////        // http://tools.ietf.org/html/draft-ietf-appsawg-json-pointer-04
////        let json: JSum = [
////            "foo": ["bar", "baz"],
////            "": 0,
////            "a/b": 1,
////            "c%d": 2,
////            "e^f": 3,
////            "g|h": 4,
////            "i\\j": 5,
////            "k\"l": 6,
////            " ": 7,
////            "m~n": 8
////        ]
////
////        // ""         // the whole document
////        // "/foo"       ["bar", "baz"]
////        // "/foo/0"    "bar"
////        // "/"          0
////        // "/a~1b"      1
////        // "/c%d"       2
////        // "/e^f"       3
////        // "/g|h"       4
////        // "/i\\j"      5
////        // "/k\"l"      6
////        // "/ "         7
////        // "/m~0n"      8
////
////        do {
////            do { let x = try json.reference(""); XCTAssertEqual(x, json) }
////            do { let x = try json.reference("/foo"); XCTAssertEqual(x, ["bar", "baz"]) }
////            do { let x = try json.reference("/foo/0"); XCTAssertEqual(x, "bar") }
////            do { let x = try json.reference("/"); XCTAssertEqual(x, 0) }
////            do { let x = try json.reference("/a~1b"); XCTAssertEqual(x, 1) }
////            do { let x = try json.reference("/c%d"); XCTAssertEqual(x, 2) }
////            do { let x = try json.reference("/e^f"); XCTAssertEqual(x, 3) }
////            do { let x = try json.reference("/g|h"); XCTAssertEqual(x, 4) }
////            do { let x = try json.reference("/i\\j"); XCTAssertEqual(x, 5) }
////            do { let x = try json.reference("/k\"l"); XCTAssertEqual(x, 6) }
////            do { let x = try json.reference("/ "); XCTAssertEqual(x, 7) }
////            do { let x = try json.reference("m~0n"); XCTAssertEqual(x, 8) }
////
////        } catch {
////            XCTFail("JSON Pointer error: \(error)")
////        }
////    }
//
//    func testStreamingParser() {
//        do {
//            let opts = JSONParser.Options.Strict
//
//            do {
//                var events: [JSONParser.Event] = []
//                let cb: (JSONParser.Event)->() = { event in events.append(event) }
//
//                let parser = JSONParser(options: opts, delegate: cb)
//                func one(_ c: UnicodeScalar) -> [UnicodeScalar] { return [c] }
//
//                try parser.parse(one("["))
//                XCTAssertEqual(events, [.arrayStart(one("["))])
//
//                try parser.parse(one(" "))
//                XCTAssertEqual(events, [.arrayStart(one("[")), .whitespace([" "])])
//
//                try parser.parse(one("1"))
//                // note no trailing number event, because it doesn't know when it is completed
//                XCTAssertEqual(events, [.arrayStart(one("[")), .whitespace([" "])]) // , .number(["1"])])
//
//                try parser.parse(one("\n"))
//                XCTAssertEqual(events, [.arrayStart(one("[")), .whitespace([" "]), .number(["1"]), .whitespace(["\n"])])
//
//                try parser.parse(one("]"), complete: true)
//                XCTAssertEqual(events, [.arrayStart(one("[")), .whitespace([" "]), .number(["1"]), .whitespace(["\n"]), .arrayEnd(one("]"))])
//            }
//
//            // break up the parse into a variety of subsets to test that the streaming parser emits the exact same events
//            let strm = Array("{\"object\": 1234.56E2}".unicodeScalars)
//            let rangesList: [[CountableRange<Int>]] = [
//                Array<CountableRange<Int>>(arrayLiteral: 0..<1, 1..<2, 2..<3, 3..<4, 4..<5, 5..<6, 6..<7, 7..<8, 8..<9, 9..<10, 10..<11, 11..<12, 12..<13, 13..<14, 14..<15, 15..<16, 16..<17, 17..<18, 18..<19, 19..<20, 20..<21),
//                Array<CountableRange<Int>>(arrayLiteral: 0..<10, 10..<15, 15..<16, 16..<19, 19..<21),
//                Array<CountableRange<Int>>(arrayLiteral: 0..<7, 7..<8, 8..<9, 9..<10, 10..<15, 15..<16, 16..<17, 17..<20, 20..<21),
//                Array<CountableRange<Int>>(arrayLiteral: 0..<9, 9..<10, 10..<11, 11..<18, 18..<19, 19..<20, 20..<21),
//                Array<CountableRange<Int>>(arrayLiteral: 0..<21),
//                ]
//
//            for ranges in rangesList {
//                var events: [JSONParser.Event] = []
//                let cb: (JSONParser.Event)->() = { event in events.append(event) }
//
//                let parser = JSONParser(options: opts, delegate: cb)
//
//                for range in ranges { try parser.parse(Array(strm[range])) }
//                try parser.parse([], complete: true)
//
//                XCTAssertEqual(events, [JSONParser.Event.objectStart(["{"]),
//                    JSONParser.Event.stringStart(["\""]),
//                    JSONParser.Event.stringContent(Array("object".unicodeScalars), []),
//                    JSONParser.Event.stringEnd(["\""]),
//                    JSONParser.Event.keyValueSeparator([":"]), JSONParser.Event.whitespace([" "]),
//                    JSONParser.Event.number(Array("1234.56E2".unicodeScalars)),
//                    JSONParser.Event.objectEnd(["}"])])
//
//            }
//
//            expectEvents("[[[]]]", [.arrayStart(["["]), .arrayStart(["["]), .arrayStart(["["]), .arrayEnd(["]"]), .arrayEnd(["]"]), .arrayEnd(["]"])])
//            expectEvents("[[ ]]", [.arrayStart(["["]), .arrayStart(["["]), .whitespace([" "]), .arrayEnd(["]"]), .arrayEnd(["]"])])
////            expectEvents("[{\"x\": 2.2}]", [.arrayStart, .objectStart, .string(["x"], []), .keyValueSeparator, .whitespace([" "]), .number(["2", ".", "2"]), .objectEnd, .arrayEnd])
//
//       } catch {
//            XCTFail(String(describing: error))
//        }
//    }
//
//
////    func testStreamingBricolage() {
////        do {
////            let opts = JSONParser.Options.Strict
////
////            do {
////                let bric: JSum = [123, 456.789, ["xyz": true], false, [], [nil], nil]
////                let json = bric.stringify().unicodeScalars
////                var brics: [JSum] = []
////                try JSum.bricolageParser(options: opts, delegate: { (b, _) in brics.append(b); return b }).parse(json, complete: true)
////
////                // the expected output: note that redundant values are expected, since every bric generates an event
////                let expected: [JSum] = [123, 456.789, "xyz", true, ["xyz": true], false, [], nil, [nil], nil, [123, 456.789, ["xyz": true], false, [], [nil], nil]]
////
////                XCTAssertEqual(brics, expected)
////            } catch {
////                XCTFail(String(describing: error))
////            }
////
////            do {
////                var processed: [JSum] = []
////
////                // here we are filtereding all events at leavel 1 so they are not stored in the top-level JSum array
////                // this demonstrates using the parser as a streaming Bricolage parser of top-level array elements
////                // without the parser needing the retain all of the events themselves
////                let parser = JSum.bricolageParser(options: opts, delegate: { (bric, level) in
////                    if level == 1 {
////                        processed.append(bric)
////                        return nil
////                    } else {
////                        return bric // not level 1: return the bric itself
////                    }
////                })
////
////                let inputs: Array<JSum> = [ ["a": true], ["b": 123.45], ["c": nil], ["d": "xyz"] ]
////                try parser.parse(["["]) // open a top-level array
////                XCTAssertEqual([], processed) // no events yet
////
////                for (i, input) in inputs.enumerated() { // parse each of the strings
////                    try parser.parse(input.stringify().unicodeScalars)
////                    XCTAssertEqual(i + 1, processed.count) // one event per input
////                    try parser.parse([","]) // trailing delimiter to continue the array
////                }
////
////                // note that we never complete the parse (we end with a trailing comma)
////                XCTAssertEqual(processed, inputs)
////            } catch {
////                XCTFail(String(describing: error))
////            }
////
////        }
////    }
//
//    /// Assert that the given events are emitted by the parser
//    func expectEvents(_ string: String, _ events: [JSONParser.Event], file: StaticString = #file, line: UInt = #line) {
//        do {
//            var evts: [JSONParser.Event] = []
//            let cb: (JSONParser.Event)->() = { e in evts.append(e) }
//
//            let parser = JSONParser(options: JSONParser.Options.Strict, delegate: cb)
//            try parser.parseString(string)
//            XCTAssertEqual(evts, events, file: (file), line: line)
//        } catch {
//            XCTFail(String(describing: error), file: (file), line: line)
//        }
//    }
//
////    func testStreamingEncoding() {
////        for (expected, input) in [
////            (expected: nil as JSum, input: "null"),
////            (expected: ["😂": nil] as JSum, input: "{\"😂\": null}"),
////            ] {
////                // encode the above in a variety of codecs and feed them into a streaming parser to make sure they parse correctly
////                let utf16: [UTF16.CodeUnit] = Array(input.utf16)
////                let utf8: [UTF8.CodeUnit] = Array(input.utf8)
////
////                // there's no nice "utf32" convenience property on String, so we manually build it up
////                var utf32: [UTF32.CodeUnit] = []
////                for scalar in input.unicodeScalars {
////                    UTF32.encode(scalar, into: { utf32.append($0) })
////                }
////
////                // print("utf8: \(utf8)") // 14 elements: [91, 34, 240, 159, 152, 130, 34, 44, 32, 110, 117, 108, 108, 93]
////                // print("utf16: \(utf16)") // 12 elements: [91, 34, 55357, 56834, 34, 44, 32, 110, 117, 108, 108, 93]
////                // print("utf32: \(utf32)") // 11 elements: [91, 34, 128514, 34, 44, 32, 110, 117, 108, 108, 93]
////
////                do {
////                    let utf8out = try parseCodec(UTF8.self, utf8)
////                    XCTAssertEqual(utf8out, expected)
////                } catch {
////                    XCTFail(String(describing: error))
////                }
////
////                do {
////                    let utf16out = try parseCodec(UTF16.self, utf16)
////                    XCTAssertEqual(utf16out, expected)
////                } catch {
////                    XCTFail(String(describing: error))
////                }
////
////
////                do {
////                    let utf32out = try parseCodec(UTF32.self, utf32)
////                    XCTAssertEqual(utf32out, expected)
////                } catch {
////                    XCTFail(String(describing: error))
////                }
////        }
////    }
//
//    func testStreamingDecoding() {
//        // U+1F602 (Emoji: "face with tears of joy") in UTF-8 is: 240, 159, 152, 130
//        let units: [UTF8.CodeUnit] = [240, 159, 152, 130]
//
//        _ = transcode(units.makeIterator(), from: UTF8.self, to: UTF32.self, stoppingOnError: true, into: {
//            assert(UnicodeScalar($0) == "\u{1F602}")
//            })
//
//
//        do {
//            var codec = UTF8()
//            var g = units.makeIterator()
//            switch codec.decode(&g) {
//            case .emptyInput: fatalError("No Input")
//            case .error: fatalError("Decoding Error")
//            case .scalarValue(let scalar): assert(scalar == "\u{1F602}")
//            }
//
//        }
//
//        do {
//            var codec = UTF8()
//
//            do {
//                var g1 = CollectionOfOne.Iterator(_elements: units[0])
//                let r1 = codec.decode(&g1)
//                print("r1: \(r1)") // .Error
//            }
//
//            do {
//                var g2 = CollectionOfOne.Iterator(_elements: units[1])
//                let r2 = codec.decode(&g2)
//                print("r2: \(r2)") // .EmptyInput
//            }
//
//            do {
//                var g3 = CollectionOfOne.Iterator(_elements: units[2])
//                let r3 = codec.decode(&g3)
//                print("r3: \(r3)") // .EmptyInput
//            }
//
//            do {
//                var g4 = CollectionOfOne.Iterator(_elements: units[3])
//                let r4 = codec.decode(&g4)
//                print("r4: \(r4)") // .EmptyInput
//            }
//        }
//    }
//
////    func testMaxlineStringify() {
////        let arr: JSum = [1, 2]
////        let bric: JSum = ["abc": [1, 2, 3, 4]]
////
////        XCTAssertEqual("[\n  1,\n  2\n]", arr.stringify(space: 2, maxline: 7))
////        XCTAssertEqual("[ 1, 2 ]", arr.stringify(space: 2, maxline: 8))
////
////        XCTAssertEqual("{\"abc\":[1,2,3,4]}", bric.stringify(space: 0, maxline: 0))
////        XCTAssertEqual("{\n  \"abc\": [\n    1,\n    2,\n    3,\n    4\n  ]\n}", bric.stringify(space: 2, maxline: 0))
////
////        XCTAssertEqual("{ \"abc\": [ 1, 2, 3, 4 ] }", bric.stringify(space: 2, maxline: 80))
////        XCTAssertEqual("{\n  \"abc\": [ 1, 2, 3, 4 ]\n}", bric.stringify(space: 2, maxline: 23))
////        //XCTAssertEqual("{ \"abc\": [\n    1, 2, 3, 4\n  ]\n}", bric.stringify(space: 2, maxline: 15))
////
////        XCTAssertEqual("{\n  \"abc\": [\n    1,\n    2,\n    3,\n    4\n  ]\n}", bric.stringify(space: 2, maxline: 5))
////
////
////    }
//
//    /// Returns the path of the folder containing test resources
//    private func testResourcePath() -> String {
//        return String(#file.reversed().drop(while: { $0 != "/" }).reversed()) + "testdata/"
//    }
//    
//    #if canImport(JavaScriptCore)
////    func testSerializationPerformance() throws {
////        do {
////            let path = testResourcePath() + "/profile/rap.json"
////            let contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
////            let bric = try JSum.parse(contents as String)
////            let cocoa = try JSONSerialization.jsonObject(with: contents.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions())
////
////            for _ in 0...10 {
////                var strs: [String] = [] // hang onto the strings so we don't include ARC releases in the profile
////                var datas: [Data] = []
////
////                let natives: [Bool] = [false, true]
////                let styleNames = natives.map({ $0 ? "bric" : "cocoa" })
////                var times: [TimeInterval] = []
////
////                for native in natives {
////                    let start = CFAbsoluteTimeGetCurrent()
////                    for _ in 0...10 {
////                        if native {
////                            strs.append(try bric.canonicalJSON)
////                        } else {
////                            datas.append(try JSONSerialization.data(withJSONObject: cocoa, options: JSONSerialization.WritingOptions.prettyPrinted))
////                        }
////                    }
////                    let end = CFAbsoluteTimeGetCurrent()
////                    times.append(end-start)
////                }
////                print("serialization times: \(styleNames) \(times)")
////            }
////        }
////    }
//    #endif
//    
////    func testBricDate() throws {
////        let now = Date(timeIntervalSince1970: 500000)
////        let dict = ["timestamp": now]
////        let bric = dict.bric()
////        do {
////            let brac = try [String:Date].brac(bric: bric)
////            XCTAssertEqual(dict, brac)
////        }
////    }
//
////    func testNestedBricDate() throws {
////        typealias X = Dictionary<String, Optional<Optional<Optional<Optional<Date>>>>>
////        let now = Date(timeIntervalSince1970: 500000)
////        let dict: X = X(dictionaryLiteral: ("timestamp", now))
////        let bric = dict.bric()
////        do {
////            let brac: X = try X.brac(bric: bric)
////            let t1 = dict["timestamp"]!!!!
////            let t2 = brac["timestamp"]!!!!
////            XCTAssertTrue(t1 == t2)
////        }
////    }
//
////    func testMirrorBric() {
////        do {
////            struct Foo { var bar: String; var num: Double?; var arr: [Foo] }
////            let foo = Foo(bar: "xxx", num: 12.34, arr: [Foo(bar: "yyy", num: nil, arr: [])])
////            let mirror = Mirror(reflecting: foo)
////            let bric = mirror.bric()
////            XCTAssertEqual(bric, ["bar": "xxx", "num": 12.34, "arr": [["bar": "yyy", "num": nil, "arr": []]]])
////        }
////
////        do {
////            let tuple = (1, 23.4, true, ([1, 2, 3], 23.4, true))
////            let mirror = Mirror(reflecting: tuple)
////            let bric = mirror.bric()
////            XCTAssertEqual(bric, [1, 23.4, true, [[1, 2, 3], 23.4, true]])
////        }
////    }
//
////    func testBracSwap() {
////        var x = 1, y = 2.2
////
////        XCTAssertEqual(x, 1)
////        XCTAssertEqual(y, 2.2)
////
////        do { try bracSwap(&x, &y) } catch { XCTFail(String(describing: error)) }
////
////        XCTAssertEqual(x, 2)
////        XCTAssertEqual(y, 1.0)
////    }
//
////    func testFidelityBricolage() {
////        let fb: FidelityBricolage = ["a": 1, "b": 2, "c": 3, "d": 4]
////        if case .obj(let obj) = fb {
////            XCTAssertEqual(Array(obj.map({ String(String.UnicodeScalarView() + $0.0) })), ["a", "b", "c", "d"])
////        } else {
////            XCTFail("FidelityBricolage not object")
////        }
////
////        let _: Bric = fb.bric()
////        // XCTAssertNotEqual(Array(bric.obj!.keys), ["a", "b", "c", "d"]) // note that we lose ordering when converting to standard JSum, but we can't rely on failure because it will be dependant on varying hashcodes
////    }
//
//    func testOneOfStruct() {
//        do {
//            let one = OneOf<String>.Or<String>(t1: "xxx")
//            let two = OneOf<String>.Or<String>(t1: "xxx")
//            XCTAssertEqual(one, two)
//        }
//
//        do {
//            let one = OneOf<String>.Or<String>(t2: "xxx")
//            let two = OneOf<String>.Or<String>(t2: "xxx")
//            XCTAssertEqual(one, two)
//        }
//
//        do {
//            let one = OneOf<String>.Or<String>(t1: "xxx")
//            let two = OneOf<String>.Or<String>(t2: "xxx")
//            XCTAssertNotEqual(one, two)
//        }
//
//        do {
//            var manyOrOneString = OneOf2<[String], String>("foo")
//            guard case .v2 = manyOrOneString else { return XCTFail("wrong type before swap array") }
//            manyOrOneString.swapped.array.removeAll()
//            guard case .v1 = manyOrOneString else { return XCTFail("wrong type after swap array") }
//        }
//    }
//
//    func testOneOfCoalesce() {
//        func failString() -> String {
//            XCTFail("should not be called bcause coalesce takes autoclosures")
//            return ""
//        }
//
//        let o2 = OneOf<String>.Or<Int>.coalesce(1, failString())
//        XCTAssertEqual(1, o2.v2)
//
//        let o5 = OneOf5<String, Int, Double, Float, Int>.coalesce(nil, nil, 1.7, 9, failString())
//        XCTAssertEqual(1.7, o5.v3)
//
//        /// coalescing operator
//        let oneof4: OneOf2<OneOf2<OneOf2<Bool, Double>, Int>, String> = nil ??? nil ??? 3.456 ??? true // returns .v1(.v1(.v2(3.456))
//        XCTAssertEqual(.v1(.v1(.v2(3.456))), oneof4)
//    }
//
//    func testExtricate() {
//        do {
//            typealias Src = OneOf2<OneOf<String>.Or<Int>, OneOf2<Bool, Double>>
//            typealias Dst = OneOf4<String, Int, Bool, Double>
//            let x: Src = Src(oneOf("abc"))
//            let _: Dst = x.flattened
//            let _: Dst = x.flattened.swapped.swapped // double swapped is always the same as itself
//        }
//
//        do {
//            typealias Src = OneOf2<OneOf3<String, Int, Void>, OneOf2<Bool, Double>>
//            typealias Dst = OneOf5<String, Int, Void, Bool, Double>
//            let x: Src = Src(oneOf("abc"))
//            let _: Dst = x.flattened
//            let _: Dst = x.flattened.swapped.swapped // double swapped is always the same as itself
//        }
//
//        do {
//            typealias Src1 = OneOf<String>.Or<Int>
//            typealias Src2 = OneOf<Bool>.Or<Never>.Or<Double>
//            typealias Src = OneOf<Src1>.Or<Src2>
//            typealias Dst = OneOf<String>.Or<Int>.Or<Bool>.Or<Never>.Or<Double>
//            let x: Src = Src(oneOf("abc"))
//            let _: Dst = x.flattened
//            let _: Dst = x.flattened.swapped.swapped // double swapped is always the same as itself
//        }
//
//        do {
//            typealias Src = OneOf<String>.Or<Int>.Or<Bool>.Or<Double>.Or<Never>
//            typealias Dst1 = OneOf<Int>.Or<String>.Or<Bool>.Or<Double>.Or<Never>
//            typealias Dst2 = OneOf<String>.Or<Int>.Or<Bool>.Or<Never>.Or<Double>
//            let x: Src = Src("abc")
//            let _: Dst1 = x.swappingFirst
//            let _: Dst2 = x.swappingLast
//        }
//
//    }
//
//    func testKeyRouting() {
//        struct Thing1 {
//            var thing1: Int
//            var name: String?
//        }
//        struct Thing2 {
//            var thing2: Double
//            var name: String?
//        }
//
//        struct Things {
//            var thing: OneOf<Thing1>.Or<Thing2>
//            var name: String? {
//                get { return thing[routing: \.name, \.name] }
//                set { thing[routing: \.name, \.name] = newValue }
//            }
//        }
//
//        var thing1 = Things(thing: .init(Thing1(thing1: 11, name: "X")))
//        XCTAssertEqual("X", thing1.name)
//        thing1.name = .some("Y")
//        XCTAssertEqual("Y", thing1.name)
//
//        let thing2 = Things(thing: .init(Thing2(thing2: 12.3, name: "Y")))
//
//        var things = [thing1, thing2]
//        things[walking: \.name] = ["ABC", "ABC"]
//        XCTAssertEqual(things[walking: \.name], ["ABC", "ABC"])
//    }
//
//    let RefPerformanceCount = 100000
//
//    func testOptionalPerformance() {
//        var array = Array<Optional<Bool>>()
//        array.reserveCapacity(RefPerformanceCount)
//        measure { // average: 0.001
//            for _ in 1...self.RefPerformanceCount { array.append(.some(true)) }
//            let allTrue = array.reduce(true, { (x, y) in x && (y ?? false) })
//            XCTAssertEqual(allTrue, true)
//        }
//    }
//
////    func testDeepMerge() {
////        XCTAssertEqual(JSum.obj(["foo": "bar"]).merge(bric: ["bar": "baz"]), ["foo": "bar", "bar": "baz"])
////        XCTAssertEqual(JSum.obj(["foo": "bar"]).merge(bric: ["bar": "baz", "foo": "bar2"]), ["foo": "bar", "bar": "baz"])
////        XCTAssertEqual(JSum.obj(["foo": [1, 2, 3]]).merge(bric: ["bar": "baz", "foo": "bar2"]), ["foo": [1,2,3], "bar": "baz"])
////        XCTAssertEqual(JSum.obj(["foo": [1, 2, ["x": "y"]]]).merge(bric: ["bar": "baz", "foo": [1, 2, ["a": "b"]]]), ["foo": [1, 2, ["a": "b", "x": "y"]], "bar": "baz"])
////        XCTAssertEqual(JSum.obj(["foo": [1, 2, [[[["x": "y"]]]]]]).merge(bric: ["bar": "baz", "foo": [1, 2, [[[["a": "b"]]]]]]), ["foo": [1, 2, [[[["a": "b", "x": "y"]]]]], "bar": "baz"])
////        XCTAssertEqual(JSum.obj(["foo": [1, 2, [[2, [["x": "y"]]]]]]).merge(bric: ["bar": "baz", "foo": [1, 2, [[2, [["a": "b"]]]]]]), ["foo": [1, 2, [[2, [["a": "b", "x": "y"]]]]], "bar": "baz"])
////    }
//
////    func testShallowMerge() {
////        XCTAssertEqual(JSum.obj(["foo": "bar"]).assign(bric: ["bar": "baz"]), ["foo": "bar", "bar": "baz"])
////        XCTAssertEqual(JSum.obj(["foo": "bar"]).assign(bric: ["bar": "baz", "foo": "bar2"]), ["foo": "bar", "bar": "baz"])
////        XCTAssertEqual(JSum.obj(["foo": [1, 2, 3]]).assign(bric: ["bar": "baz", "foo": "bar2"]), ["foo": [1,2,3], "bar": "baz"])
////        XCTAssertEqual(JSum.obj(["foo": [1, 2, ["x": "y"]]]).assign(bric: ["bar": "baz", "foo": [1, 2, ["a": "b"]]]), ["foo": [1, 2, ["x": "y"]], "bar": "baz"])
////    }
//
////    func testCodableConversion() throws {
////        let alien = Alien(name: "Zaphod", home: Planet(name: "Betelgeuse Five", coordinates: [123, 456, 789.5]))
////        let coder = BricEncoder()
////
////        let bricObj = try coder.encodeObject(alien)
////        XCTAssertEqual(bricObj, ["name":"Zaphod","home":["name":"Betelgeuse Five","coordinates": [123, 456, 789.5]]] as NSDictionary)
////
////        let bric = try coder.encode(alien)
////        XCTAssertEqual(bric, ["name":"Zaphod","home":["name":"Betelgeuse Five","coordinates": [123, 456, 789.5]]])
////    }
//
//    func testCodingExtraction() throws {
//        let aliens = [
//            Alien(name: "Zaphod", home: Planet(name: "Betelgeuse Five", coordinates: [123, 456, 789.5])),
//            Alien(name: "Ford", home: Planet(name: "Betelgeuse Seven", coordinates: [123, 456.2, 789.8])),
//            ]
//
//        // not sure why we double contained values…
//        let mult = 2
////        XCTAssertEqual(3 * mult, try ["A": "X", "B": "Y", "C": "Z"].encodableChildrenOfType(String.self).count)
////        XCTAssertEqual(3 * mult, try ["A": 1, "B": 2, "C": 3].encodableChildrenOfType(Int.self).count)
////        XCTAssertEqual(3 * mult, try [[[1,2,3]]].encodableChildrenOfType(Int.self).count)
////
////        XCTAssertEqual(2, try aliens.encodableChildrenOfType(Alien.self).count)
////        XCTAssertEqual(2, try aliens.encodableChildrenOfType(Planet.self).count)
////        XCTAssertEqual(4, try aliens.encodableChildrenOfType(String.self).count)
////        XCTAssertEqual(6 * mult, try aliens.encodableChildrenOfType(Float.self).count)
//
//
//    }
//    
//}
//
//fileprivate extension MutableCollection {
//    subscript<T>(walking keyPath: WritableKeyPath<Element, T>) -> [T] {
//        get {
//            return self.map({ $0[keyPath: keyPath] })
//        }
//
//        set {
//            for (i, value) in zip(indices, newValue) {
//                self[i][keyPath: keyPath] = value
//            }
//        }
//    }
//}
//
//struct Alien : Codable {
//    let name: String
//    let home: Planet
//}
//
//struct Planet : Codable {
//    let name: String
//    let coordinates: Array<Float>
//}
//
//
///// Parses the given stream of elements with the associated codec
////func parseCodec<C: UnicodeCodec, S: Sequence>(_ codecType: C.Type, _ seq: S) throws -> JSum where S.Iterator.Element == C.CodeUnit {
////    var top: JSum = nil
////    let parser = JSum.bricolageParser(options: .Strict) { (b, l) in
////        if l == 0 { top = b }
////        return b
////    }
////
////    let success: Bool = transcode(seq.makeIterator(), from: codecType, to: UTF32.self, stoppingOnError: true, into: {
////        do {
////            try parser.parse(CollectionOfOne(UnicodeScalar($0)!))
////        } catch {
////            fatalError("decoding error")
////        }
////        })
////
////    if success {
////    } else {
////    }
////
////    return top
////}
