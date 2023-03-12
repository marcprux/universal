/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
import XCTest
import XML

final class XMLTests: XCTestCase {

    // MARK: XML Tests

    private let xml = { (str: String) in try XML.parse(str.data(using: .utf8) ?? Data()) }

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

        XCTAssertEqual(["root"], doc1.object?.keys.map({ $0 }))
        XCTAssertEqual(["", "child"], doc1.object?.values.first?.object?.keys.sorted())
        XCTAssertEqual(["root"], doc2.object?.keys.map({ $0 }))
        XCTAssertEqual(["", "child"], doc2.object?.values.first?.object?.keys.sorted())
        XCTAssertEqual(["root"], doc3.object?.keys.map({ $0 }))
        XCTAssertEqual(["", "child"], doc3.object?.values.first?.object?.keys.sorted())

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

    func testParseXMLCrazy() throws {
        let parsed = try xml("""
        <!DOCTYPE r [ <!ENTITY y "a]>b"> ]>
        <r>
        <a b="&y;>" />
        <![CDATA[[a>b <a>b <a]]>
        <?x <a> <!-- <b> ?> c --> d
        </r>
        """)

        let r = try XCTUnwrap(parsed.object?["r"])
        XCTAssertEqual(["a"], r.object?.keys.flatMap(Array.init))
        let a = try XCTUnwrap(r.object?["a"])
        XCTAssertEqual(["b"], a.object?.keys.flatMap(Array.init))
        XCTAssertEqual("a]>b>", a["b"]?.string)

//        XCTAssertEqual("Value", element?.object?["a"]?.string?.trimmingCharacters(in: .whitespacesAndNewlines))
//        XCTAssertEqual("", element?.object?["child2"]?.string)
    }


}
