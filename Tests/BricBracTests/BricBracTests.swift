//
//  BricBracTests.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 6/14/15.
//  Copyright © 2010-2020 io.glimpse. All rights reserved.
//

import XCTest
import BricBrac
import JavaScriptCore

class BricBracTests : XCTestCase {

    public static var allTests: [(String, (BricBracTests) -> () throws -> Void)] = [
        //("testBricConversion", testBricConversion),
        ("testAllocatonProfiling", testAllocatonProfiling),
        ("testEscaping", testEscaping),
        ("testISO8601JSONDates", testISO8601JSONDates),
        ("testBricBracPerson", testBricBracPerson),
        ("testBricBracCompany", testBricBracCompany),
        ("testReferenceCycles", testReferenceCycles),
        ("testLayers", testLayers),
        ("testOutputNulls", testOutputNulls),
        ("testBricBracModifiers", testBricBracModifiers),
        ("testBricBracSerialization", testBricBracSerialization),
        ("testBricBracParsing", testBricBracParsing),
        ("testBricSwapping", testBricSwapping),
        ("testBricBracCocoaCompatNumbers", testBricBracCocoaCompatNumbers),
        ("testNulNilEquivalence", testNulNilEquivalence),
        ("testKeyedSubscripting", testKeyedSubscripting),
        ("testBricAlter", testBricAlter),
        ("testJSONFormatting", testJSONFormatting),
        ("testBricBracCompatibility", testBricBracCompatibility),
        ("testStringReplace", testStringReplace),
        ("testJSONPointers", testJSONPointers),
        ("testStreamingParser", testStreamingParser),
        ("testStreamingBricolage", testStreamingBricolage),
        ("testStreamingEncoding", testStreamingEncoding),
        ("testStreamingDecoding", testStreamingDecoding),
        ("testMaxlineStringify", testMaxlineStringify),
        ("testSerializationPerformance", testSerializationPerformance),
        ("testBricDate", testBricDate),
        ("testNestedBricDate", testNestedBricDate),
        ("testMirrorBric", testMirrorBric),
        ("testBracSwap", testBracSwap),
        ("testFidelityBricolage", testFidelityBricolage),
        ("testOneOfStruct", testOneOfStruct),
        ("testKeyRouting", testKeyRouting),
        ("testOneOfCoalesce", testOneOfCoalesce),
        ("testExtricate", testExtricate),
        ("testOptionalPerformance", testOptionalPerformance),
        ("testDeepMerge", testDeepMerge),
        ("testShallowMerge", testShallowMerge),
        ("testCodableConversion", testCodableConversion),
        ("testCodingExtraction", testCodingExtraction),
        ("testShifting", testShifting),
        ("testExplicitNull", testExplicitNull),
        ("testIndirect", testIndirect),
        ]

#if canImport(Foundation)
    func testBricConversion() {
        let bric: Bric = ["a": [1, 2, true, false, nil]]
        let cocoa = FoundationBricolage.brac(bric: bric)
        XCTAssertNotNil(cocoa.object)
        let bric2 = cocoa.bric()
        XCTAssertEqual(bric, bric2)

        XCTAssertEqual(Bric.str("ABC"), FoundationBricolage(primitive: "ABC" as NSObject)?.bric())
        XCTAssertEqual(Bric.bol(false), FoundationBricolage(primitive: false as NSObject)?.bric())
        XCTAssertEqual(Bric.bol(true), FoundationBricolage(primitive: true as NSObject)?.bric())
        XCTAssertEqual(Bric.num(1.0), FoundationBricolage(primitive: 1 as NSObject)?.bric())
        XCTAssertEqual(Bric.num(1.0), FoundationBricolage(primitive: 1.0 as NSObject)?.bric())
        XCTAssertEqual(Bric.num(3.14159), FoundationBricolage(primitive: 3.14159 as NSObject)?.bric())
        XCTAssertEqual(Bric.nul, FoundationBricolage(primitive: NSNull() as NSObject)?.bric())

        // array and dict are unsupported
        XCTAssertEqual(nil, FoundationBricolage(primitive: [] as NSObject)?.bric())
        XCTAssertEqual(nil, FoundationBricolage(primitive: [:] as NSObject)?.bric())
    }
#endif

    func testAllocatonProfiling() throws {
        // json with unicode escapes
        // let path: String! = NSBundle(forClass: Self.self).pathForResource("test/profile/caliper.json", ofType: "")!

        // json no with escapes
        let path = testResourcePath() + "/profile/rap.json"

        print("loading resource: " + path)
        let contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        let scalars = Array((contents as String).unicodeScalars)

        var t = CFAbsoluteTimeGetCurrent()
        var c = 0
        while true {
            _ = try? Bric.parse(scalars) // caliper.json: ~64/sec, rap.json: 105/sec
//            _ = try? Bric.validate(scalars, options: .Strict) // caliper.json: ~185/sec, rap.json: ~380/sec
//            _ = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) // caliper.json: ~985/sec, rap.json: 1600/sec
            c += 1
            let t2 = CFAbsoluteTimeGetCurrent()
            if t2 > (t + 1.0) {
                print("parse-per-second: \(c)")
                t = t2
                c = 0
                break
            }
        }
    }

    func testEscaping() throws {
        func q(_ s: String)->String { return "\"" + s + "\"" }

        expectPass(q("\\/"), "/")
        expectPass(q("http:\\/\\/glimpse.io\\/"), "http://glimpse.io/")

        expectPass(q("\\n"), "\n")
        expectPass(q("\\r"), "\r")
        expectPass(q("\\t"), "\t")

        expectPass(q("\\\""), "\"")
        expectPass(q("\\\\"), "\\")

        expectPass(q("\\nX"), "\nX")
        expectPass(q("\\rYY"), "\rYY")
        expectPass(q("\\tZZZ"), "\tZZZ")

        expectPass(q("A\\nX"), "A\nX")
        expectPass(q("BB\\rYY"), "BB\rYY")

        expectPass(q("\\u002F"), "/")
        expectPass(q("\\u002f"), "/")

        expectPass("[ \"\\\"\" ]", ["\""])
        expectPass("[ \"x\", \"\\\"\" ]", ["x", "\""])

        expectPass(q("abc\\uD834\\uDD1Exyz"), "abc\u{0001D11E}xyz") // ECMA-404 section 9

        expectPass("[ { \"number\": 1 } ]", [[ "number": 1 ]])
        expectPass("[ { \"q\": \"\\\"\" } ]", [ [ "q": "\"" ]])

        do {
            let unescaped: Bric = "abc\"def"
            let escaped: String = "\"abc\\\"def\""

            let str = unescaped.stringify()
            XCTAssertEqual(escaped, str)

            let bric = try Bric.parse(escaped)
            XCTAssertEqual(unescaped, bric)
        }
    }

    func testISO8601JSONDates() {
        func testDateParse(_ str: Bric, _ unix: Int64?, canonical: Bool = false, line: UInt = #line) {
            guard let dtm = str.dtm else { return XCTAssertEqual(nil, unix, line: line) }

            // we extracted a date/time; convert it to a UNIX timestamp
            var dc = DateComponents()
            dc.year = dtm.year
            dc.month = dtm.month
            dc.day = dtm.day
            dc.hour = dtm.hour
            dc.minute = dtm.minute
            dc.second = Int(floor(dtm.second))
            dc.nanosecond = Int((dtm.second - Double(dc.second!)) * 1e9)
            dc.timeZone = TimeZone(secondsFromGMT: ((dtm.zone.hours * 60) + dtm.zone.minutes) * 60)
            guard let date = Calendar.current.date(from: dc) else { return XCTFail("could not convert calendar from \(dc)", line: line) }
            let unixsecs = date.timeIntervalSince1970
            if unixsecs > 8640000000000.000 { XCTAssertEqual(unix, nil, line: line) } // over the max permitted
            if unixsecs < -8640000000000.000 { XCTAssertEqual(unix, nil, line: line) } // under the min permitted
            XCTAssertEqual(unix, Int64(unixsecs * 1000), line: line)

            if canonical == true {
                // for canonical strings, also check that the stringified version is correct
                XCTAssertEqual(str.str ?? "", dtm.description, line: line)
            }
        }

        // date compat tests from https://github.com/es-shims/es5-shim/blob/master/tests/spec/s-date.js

        // extended years
//        testDateParse("0001-01-01T00:00:00Z", -62135596800000)
        testDateParse("+275760-09-13T00:00:00.000Z", 8640000000000000)
        //        testDateParse("+275760-09-13T00:00:00.001Z", nil)
        //        testDateParse("-271821-04-20T00:00:00.000Z", -8640000000000000)
        //        testDateParse("-271821-04-19T23:59:59.999Z", nil)
        testDateParse("+033658-09-27T01:46:40.000Z", 1000000000000000)
//        testDateParse("-000001-01-01T00:00:00Z", -62198755200000)
        testDateParse("+002009-12-15T00:00:00Z", 1260835200000)

        testDateParse("2012-11-31T23:59:59.000Z", nil)
        testDateParse("2012-12-31T23:59:59.000Z", 1356998399000, canonical: true)
        testDateParse("2012-12-31T23:59:60.000Z", nil)
        testDateParse("2012-04-04T05:02:02.170Z", 1333515722170, canonical: true)
        testDateParse("2012-04-04T05:02:02.170999Z", 1333515722170, canonical: true)
        testDateParse("2012-04-04T05:02:02.17Z", 1333515722170)
        testDateParse("2012-04-04T05:02:02.1Z", 1333515722100)
        testDateParse("2012-04-04T24:00:00.000Z", 1333584000000, canonical: true)
        testDateParse("2012-04-04T24:00:00.500Z", nil)
        testDateParse("2012-12-31T10:08:60.000Z", nil)
        testDateParse("2012-13-01T12:00:00.000Z", nil)
        testDateParse("2012-12-32T12:00:00.000Z", nil)
        testDateParse("2012-12-31T25:00:00.000Z", nil)
        testDateParse("2012-12-31T24:01:00.000Z", nil)
        testDateParse("2012-12-31T12:60:00.000Z", nil)
        testDateParse("2012-12-31T12:00:60.000Z", nil)
        testDateParse("2012-00-31T23:59:59.000Z", nil)
        testDateParse("2012-12-00T23:59:59.000Z", nil)
        testDateParse("2012-02-29T12:00:00.000Z", 1330516800000, canonical: true)
        testDateParse("2011-02-29T12:00:00.000Z", nil)
        testDateParse("2011-03-01T12:00:00.000Z", 1298980800000, canonical: true)

        // https://github.com/kriskowal/es5-shim/issues/80 Safari bug with leap day
        testDateParse("2034-03-01T00:00:00.000Z", 2024784000000)
        testDateParse("2034-02-27T23:59:59.999Z", 2024784000000 - 86400001, canonical: true)

        // Time Zone Offset
        testDateParse("2012-01-29T12:00:00.000+01:00", 1327834800000, canonical: true)
        testDateParse("2012-01-29T12:00:00.000-00:00", 1327838400000)
        testDateParse("2012-01-29T12:00:00.000+00:00", 1327838400000)
        //        testDateParse("2012-01-29T12:00:00.000+23:59", 1327752060000)
        //        testDateParse("2012-01-29T12:00:00.000-23:59", 1327924740000)
        testDateParse("2012-01-29T12:00:00.000+24:00", nil)
        testDateParse("2012-01-29T12:00:00.000+24:01", nil)
        testDateParse("2012-01-29T12:00:00.000+24:59", nil)
        testDateParse("2012-01-29T12:00:00.000+25:00", nil)
        testDateParse("2012-01-29T12:00:00.000+00:60", nil)
        //        testDateParse("-271821-04-20T00:00:00.000+00:01", nil)
        //        testDateParse("-271821-04-20T00:01:00.000+00:01", -8640000000000000)
        
    }

