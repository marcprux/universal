/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
import XCTest
import YAML
import Quanta

extension YAML : ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = YAML(.init(Either.Or(value)))
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = YAML(.init(Either.Or(value)))
    }

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = YAML(.init(Either.Or(value)))
    }
}

extension YAML.Scalar : ExpressibleByStringLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = YAML.Scalar(value)
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = YAML.Scalar(value)
    }

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = YAML.Scalar(value)
    }
}


extension YAML.Scalar {
    /// Creates a YAML scalar from the given string.
    public static func str(_ value: StringLiteralType) -> YAML.Scalar {
        YAML.Scalar(value)
    }

    /// Creates a YAML scalar from the given int.
    public static func int(_ value: IntegerLiteralType) -> YAML.Scalar {
        YAML.Scalar(.init(value))
    }

    /// Creates a YAML scalar from the given double.
    public static func dbl(_ value: FloatLiteralType) -> YAML.Scalar {
        YAML.Scalar(.init(value))
    }
}

extension YAML : ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension YAML.Scalar : ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = YAML.Scalar.null
    }
}

extension YAML : ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = YAML(Either.Or(Scalar(Either.Or(value))))
    }
}

extension YAML : ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = YAML(Either.Or(Scalar(Either.Or(value))))
    }
}

extension YAML : ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = YAML(Either.Or(Scalar(value)))
    }
}

extension YAML : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: YAML...) {
        self = YAML(Either.Or(Quanta(rawValue: Either.Or(elements))))
    }
}

extension YAML : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (YAML.Object.Key, YAML)...) {
        self = YAML(Either.Or(Quanta(rawValue: Either.Or(Dictionary(uniqueKeysWithValues: elements)))))
    }
}


final class YAMLTests : XCTestCase {

    // MARK: YAML Tests

    private let yaml = YAML.parse(yaml:)
    private let yamlMulti = YAML.parse(yamls:)

    func testNull() {
        XCTAssertEqual(try yaml("# comment line"), .null)
        XCTAssertEqual(try yaml(""), .null)
        XCTAssertEqual(try yaml("null"), .null)
        XCTAssertEqual(try yaml("Null"), .null)
        XCTAssertEqual(try yaml("NULL"), .null)
        XCTAssertEqual(try yaml("~"), .null)
        XCTAssertEqual(try yaml("NuLL"), .string("NuLL"))
        XCTAssertEqual(try yaml("null#"), .string("null#"))
        XCTAssertEqual(try yaml("null#string"), .string("null#string"))
        XCTAssertEqual(try yaml("null #comment"), .null)

        let value: YAML = .null
        XCTAssertEqual(value, .null)
    }

    func testBool() {
        XCTAssertEqual(try yaml("true"), .true)
        XCTAssertEqual(try yaml("True").boolean, true)
        XCTAssertEqual(try yaml("TRUE"), .true)
        XCTAssertEqual(try yaml("trUE"), .string("trUE"))
        XCTAssertEqual(try yaml("true#"), .string("true#"))
        XCTAssertEqual(try yaml("true#string"), .string("true#string"))
        XCTAssertEqual(try yaml("true #comment"), .true)
        XCTAssertEqual(try yaml("true  #"), .true)
        XCTAssertEqual(try yaml("true  "), .true)
        XCTAssertEqual(try yaml("true\n"), .true)
        XCTAssertEqual(try yaml("true \n"), .true)
        XCTAssertEqual(.true, (try yaml("\ntrue \n")))

        XCTAssertEqual(try yaml("false"), .boolean(false))
        XCTAssertEqual(try yaml("False").boolean, false)
        XCTAssertEqual(try yaml("FALSE"), .false)
        XCTAssertEqual(try yaml("faLSE"), .string("faLSE"))
        XCTAssertEqual(try yaml("false#"), .string("false#"))
        XCTAssertEqual(try yaml("false#string"), .string("false#string"))
        XCTAssertEqual(try yaml("false #comment"), .false)
        XCTAssertEqual(try yaml("false  #"), .false)
        XCTAssertEqual(try yaml("false  "), .false)
        XCTAssertEqual(try yaml("false\n"), .false)
        XCTAssertEqual(try yaml("false \n"), .false)
        XCTAssertEqual(.false, (try yaml("\nfalse \n")))

        let value: YAML = .true
        XCTAssertEqual(value, .true)
        XCTAssertEqual(value.boolean, true)
    }

    func testInt() {
        XCTAssertEqual(try yaml("0"), .integer(0))
        XCTAssertEqual(try yaml("+0").integer, 0)
        XCTAssertEqual(try yaml("-0"), 0)
        XCTAssertEqual(try yaml("2"), 2)
        XCTAssertEqual(try yaml("+2"), 2)
        XCTAssertEqual(try yaml("-2"), -2)
        XCTAssertEqual(try yaml("00123"), 123)
        XCTAssertEqual(try yaml("+00123"), 123)
        XCTAssertEqual(try yaml("-00123"), -123)
        XCTAssertEqual(try yaml("0o10"), 8)
        XCTAssertEqual(try yaml("0o010"), 8)
        XCTAssertEqual(try yaml("0o0010"), 8)
        XCTAssertEqual(try yaml("0x10"), 16)
        XCTAssertEqual(try yaml("0x1a"), 26)
        XCTAssertEqual(try yaml("0x01a"), 26)
        XCTAssertEqual(try yaml("0x001a"), 26)
        XCTAssertEqual(try yaml("10:10"), 610)
        XCTAssertEqual(try yaml("10:10:10"), 36610)

        XCTAssertEqual(try yaml("2"), 2)
        XCTAssertEqual(try yaml("2.0"), 2.0)
        XCTAssert(try yaml("2.5") != 2)
        XCTAssertEqual(try yaml("2.5").integer, nil)

        let value1: YAML = 2
        XCTAssertEqual(value1, 2)
        XCTAssertEqual(value1.integer, 2)
        XCTAssertEqual(value1.double, nil)
    }

