/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
import XCTest
import Quanta
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class QuantaTests : XCTestCase {
    func testQuanta() throws {
        XCTAssertNotEqual(Dictionary.Quanta(.init([1])), Dictionary.Quanta(.init([1 : 1])))

        typealias QInt = Dictionary<Int, Int>.Quanta
        XCTAssertEqual(QInt(.init([1])).mapValues({ $0 }), QInt(.init([1 : 1])).mapValues({ $0 }))
    }
}