    func testBricBracPerson() {
        do {
            let p1 = try Person.brac(bric: ["name": "Marc", "age": 41, "male": true, "children": ["Bebe"]]) // , "children": []])
            print("p1: \(p1)")
            XCTAssertEqual(41, p1.age)

            XCTAssertEqual(p1.bric(), ["name": "Marc", "age": 41, "male": true, "children": ["Bebe"]])
            let p2 = try Person.brac(bric: p1.bric())
            XCTAssertEqual(p1, p2, "Default bric equatability should work")

            let p3 = try Person.brac(bric: ["name": "Marc", "age": 41, "male": true, "children": ["Beatrix"]])
            XCTAssertNotEqual(p1, p3, "Default bric equatability should work")

        } catch {
            XCTFail("error deserializing: \(error)")
        }

        do {
            // test numeric overflow throwing exception
            _ = try Person.brac(bric: ["name": "Marc", "age": .num(Double(Int.min)), "male": true, "children": ["Bebe"]])
        } catch BracError.numericOverflow {
            // as expected
        } catch {
            XCTFail("unexpected error when deserializing: \(error)")
        }

        do {
            _ = try Person.brac(bric: ["name": "Marc", "male": true])
            XCTFail("should not have been able to deserialize with required fields")
        } catch BracError.missingRequiredKey {
            // as expected
        } catch BracError.invalidType {
            // FIXME: we should instead be throwing a MissingRequiredKey
        } catch {
            XCTFail("unexpected error when deserializing: \(error)")
        }
    }

    func testBricBracCompany() {
        do { // Human CEO
            let bric: Bric = ["name": "Apple", "ceo": ["name": "Tim", "age": 50, "male": true, "children": []], "status": "public", "customers": [["name": "Emily", "age": 41, "male": false, "children": ["Bebe"]]], "employees": [["name": "Marc", "age": 41, "male": true, "children": ["Bebe"]]], "subsidiaries": nil]

            XCTAssertEqual(bric["ceo"]?["name"], "Tim")
            XCTAssertEqual(bric["status"], "public")
            XCTAssertEqual(bric["employees"]?[0]?["children"]?[0], "Bebe")

            let c = try Company.brac(bric: bric)

            let bric2 = c.bric()
            XCTAssertEqual(bric2["ceo"]?["name"], "Tim")
            XCTAssertEqual(bric2["status"], "public")
            XCTAssertEqual(bric2["employees"]?[0]?["children"]?[0], "Bebe")


            XCTAssertEqual(bric, bric2)
        } catch {
            XCTFail("unexpected error when deserializing: \(error)")
        }

        do { // Robot CEO
            let bric: Bric = ["name": "Apple", "ceo": "Stevebot", "customers": [["name": "Emily", "age": 41, "male": false, "children": ["Bebe"]]], "employees": [["name": "Marc", "age": 41, "male": true, "children": ["Bebe"]]], "status": "public", "subsidiaries": nil]
            let c = try Company.brac(bric: bric)
            XCTAssertEqual(bric, c.bric())
        } catch {
            XCTFail("unexpected error when deserializing: \(error)")
        }

        do { // No CEO
            let bric: Bric = ["name": "Apple", "ceo": nil, "status": "public", "customers": [["name": "Emily", "age": 41, "male": false, "children": ["Bebe"]]], "employees": [["name": "Marc", "age": 41, "male": true, "children": ["Bebe"]]], "subsidiaries": nil]
            let c = try Company.brac(bric: bric)
            XCTAssertEqual(bric, c.bric())
        } catch {
            XCTFail("unexpected error when deserializing: \(error)")
        }

    }

    func testReferenceCycles() {
        let company = Company(name: "Glimpse", ceo: nil, status: .`private`, customers: [], employees: [])
        company.subsidiaries = [company]
//        company.bric() // this would blow the stack because of object cycles
    }

    /// Tests wrapping behavior for bric and brac
    func testLayers() {
        do {
            do {
                let x = try Array<String>.brac(bric: ["foo", "bar"])
                XCTAssertEqual(x, ["foo", "bar"])
            }

            do {
                let x = try Optional<Array<Double>>.brac(bric: [1,2,3])
                XCTAssertEqual(x.bric(), [1,2,3])
            }

            do {
                let x = try Optional<Array<Double>>.brac(bric: nil)
                if x != nil {
                    XCTFail("not nil")
                }
            }

            do {
                let x = try Array<Optional<Array<Bool>>>.brac(bric: [[false] as Bric, nil, [true, true] as Bric, [] as Bric])
                XCTAssertEqual(x.bric(), [[false], nil, [true, true], []])
            }

            do {
                let x = try Optional<Optional<Optional<Optional<Optional<Int>>>>>.brac(bric: 1.1)
                XCTAssertEqual(x.bric(), 1)
            }

            do {
                let x1 = try Optional<Int>.brac(bric: nil)
                let x2 = try Optional<Optional<Int>>.brac(bric: nil)
                let x3 = try Optional<Optional<Optional<Int>>>.brac(bric: nil)
                let x4 = try Optional<Optional<Optional<Optional<Int>>>>.brac(bric: nil)
                let x5 = try Optional<Optional<Optional<Optional<Optional<Int>>>>>.brac(bric: nil)
                if x1 != nil || x2 != nil || x3 != nil || x4 != nil || x5 != nil {
                    XCTFail("bad value")
                } else {
                    _ = x1.bric()
                    _ = x2.bric()
                    _ = x3.bric()
                    _ = x4.bric()
                    _ = x5.bric()
                }
            }

            do {
                let x1 = try Array<Int>.brac(bric: [1])
                let x2 = try Array<Array<Int>>.brac(bric: [[2, 1]])
                let x3 = try Array<Array<Array<Int>>>.brac(bric: [[[3, 2, 1]]])
                let x4 = try Array<Array<Array<Array<Int>>>>.brac(bric: [[[[4, 3, 2, 1]]]])
                let x5 = try Array<Array<Array<Array<Array<Int>>>>>.brac(bric: [[[[[5, 4, 3, 2, 1]]]]])
                XCTAssertEqual(x1.bric(), [1])
                XCTAssertEqual(x2.bric(), [[2,1]])
                XCTAssertEqual(x3.bric(), [[[3,2,1]]])
                XCTAssertEqual(x4.bric(), [[[[4,3,2,1]]]])
                XCTAssertEqual(x5.bric(), [[[[[5, 4, 3, 2, 1]]]]])

                XCTAssertEqual(x1.bric(), [1])
                XCTAssertEqual(x2.bric(), [[2,1]])
                XCTAssertEqual(x3.bric(), [[[3,2,1]]])
                XCTAssertEqual(x4.bric(), [[[[4,3,2,1]]]])
                XCTAssertEqual(x5.bric(), [[[[[5, 4, 3, 2, 1]]]]])
            }

            do {
                if let x = try Optional<CollectionOfOne<Double>>.brac(bric: [1.111]) {
                    XCTAssertEqual(x.first ?? 0, 1.111)
                    XCTAssertEqual(x.bric(), [1.111])
                } else {
                    XCTFail("error")
                }
            }

            do {
                if let x = try Optional<CollectionOfOne<Dictionary<String, Set<Int>>>>.brac(bric: [["foo": [1,1,2]]]) {
                    XCTAssertEqual(x.first ?? [:], ["foo": Set([1,2])])
                    _ = x.bric()
                } else {
                    XCTFail("error")
                }
            }

//            do {
//                let bric: Bric = [["foo": 1.1], ["bar": 2.3]]
//
//                let x = try Optional<Array<Dictionary<String, Double>>>.brac(bric: bric)
//                if let x = x {
//                    XCTAssertEqual(x, [["foo": 1.1], ["bar": 2.3]])
//                    x.bric()
//                } else {
//                    XCTFail()
//                }
//            }

            do {
                enum StringEnum : String, Bricable, Bracable { case foo, bar }
                _ = try Array<Optional<StringEnum>>.brac(bric: ["foo", nil, "bar"])
            }

        } catch {
            XCTFail("unexpected error when wrapping in a layer: \(error)")
        }

        // now do some that should fail
        do {
            _ = try Array<String>.brac(bric: ["foo", 1])
            XCTFail("should have failed")
        } catch {
            // good
        }

        do {
            _ = try Optional<Array<Double>>.brac(bric: [1,2,nil])
            XCTFail("should have failed")
        } catch {
            // good
        }

        do {
            _ = try Optional<CollectionOfOne<Double>>.brac(bric: [1,2])
            XCTFail("should have failed")
        } catch {
            // good
        }

        do {
            _ = try Optional<CollectionOfOne<Double>>.brac(bric: [])
            XCTFail("should have failed")
        } catch {
            // good
        }

        do {
            _ = try Array<Int>.brac(bric: [[1]])
            XCTFail("should have failed")
        } catch {
            // good
        }

        do {
            _ = try Array<Array<Int>>.brac(bric: [[[2, 1]]])
            XCTFail("should have failed")
        } catch {
            // good
        }

        do {
            _ = try Array<Array<Array<Int>>>.brac(bric: [[[[3, 2, 1]]]])
            XCTFail("should have failed")
        } catch {
            // good
        }

        do {
            _ = try Array<Array<Array<Array<Int>>>>.brac(bric: [[[[[4, 3, 2, 1]]]]])
            XCTFail("should have failed")
        } catch {
            // good
        }

        do {
            _ = try Array<Array<Array<Array<Array<Int>>>>>.brac(bric: [[[[[[5, 4, 3, 2, 1]]]]]])
            XCTFail("should have failed")
        } catch {
            // good
        }

    }

    func bricOrderedMapper(_ dict: [String: Bric]) -> AnyIterator<(key: String, value: Bric)> {
        return AnyIterator(dict.sorted { $0.0 < $1.0 }.makeIterator())
    }

    func testOutputNulls() {
        let bric: Bric = ["num": 1, "nul": nil]

        XCTAssertEqual("{\"nul\":null,\"num\":1}", bric.stringify(mapper: bricOrderedMapper))
    }

    func testBricBracModifiers() {
        var bric = Bric.str("x")
        bric.str! += "x"
        XCTAssertEqual("xx", bric)
        bric.str = nil
        XCTAssertEqual(.nul, bric)

        bric.num = 2.0
        XCTAssertEqual(2.0, bric)
        bric.num! += 0.2
        XCTAssertEqual(2.2, bric)

        bric.bol = false
        XCTAssertEqual(false, bric)
        bric.bol!.toggle()
        XCTAssertEqual(true, bric)

        bric.arr = [1, 2]
        XCTAssertEqual([1, 2], bric)
        bric.arr!.append(3)
        XCTAssertEqual([1, 2, 3], bric)

        bric.obj = ["X": 1, "Y": 2]
        XCTAssertEqual(["X": 1, "Y": 2], bric)
        bric.obj!["Y"]!.num! += 2
        XCTAssertEqual(["X": 1, "Y": 4], bric)

    }

    func testBricBracSerialization() {
        let json = """
{"ceo":{"age":50,"children":[],"male":true,"name":"Tim"},"customers":[{"age":41,"children":["Bebe"],"male":false,"name":"Emily"}],"employees":[{"age":41,"children":["Bebe"],"male":true,"name":"Marc"}],"name":"Apple","status":"public"}
"""

        do {
            let bric: Bric = ["name": "Apple", "ceo": ["name": "Tim", "age": 50, "male": true, "children": []], "status": "public", "customers": [["name": "Emily", "age": 41, "male": false, "children": ["Bebe"]]], "employees": [["name": "Marc", "age": 41, "male": true, "children": ["Bebe"]]]]

            let str = bric.stringify(mapper: bricOrderedMapper)
            // note that key order differs on MacOS and iOS, probably due to different hashing
            XCTAssertEqual(str, json)
        }

        do { // test quote serialization
            let bric: Bric = "abc\"def"
            let str = bric.stringify()
            XCTAssertEqual("\"abc\\\"def\"", str)
        }
    }