    func testDouble() {
        XCTAssertEqual(try yaml(".inf"), .double(Double.infinity))
        XCTAssertEqual(try yaml(".Inf").double, Double.infinity)
        XCTAssertEqual(try yaml(".INF").double, Double.infinity)
        XCTAssertEqual(try yaml(".iNf"), ".iNf")
        XCTAssertEqual(try yaml(".inf#"), ".inf#")
        XCTAssertEqual(try yaml(".inf# string"), ".inf# string")
        XCTAssertEqual(try yaml(".inf # comment").double, Double.infinity)
        XCTAssertEqual(try yaml(".inf .inf"), ".inf .inf")
        XCTAssertEqual(try yaml("+.inf # comment").double, Double.infinity)

        XCTAssertEqual(try yaml("-.inf"), .double(-Double.infinity))
        XCTAssertEqual(try yaml("-.Inf").double, -Double.infinity)
        XCTAssertEqual(try yaml("-.INF").double, -Double.infinity)
        XCTAssertEqual(try yaml("-.iNf"), "-.iNf")
        XCTAssertEqual(try yaml("-.inf#"), "-.inf#")
        XCTAssertEqual(try yaml("-.inf# string"), "-.inf# string")
        XCTAssertEqual(try yaml("-.inf # comment").double, -Double.infinity)
        XCTAssertEqual(try yaml("-.inf -.inf"), "-.inf -.inf")

        XCTAssert(try yaml(".nan") != .double(Double.nan))
        XCTAssert(try yaml(".nan").double!.isNaN)
        //TODO: Causes exception
        //    XCTAssert(try yaml(".NaN").double!.isNaN)
        XCTAssert(try yaml(".NAN").double!.isNaN)
        XCTAssertEqual(try yaml(".Nan").double, nil)
        XCTAssertEqual(try yaml(".nan#"), ".nan#")
        XCTAssertEqual(try yaml(".nan# string"), ".nan# string")
        XCTAssert(try yaml(".nan # comment").double!.isNaN)
        XCTAssertEqual(try yaml(".nan .nan"), ".nan .nan")

        XCTAssertEqual(try yaml("0."), .double(0))
        XCTAssertEqual(try yaml(".0").double, 0)
        XCTAssertEqual(try yaml("+0."), 0.0)
        XCTAssertEqual(try yaml("+.0"), 0.0)
        XCTAssert(try yaml("+.") != 0.0)
        XCTAssertEqual(try yaml("-0."), 0.0)
        XCTAssertEqual(try yaml("-.0"), 0.0)
        XCTAssert(try yaml("-.") != 0)
        XCTAssertEqual(try yaml("2."), 2.0)
        /* Disabled for Linux */
#if !os(Linux) && !os(Android)
        XCTAssertEqual(try yaml(".2"), 0.2)
        XCTAssertEqual(try yaml("+2."), 2.0)
        XCTAssertEqual(try yaml("+.2"), 0.2)
        XCTAssertEqual(try yaml("-2."), -2.0)
        XCTAssertEqual(try yaml("-.2"), -0.2)
        XCTAssertEqual(try yaml("1.23015e+3"), 1.23015e+3)
        XCTAssertEqual(try yaml("12.3015e+02"), 12.3015e+02)
        XCTAssertEqual(try yaml("1230.15"), 1230.15)
        XCTAssertEqual(try yaml("+1.23015e+3"), 1.23015e+3)
        XCTAssertEqual(try yaml("+12.3015e+02"), 12.3015e+02)
        XCTAssertEqual(try yaml("+1230.15"), 1230.15)
        XCTAssertEqual(try yaml("-1.23015e+3"), -1.23015e+3)
        XCTAssertEqual(try yaml("-12.3015e+02"), -12.3015e+02)
        XCTAssertEqual(try yaml("-1230.15"), -1230.15)
        XCTAssertEqual(try yaml("-01230.15"), -1230.15)
        XCTAssertEqual(try yaml("-12.3015e02"), -12.3015e+02)
#endif

        XCTAssertEqual(try yaml("2"), 2)
        XCTAssertEqual(try yaml("2.0"), 2.0)
        XCTAssertEqual(try yaml("2.5"), 2.5)
        //XCTAssertEqual(try yaml("2.5").int, nil)

        let value1: YAML = 0.2
        XCTAssertEqual(value1, 0.2)
        XCTAssertEqual(value1.double, 0.2)
    }

