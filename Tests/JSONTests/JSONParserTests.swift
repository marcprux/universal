//
//  JSONParserTests.swift
//
//  Created by Marc Prud'hommeaux on 6/14/15.
//
import Testing
import Foundation
import JSON
import Either

@Suite struct JSONParserTests {

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

}


extension UUID {
    /// Creates a UUID with the given random number generator.
    init<R: RandomNumberGenerator>(rnd: inout R) {
        self.init { UInt8.random(in: .min...(.max), using: &rnd) }
    }

    /// Creates a UUID by populating the bytes with the given block.
    init(bytes: () -> UInt8) {
        self.init(uuid: (bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes(), bytes()))
    }
}