    func expectFail(_ s: String, _ msg: String? = nil, options: JSONParser.Options = .Strict, file: StaticString = #file, line: UInt = #line) {
        do {
            _ = try Bric.parse(s, options: options)
            XCTFail("Should have failed to parse", file: (file), line: line)
        } catch {
            if let m = msg {
                XCTAssertEqual(m, String(describing: error), file: (file), line: line)
            }
        }
    }

    func expectPass(_ s: String, _ bric: Bric? = nil, options: JSONParser.Options = .Strict, file: StaticString = #file, line: UInt = #line) {
        do {
            let b = try Bric.parse(s, options: options)
            if let bric = bric {
                XCTAssertEqual(bric, b, file: (file), line: line)
            } else {
                // no comparison bric; just pass
            }
        } catch {
            XCTFail("\(error)", file: (file), line: line)
        }
    }

    func testDoubleOptionalEncoding() throws {
        struct OStrings : Codable, Hashable {
            let a: String?
            let b: String??
        }

        XCTAssertEqual("{}", OStrings(a: .none, b: .none).jsonDebugDescription)
        XCTAssertEqual("{\"b\":null}", OStrings(a: .none, b: .some(.none)).jsonDebugDescription)
        XCTAssertEqual("{\"b\":\"X\"}", OStrings(a: .none, b: "X").jsonDebugDescription)

        func dec(_ string: String) throws -> OStrings {
            try JSONDecoder().decode(OStrings.self, from: Data(string.utf8))
        }
        XCTAssertEqual(try dec("{}"), OStrings(a: .none, b: .none))
        XCTAssertEqual(try dec("{\"b\":null}"), OStrings(a: .none, b: .none)) // .some(.none))) // this is why we need Nullable: double-optional doesn't decode explicit nulls as a .some(.none)
        XCTAssertEqual(try dec("{\"b\":\"X\"}"), OStrings(a: .none, b: "X"))

    }

    func testDecimalEncoding() throws {
        XCTAssertEqual("[12.800000000000001]", [Double(12.8)].jsonDebugDescription)
        XCTAssertEqual("[12.8]", [Decimal(12.8)].jsonDebugDescription)

        XCTAssertEqual("[12.800000000000001]", [OneOf<Double>.Or<Decimal>.v1(Double(12.8))].jsonDebugDescription)
        XCTAssertEqual("[12.8]", [OneOf2<Double, Decimal>.v2(Decimal(12.8))].jsonDebugDescription)
    }