    func testString() throws {
        XCTAssertEqual(try yaml("Behrang"), .string("Behrang"))
        XCTAssertEqual(try yaml("\"Behrang\""), .string("Behrang"))
        XCTAssertEqual(try yaml("\"B\\\"ehran\\\"g\""), .string("B\"ehran\"g"))
        XCTAssert(try yaml("Behrang Noruzi Niya").string ==
                  "Behrang Noruzi Niya")
        XCTAssertEqual(try yaml("Radin Noruzi Niya"), "Radin Noruzi Niya")
        XCTAssertEqual(try yaml("|"), "")
        XCTAssertEqual(try yaml("| "), "")
        XCTAssertEqual(try yaml("|  # comment"), "")
        XCTAssertEqual(try yaml("|  # comment\n"), "")

        XCTAssertThrowsError(try yaml("|\nRadin"))
        XCTAssertEqual(try yaml("|\n Radin"), "Radin")
        XCTAssertEqual(try yaml("|  \n Radin"), "Radin")
        XCTAssertEqual(try yaml("|  # comment\n Radin"), "Radin")
        XCTAssertEqual(try yaml("|\n  Radin"), "Radin")
        XCTAssertEqual(try yaml("|2\n  Radin"), "Radin")
        XCTAssertEqual(try yaml("|1\n  Radin"), " Radin")
        XCTAssertEqual(try yaml("|1\n\n  Radin"), "\n Radin")
        XCTAssertEqual(try yaml("|\n\n  Radin"), "\nRadin")
        XCTAssertNil(try? yaml("|3\n\n  Radin"))
        XCTAssertNil(try? yaml("|3\n    \n   Radin"))
        XCTAssertEqual(try yaml("|3\n   \n   Radin"), "\nRadin")
        XCTAssert(try yaml("|\n  \n\n \n  Radin\n\n \n\n  Noruzi Niya") ==
                  "\n\n\nRadin\n\n\n\nNoruzi Niya")
        XCTAssert(try yaml("|\n  \n\n \n  Radin\n\n \n\n  Noruzi Niya\n  #1") ==
                  "\n\n\nRadin\n\n\n\nNoruzi Niya\n#1")
        XCTAssert(try yaml("|\n  \n\n \n  Radin\n\n \n\n  Noruzi Niya\n  #1" +
                                 "\n # Comment") == "\n\n\nRadin\n\n\n\nNoruzi Niya\n#1\n")
        XCTAssertEqual(try yaml("|\n Radin\n"), "Radin\n")
        XCTAssertEqual(try yaml("|\n Radin\n\n"), "Radin\n")
        XCTAssertEqual(try yaml("|\n Radin\n \n "), "Radin\n")
        XCTAssertEqual(try yaml("|\n Radin\n  \n  "), "Radin\n")
        XCTAssertEqual(try yaml("|-\n Radin\n  \n  "), "Radin")
        XCTAssertEqual(try yaml("|+\n Radin\n"), "Radin\n")
        XCTAssertEqual(try yaml("|+\n Radin\n\n"), "Radin\n\n")
        XCTAssertEqual(try yaml("|+\n Radin\n \n "), "Radin\n\n")
        XCTAssertEqual(try yaml("|+\n Radin\n  \n  "), "Radin\n \n ")
        XCTAssertEqual(try yaml("|2+\n  Radin\n  \n  "), "Radin\n\n")
        XCTAssertEqual(try yaml("|+2\n  Radin\n  \n  "), "Radin\n\n")
        XCTAssertEqual(try yaml("|-2\n  Radin\n  \n  "), "Radin")
        XCTAssertEqual(try yaml("|2-\n  Radin\n  \n  "), "Radin")
        XCTAssertThrowsError(try yaml("|22\n  Radin\n  \n  "))
        XCTAssertThrowsError(try yaml("|--\n  Radin\n  \n  "))
        XCTAssert(try yaml(">+\n  trimmed\n  \n \n\n  as\n  space\n\n   \n") ==
                  "trimmed\n\n\nas space\n\n \n")
        XCTAssert(try yaml(">-\n  trimmed\n  \n \n\n  as\n  space") ==
                  "trimmed\n\n\nas space")
        XCTAssert(try yaml(">\n  foo \n \n  \t bar\n\n  baz\n") ==
                  "foo \n\n\t bar\n\nbaz\n")

        XCTAssertThrowsError(try yaml(">\n  \n Behrang"))
        XCTAssertEqual(try yaml(">\n  \n  Behrang"), "\nBehrang")
        XCTAssert(try yaml(">\n\n folded\n line\n\n next\n line\n   * bullet\n\n" +
                                 "   * list\n   * lines\n\n last\n line\n\n# Comment") ==
            .string("\nfolded line\nnext line\n  * bullet\n\n  * list\n  * lines" +
                    "\n\nlast line\n"))

        XCTAssert(try yaml("\"\n  foo \n \n  \t bar\n\n  baz\n\"") ==
                  " foo\nbar\nbaz ")
        XCTAssert(try yaml("\"folded \nto a space,\t\n \nto a line feed," +
                                 " or \t\\\n \\ \tnon-content\"") ==
                  "folded to a space,\nto a line feed, or \t \tnon-content")
        XCTAssert(try yaml("\" 1st non-empty\n\n 2nd non-empty" +
                                 " \n\t3rd non-empty \"") ==
                  " 1st non-empty\n2nd non-empty 3rd non-empty ")

        XCTAssertEqual(try yaml("'here''s to \"quotes\"'"), "here's to \"quotes\"")
        XCTAssert(try yaml("' 1st non-empty\n\n 2nd non-empty" +
                                 " \n\t3rd non-empty '") ==
                  " 1st non-empty\n2nd non-empty 3rd non-empty ")

        XCTAssertEqual(try yaml("x\n y\nz"), "x y z")
        XCTAssertEqual(try yaml(" x\ny\n z"), "x y z")
        XCTAssertEqual(try yaml("a: x\n y\n  z"), ["a": "x y z"])
        XCTAssertThrowsError(try yaml("a: x\ny\n  z"))
        XCTAssertEqual(try yaml("- a: x\n   y\n    z"), [["a": "x y z"]])
        XCTAssertEqual(try yaml("- a:\n   x\n    y\n   z"), [["a": "x y z"]])
        XCTAssertEqual(try yaml("- a:     \n   x\n    y\n   z"), [[.str("a"): "x y z"]])
        XCTAssert(try yaml("- a: # comment\n   x\n    y\n   z") ==
                  [[.str("a"): "x y z"]])

        let value1: YAML = "Radin"
        XCTAssertEqual(value1, "Radin")
        XCTAssertEqual(value1.string, "Radin")

        let value2 = try yaml(
            "# Outside flow collection:\n" +
            "- ::vector\n" +
            "- \": - ()\"\n" +
            "- Up, up, and away!\n" +
            "- -123\n" +
            "- http://example.com/foo#bar\n" +
            "# Inside flow collection:\n" +
            "- [ ::vector,\n" +
            "  \": - ()\",\n" +
            "  \"Up, up and away!\",\n" +
            "  -123,\n" +
            "  http://example.com/foo#bar ]\n"
        )
        XCTAssertEqual(value2.count, 6)
        XCTAssertEqual(value2[0], "::vector")
        XCTAssertEqual(value2[5]?[0], "::vector")
        XCTAssertEqual(value2[5]?[4], "http://example.com/foo#bar")
    }

