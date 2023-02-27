/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
import XCTest
import XML

final class XMLTests: XCTestCase {

    // MARK: XML Tests

    private let xml = { (str: String) in try XML.parse(str.data(using: .utf8) ?? Data()) }

    func testParseXMLJSum() throws {
//        XCTAssertEqual(try xml(#"<a/>"#), ["a": nil])
//        XCTAssertEqual(try xml(#"<a b="c"/>"#), ["a": ["b": "c"]])
//        XCTAssertEqual(try xml(#"<a><b>c</b></a>"#), ["a": ["b": "c"]])
//        XCTAssertEqual(try xml(#"<a><b><c d="e">f</c></b></a>"#), ["a": ["b": ["c": ["d": "e", "_": "f"]]]])
//
//        XCTAssertEqual(try xml(#"<a><b>c</b></a>"#), ["a": ["b": "c"]])
//        XCTAssertEqual(try xml(#"<a><b>c</b><b>d</b></a>"#), ["a": ["b": ["c", "d"]]])
//        XCTAssertEqual(try xml(#"<a><b>c</b><b>d</b><b><e f="g">X</e></b></a>"#), ["a": ["b": ["c", "d", ["e": ["f": "g", "_": "X"]]]]])
    }

    func testParseXML() throws {
        let parsed = try xml("""
        <root>
            <element attr="value">
                <child1>
                    Value
                </child1>
                <child2/>
            </element>
        </root>
        """)

        let element = parsed.object?["root"]?.object?["element"]
        XCTAssertEqual("Value", element?.object?["child1"]?.string?.trimmingCharacters(in: .whitespacesAndNewlines))
        XCTAssertEqual("", element?.object?["child2"]?.string)
    }

    func testParseXMLNamespaced() throws {
        let doc1 = try xml("""
        <foo:root xmlns:foo="http://main/ns" xmlns:bar="http://secondary/ns">
          <foo:child bar:attr="1234">some data</foo:child>
        </foo:root>
        """)

        let doc2 = try xml("""
        <bar:root xmlns:bar="http://main/ns" xmlns:foo="http://secondary/ns">
          <bar:child foo:attr="1234">some data</bar:child>
        </bar:root>
        """)

        let doc3 = try xml("""
        <root xmlns="http://main/ns" xmlns:baz="http://secondary/ns">
          <child baz:attr="1234">some data</child>
        </root>
        """)

//        guard let e1 = doc1.elementChildren.first else { return XCTFail("no root") }
//        guard let c1 = e1.elementChildren.first else { return XCTFail("no child") }
//        guard let e2 = doc2.elementChildren.first else { return XCTFail("no root") }
//        guard let c2 = e2.elementChildren.first else { return XCTFail("no child") }
//        guard let e3 = doc3.elementChildren.first else { return XCTFail("no root") }
//        guard let c3 = e3.elementChildren.first else { return XCTFail("no child") }
//
//        XCTAssertEqual(["bar": "http://secondary/ns", "foo": "http://main/ns"], e1.namespaces)
//        XCTAssertEqual(["foo": "http://secondary/ns", "bar": "http://main/ns"], e2.namespaces)
//        XCTAssertEqual(["baz": "http://secondary/ns", "": "http://main/ns"], e3.namespaces)
//
//        XCTAssertEqual("root", e1.elementName)
//        XCTAssertEqual("http://main/ns", e1.namespaceURI)
//        XCTAssertEqual("child", c1.elementName)
//        XCTAssertEqual("http://main/ns", c1.namespaceURI)
//        XCTAssertEqual("1234", c1.attributeValue(key: "attr", namespaceURI: "http://secondary/ns"))
//
//        XCTAssertEqual("root", e2.elementName)
//        XCTAssertEqual("http://main/ns", e2.namespaceURI)
//        XCTAssertEqual("child", c2.elementName)
//        XCTAssertEqual("http://main/ns", c2.namespaceURI)
//        XCTAssertEqual("1234", c2.attributeValue(key: "attr", namespaceURI: "http://secondary/ns"))
//
//        XCTAssertEqual("root", e3.elementName)
//        XCTAssertEqual("http://main/ns", e3.namespaceURI)
//        XCTAssertEqual("child", c3.elementName)
//        XCTAssertEqual("http://main/ns", c3.namespaceURI)
//        XCTAssertEqual("1234", c3.attributeValue(key: "attr", namespaceURI: "http://secondary/ns"))

    }

    func testTidyHTML() throws {
        #if os(iOS) || os(tvOS) || os(watchOS) // XMLDocument unavailable on iOS…
        //XCTAssertThrowsError(try tidyHTML()) // …so the `.tidyHTML` flag should throw an error
        #elseif os(Windows)
        // Windows XML parsing doesn't seem to handle whitespace the same
        // try tidyHTML(preservesWhitespace: false) // actually, tidying doesn't seem to work at all
        #elseif !os(Linux) && !os(Android) // these pass on Linux, but the whitespace in the output is different, so it fails the exact equality tests; I'll need to implement XCTAssertEqualDisgrgardingWhitespace() to test on Linux
        try tidyHTML()
        #endif
    }