    func testBricSwapping() {
        struct Swapper : KeyedCodable, Equatable {
            static let codableKeys = [\Self.x : CodingKeys.x, \Self.y : CodingKeys.y]

            let x: Int
            let y: Float

            enum CodingKeys : String, CodingKey { case x, y }
            static let codingKeyPaths = (\Self.x, \Self.y)
        }

        do {
            var swapper = Swapper(x: 5, y: 6)
            XCTAssertEqual(5, swapper.x)
            XCTAssertEqual(6, swapper.y)
            try swapper.swapBricValues(keys: (.x, .y))
            XCTAssertEqual(6, swapper.x)
            XCTAssertEqual(5, swapper.y)

            do {
                let swapper1 = Swapper(x: 1, y: 2)
                var swapper2 = swapper1
                try swapper2.swapBricValues(keys: (.x, .y))
                try swapper2.swapBricValues(keys: (.x, .y))
                XCTAssertEqual(swapper1, swapper2) // make sure round-trip is equal
            }

//            do {
//                // doesn't work: “Parsed JSON number <2.200000047683716> does not fit in Int”
//                let swapper1 = Swapper(x: 1, y: 2.2)
//                var swapper2 = swapper1
//                try swapper2.swapBricValues(keys: (.x, .y))
//                try swapper2.swapBricValues(keys: (.x, .y))
//                XCTAssertNotEqual(swapper1, swapper2) // make sure round-trip is *not* equal
//            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testBricBracParsing() {
        func q(_ s: String)->String { return "\"" + s + "\"" }

        expectPass("1", 1)
        expectPass("1.0", 1.0)
        expectPass("1.1", 1.1)
        expectPass("-1.00100", -1.001)
        expectPass("1E+1", 10)
        expectPass("1E-1", 0.1)
        expectPass("1.0E+1", 10)
        expectPass("1.0E-1", 0.1)
        expectPass("1.2E+1", 12)
        expectPass("1.2E-1", 0.12)
        expectPass("1E+10", 1E+10)
        expectPass("1e-100", 1e-100)

        expectFail("-01234.56789", "Leading zero in number (line: 1 column: 12)")
        expectPass("-01234.56789", -01234.56789, options: .AllowLeadingZeros)

        expectFail("1 XXX", "Trailing content (line: 1 column: 3)")
        expectPass("1 XXX", 1, options: .AllowTrailingContent)

        expectFail("n")
        expectFail("nu")
        expectFail("nul")
        expectPass("null", .nul)

        expectFail("t")
        expectFail("tr")
        expectFail("tru")
        expectPass("true", true)

        expectFail("f")
        expectFail("fa")
        expectFail("fal")
        expectFail("fals")
        expectPass("false", false)
        
        expectFail("truefalse", "Trailing content (line: 1 column: 5)")

        expectFail(",", "Comma found with no pending result (line: 1 column: 1)")
        expectFail("]", "Unmatched close array brace (line: 1 column: 1)")
        expectFail("}", "Unmatched close object brace (line: 1 column: 1)")
        expectFail(":", "Object key assignment outside of an object (line: 1 column: 1)")
        expectFail("[\"key\" :", "Object key assignment outside of an object (line: 1 column: 8)")


        expectFail("[truefalse]", "Character found with pending result value (line: 1 column: 6)")
        expectFail("[true1]", "Number found with pending result value (line: 1 column: 6)")
        expectFail("[1true]", "Character found with pending result value (line: 1 column: 3)")
        expectFail("[true\"ABC\"]", "String found with pending result value (line: 1 column: 6)")
        expectFail("[\"ABC\" true]", "Character found with pending result value (line: 1 column: 8)")
        expectFail("[\"a\"\"b\"]", "String found with pending result value (line: 1 column: 5)")
        expectFail("[\"a\"1\"b\"]", "Number found with pending result value (line: 1 column: 5)")
        expectFail("[\"a\"nu\"b\"]", "Character found with pending result value (line: 1 column: 5)")

        expectFail("[true", "Unclosed container (line: 1 column: 5)")
        expectFail("{", "Unclosed container (line: 1 column: 1)")
        expectFail("{\"qqq\"", "Unclosed container (line: 1 column: 6)")

        expectFail(q("abc\tdef"), "Strings may not contain tab characters (line: 1 column: 5)")
        expectFail(q("\n"), "Strings may not contain newlines (line: 2 column: 0)")

        expectPass("[\"abcéfg\", 123.4567]", ["abcéfg", 123.4567])
        expectPass("[123.4567]", [123.4567])
        expectPass("0", 0)
        expectPass("0.1", 0.1)
        expectPass("123.4567", 123.4567)
        expectPass("123.4567 ", 123.4567)
        expectPass("[[[[123.4567]]]]", [[[[123.4567]]]])
        expectPass("{\"foo\": \"bar\"}", ["foo": "bar"])
        expectPass("{\"foo\": 1}", ["foo": 1])
        expectPass("{\"foo\": null}", ["foo": nil])
        expectPass("{\"foo\": true}", ["foo": true])
        expectPass("{\"foo\": false}", ["foo": false])
        expectPass("{\"foo\": false, \"bar\": true}", ["foo": false, "bar": true])
        expectPass("{\"foo\": false, \"bar\": {\"a\": \"bcd\"}}", ["foo": false, "bar": ["a": "bcd"]])
        expectPass("{\"foo\": false, \"bar\": {\"a\": [\"bcd\"]}}", ["foo": false, "bar": ["a": ["bcd"]]])
        expectPass("{\"foo\": false, \"bar\": {\"a\": [\"bcd\"],\"b\":[]},\"baz\": 2}", ["foo": false, "bar": ["a": ["bcd"], "b": []], "baz": 2])

        expectPass("[1, \"a\", true]", [1, "a", true])
        expectPass("[  \r\n  \n  1  \n  \n  ,  \n  \t\n  \"a\"  \n  \n  ,  \r\t\n  \n  true  \t\t\r\n  \n  ]", [1, "a", true])
        expectFail("[1, \"a\", true,]", "Trailing comma (line: 1 column: 15)")

        expectPass("{\"customers\":[{\"age\":41,\"male\":false,\"children\":null,\"name\":\"Emily\"}],\"employees\":[null],\"ceo\":null,\"name\":\"Apple\"}")

        expectPass("{\"customers\":[{\"age\":41,\"male\":false,\"children\":[\"Bebe\"],\"name\":\"Emily\"}],\"employees\":[{\"age\":41,\"male\":true,\"children\":[\"Bebe\"],\"name\":\"Marc\"}],\"ceo\":{\"age\":50.01E+10,\"male\":true,\"children\":[],\"name\":\"Tim\"},\"name\":\"Apple\"}")

        expectFail("{\"Missing colon\" null}", "Invalid character within object start (line: 1 column: 18)")
        expectFail("{\"Extra colon\":: null}", "Object key assignment outside of an object (line: 1 column: 16)")
        expectFail("{\"Extra colon\"::: null}", "Object key assignment outside of an object (line: 1 column: 16)")

        expectFail("{{", "Object start within object start (line: 1 column: 2)")
        expectFail("{[", "Array start within object start (line: 1 column: 2)")
        expectFail("{x", "Invalid character within object start (line: 1 column: 2)")
        expectFail("[x", "Unrecognized token: x (line: 1 column: 2)")

        expectPass(q("a"), "a")
        expectPass(q("abc"), "abc")

        expectPass(q("/"), "/")
        expectPass(q("\\/"), "/")
        expectPass(q("http:\\/\\/glimpse.io\\/"), "http://glimpse.io/")

        expectPass(q("\\n"), "\n")
        expectPass(q("\\r"), "\r")
        expectPass(q("\\t"), "\t")

        expectPass(q("\\nX"), "\nX")
        expectPass(q("\\rYY"), "\rYY")
        expectPass(q("\\tZZZ"), "\tZZZ")

        expectPass(q("A\\nX"), "A\nX")
        expectPass(q("BB\\rYY"), "BB\rYY")
        expectPass(q("CCC\\tZZZ"), "CCC\tZZZ")

        expectPass(q("\\u002F"), "/")
        expectPass(q("\\u002f"), "/")

        expectPass(q("abc\\uD834\\uDD1Exyz"), "abc\u{0001D11E}xyz") // ECMA-404 section 9

        for char in ["X", "é", "\u{003}", "😡"] {
            expectPass(q(char), .str(char))
        }
    }

    /// Verify that our serialization is compatible with NSJSONSerialization
    func testBricBracCocoaCompatNumbers() {
        #if swift(<5.1) // FIXME: something broke in the beta
        compareCocoaParsing("1.2345678", msg: "fraction alone")
        compareCocoaParsing("1.2345678 ", msg: "fraction with trailing space")
        compareCocoaParsing("1.2345678\n", msg: "fraction with trailing newline")
        compareCocoaParsing("1.2345678\n\n", msg: "fraction with trailing newlines")
        #endif

        compareCocoaParsing("1", msg: "number with no newline")
        compareCocoaParsing("1 ", msg: "number with trailing space")
        compareCocoaParsing("1\n", msg: "number with trailing newline")
        compareCocoaParsing("1\n\n", msg: "number with trailing newlines")

        compareCocoaParsing("0.1", msg: "fractional number with leading zero")
//        compareCocoaParsing("1.234567890E+34", msg: "number with upper-case exponent")
//        compareCocoaParsing("0.123456789e-12", msg: "number with lower-case exponent")

        compareCocoaParsing("[0e]", msg: "number with trailing e at end of array")
        compareCocoaParsing("[0e+]", msg: "number with trailing e+ at end of array")

        compareCocoaParsing("0.1", msg: "preceeding zero OK")
        compareCocoaParsing("01", msg: "preceeding zero should fail")
        compareCocoaParsing("01.23", msg: "preceeding zero should fail")
        compareCocoaParsing("01.01", msg: "preceeding zero should fail")
        compareCocoaParsing("01.0", msg: "preceeding zero should fail")
    }

    func profileJSON(_ str: String, count: Int, validate: Bool, cocoa: Bool, cf: Bool) throws {
        let scalars = Array((str as String).unicodeScalars)

        if let data = str.data(using: String.Encoding.utf8) {

            let js = CFAbsoluteTimeGetCurrent()
            for _ in 1...count {
                if cf {
                    _ = try CoreFoundationBricolage.parseJSON(scalars, options: JSONParser.Options.Strict)
//                    let nsobj = Unmanaged<NSObject>.fromOpaque(COpaquePointer(fbric.ptr)).takeRetainedValue()
                } else if cocoa {
                    let _: NSObject = try Bric.parseCocoa(scalars)
                } else if validate {
                    try Bric.validate(scalars, options: JSONParser.Options.Strict)
                } else {
                    _ = try Bric.parse(scalars)
                }
            }
            let je = CFAbsoluteTimeGetCurrent()

            let cs = CFAbsoluteTimeGetCurrent()
            for _ in 1...count {
                try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            }
            let ce = CFAbsoluteTimeGetCurrent()

            print((cf ? "CF" : cocoa ? "Cocoa" : validate ? "Validated" : "Fluent") + ": BricBrac: \(je-js) Cocoa: \(ce-cs) (\(Int(round((je-js)/(ce-cs))))x slower)")
        }
    }

    @discardableResult func parsePath(_ path: String, strict: Bool, file: StaticString = #file, line: UInt = #line) throws -> Bric {
        let str = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        let bric = try Bric.parse(str as String, options: strict ? .Strict : .Lenient)

        // always check to ensure that our strinification matches that of JavaScriptCore
        compareJSCStringification(bric, msg: (path as NSString).lastPathComponent, file: file, line: line)
        return bric
    }

    func compareCocoaParsing(_ string: String, msg: String, file: StaticString = #file, line: UInt = #line) {
        var cocoaBric: NSObject?
        var bricError: Error?
        var cocoa: NSObject?
        var cocoaError: Error?

        do {
            // NSJSONSerialization doesn't always ignore trailing spaces: http://openradar.appspot.com/21472364
            let str = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            cocoa = try JSONSerialization.jsonObject(with: str.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSObject
        } catch {
            cocoaError = error
        }

        do {
            cocoaBric = try Bric.parseCocoa(string)
        } catch {
            bricError = error
        }

        switch (cocoaBric, cocoa, bricError, cocoaError) {
        case (.some(let j), .some(let c), _, _):
            if j != c {
//                dump(j)
//                dump(c)
                print(j)
                print(c)
//                assert(j == c)
            }
            #if os(iOS)
            // for some reason, iOS numbers do not equate true for some floats, so we just compare the strings
            XCTAssertTrue(j.description == c.description, "Parsed contents differed for «\(msg)»", file: (file), line: line)
            #else
            XCTAssertTrue(j == c, "Parsed contents differed for «\(msg)»", file: (file), line: line)
            #endif
        case (_, _, .some(let je), .some(let ce)):
            // for manual inspection of error messages, change equality to inequality
            if String(describing: je) == String(describing: ce) {
                print("Bric Error «\(msg)»: \(je)")
                print("Cocoa Error «\(msg)»: \(ce)")
            }
            break
        case (_, _, _, .some(let ce)):
            XCTFail("Cocoa failed/BricBrac passed «\(msg)»: \(ce)", file: (file), line: line)
        case (_, _, .some(let je), _):
            XCTFail("BricBrac failed/Cocoa passed «\(msg)»: \(je)", file: (file), line: line)
        default:
            XCTFail("Unexpected scenario «\(msg)»", file: (file), line: line)
        }
    }

    let ctx = JSContext()

    /// Asserts that Bric's stringify() exactly matches JavaScriptCore's JSON.stringify, with the following exceptions:
    ///
    /// * Key ordering is forced to be alphabetical (to compensate for the undefined key enumeration ordering of
    ///   Swift Dictionaries and JSC Objects)
    ///
    /// * We outputs exponential notation for some large integers, whereas JSC nevers appears to do so
    func compareJSCStringification(_ b: Bric, space: Int = 2, msg: String, file: StaticString = #file, line: UInt = #line) {
        // JSC only allows dictionaries and arrays, so wrap any primitives in an array
        let bric: Bric = ["ob": b] // we just wrap everything in an array

        // key ordering in output is arbitrary depending on the underlying dictionary implementation,
        // and Swift and JavaScriptCore list keys in a different order; so to test this properly,
        // we need to serialize the swift key order the same as JavaScriptCore; we do this by
        // having the mapper query the JSContents for the order in which the keys would be output
        func mapper(_ dict: [String: Bric]) -> AnyIterator<(key: String, value: Bric)> {
            return AnyIterator(Array(dict).sorted(by: { kv1, kv2 in
                return kv1.0 < kv2.0
            }).makeIterator())
        }

        let bstr = bric.stringify()

        let evaluated = ctx?.evaluateScript("testOb = " + bstr)
        XCTAssertTrue((evaluated?.isObject)!, "\(msg) parsed instance was not an object: \(bstr)", file: (file), line: line)
        XCTAssertNil(ctx?.exception, "\(msg) error evaluating brac'd string: \(String(describing: ctx?.exception))", file: (file), line: line)

        let bricString = bric.stringify(space: space, mapper: mapper)

        let stringified = ctx?.evaluateScript("JSON.stringify(testOb, function(key, value) { if (value === null || value === void(0) || value.constructor !== Object) { return value; } else { return Object.keys(value).sort().reduce(function (sorted, key) { sorted[key] = value[key]; return sorted; }, {}); } }, \(space))")
        if !(stringified?.isString)! {
            XCTFail("\(msg) could not stringify instance in JS context: \(String(describing: ctx?.exception))", file: (file), line: line)
        } else {
            let str = stringified?.toString()
            if bricString.contains("e+") { // we differ in that we output exponential notation
                return
            }

            XCTAssertTrue(str == bricString, "\(msg) did not match:\n\(String(describing: str))\n\(bricString)", file: (file), line: line)
        }

    }

    func testNulNilEquivalence() {
        do {
            let j1 = Bric.obj(["foo": "bar"])

            let j2 = Bric.obj(["foo": "bar", "baz": nil])

            // the two Brics are not the same...
            XCTAssertNotEqual(j1, j2)

            // ... and the two underlying dictionaries are the same ...
            if case let .obj(d1) = j1, case let .obj(d2) = j2 {
                XCTAssertNotEqual(d1, d2)
            }

            let j3 = Bric.obj(["foo": "bar", "baz": .nul])
            // the two Brics are the same...
            XCTAssertEqual(j2, j3)

            // ... and the two underlying dictionaries are the same ...
            if case .obj(let d2) = j2, case .obj(let d3) = j3 {
                XCTAssertEqual(d2, d3)
            }

            print(j3.stringify())

        }
    }


    func testKeyedSubscripting() {
        let val: Bric = ["key": "foo"]
        if let _: String = val["key"]?.str {
        } else {
            XCTFail()
        }
    }

    func testBricAlter() {
        XCTAssertEqual("Bar", Bric.str("Foo").alter { (_, _) in "Bar" })
        XCTAssertEqual(123, Bric.str("Foo").alter { (_, _) in 123 })
        XCTAssertEqual([:], Bric.arr([]).alter { (_, _) in [:] })

        XCTAssertEqual(["foo": 1, "bar": "XXX"], Bric.obj(["foo": 1, "bar": 2]).alter {
            return $0 == [.key("bar")] ? "XXX" : $1
        })

        do {
            let b1: Bric = [["foo": 1, "bar": 2], ["foo": 1, "bar": 2]]
            let b2: Bric = [["foo": 1, "bar": 2], ["foo": "XXX", "bar": "XXX"]]
            let path: Bric.Pointer = [.index(1) ]
            XCTAssertEqual(b2, b1.alter { return $0.starts(with: path) && $0 != path ? "XXX" : $1 })
        }
    }

//    func testBricBracAround() {
//        do {
//            let x1: Array<String> = ["a", "b", "c"]
//            let x2 = try Array<String>.brac(x1.bric())
//            XCTAssertEqual(x1, x2)
//        } catch {
//            XCTFail("Round-trip error")
//        }
//    }

    func testJSONFormatting() throws {
        let json = "{\"abc\": 1.2233 , \"xyz\" :  \n\t\t[true,false, null]}  "
        let compact = "{\"abc\":1.2233,\"xyz\":[true,false,null]}"
        let pretty = "{\n  \"abc\" : 1.2233,\n  \"xyz\" : [\n    true,\n    false,\n    null\n  ]\n}"
        do {
            let p1 = try JSONParser.formatJSON(json)
            XCTAssertEqual(p1, json)

            let p2 = try JSONParser.formatJSON(json, indent: 0)
            XCTAssertEqual(p2, compact)

            let p3 = try JSONParser.formatJSON(json, indent: 2)
            XCTAssertEqual(p3, pretty)
        }
    }

    func testBricBracCompatibility() {

        let fm = FileManager.default
        do {
            let rsrc: String? = testResourcePath()
            if let folder = rsrc {
                let types = try fm.contentsOfDirectory(atPath: folder)
                XCTAssertEqual(types.count, 5) // data, jsonchecker, profile, schema
                for type in types {
                    let dir = (folder as NSString).appendingPathComponent(type)
                    let jsons = try fm.contentsOfDirectory(atPath: dir)
                    for file in jsons {
                        do {
                            let fullPath = (dir as NSString).appendingPathComponent(file)

                            // first check to ensure that NSJSONSerialization's results match BricBrac's

                            if file.hasSuffix(".json") {

                                // make sure our round-trip validing parser works
                                let contents = try NSString(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue) as String


                                do {
                                    let scalars = contents.unicodeScalars // quite a bit slower than operating on the array
                                    // let scalars = Array(contents.unicodeScalars)
                                    let roundTripped = try roundTrip(scalars)
                                    XCTAssertEqual(String(scalars), String(roundTripped))
                                } catch {
                                    // ignore parse errors, since this isn't where we are validating pass/fail
                                }

                                // dodge http://openradar.appspot.com/21472364
                                if file != "caliper.json" && file != "pass1.json" && file != "vega2.schema.json" {
                                    #if swift(>=5.1)
                                    // something broke with the 5.1 beta
                                    if file != "test_basic_03.json" {
                                        compareCocoaParsing(contents, msg: file)
                                    }
                                    #else
                                    compareCocoaParsing(contents, msg: file)
                                    #endif
                                }


                                if type == "profile" {
                                    let count = 6
                                    print("\nProfiling \((fullPath as NSString).lastPathComponent) \(count) times:")
                                    let str = try NSString(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue) as String
                                    try profileJSON(str, count: count, validate: true, cocoa: false, cf: false)
                                    try profileJSON(str, count: count, validate: false, cocoa: false, cf: false)
                                    try profileJSON(str, count: count, validate: false, cocoa: false, cf: true)
                                    try profileJSON(str, count: count, validate: false, cocoa: true, cf: false)
                                } else if type == "jsonschema" {
                                    let bric = try Bric.parse(contents)

                                    // the format of the tests in https://github.com/json-schema/JSON-Schema-Test-Suite are arrays of objects that contain a "schema" item
                                    guard case let .arr(items) = bric else {
                                        XCTFail("No top-level array in \(file)")
                                        continue
                                    }
                                    for (_, item) in items.enumerated() {
                                        guard case let .obj(def) = item else {
                                            XCTFail("Array element was not an object: \(file)")
                                            continue
                                        }
                                        guard case let .some(schem) = def["schema"] else {
                                            XCTFail("Schema object did not contain a schema object key: \(file)")
                                            continue
                                        }
                                        if schem == schem {

                                        }

//                                        do {
//                                            let schema = try Schema.brac(schem)
//                                            let reschema = try Schema.brac(schema.bric())
//                                            XCTAssertEqual(schema, reschema)
//                                        } catch {
//                                            XCTFail("failed to load element #\(i) of \(file) error=\(error): \(schem.stringify())")
//                                        }
                                    }
                                } else if type == "schemas" {
                                    // try to codegen all the schemas
                                    _ = try parsePath(fullPath, strict: true)
//                                    _ = try Schema.brac(bric: bric)
//                                    if false {
//                                        let swift = try schema.generateType()
//                                        print("##### swift for \(file):\n\(swift)")
//                                    }
                                } else {
                                    try parsePath(fullPath, strict: type == "jsonchecker")
                                    if file.hasPrefix("fail") {
                                        if file == "fail1.json" {
                                            // don't fail on the no root string test; the spec doesn't forbit it
                                            // "A JSON payload should be an object or array, not a string."
                                        } else if file == "fail18.json" {
                                            // don't fail on the arbitrary depth limit test; the spec doesn't forbit it
                                            // [[[[[[[[[[[[[[[[[[[["Too deep"]]]]]]]]]]]]]]]]]]]]
                                        } else {
                                            XCTFail("Should have failed test at: \(file)")
                                        }
                                    }
                                }
                            }
                        } catch {
                            if file.hasPrefix("fail") {
                                // should fail
                            } else {
                                XCTFail("Should have passed test at: \(file) error: \(error)")
                                dump(error)
                            }
                        }
                    }
                }
            }
        } catch {
            XCTFail("unexpected error when loading tests: \(error)")
        }
    }



    func testStringReplace() {
        XCTAssertEqual("foo".replace(string: "oo", with: "X"), "fX")
        XCTAssertEqual("foo".replace(string: "o", with: "X"), "fXX")
        XCTAssertEqual("foo".replace(string: "o", with: "XXXX"), "fXXXXXXXX")
        XCTAssertEqual("foo".replace(string: "ooo", with: "XXXX"), "foo")
        XCTAssertEqual("123".replace(string: "3", with: ""), "12")
        XCTAssertEqual("123".replace(string: "1", with: ""), "23")
        XCTAssertEqual("123".replace(string: "2", with: ""), "13")
        XCTAssertEqual("abcabcbcabcbcbc".replace(string: "bc", with: "XYZ"), "aXYZaXYZXYZaXYZXYZXYZ")
    }

    func testJSONPointers() {
        // http://tools.ietf.org/html/draft-ietf-appsawg-json-pointer-04
        let json: Bric = [
            "foo": ["bar", "baz"],
            "": 0,
            "a/b": 1,
            "c%d": 2,
            "e^f": 3,
            "g|h": 4,
            "i\\j": 5,
            "k\"l": 6,
            " ": 7,
            "m~n": 8
        ]

        // ""         // the whole document
        // "/foo"       ["bar", "baz"]
        // "/foo/0"    "bar"
        // "/"          0
        // "/a~1b"      1
        // "/c%d"       2
        // "/e^f"       3
        // "/g|h"       4
        // "/i\\j"      5
        // "/k\"l"      6
        // "/ "         7
        // "/m~0n"      8

        do {
            do { let x = try json.reference(""); XCTAssertEqual(x, json) }
            do { let x = try json.reference("/foo"); XCTAssertEqual(x, ["bar", "baz"]) }
            do { let x = try json.reference("/foo/0"); XCTAssertEqual(x, "bar") }
            do { let x = try json.reference("/"); XCTAssertEqual(x, 0) }
            do { let x = try json.reference("/a~1b"); XCTAssertEqual(x, 1) }
            do { let x = try json.reference("/c%d"); XCTAssertEqual(x, 2) }
            do { let x = try json.reference("/e^f"); XCTAssertEqual(x, 3) }
            do { let x = try json.reference("/g|h"); XCTAssertEqual(x, 4) }
            do { let x = try json.reference("/i\\j"); XCTAssertEqual(x, 5) }
            do { let x = try json.reference("/k\"l"); XCTAssertEqual(x, 6) }
            do { let x = try json.reference("/ "); XCTAssertEqual(x, 7) }
            do { let x = try json.reference("m~0n"); XCTAssertEqual(x, 8) }

        } catch {
            XCTFail("JSON Pointer error: \(error)")
        }
    }

    func testStreamingParser() {
        do {
            let opts = JSONParser.Options.Strict

            do {
                var events: [JSONParser.Event] = []
                let cb: (JSONParser.Event)->() = { event in events.append(event) }

                let parser = JSONParser(options: opts, delegate: cb)
                func one(_ c: UnicodeScalar) -> [UnicodeScalar] { return [c] }

                try parser.parse(one("["))
                XCTAssertEqual(events, [.arrayStart(one("["))])

                try parser.parse(one(" "))
                XCTAssertEqual(events, [.arrayStart(one("[")), .whitespace([" "])])

                try parser.parse(one("1"))
                // note no trailing number event, because it doesn't know when it is completed
                XCTAssertEqual(events, [.arrayStart(one("[")), .whitespace([" "])]) // , .number(["1"])])

                try parser.parse(one("\n"))
                XCTAssertEqual(events, [.arrayStart(one("[")), .whitespace([" "]), .number(["1"]), .whitespace(["\n"])])

                try parser.parse(one("]"), complete: true)
                XCTAssertEqual(events, [.arrayStart(one("[")), .whitespace([" "]), .number(["1"]), .whitespace(["\n"]), .arrayEnd(one("]"))])
            }

            // break up the parse into a variety of subsets to test that the streaming parser emits the exact same events
            let strm = Array("{\"object\": 1234.56E2}".unicodeScalars)
            let rangesList: [[CountableRange<Int>]] = [
                Array<CountableRange<Int>>(arrayLiteral: 0..<1, 1..<2, 2..<3, 3..<4, 4..<5, 5..<6, 6..<7, 7..<8, 8..<9, 9..<10, 10..<11, 11..<12, 12..<13, 13..<14, 14..<15, 15..<16, 16..<17, 17..<18, 18..<19, 19..<20, 20..<21),
                Array<CountableRange<Int>>(arrayLiteral: 0..<10, 10..<15, 15..<16, 16..<19, 19..<21),
                Array<CountableRange<Int>>(arrayLiteral: 0..<7, 7..<8, 8..<9, 9..<10, 10..<15, 15..<16, 16..<17, 17..<20, 20..<21),
                Array<CountableRange<Int>>(arrayLiteral: 0..<9, 9..<10, 10..<11, 11..<18, 18..<19, 19..<20, 20..<21),
                Array<CountableRange<Int>>(arrayLiteral: 0..<21),
                ]

            for ranges in rangesList {
                var events: [JSONParser.Event] = []
                let cb: (JSONParser.Event)->() = { event in events.append(event) }

                let parser = JSONParser(options: opts, delegate: cb)

                for range in ranges { try parser.parse(Array(strm[range])) }
                try parser.parse([], complete: true)

                XCTAssertEqual(events, [JSONParser.Event.objectStart(["{"]),
                    JSONParser.Event.stringStart(["\""]),
                    JSONParser.Event.stringContent(Array("object".unicodeScalars), []),
                    JSONParser.Event.stringEnd(["\""]),
                    JSONParser.Event.keyValueSeparator([":"]), JSONParser.Event.whitespace([" "]),
                    JSONParser.Event.number(Array("1234.56E2".unicodeScalars)),
                    JSONParser.Event.objectEnd(["}"])])

            }

            expectEvents("[[[]]]", [.arrayStart(["["]), .arrayStart(["["]), .arrayStart(["["]), .arrayEnd(["]"]), .arrayEnd(["]"]), .arrayEnd(["]"])])
            expectEvents("[[ ]]", [.arrayStart(["["]), .arrayStart(["["]), .whitespace([" "]), .arrayEnd(["]"]), .arrayEnd(["]"])])
//            expectEvents("[{\"x\": 2.2}]", [.arrayStart, .objectStart, .string(["x"], []), .keyValueSeparator, .whitespace([" "]), .number(["2", ".", "2"]), .objectEnd, .arrayEnd])

       } catch {
            XCTFail(String(describing: error))
        }
    }


    func testStreamingBricolage() {
        do {
            let opts = JSONParser.Options.Strict

            do {
                let bric: Bric = [123, 456.789, ["xyz": true], false, [], [nil], nil]
                let json = bric.stringify().unicodeScalars
                var brics: [Bric] = []
                try Bric.bricolageParser(options: opts, delegate: { (b, _) in brics.append(b); return b }).parse(json, complete: true)

                // the expected output: note that redundant values are expected, since every bric generates an event
                let expected: [Bric] = [123, 456.789, "xyz", true, ["xyz": true], false, [], nil, [nil], nil, [123, 456.789, ["xyz": true], false, [], [nil], nil]]

                XCTAssertEqual(brics, expected)
            } catch {
                XCTFail(String(describing: error))
            }

            do {
                var processed: [Bric] = []

                // here we are filtereding all events at leavel 1 so they are not stored in the top-level Bric array
                // this demonstrates using the parser as a streaming Bricolage parser of top-level array elements
                // without the parser needing the retain all of the events themselves
                let parser = Bric.bricolageParser(options: opts, delegate: { (bric, level) in
                    if level == 1 {
                        processed.append(bric)
                        return nil
                    } else {
                        return bric // not level 1: return the bric itself
                    }
                })

                let inputs: Array<Bric> = [ ["a": true], ["b": 123.45], ["c": nil], ["d": "xyz"] ]
                try parser.parse(["["]) // open a top-level array
                XCTAssertEqual([], processed) // no events yet

                for (i, input) in inputs.enumerated() { // parse each of the strings
                    try parser.parse(input.stringify().unicodeScalars)
                    XCTAssertEqual(i + 1, processed.count) // one event per input
                    try parser.parse([","]) // trailing delimiter to continue the array
                }

                // note that we never complete the parse (we end with a trailing comma)
                XCTAssertEqual(processed, inputs)
            } catch {
                XCTFail(String(describing: error))
            }

        }
    }

    /// Assert that the given events are emitted by the parser
    func expectEvents(_ string: String, _ events: [JSONParser.Event], file: StaticString = #file, line: UInt = #line) {
        do {
            var evts: [JSONParser.Event] = []
            let cb: (JSONParser.Event)->() = { e in evts.append(e) }

            let parser = JSONParser(options: JSONParser.Options.Strict, delegate: cb)
            try parser.parseString(string)
            XCTAssertEqual(evts, events, file: (file), line: line)
        } catch {
            XCTFail(String(describing: error), file: (file), line: line)
        }
    }

    func testStreamingEncoding() {
        for (expected, input) in [
            (expected: nil as Bric, input: "null"),
            (expected: ["😂": nil] as Bric, input: "{\"😂\": null}"),
            ] {
                // encode the above in a variety of codecs and feed them into a streaming parser to make sure they parse correctly
                let utf16: [UTF16.CodeUnit] = Array(input.utf16)
                let utf8: [UTF8.CodeUnit] = Array(input.utf8)

                // there's no nice "utf32" convenience property on String, so we manually build it up
                var utf32: [UTF32.CodeUnit] = []
                for scalar in input.unicodeScalars {
                    UTF32.encode(scalar, into: { utf32.append($0) })
                }

                // print("utf8: \(utf8)") // 14 elements: [91, 34, 240, 159, 152, 130, 34, 44, 32, 110, 117, 108, 108, 93]
                // print("utf16: \(utf16)") // 12 elements: [91, 34, 55357, 56834, 34, 44, 32, 110, 117, 108, 108, 93]
                // print("utf32: \(utf32)") // 11 elements: [91, 34, 128514, 34, 44, 32, 110, 117, 108, 108, 93]

                do {
                    let utf8out = try parseCodec(UTF8.self, utf8)
                    XCTAssertEqual(utf8out, expected)
                } catch {
                    XCTFail(String(describing: error))
                }

                do {
                    let utf16out = try parseCodec(UTF16.self, utf16)
                    XCTAssertEqual(utf16out, expected)
                } catch {
                    XCTFail(String(describing: error))
                }


                do {
                    let utf32out = try parseCodec(UTF32.self, utf32)
                    XCTAssertEqual(utf32out, expected)
                } catch {
                    XCTFail(String(describing: error))
                }
        }
    }

    func testStreamingDecoding() {
        // U+1F602 (Emoji: "face with tears of joy") in UTF-8 is: 240, 159, 152, 130
        let units: [UTF8.CodeUnit] = [240, 159, 152, 130]

        _ = transcode(units.makeIterator(), from: UTF8.self, to: UTF32.self, stoppingOnError: true, into: {
            assert(UnicodeScalar($0) == "\u{1F602}")
            })


        do {
            var codec = UTF8()
            var g = units.makeIterator()
            switch codec.decode(&g) {
            case .emptyInput: fatalError("No Input")
            case .error: fatalError("Decoding Error")
            case .scalarValue(let scalar): assert(scalar == "\u{1F602}")
            }

        }

        do {
            var codec = UTF8()

            do {
                var g1 = CollectionOfOne.Iterator(_elements: units[0])
                let r1 = codec.decode(&g1)
                print("r1: \(r1)") // .Error
            }

            do {
                var g2 = CollectionOfOne.Iterator(_elements: units[1])
                let r2 = codec.decode(&g2)
                print("r2: \(r2)") // .EmptyInput
            }

            do {
                var g3 = CollectionOfOne.Iterator(_elements: units[2])
                let r3 = codec.decode(&g3)
                print("r3: \(r3)") // .EmptyInput
            }

            do {
                var g4 = CollectionOfOne.Iterator(_elements: units[3])
                let r4 = codec.decode(&g4)
                print("r4: \(r4)") // .EmptyInput
            }
        }
    }

    func testMaxlineStringify() {
        let arr: Bric = [1, 2]
        let bric: Bric = ["abc": [1, 2, 3, 4]]

        XCTAssertEqual("[\n  1,\n  2\n]", arr.stringify(space: 2, maxline: 7))
        XCTAssertEqual("[ 1, 2 ]", arr.stringify(space: 2, maxline: 8))

        XCTAssertEqual("{\"abc\":[1,2,3,4]}", bric.stringify(space: 0, maxline: 0))
        XCTAssertEqual("{\n  \"abc\": [\n    1,\n    2,\n    3,\n    4\n  ]\n}", bric.stringify(space: 2, maxline: 0))

        XCTAssertEqual("{ \"abc\": [ 1, 2, 3, 4 ] }", bric.stringify(space: 2, maxline: 80))
        XCTAssertEqual("{\n  \"abc\": [ 1, 2, 3, 4 ]\n}", bric.stringify(space: 2, maxline: 23))
        //XCTAssertEqual("{ \"abc\": [\n    1, 2, 3, 4\n  ]\n}", bric.stringify(space: 2, maxline: 15))

        XCTAssertEqual("{\n  \"abc\": [\n    1,\n    2,\n    3,\n    4\n  ]\n}", bric.stringify(space: 2, maxline: 5))


    }

    /// Returns the path of the folder containing test resources
    private func testResourcePath() -> String {
        return String(#file.reversed().drop(while: { $0 != "/" }).reversed()) + "test/"
    }
    
    func testSerializationPerformance() throws {
        do {
            let path = testResourcePath() + "/profile/rap.json"
            let contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
            let bric = try Bric.parse(contents as String)
            let cocoa = try JSONSerialization.jsonObject(with: contents.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions())

            for _ in 0...10 {
                var strs: [String] = [] // hang onto the strings so we don't include ARC releases in the profile
                var datas: [Data] = []

                let natives: [Bool] = [false, true]
                let styleNames = natives.map({ $0 ? "bric" : "cocoa" })
                var times: [TimeInterval] = []

                for native in natives {
                    let start = CFAbsoluteTimeGetCurrent()
                    for _ in 0...10 {
                        if native {
                            strs.append(bric.stringify(space: 2))
                        } else {
                            datas.append(try JSONSerialization.data(withJSONObject: cocoa, options: JSONSerialization.WritingOptions.prettyPrinted))
                        }
                    }
                    let end = CFAbsoluteTimeGetCurrent()
                    times.append(end-start)
                }
                print("serialization times: \(styleNames) \(times)")
            }
        }
    }

    func testBricDate() throws {
        let now = Date(timeIntervalSince1970: 500000)
        let dict = ["timestamp": now]
        let bric = dict.bric()
        do {
            let brac = try [String:Date].brac(bric: bric)
            XCTAssertEqual(dict, brac)
        }
    }

    func testNestedBricDate() throws {
        typealias X = Dictionary<String, Optional<Optional<Optional<Optional<Date>>>>>
        let now = Date(timeIntervalSince1970: 500000)
        let dict: X = X(dictionaryLiteral: ("timestamp", now))
        let bric = dict.bric()
        do {
            let brac: X = try X.brac(bric: bric)
            let t1 = dict["timestamp"]!!!!
            let t2 = brac["timestamp"]!!!!
            XCTAssertTrue(t1 == t2)
        }
    }

    func testMirrorBric() {
        do {
            struct Foo { var bar: String; var num: Double?; var arr: [Foo] }
            let foo = Foo(bar: "xxx", num: 12.34, arr: [Foo(bar: "yyy", num: nil, arr: [])])
            let mirror = Mirror(reflecting: foo)
            let bric = mirror.bric()
            XCTAssertEqual(bric, ["bar": "xxx", "num": 12.34, "arr": [["bar": "yyy", "num": nil, "arr": []]]])
        }

        do {
            let tuple = (1, 23.4, true, ([1, 2, 3], 23.4, true))
            let mirror = Mirror(reflecting: tuple)
            let bric = mirror.bric()
            XCTAssertEqual(bric, [1, 23.4, true, [[1, 2, 3], 23.4, true]])
        }
    }

    func testBracSwap() {
        var x = 1, y = 2.2

        XCTAssertEqual(x, 1)
        XCTAssertEqual(y, 2.2)

        do { try bracSwap(&x, &y) } catch { XCTFail(String(describing: error)) }

        XCTAssertEqual(x, 2)
        XCTAssertEqual(y, 1.0)
    }

    func testFidelityBricolage() {
        let fb: FidelityBricolage = ["a": 1, "b": 2, "c": 3, "d": 4]
        if case .obj(let obj) = fb {
            XCTAssertEqual(Array(obj.map({ String(String.UnicodeScalarView() + $0.0) })), ["a", "b", "c", "d"])
        } else {
            XCTFail("FidelityBricolage not object")
        }

        let _: Bric = fb.bric()
        // XCTAssertNotEqual(Array(bric.obj!.keys), ["a", "b", "c", "d"]) // note that we lose ordering when converting to standard Bric, but we can't rely on failure because it will be dependant on varying hashcodes
    }

    func testOneOfStruct() {
        do {
            let one = OneOf<String>.Or<String>(t1: "xxx")
            let two = OneOf<String>.Or<String>(t1: "xxx")
            XCTAssertEqual(one, two)
        }

        do {
            let one = OneOf<String>.Or<String>(t2: "xxx")
            let two = OneOf<String>.Or<String>(t2: "xxx")
            XCTAssertEqual(one, two)
        }

        do {
            let one = OneOf<String>.Or<String>(t1: "xxx")
            let two = OneOf<String>.Or<String>(t2: "xxx")
            XCTAssertNotEqual(one, two)
        }

        do {
            var manyOrOneString = OneOf2<[String], String>("foo")
            guard case .v2 = manyOrOneString else { return XCTFail("wrong type before swap array") }
            manyOrOneString.swap_2_1.array.removeAll()
            guard case .v1 = manyOrOneString else { return XCTFail("wrong type after swap array") }
        }
    }

    func testOneOfCoalesce() {
        func failString() -> String {
            XCTFail("should not be called bcause coalesce takes autoclosures")
            return ""
        }

        let o2 = OneOf<String>.Or<Int>.coalesce(1, failString())
        XCTAssertEqual(1, o2.v2)

        let o5 = OneOf5<String, Int, Double, Float, Int>.coalesce(nil, nil, 1.7, 9, failString())
        XCTAssertEqual(1.7, o5.v3)

        /// coalescing operator
        let oneof4: OneOf2<OneOf2<OneOf2<Bool, Double>, Int>, String> = nil ??? nil ??? 3.456 ??? true // returns .v1(.v1(.v2(3.456))
        XCTAssertEqual(.v1(.v1(.v2(3.456))), oneof4)
    }

    func testExtricate() {
        do {
            typealias Src = OneOf2<OneOf<String>.Or<Int>, OneOf2<Bool, Double>>
            typealias Dst = OneOf4<String, Int, Bool, Double>
            let x: Src = Src(oneOf("abc"))
            let _: Dst = x.flattened
            let _: Dst = x.flattened.swapped.swapped // double swapped is always the same as itself
        }

        do {
            typealias Src = OneOf2<OneOf3<String, Int, Void>, OneOf2<Bool, Double>>
            typealias Dst = OneOf5<String, Int, Void, Bool, Double>
            let x: Src = Src(oneOf("abc"))
            let _: Dst = x.flattened
            let _: Dst = x.flattened.swapped.swapped // double swapped is always the same as itself
        }

        do {
            typealias Src1 = OneOf<String>.Or<Int>
            typealias Src2 = OneOf<Bool>.Or<Never>.Or<Double>
            typealias Src = OneOf<Src1>.Or<Src2>
            typealias Dst = OneOf<String>.Or<Int>.Or<Bool>.Or<Never>.Or<Double>
            let x: Src = Src(oneOf("abc"))
            let _: Dst = x.flattened
            let _: Dst = x.flattened.swapped.swapped // double swapped is always the same as itself
        }
    }

    func testKeyRouting() {
        struct Thing1 {
            var thing1: Int
            var name: String?
        }
        struct Thing2 {
            var thing2: Double
            var name: String?
        }

        struct Things {
            var thing: OneOf<Thing1>.Or<Thing2>
            var name: String? {
                get { return thing[routing: (\.name, \.name)] }
                set { thing[routing: (\.name, \.name)] = newValue }
            }
        }

        var thing1 = Things(thing: .init(Thing1(thing1: 11, name: "X")))
        XCTAssertEqual("X", thing1.name)
        thing1.name = .some("Y")
        XCTAssertEqual("Y", thing1.name)

        let thing2 = Things(thing: .init(Thing2(thing2: 12.3, name: "Y")))

        var things = [thing1, thing2]
        things[walking: \.name] = ["ABC", "ABC"]
        XCTAssertEqual(things[walking: \.name], ["ABC", "ABC"])
    }

    let RefPerformanceCount = 100000

    func testOptionalPerformance() {
        var array = Array<Optional<Bool>>()
        array.reserveCapacity(RefPerformanceCount)
        measure { // average: 0.001
            for _ in 1...self.RefPerformanceCount { array.append(.some(true)) }
            let allTrue = array.reduce(true, { (x, y) in x && (y ?? false) })
            XCTAssertEqual(allTrue, true)
        }
    }

    func testDeepMerge() {
        XCTAssertEqual(Bric.obj(["foo": "bar"]).merge(bric: ["bar": "baz"]), ["foo": "bar", "bar": "baz"])
        XCTAssertEqual(Bric.obj(["foo": "bar"]).merge(bric: ["bar": "baz", "foo": "bar2"]), ["foo": "bar", "bar": "baz"])
        XCTAssertEqual(Bric.obj(["foo": [1, 2, 3]]).merge(bric: ["bar": "baz", "foo": "bar2"]), ["foo": [1,2,3], "bar": "baz"])
        XCTAssertEqual(Bric.obj(["foo": [1, 2, ["x": "y"]]]).merge(bric: ["bar": "baz", "foo": [1, 2, ["a": "b"]]]), ["foo": [1, 2, ["a": "b", "x": "y"]], "bar": "baz"])
        XCTAssertEqual(Bric.obj(["foo": [1, 2, [[[["x": "y"]]]]]]).merge(bric: ["bar": "baz", "foo": [1, 2, [[[["a": "b"]]]]]]), ["foo": [1, 2, [[[["a": "b", "x": "y"]]]]], "bar": "baz"])
        XCTAssertEqual(Bric.obj(["foo": [1, 2, [[2, [["x": "y"]]]]]]).merge(bric: ["bar": "baz", "foo": [1, 2, [[2, [["a": "b"]]]]]]), ["foo": [1, 2, [[2, [["a": "b", "x": "y"]]]]], "bar": "baz"])
    }

    func testShallowMerge() {
        XCTAssertEqual(Bric.obj(["foo": "bar"]).assign(bric: ["bar": "baz"]), ["foo": "bar", "bar": "baz"])
        XCTAssertEqual(Bric.obj(["foo": "bar"]).assign(bric: ["bar": "baz", "foo": "bar2"]), ["foo": "bar", "bar": "baz"])
        XCTAssertEqual(Bric.obj(["foo": [1, 2, 3]]).assign(bric: ["bar": "baz", "foo": "bar2"]), ["foo": [1,2,3], "bar": "baz"])
        XCTAssertEqual(Bric.obj(["foo": [1, 2, ["x": "y"]]]).assign(bric: ["bar": "baz", "foo": [1, 2, ["a": "b"]]]), ["foo": [1, 2, ["x": "y"]], "bar": "baz"])
    }

    func testCodableConversion() throws {
        let alien = Alien(name: "Zaphod", home: Planet(name: "Betelgeuse Five", coordinates: [123, 456, 789.5]))
        let coder = BricEncoder()

        let bricObj = try coder.encodeObject(alien)
        XCTAssertEqual(bricObj, ["name":"Zaphod","home":["name":"Betelgeuse Five","coordinates": [123, 456, 789.5]]] as NSDictionary)

        let bric = try coder.encode(alien)
        XCTAssertEqual(bric, ["name":"Zaphod","home":["name":"Betelgeuse Five","coordinates": [123, 456, 789.5]]])
    }

    func testCodingExtraction() throws {
        let aliens = [
            Alien(name: "Zaphod", home: Planet(name: "Betelgeuse Five", coordinates: [123, 456, 789.5])),
            Alien(name: "Ford", home: Planet(name: "Betelgeuse Seven", coordinates: [123, 456.2, 789.8])),
            ]

        // not sure why we double contained values…
        let mult = 2
        XCTAssertEqual(3 * mult, try ["A": "X", "B": "Y", "C": "Z"].encodableChildrenOfType(String.self).count)
        XCTAssertEqual(3 * mult, try ["A": 1, "B": 2, "C": 3].encodableChildrenOfType(Int.self).count)
        XCTAssertEqual(3 * mult, try [[[1,2,3]]].encodableChildrenOfType(Int.self).count)

        XCTAssertEqual(2, try aliens.encodableChildrenOfType(Alien.self).count)
        XCTAssertEqual(2, try aliens.encodableChildrenOfType(Planet.self).count)
        XCTAssertEqual(4, try aliens.encodableChildrenOfType(String.self).count)
        XCTAssertEqual(6 * mult, try aliens.encodableChildrenOfType(Float.self).count)


    }
    
}

fileprivate extension MutableCollection {
    subscript<T>(walking keyPath: WritableKeyPath<Element, T>) -> [T] {
        get {
            return self.map({ $0[keyPath: keyPath] })
        }

        set {
            for (i, value) in zip(indices, newValue) {
                self[i][keyPath: keyPath] = value
            }
        }
    }
}

struct Alien : Codable {
    let name: String
    let home: Planet
}

struct Planet : Codable {
    let name: String
    let coordinates: Array<Float>
}


/// Parses the given stream of elements with the associated codec
func parseCodec<C: UnicodeCodec, S: Sequence>(_ codecType: C.Type, _ seq: S) throws -> Bric where S.Iterator.Element == C.CodeUnit {
    var top: Bric = nil
    let parser = Bric.bricolageParser(options: .Strict) { (b, l) in
        if l == 0 { top = b }
        return b
    }

    let success: Bool = transcode(seq.makeIterator(), from: codecType, to: UTF32.self, stoppingOnError: true, into: {
        do {
            try parser.parse(CollectionOfOne(UnicodeScalar($0)!))
        } catch {
            fatalError("decoding error")
        }
        })

    if success {
    } else {
    }

    return top
}


/// Takes any collection of UnicodeScalars and parses it, returning the exact same collection
func roundTrip<C: RangeReplaceableCollection>(_ src: C) throws -> C where C.Iterator.Element == UnicodeScalar {
    var out: C = C.init()
    out.reserveCapacity(src.count)
    try JSONParser(options: .Strict, delegate: { out.append(contentsOf: $0.value) }).parse(src, complete: true)
    return out
}

struct Person : Equatable {
    var name: String
    var male: Bool
    var age: UInt8?
    var children: [String]
}

/// Example of using an enum in a type extension for BricBrac with automatic hashability and equatability
extension Person : BricBrac {
    enum Keys: String {
        case name, male, age, children
    }

    func bric() -> Bric {
        return Bric(object: [
            (Keys.name.rawValue, name.bric()),
            (Keys.male.rawValue, male.bric()),
            (Keys.age.rawValue, age.bric()),
            (Keys.children.rawValue, children.bric()),
            ])
    }

    static func brac(bric: Bric) throws -> Person {
        return try Person(
            name: bric.brac(key: Keys.name.rawValue),
            male: bric.brac(key: Keys.male.rawValue),
            age: bric.brac(key: Keys.age.rawValue),
            children: bric.brac(key: Keys.children.rawValue)
        )
    }
}


enum Executive : Equatable, BricBrac {
    case human(Person)
    case robot(serialNumber: String)

    func bric() -> Bric {
        switch self {
        case .human(let p): return p.bric()
        case .robot(let id): return id.bric()
        }
    }

    static func brac(bric: Bric) throws -> Executive {
        switch bric {
        case .str(let id): return .robot(serialNumber: id)
        case .obj(let dict) where dict["name"] != nil: return try .human(Person.brac(bric: bric))
        default: return try bric.invalidType()
        }
    }
}

enum CorporateStatus : String, Equatable, BricBrac {
    case `public`, `private`
}

enum CorporateCode : Int, BricBrac {
    case a = 1, b = 2, c = 3, d = 4
}

/// Example of using a class and a tuple in the type itself to define the keys for BricBrac
final class Company : Equatable, BricBrac {
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.name == rhs.name
            && lhs.ceo == rhs.ceo
            && lhs.status == rhs.status
            && lhs.customers == rhs.customers
            && lhs.employees == rhs.employees
            && lhs.subsidiaries == rhs.subsidiaries
    }

    fileprivate static let keys = (
        name: "name",
        ceo: "ceo",
        status: "status",
        customers: "customers",
        employees: "employees",
        subsidiaries: "subsidiaries")

    var name: String
    var ceo: Executive?
    var status: CorporateStatus
    var customers: ContiguousArray<Person>
    var employees: [Person]
    var subsidiaries: [Company]?


    init(name: String, ceo: Executive?, status: CorporateStatus, customers: ContiguousArray<Person>, employees: [Person], subsidiaries: [Company]? = nil) {
        self.name = name
        self.ceo = ceo
        self.status = status
        self.customers = customers
        self.employees = employees
        self.subsidiaries = subsidiaries
    }

    func bric() -> Bric {
        let keys = Company.keys
        return [
            keys.name: name.bric(),
            keys.ceo: ceo.bric(),
            keys.status: status.bric(),
            keys.customers: customers.bric(),
            keys.employees: employees.bric(),
            keys.subsidiaries: subsidiaries.bric()
        ]
    }

    static func brac(bric: Bric) throws -> Company {
        return try Company(
            name: bric.brac(key: keys.name),
            ceo: bric.brac(key: keys.ceo),
            status: bric.brac(key: keys.status),
            customers: bric.brac(key: keys.customers),
            employees: bric.brac(key: keys.employees),
            subsidiaries: bric.brac(key: keys.subsidiaries))
    }
}

/// http://www.epa.gov/otaq/cert/mpg/mpg-data/readme.txt
struct Car {
    /// manufacturer or division name
    var manufacturer: String
    /// model name
    var model: Optional<String>
    /// displacement in liters
    var displacement: Double
    /// year manufactured
    var year: UInt16
    /// number of engine cylinders
    var cylinders: Cylinders
    /// type of transmission
    var transmissionType: String // TODO: make an enum with an associated type
    /// drive axle type
    var drive: Drive
    /// estimated city mpg (miles/gallon)
    var cityMileage: Int
    /// estimated highway mpg (miles/gallon)
    var highwayMileage: Int
    /// fuel type
    var fuel: Fuel
    /// vehicle class name
    var `class`: Class

    enum Cylinders : Int { case four = 4, six = 6, eight = 8 }
    enum Drive : String { case front = "f", rear = "r", four }
    enum Fuel : String { case regular = "r", premium = "p" }
    enum Class : String { case subcompact, compact, midsize, suv, minivan, pickup }
}

extension CGPoint : Bricable, Bracable {
    public func bric() -> Bric {
        return ["x": Bric(num: x.native), "y": Bric(num: y.native)]
    }

    public static func brac(bric: Bric) throws -> CGPoint {
        return try CGPoint(x: CGFloat(bric.brac(key: "x") as CGFloat.NativeType), y: CGFloat(bric.brac(key: "y") as CGFloat.NativeType))
    }
}

/// Example of conferring JSON serialization on an existing non-final class
extension Date : Bricable, Bracable {
    /// NSDate will be saved by simply storing it as a double with the number of seconds since 1970
    public func bric() -> Bric {
        return Bric(num: timeIntervalSince1970)
    }

    /// Restore an NSDate from a "time" field
    public static func brac(bric: Bric) throws -> Date {
        return self.init(timeIntervalSince1970: try bric.bracNum())
    }
}

extension BricBracTests {
    func testIndirect() {
        let encoder = JSONEncoder()
        if #available(OSX 10.13, *) {
            encoder.outputFormatting = .sortedKeys
        }

        do {
            let value = Indirect(["Foo"])
            XCTAssertEqual(String(bytes: try encoder.encode(value), encoding: .utf8), """
["Foo"]
""")
            XCTAssertEqual(value, try value.roundtripped())
        }

    }

    func testExplicitNull() {
        struct ExplicitNullHolder : Codable, Equatable {
            public let optionalString: String?
            public let nullableString: Nullable<String>
            public let nullable: ExplicitNull
            public let nullableOptional: ExplicitNull?
        }


        let encoder = JSONEncoder()
        if #available(OSX 10.13, *) {
            encoder.outputFormatting = .sortedKeys
        }

        do {
            let nh = ExplicitNullHolder(optionalString: nil, nullableString: .init(.null), nullable: nil, nullableOptional: nil)
            XCTAssertEqual(String(bytes: try encoder.encode(nh), encoding: .utf8), """
{"nullable":null,"nullableString":null}
""")
            XCTAssertEqual(nh, try nh.roundtripped())
        }

        do {
            let nh = ExplicitNullHolder(optionalString: nil, nullableString: .init("Foo"), nullable: nil, nullableOptional: nil)
            XCTAssertEqual(String(bytes: try encoder.encode(nh), encoding: .utf8), """
{"nullable":null,"nullableString":"Foo"}
""")
            XCTAssertEqual(nh, try nh.roundtripped())
        }

        do {
            let nh = ExplicitNullHolder(optionalString: nil, nullableString: .init("Foo"), nullable: nil, nullableOptional: .some(nil))
            XCTAssertEqual(String(bytes: try encoder.encode(nh), encoding: .utf8), """
{"nullable":null,"nullableOptional":null,"nullableString":"Foo"}
""")
            //XCTAssertEqual(nh, try nh.roundtripped()) // this fails because optional intercepts the null
        }
    }