    func testFlowSeq() {
        XCTAssertEqual(try yaml("[]"), .array([]))
        XCTAssertEqual(try yaml("[]").count, 0)
        XCTAssertEqual(try yaml("[ true ]"), [YAML.true])
        XCTAssertEqual(try yaml("[ true ]"), .array([true]))
        XCTAssertEqual(try yaml("[ true ]"), [true])
        XCTAssertEqual(try yaml("[ true ]")[0], true)
        XCTAssertEqual(try yaml("[true, false, true]"), [true, false, true])
        XCTAssertEqual(try yaml("[Behrang, Radin]"), ["Behrang", "Radin"])
        XCTAssertEqual(try yaml("[true, [false, true]]"), [true, [false, true]])
        XCTAssert(try yaml("[true, true  ,false,  false  ,  false]") ==
                  [true, true, false, false, false])
        XCTAssert(try yaml("[true, .NaN]") != [true, .double(Double.nan)])
        XCTAssert(try yaml("[~, null, TRUE, False, .INF, -.inf, 0, 123, -456" +
                                 ", 0o74, 0xFf, 1.23, -4.5]") ==
                  [nil, nil, true, false,
                   .double(Double.infinity), .double(-Double.infinity),
                   0, 123, -456, 60, 255, 1.23, -4.5])
        XCTAssertThrowsError(try yaml("x:\n y:\n  z: [\n1]"))
        XCTAssertThrowsError(try yaml("x:\n y:\n  z: [\n  1]"))
        XCTAssertEqual(try yaml("x:\n y:\n  z: [\n   1]"), ["x": ["y": ["z": [1]]]])
    }

    func testBlockSeq() throws {
        XCTAssertEqual(try yaml("- 1\n- 2"), [1, 2])
        XCTAssertEqual(try yaml("- 1\n- 2")[1], 2)
        XCTAssertEqual(try yaml("- x: 1"), [["x": 1]])
        XCTAssertEqual(try yaml("- x: 1\n  y: 2")[0], ["x": 1, "y": 2])
        XCTAssertEqual(try yaml("- 1\n    \n- x: 1\n  y: 2"), [1, ["x": 1, "y": 2]])
        XCTAssertEqual(try yaml("- x:\n  - y: 1"), [["x": [["y": 1]]]])
    }

    func testFlowMap() throws {
        XCTAssertEqual(try yaml("{}"), [:])
        XCTAssertEqual(try yaml("{\"x\":1}")["x"], 1)
        XCTAssertEqual(try yaml("{x: 1}"), ["x": 1])
        XCTAssertThrowsError(try yaml("{x: 1, x: 2}"))
        XCTAssertEqual(try yaml("{x: 1}")["x"], 1)
        XCTAssertThrowsError(try yaml("{x:1}"))
        XCTAssertEqual(try yaml("{\"x\":1, 'y': true}")["y"], true)
        XCTAssertEqual(try yaml("{\"x\":1, 'y': true, z: null}")["z"], .null)
        XCTAssert(try yaml("{first name: \"Behrang\"," +
                                 " last name: 'Noruzi Niya'}") ==
                  ["first name": "Behrang", "last name": "Noruzi Niya"])
        XCTAssert(try yaml("{fn: Behrang, ln: Noruzi Niya}")["ln"] ==
                  "Noruzi Niya")
        XCTAssert(try yaml("{fn: Behrang\n ,\nln: Noruzi Niya}")["ln"] ==
                  "Noruzi Niya")
    }

