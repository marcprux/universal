//
//  PLISTTests.swift
//
//  Created by Marc Prud'hommeaux on 3/20/23.
//
import XCTest
import PLIST
import Either

final class PLISTTests : XCTestCase {
    func testParseNextStepPLIST() throws {
        let plist = try PLIST.parse(Data("""
        a = true;
        b = 1;
        """.utf8))
        XCTAssertEqual("true", plist["a"])
        XCTAssertEqual("1", plist["b"])
    }

    func testParseXMLPLIST() throws {
        let plist = try PLIST.parse(Data("""
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>TestArray</key>
            <array>
                <string>one</string>
                <string>two</string>
                <string>three</string>
            </array>
            <key>TestBoolean</key>
            <true/>
            <key>TestData</key>
            <data>
            PGR1bW15IGRhdGE+
            </data>
            <key>TestDate</key>
            <date>2013-02-22T12:49:10Z</date>
            <key>TestDict</key>
            <dict>
                <key>Author</key>
                <string>Phil</string>
                <key>When</key>
                <date>2000-01-02T08:04:05Z</date>
            </dict>
            <key>TestInteger</key>
            <integer>256</integer>
            <key>TestReal</key>
            <real>1.4</real>
            <key>TestString</key>
            <string>ExifTool PLIST test</string>
            <key>TestUnicode</key>
            <string>ExîfTöøl PLIST tést</string>
        </dict>
        </plist>
        """.utf8))

        XCTAssertEqual(true, plist["TestBoolean"])
        XCTAssertEqual("ExifTool PLIST test", plist["TestString"])
        XCTAssertEqual("ExîfTöøl PLIST tést", plist["TestUnicode"])
        XCTAssertEqual(256, plist["TestInteger"])
        XCTAssertEqual(1.4, plist["TestReal"])
        XCTAssertEqual(.date(try XCTUnwrap(ISO8601DateFormatter().date(from: "2013-02-22T12:49:10Z"))), plist["TestDate"])
        XCTAssertEqual(.data(try XCTUnwrap(Data(base64Encoded: "PGR1bW15IGRhdGE+"))), plist["TestData"])
        XCTAssertEqual(["one", "two", "three"], plist["TestArray"])
        XCTAssertEqual([
            "Author": "Phil",
            "When": .date(try XCTUnwrap(ISO8601DateFormatter().date(from: "2000-01-02T08:04:05Z")))
        ], plist["TestDict"])
    }
}