    func testShifting() {
        do {
            enum X : Equatable { case x }
            enum Y { case y }
            enum Z { case z }
            typealias XOrYOrZ = OneOf<X>.Or<Y>.Or<Z>

            let xoryorz: OneOf3<X, Y, Z> = XOrYOrZ(.x)
            let xoryorzShifted: OneOf3<Z, X, Y> = xoryorz.shifted
            let xoryorzUnshifted: OneOf3<Y, Z, X> = xoryorz.unshifted

            XCTAssertEqual(xoryorzShifted, .init(.x))
            XCTAssertEqual(xoryorzUnshifted, .init(.x))
        }
    }

    func testNullableOptionals() {

        struct NullableHolder : Codable, Equatable {
            public let ons: Optional<Nullable<String>>

            init(ons: Optional<Nullable<String>>) {
                self.ons = ons
            }

            init(from decoder: Decoder) throws {
                func _t<T>() -> T.Type { T.self }

                let values = try decoder.container(keyedBy: CodingKeys.self)
                // override the default optional handling so we can support explicit `null` values
                ons = try values.decodeOptional(_t(), forKey: .ons)
//                ons = !values.contains(.ons) ? .none : try values.decode(Nullable<String>.self, forKey: .ons)
            }
        }

        let encoder = JSONEncoder()
        if #available(OSX 10.13, *) {
            encoder.outputFormatting = .sortedKeys
        }