    func testBlockMap() throws {
        XCTAssert(try yaml("x: 1\ny: 2") == YAML.object(["x": .integer(1), "y": .integer(2)]))
        XCTAssertThrowsError(try yaml("x: 1\nx: 2"))
        XCTAssertEqual(try yaml("x: 1\n? y\n: 2"), ["x": 1, "y": 2])
        XCTAssertThrowsError(try yaml("x: 1\n? x\n: 2"))
        XCTAssertThrowsError(try yaml("x: 1\n?  y\n:\n2"))
        XCTAssertEqual(try yaml("x: 1\n?  y\n:\n 2"), ["x": 1, "y": 2])
        XCTAssertEqual(try yaml("x: 1\n?  y"), ["x": 1, "y": nil])
        XCTAssertEqual(try yaml("?  y"), ["y": nil])
        XCTAssert(try yaml(" \n  \n \n  \n\nx: 1  \n   \ny: 2" +
                                 "\n   \n  \n ")["y"] == 2)
        XCTAssert(try yaml("x:\n a: 1 # comment \n b: 2\ny: " +
                                 "\n  c: 3\n  ")["y"]?["c"] == 3)
        XCTAssert(try yaml("# comment \n\n  # x\n  # y \n  \n  x: 1" +
                                 "  \n  y: 2") == ["x": 1, "y": 2])
    }

    func testDirectives() throws {
        XCTAssertThrowsError(try yaml("%YAML 1.2\n1"))
        XCTAssertEqual(try yaml("%YAML   1.2\n---1"), 1)
        XCTAssertEqual(try yaml("%YAML   1.2  #\n---1"), 1)
        XCTAssertThrowsError(try yaml("%YAML   1.2\n%YAML 1.2\n---1"))
        XCTAssertThrowsError(try yaml("%YAML 1.0\n---1"))
        XCTAssertThrowsError(try yaml("%YAML 1\n---1"))
        XCTAssertThrowsError(try yaml("%YAML 1.3\n---1"))
        XCTAssertThrowsError(try yaml("%YAML \n---1"))
    }

    func testReserves() throws {
        XCTAssertThrowsError(try yaml("`reserved"))
        XCTAssertThrowsError(try yaml("@behrangn"))
        XCTAssertThrowsError(try yaml("twitter handle: @behrangn"))
    }

    func testAliases() {
        XCTAssertEqual(try yaml("x: &a 1\ny: *a"), ["x": 1, "y": 1])
        XCTAssertThrowsError(try yamlMulti("x: &a 1\ny: *a\n---\nx: *a"))
        XCTAssertThrowsError(try yaml("x: *a"))
    }

    func testUnicodeSurrogates() {
        XCTAssertEqual(try yaml("x: Dog‼🐶\ny: 𝒂𝑡"), ["x": "Dog‼🐶", "y": "𝒂𝑡"])
    }


    // MARK: Example Tests

    func testExample0() throws {
        var value = try yaml(
            "- just: write some\n" +
            "- yaml: \n" +
            "  - [here, and]\n" +
            "  - {it: updates, in: real-time}\n"
        )
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value[0]?["just"], "write some")
        XCTAssertEqual(value[1]?["yaml"]?[0]?[1], "and")
        XCTAssertEqual(value[1]?["yaml"]?[1]?["in"], "real-time")

