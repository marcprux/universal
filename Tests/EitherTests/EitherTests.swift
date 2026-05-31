/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Either
import Testing
import Foundation

@Suite struct EitherTests {
    @Test func testEitherOr() throws {
        typealias StringOrInt = Either<String>.Or<Int>
        let str = StringOrInt("ABC")
        let int = StringOrInt(12)
        #expect(str != int)
        #expect("[\"ABC\"]" == (try String(data: JSONEncoder().encode([str]), encoding: .utf8)))
        #expect("[12]" == (try String(data: JSONEncoder().encode([int]), encoding: .utf8)))
    }
}