        do {
            let nh = NullableHolder(ons: .none)
            XCTAssertEqual(String(bytes: try encoder.encode(nh), encoding: .utf8), """
{}
""")
            XCTAssertEqual(nh, try nh.roundtripped())
        }

        do {
            let nh = NullableHolder(ons: .some(.init("X")))
            XCTAssertEqual(String(bytes: try encoder.encode(nh), encoding: .utf8), """
{"ons":"X"}
""")
            XCTAssertEqual(nh, try nh.roundtripped())
        }

        do {
            let nh = NullableHolder(ons: .some(.init(.null)))
            XCTAssertEqual(String(bytes: try encoder.encode(nh), encoding: .utf8), """
{"ons":null}
""")
            // without the special `Decodable` implementation, we would get: XCTAssertEqual failed: ("NullableHolder(ons: Optional(BricBrac.OneOf2<BricBrac.ExplicitNull, Swift.String>.v1(BricBrac.ExplicitNull())))") is not equal to ("NullableHolder(ons: nil)")
            XCTAssertEqual(nh, try nh.roundtripped())
        }
    }

    /// This test demonstrates that having an `Optional<Optional<T>>` is not sufficient for maintaining
    /// serialization fidelity when we want to declare an explicit `null` value and have it be
    /// preserved through serialization round-tripping.
    ///
    /// I.e., it shows why we need `ExplicitNull` and `Nullable` when we need to maintain a distinction
    /// between an `undefined` value and an explicitly `null` value (as is common with JavaScript, and, therefore, JSON).
    ///
    /// This could be resolved with the `nullDecodingStrategy` property discussed at
    /// https://forums.swift.org/t/pitch-jsondecoder-nulldecodingstrategy/13980
    /// but it doesn't look like it will be implemented.
    @available(OSX 10.13, *)
    func testOptionalOptionalsLosingSerializationFidelity() {
        struct OptionalOptional : Codable, Equatable {
            public let oos: Optional<Optional<String>>
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys // we want consistent key ordering

        do {
            let oo = OptionalOptional(oos: .some(.some("x")))
            XCTAssertEqual(String(bytes: try encoder.encode(oo), encoding: .utf8), """
{"oos":"x"}
""")
            XCTAssertEqual(oo, try oo.roundtripped())
        }

        do {
            let oo = OptionalOptional(oos: .none)
            XCTAssertEqual(String(bytes: try encoder.encode(oo), encoding: .utf8), """
{}
""")
            XCTAssertEqual(oo, try oo.roundtripped())
        }

        do {
            let oo = OptionalOptional(oos: .some(.none))
            // this is right…
            XCTAssertEqual(String(bytes: try encoder.encode(oo), encoding: .utf8), """
{"oos":null}
""")
            // … but this is wrong!
            XCTAssertNotEqual(oo, try oo.roundtripped()) // the NOT-equals shows why double-optional loses fidelity
        }
    }

    func testIndirectDeepCoding() throws {
        struct I1 : Codable {
            var map: [String: String] = [:]
            var i2: Indirect<I2>? = nil
        }

        struct I2 : Codable {
            var i3: Indirect<I3>? = nil
        }


        struct I3 : Codable {
            var name: String? = nil
        }

        var i1 = I1()

        i1.i2 = .init(I2())
        i1.i2?.wrappedValue.i3 = .init(I3())
        i1.i2?.wrappedValue.i3?.wrappedValue.name = "Foo"

        for i in 1..<10 {
            i1.map["\(i)"] = "\(i)"
        }

        // ensure that `encodedString` returns sorted keys
        XCTAssertEqual("""
{"i2":{"i3":{"name":"Foo"}},"map":{"1":"1","2":"2","3":"3","4":"4","5":"5","6":"6","7":"7","8":"8","9":"9"}}
""", try i1.encodedStringSorted())

        for i in 1..<10000 {
            i1.map["\(i)"] = "\(i)"
        }

        let str = try i1.encodedStringSorted()
        let strlen = str.count

        // stress test parallel encoding; tack on a few more 9's to really try it out
        // 999: direct memory string: 16.263 seconds, 16.472 seconds, 16.468 seconds
        // 999: string copy: 16.812 seconds, 16.194 seconds, 15.793 seconds
        DispatchQueue.concurrentPerform(iterations: 99) { _ in
            let str = try? i1.encodedString()
            // make sure the string is really the same
            // we use assert in case `XCTAssert*` functions have some internal locks or something
            assert(strlen == str?.count) // ordered vs. unordered should be the same character count
        }
    }

    func testCustomKeySorting() throws {
        struct SortedOutput : Codable {
            let az = "A"
            let by = 1.0
            let cx = false
            let qq = "Q"

            private enum CodingKeys : String, CaseIterable, Equatable, OrderedCodingKey {
                case by, az = "az", cx = "cx", qq
            }
        }

        let obj = SortedOutput()


        // by default, keys are in undefined order:
        // SortedOutput prop order:  az, by, cx
        // CoddingKey order:         by, az, cx
        // JSON output:              az, cx, by
        // XCTAssertEqual failed: ("Optional("{\"az\":\"A\",\"cx\":false,\"by\":1}")") is not equal to ("Optional("{\"az\":\"A\",\"by\":1,\"cx\":false}")")

        XCTAssertEqual(try obj.encodedStringSorted(), """
        {"az":"A","by":1,"cx":false,"qq":"Q"}
        """)

        // default encoding order should *not* be in the declared order (although it is possible that via random hashing this sometimes happens anyway)
        XCTAssertNotEqual(try obj.encodedString(), """
        {"by":1,"az":"A","cx":false,"qq":"Q"}
        """)

        if #available(macOS 10.15, *) {
            XCTAssertEqual(try obj.encodedStringOrdered(format: []), """
            {"by":1,"az":"A","cx":false,"qq":"Q"}
            """)
        }
    }
}