        XCTAssertEqual(value, [
            [
                "just": "write some"
            ],
            [
                "yaml": [
                    [
                        "here",
                        "and",
                    ],
                    [
                        "it": "updates",
                        "in": "real-time",
                    ]
                ]
            ]
        ])

//        value[0]?["just"] = .str("replaced string")
//        XCTAssertEqual(value[0]?["just"], "replaced string")
//        value[0]?["another"] = .num(2)
//        XCTAssertEqual(value[0]?["another"], 2)
//
//        value[0]?["new"] = [:]
//        value[0]?["new"]?["key"] = .arr(.init(repeating: ["key" : nil], count: 16))
//
//        value[0]?["new"]?["key"]?[10]?["key"] = .str("Ten")
//        XCTAssertEqual(value[0]?["new"]?["key"]?[10]?["key"], "Ten")
//        value[0]?["new"]?["key"]?[5]?["key"] = .str("Five")
//        XCTAssertEqual(value[0]?["new"]?["key"]?[5]?["key"], "Five")
//        value[0]?["new"]?["key"]?[15]?["key"] = .str("Fifteen")
//        XCTAssertEqual(value[0]?["new"]?["key"]?[15]?["key"], "Fifteen")

//        value[2] = .num(2)
//        XCTAssertEqual(value[2], 2)
        value = nil
        XCTAssertEqual(value, nil)
    }

    func testExample1() throws {
        let value = try yaml(
            "- Mark McGwire\n" +
            "- Sammy Sosa\n" +
            "- Ken Griffey\n"
        )
        XCTAssertEqual(value.count, 3)
        XCTAssertEqual(value[1], "Sammy Sosa")
        XCTAssertEqual(value, [
            "Mark McGwire",
            "Sammy Sosa",
            "Ken Griffey",
        ])
    }

    func testExample2() throws {
        let value = try yaml(
            "hr:  65    # Home runs\n" +
            "avg: 0.278 # Batting average\n" +
            "rbi: 147   # Runs Batted In\n"
        )
        XCTAssertEqual(value.count, 3)
        XCTAssertEqual(value["avg"], 0.278)

        XCTAssertEqual(value, [
            "hr": 65,
            "avg": 0.278,
            "rbi": 147,
        ])

    }

    func testExample3() throws {
        let value = try yaml(
            "american:\n" +
            "  - Boston Red Sox\n" +
            "  - Detroit Tigers\n" +
            "  - New York Yankees\n" +
            "national:\n" +
            "  - New York Mets\n" +
            "  - Chicago Cubs\n" +
            "  - Atlanta Braves\n"
        )
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value["national"]?.count, 3)
        XCTAssertEqual(value["national"]?[2], "Atlanta Braves")

        XCTAssertEqual(value, [
            "american": ["Boston Red Sox", "Detroit Tigers", "New York Yankees"],
            "national": ["New York Mets", "Chicago Cubs", "Atlanta Braves"],
        ])
    }

    func testExample4() throws {
        let value = try yaml(
            "-\n" +
            "  name: Mark McGwire\n" +
            "  hr:   65\n" +
            "  avg:  0.278\n" +
            "-\n" +
            "  name: Sammy Sosa\n" +
            "  hr:   63\n" +
            "  avg:  0.288\n"
        )
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value[1]?["avg"]?.double ?? .nan, 0.288, accuracy: 0.00001)

        XCTAssertEqual(value, [
            [
                "name": "Mark McGwire",
                "hr": 65,
                "avg": 0.278
            ],
            [
                "name": "Sammy Sosa",
                "hr": 63,
                "avg": 0.288,
            ]
        ])
    }

    func testExample5() throws {
        let value = try yaml(
            "- [name        , hr, avg  ]\n" +
            "- [Mark McGwire, 65, 0.278]\n" +
            "- [Sammy Sosa  , 63, 0.288]\n"
        )
        XCTAssertEqual(value.count, 3)
        XCTAssertEqual(value[2]?.count, 3)
        XCTAssertEqual(value[2]?[2]?.double ?? .nan, 0.288, accuracy: 0.00001)
    }

    func testExample6() throws {
        let value = try yaml(
            "Mark McGwire: {hr: 65, avg: 0.278}\n" +
            "Sammy Sosa: {\n" +
            "    hr: 63,\n" +
            "    avg: 0.288\n" +
            "  }\n"
        )
        XCTAssertEqual(value["Mark McGwire"]?["hr"], 65)
        XCTAssertEqual(value["Sammy Sosa"]?["hr"], 63)
    }

    func testExample7() throws {
        let value = try yamlMulti(
            "# Ranking of 1998 home runs\n" +
            "---\n" +
            "- Mark McGwire\n" +
            "- Sammy Sosa\n" +
            "- Ken Griffey\n" +
            "\n" +
            "# Team ranking\n" +
            "---\n" +
            "- Chicago Cubs\n" +
            "- St Louis Cardinals\n"
        )
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value[0].count, 3)
        XCTAssertEqual(value[0][1], "Sammy Sosa")
        XCTAssertEqual(value[1].count, 2)
        XCTAssertEqual(value[1][1], "St Louis Cardinals")
    }

    func testExample8() throws {
        let value = try yamlMulti(
            "---\n" +
            "time: 20:03:20\n" +
            "player: Sammy Sosa\n" +
            "action: strike (miss)\n" +
            "...\n" +
            "---\n" +
            "time: 20:03:47\n" +
            "player: Sammy Sosa\n" +
            "action: grand slam\n" +
            "...\n"
        )
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value[0]["player"], "Sammy Sosa")
        XCTAssertEqual(value[0]["time"], 72200)
        XCTAssertEqual(value[1]["player"], "Sammy Sosa")
        XCTAssertEqual(value[1]["time"], 72227)
    }

    func testExample9() throws {
        let value = try yaml(
            "---\n" +
            "hr: # 1998 hr ranking\n" +
            "  - Mark McGwire\n" +
            "  - Sammy Sosa\n" +
            "rbi:\n" +
            "  # 1998 rbi ranking\n" +
            "  - Sammy Sosa\n" +
            "  - Ken Griffey\n"
        )
        XCTAssertEqual(value["hr"]?[1], "Sammy Sosa")
        XCTAssertEqual(value["rbi"]?[1], "Ken Griffey")
    }

    func testExample10() throws {
        let value = try yaml(
            "---\n" +
            "hr:\n" +
            "  - Mark McGwire\n" +
            "  # Following node labeled SS\n" +
            "  - &SS Sammy Sosa\n" +
            "rbi:\n" +
            "  - *SS # Subsequent occurrence\n" +
            "  - Ken Griffey\n"
        )
        XCTAssertEqual(value["hr"]?.count, 2)
        XCTAssertEqual(value["hr"]?[1], "Sammy Sosa")
        XCTAssertEqual(value["rbi"]?.count, 2)
        XCTAssertEqual(value["rbi"]?[0], "Sammy Sosa")
    }

    func XXXtestExample11() throws {
        let value = try yaml(
            "? - Detroit Tigers\n" +
            "  - Chicago cubs\n" +
            ":\n" +
            "  - 2001-07-23\n" +
            "\n" +
            "? [ New York Yankees,\n" +
            "    Atlanta Braves ]\n" +
            ": [ 2001-07-02, 2001-08-12,\n" +
            "    2001-08-14 ]\n"
        )
        _ = try yaml("- Detroit Tigers\n- Chicago cubs\n")
        _ = try yaml("- New York Yankees\n- Atlanta Braves")
        XCTAssertEqual(value.count, 2)
//        XCTAssertEqual(value[key1].count, 1)
//        XCTAssertEqual(value[key2].count, 3)
//        XCTAssertEqual(value[key2][2], "2001-08-14")
    }

    func testExample12() throws {
        let value = try yaml(
            "---\n" +
            "# Products purchased\n" +
            "- item    : Super Hoop\n" +
            "  quantity: 1\n" +
            "- item    : Basketball\n" +
            "  quantity: 4\n" +
            "- item    : Big Shoes\n" +
            "  quantity: 1\n"
        )
        XCTAssertEqual(value.count, 3)
        XCTAssertEqual(value[1]?.count, 2)
        XCTAssertEqual(value[1]?["item"], "Basketball")
        XCTAssertEqual(value[1]?["quantity"], 4)
        _ = try yaml("quantity")
//        XCTAssertEqual(value[2][key], 1)
    }

    func testExample13() throws {
        let value = try yaml(
            "# ASCII Art\n" +
            "--- |\n" +
            "  \\//||\\/||\n" +
            "  // ||  ||__\n"
        )
        XCTAssertEqual(value, "\\//||\\/||\n// ||  ||__\n")
    }

    func testExample14() throws {
        let value = try yaml(
            "--- >\n" +
            "  Mark McGwire's\n" +
            "  year was crippled\n" +
            "  by a knee injury.\n"
        )
        XCTAssertEqual(value, "Mark McGwire's year was crippled by a knee injury.\n")
    }

    func testExample15() throws {
        let value = try yaml(
            ">\n" +
            " Sammy Sosa completed another\n" +
            " fine season with great stats.\n" +
            "\n" +
            "   63 Home Runs\n" +
            "   0.288 Batting Average\n" +
            "\n" +
            " What a year!\n"
        )
        XCTAssertEqual(value, .string("Sammy Sosa completed another fine season with great stats.\n\n" +
                    "  63 Home Runs\n  0.288 Batting Average\n\nWhat a year!\n"))
    }

    func testExample16() throws {
        let value = try yaml(
            "name: Mark McGwire\n" +
            "accomplishment: >\n" +
            "  Mark set a major league\n" +
            "  home run record in 1998.\n" +
            "stats: |\n" +
            "  65 Home Runs\n" +
            "  0.278 Batting Average\n"
        )
        XCTAssertEqual(value["accomplishment"], "Mark set a major league home run record in 1998.\n")
        XCTAssertEqual(value["stats"], "65 Home Runs\n0.278 Batting Average\n")
    }

    func testExample17() throws {
        let value = try yaml(
            "unicode: \"Sosa did fine.\\u263A\"\n" +
            "control: \"\\b1998\\t1999\\t2000\\n\"\n" +
            "hex esc: \"\\x0d\\x0a is \\r\\n\"\n" +
            "\n" +
            "single: '\"Howdy!\" he cried.'\n" +
            "quoted: ' # Not a ''comment''.'\n" +
            "tie-fighter: '|\\-*-/|'\n"
        )
        // FIXME: Failing with Xcode8b6
        // XCTAssertEqual(value["unicode"], "Sosa did fine.\u{263A}")
        XCTAssertEqual(value["control"], "\u{8}1998\t1999\t2000\n")
        // FIXME: Failing with Xcode8b6
        // XCTAssertEqual(value["hex esc"], "\u{d}\u{a} is \r\n")
        XCTAssertEqual(value["single"], "\"Howdy!\" he cried.")
        XCTAssertEqual(value["quoted"], " # Not a 'comment'.")
        XCTAssertEqual(value["tie-fighter"], "|\\-*-/|")
    }

    func testExample18() throws {
        let value = try yaml(
            "plain:\n" +
            "  This unquoted scalar\n" +
            "  spans many lines.\n" +
            "\n" +
            "quoted: \"So does this\n" +
            "  quoted scalar.\\n\"\n"
        )
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value["plain"], "This unquoted scalar spans many lines.")
        XCTAssertEqual(value["quoted"], "So does this quoted scalar.\n")
    }

    func testExample19() throws {
        let value = try yaml(
            "canonical: 12345\n" +
            "decimal: +12345\n" +
            "octal: 0o14\n" +
            "hexadecimal: 0xC\n"
        )
        XCTAssertEqual(value.count, 4)
        XCTAssertEqual(value["canonical"], 12345)
        XCTAssertEqual(value["decimal"], 12345)
        XCTAssertEqual(value["octal"], 12)
        XCTAssertEqual(value["hexadecimal"], 12)
    }

    func testExample20() throws {
        let value = try yaml(
            "canonical: 1.23015e+3\n" +
            "exponential: 12.3015e+02\n" +
            "fixed: 1230.15\n" +
            "negative infinity: -.inf\n" +
            "not a number: .NaN\n"
        )
        XCTAssertEqual(value.count, 5)
        /* Disabled for Linux */
#if !os(Linux) && !os(Android)
        XCTAssertEqual(value["canonical"], 1.23015e+3)
        XCTAssertEqual(value["exponential"], 1.23015e+3)
        XCTAssertEqual(value["fixed"], 1.23015e+3)
#endif
        XCTAssertEqual(value["negative infinity"], .double(-Double.infinity))
        XCTAssertEqual(value["not a number"]?.double?.isNaN, true)
    }

    func testExample21() throws {
        let value = try yaml(
            "null:\n" +
            "booleans: [ true, false ]\n" +
            "string: '012345'\n"
        )
        XCTAssertEqual(value.count, 3)
        XCTAssertEqual(value["null"], .null)
        XCTAssertEqual(value["booleans"], [true, false])
        XCTAssertEqual(value["string"], "012345")
    }

    func testExample22() throws {
        let value = try yaml(
            "canonical: 2001-12-15T02:59:43.1Z\n" +
            "iso8601: 2001-12-14t21:59:43.10-05:00\n" +
            "spaced: 2001-12-14 21:59:43.10 -5\n" +
            "date: 2002-12-14\n"
        )
        XCTAssertEqual(value.count, 4)
        XCTAssertEqual(value["canonical"], "2001-12-15T02:59:43.1Z")
        XCTAssertEqual(value["iso8601"], "2001-12-14t21:59:43.10-05:00")
        XCTAssertEqual(value["spaced"], "2001-12-14 21:59:43.10 -5")
        XCTAssertEqual(value["date"], "2002-12-14")
    }

    let exampleYaml = """
        %YAML 1.2
        ---
        YAML: YAML Ain't Markup Language

        What It Is: YAML is a human friendly data serialization
          standard for all programming languages.

        YAML Resources:
          YAML 1.2 (3rd Edition): http://yaml.org/spec/1.2/spec.html
          YAML 1.1 (2nd Edition): http://yaml.org/spec/1.1/
          YAML 1.0 (1st Edition): http://yaml.org/spec/1.0/
          YAML Issues Page: https://github.com/yaml/yaml/issues
          YAML Mailing List: yaml-core@lists.sourceforge.net
          YAML IRC Channel: \"#yaml on irc.freenode.net\"
          YAML Cookbook (Ruby): http://yaml4r.sourceforge.net/cookbook/
          YAML Reference Parser: http://yaml.org/ypaste/

        Projects:
          C/C++ Libraries:
          - libyaml       # \"C\" Fast YAML 1.1
          - Syck          # (dated) \"C\" YAML 1.0
          - yaml-cpp      # C++ YAML 1.2 implementation
          Ruby:
          - psych         # libyaml wrapper (in Ruby core for 1.9.2)
          - RbYaml        # YAML 1.1 (PyYaml Port)
          - yaml4r        # YAML 1.0, standard library syck binding
          Python:
          - PyYaml        # YAML 1.1, pure python and libyaml binding
          - PySyck        # YAML 1.0, syck binding
          Java:
          - JvYaml        # Java port of RbYaml
          - SnakeYAML     # Java 5 / YAML 1.1
          - YamlBeans     # To/from JavaBeans
          - JYaml         # Original Java Implementation
          Perl Modules:
          - YAML          # Pure Perl YAML Module
          - YAML::XS      # Binding to libyaml
          - YAML::Syck    # Binding to libsyck
          - YAML::Tiny    # A small YAML subset module
          - PlYaml        # Perl port of PyYaml
          C#/.NET:
          - yaml-net      # YAML 1.1 library
          - yatools.net   # (in-progress) YAML 1.1 implementation
          PHP:
          - php-yaml      # libyaml bindings (YAML 1.1)
          - syck          # syck bindings (YAML 1.0)
          - spyc          # yaml loader/dumper (YAML 1.?)
          OCaml:
          - ocaml-syck    # YAML 1.0 via syck bindings
          Javascript:
          - JS-YAML       # Native PyYAML port to JavaScript.
          - JS-YAML Online# Browserified JS-YAML demo, to play with YAML.
          Actionscript:
          - as3yaml       # port of JvYAML (1.1)
          Haskell:
          - YamlReference # Haskell 1.2 reference parser
          Others:
          - yamlvim (src) # YAML dumper/emitter in pure vimscript

        Related Projects:
          - Rx            # Multi-Language Schemata Tool for JSON/YAML
          - Kwalify       # Ruby Schemata Tool for JSON/YAML
          - yaml_vim      # vim syntax files for YAML
          - yatools.net   # Visual Studio editor for YAML
          - JSON          # Official JSON Website
          - Pygments      # Python language Syntax Colorizer /w YAML support

        News:
          - 20-NOV-2011 -- JS-YAML, a JavaScript YAML parser.
          - 18-AUG-2010 -- Ruby 1.9.2 includes psych, a libyaml wrapper.
        # Maintained by Clark C. Evans
        """

    func testYamlHomepage() throws {
        let value = try yaml(exampleYaml)
        XCTAssertEqual(value.count, 6)
        XCTAssertEqual(value["YAML"], "YAML Ain't Markup Language")
        XCTAssertEqual(value["What It Is"], .string("YAML is a human friendly data serialization standard for all programming languages."))
        XCTAssertEqual(value["YAML Resources"]?.count, 8)
        XCTAssert(value["YAML Resources"]?["YAML 1.2 (3rd Edition)"] ==
                  "http://yaml.org/spec/1.2/spec.html")
        XCTAssert(value["YAML Resources"]?["YAML IRC Channel"] ==
                  "#yaml on irc.freenode.net")
        XCTAssertEqual(value["Projects"]?.count, 12)
        XCTAssertEqual(value["Projects"]?["C/C++ Libraries"]?[2], "yaml-cpp")
        XCTAssertEqual(value["Projects"]?["Perl Modules"]?.count, 5)
        XCTAssertEqual(value["Projects"]?["Perl Modules"]?[0], "YAML")
        XCTAssertEqual(value["Projects"]?["Perl Modules"]?[1], "YAML::XS")
        XCTAssertEqual(value["Related Projects"]?.count, 6)
        XCTAssertEqual(value["News"]?.count, 2)
    }

    func testPerformanceExample() {
        #if os(Linux)
        _ = try? yaml(self.exampleYaml)
        #else
        self.measure() { // stddev fails on Linux
            _ = try? yaml(self.exampleYaml)
        }
        #endif
    }
}