    func tidyHTML(preservesWhitespace: Bool = true) throws {
        func trim(_ string: String) -> String {
            if preservesWhitespace {
                return string
            } else {
                return string
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: "\r", with: "")
            }
        }

        XCTAssertEqual(trim("""
        <?xml version="1.0" encoding="UTF-8"?><html xmlns="http://www.w3.org/1999/xhtml"><head><title>My Page</title></head><body><h1>Header
        </h1><p>Body Text
        </p></body></html>
        """), trim(try XMLNode.parse(data: """
        <html>
            <head>
                <title>My Page</title>
            </head>
            <body>
                <h1>
                    Header
                </h1>
                <p>
                    Body Text
                </p>
            </body>
        </html>
        """.data(using: .utf8) ?? Data(), options: [.tidyHTML]).xmlString()))

        // tag capitalization mismatch
        XCTAssertEqual(trim("""
        <?xml version="1.0" encoding="UTF-8"?><html xmlns="http://www.w3.org/1999/xhtml"><head><title>My Page</title></head><body><h1>Header
        </h1><p>Body Text
        </p></body></html>
        """), trim(try XMLNode.parse(data: """
        <hTmL>
            <head>
                <title>My Page</title>
            </head>
            <BODY>
                <h1>
                    Header
                </H1>
                <p>
                    Body Text
                </p>
            </body>
        </HTML>
        """.data(using: .utf8) ?? Data(), options: [.tidyHTML]).xmlString()))

        // tag mismatch
        XCTAssertEqual(trim("""
        <?xml version="1.0" encoding="UTF-8"?><html xmlns="http://www.w3.org/1999/xhtml"><head><title>My Page</title></head><body><h1>Header
        </h1>Body Text<p></p></body></html>
        """), trim(try XMLNode.parse(data: """
        <html>
            <head>
                <title>My Page</title>
            </head>
            <body>
                <h1>
                    Header
                </h2
                <p>
                    Body Text
                </p>
            </body>
        </html>
        """.data(using: .utf8) ?? Data(), options: [.tidyHTML]).xmlString()))

        // unclosed tags
        XCTAssertEqual(trim("""
        <?xml version="1.0" encoding="UTF-8"?><html xmlns="http://www.w3.org/1999/xhtml"><head><title>My Page</title></head><body><h1>Header
        </h1><p>Body Text
        </p></body></html>
        """), trim(try XMLNode.parse(data: """
        <html>
            <head>
                <title>My Page</title>
            </head>
            <body>
                <h1>
                    Header
                <p>
                    Body Text
        """.data(using: .utf8) ?? Data(), options: [.tidyHTML]).xmlString()))



        XCTAssertEqual(trim("""
        <?xml version="1.0" encoding="UTF-8"?><html xmlns="http://www.w3.org/1999/xhtml"><head><title></title></head><body>Value</body></html>
        """), try XMLNode.parse(data: """
        <root>
            <element attr="value">
                <child1>
                    Value
                </CHILD1>
                <child2>
            </element>
        </root>
        """.data(using: .utf8) ?? Data(), options: [.tidyHTML]).xmlString())
    }

//    func testParsePlist() throws {
//        for plist in [
//            try Plist(data: """
//                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
//                <plist version="1.0">
//                <dict>
//                    <key>arrayOfStrings</key>
//                    <array>
//                        <string>abc</string>
//                        <string>def</string>
//                    </array>
//                    <key>stringKey</key>
//                    <string>xyz</string>
//                    <key>intKey</key>
//                    <integer>2</integer>
//                </dict>
//                </plist>
//                """.data(using: .utf8) ?? Data()),
//
//            // result of converting the above XML with: plutil -convert binary1 -o pl.bplist pl.plist
//            try Plist(data: Data(base64Encoded: "YnBsaXN0MDDTAQIDBAUGWXN0cmluZ0tleVZpbnRLZXleYXJyYXlPZlN0cmluZ3NTeHl6EAKiBwhTYWJjU2RlZggPGSAvMzU4PAAAAAAAAAEBAAAAAAAAAAkAAAAAAAAAAAAAAAAAAABA") ?? .init()),
//
//            // result of converting the above XML with: plutil -convert json -o pl.jplist pl.plist
//            // seems to not work…
//            // try Plist(data: #"{"stringKey":"xyz","intKey":2,"arrayOfStrings":["abc","def"]}"#.data(using: .utf8) ?? Data()),
//
//        ] {
//            XCTAssertEqual("xyz", plist.rawValue["stringKey"] as? String)
//            XCTAssertEqual(["abc", "def"], plist.rawValue["arrayOfStrings"] as? [String])
//            XCTAssertEqual(2, plist.rawValue["intKey"] as? Int)
//        }
//    }

}