extension Decodable where Self: Encodable {
    /// Returns a deserialized copy of this instance's encoded data
    public func roundtripped(encoder: (Self) throws -> (Data) = JSONEncoder().encode, decoder: (Self.Type, Data) throws -> (Self) = JSONDecoder().decode) rethrows -> Self {
        return try decoder(Self.self, encoder(self))
    }
}

/// A ColumnMap is a `Succinct data structure` representing a list of arbitrary JSON objects.
/// It is optimized for object lists that share many key names and have a number of similar
/// values. It encodes each value a single time along with the compact list of ranges
/// that the values occupy in the list.
public struct ColumnMap<T : Codable & Hashable> : Codable, Equatable {
    /// The total number of rows this represents; we need to store this since the list map contain trailing empty dictionaries, which wouldn't be other expressed in the column map
    public var count: Int
    /// The map of column names to the set of value items & indices
    public var columns: [String: Set<ColumnValue>]

    public struct ColumnValue : Codable, Equatable, Hashable {
        /// The value represented by this value
        public var value: T
        /// The ranges indicate where in the column array the values will be placed
        /// TODO: change to a compact serialized representation, since
        /// the default IndexSet serialization is somewhat verbose: {"indexes":[{"location":0,"length":1}]}
        /// and doesn't have a guarantee of maintaining serialization future-compatibility
        public var ranges: IndexSet

