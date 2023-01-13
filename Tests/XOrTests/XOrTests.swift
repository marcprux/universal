/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import XOr
import XCTest

final class XOrTests: XCTestCase {
    func testXOrOr() throws {
        typealias StringOrInt = XOr<String>.Or<Int>
        let str = StringOrInt("ABC")
        let int = StringOrInt(12)
        XCTAssertNotEqual(str, int)
        XCTAssertEqual("[\"ABC\"]", try String(data: JSONEncoder().encode([str]), encoding: .utf8))
        XCTAssertEqual("[12]", try String(data: JSONEncoder().encode([int]), encoding: .utf8))
    }
}