        public func hash(into hasher: inout Hasher) {
            self.value.hash(into: &hasher)
        }
    }

    /// Dehydrates a list of JSON objects into an optimized column map
    public static func fromObjectList(_ list: [[String: T]]) -> ColumnMap {
        // our intermediate structure is keyed in name then the value; we won't be able
        // to store it like this because JSON dictionaries need to be keyed by strings
        var keyValueSet: [String: [T: IndexSet]] = [:]

        for (index, keyValues) in list.enumerated() {
            for (key, value) in keyValues {
                var keyColumns = keyValueSet[key] ?? [:]
                var valueIndices = keyColumns[value] ?? []
                valueIndices.insert(index)
                keyColumns[value] = valueIndices
                keyValueSet[key] = keyColumns
            }
        }

        // now convert the [Bric: IndexSet] values into ColumnValue instances
        let columns: [String: Set<ColumnValue>] = keyValueSet.mapValues { Set($0.map(ColumnValue.init)) }

        return ColumnMap(count: list.count, columns: columns)
    }

    /// Hydrate this column map as a traditional list of JSON objects
    public func toObjectList() -> [[String: T]] {
        var rows: [[String: T]] = Array(repeating: [:], count: count)

        for (key, value) in columns {
            for colValue in value {
                for index in colValue.ranges {
                    rows[index][key] = colValue.value
                }
            }
        }

        return rows
    }
}

extension BricBracTests {
    public func testColumnMap() throws {
        let values: [[String: Bric]] = [
            ["foo": 1, "bar": "X"],
            ["foo": 2, "bar": nil],
            [:],
            ["foo": 2, "bar": []],
            [:],
            ["foo": 3, "bar": [:]],
            ["foo": 3, "bar": ["a": "b"]],
            ["foo": 3, "bar": ["a": ["b", "c"]]],
            ["foo": 1, "bar": 1.234],
            ["foo": 1, "bar": 1.234],
            ["foo": 1, "bar": true],
            ["foo": 1, "baz": true, "biz": 0.01],
            [:],
        ]

        let cl = ColumnMap.fromObjectList(values)
        print("encoded: \(try cl.bricEncoded().stringify())")

        let values2 = cl.toObjectList()
        XCTAssertEqual(values2, values)

    }
}
