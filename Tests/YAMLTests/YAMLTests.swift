/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
import Testing
import Foundation
import YAML
import Either

@Suite struct YAMLTests {

    // MARK: YAML Tests

    private let yaml: (String) throws -> YAML = YAML.parse(yaml:)
    private let yamlMulti: (String) throws -> [YAML] = YAML.parse(yamls:)

    @Test func testIntentionalFailureOnAndroid() throws {
        #if os(Android)
        #expect("right" == "wrong")
        #endif
    }

    @Test func testNull() throws {
        #expect(try yaml("# comment line") == .null)
        #expect(try yaml("") == .null)
        #expect(try yaml("null") == .null)
        #expect(try yaml("Null") == .null)
        #expect(try yaml("NULL") == .null)
        #expect(try yaml("~") == .null)
        #expect(try yaml("NuLL") == .string("NuLL"))
        #expect(try yaml("null#") == .string("null#"))
        #expect(try yaml("null#string") == .string("null#string"))
        #expect(try yaml("null #comment") == .null)

        let value: YAML = .null
        #expect(value == .null)
    }

    @Test func testBool() throws {
        #expect(try yaml("true") == .true)
        #expect(try yaml("True").boolean == true)
        #expect(try yaml("TRUE") == .true)
        #expect(try yaml("trUE") == .string("trUE"))
        #expect(try yaml("true#") == .string("true#"))
        #expect(try yaml("true#string") == .string("true#string"))
        #expect(try yaml("true #comment") == .true)
        #expect(try yaml("true  #") == .true)
        #expect(try yaml("true  ") == .true)
        #expect(try yaml("true\n") == .true)
        #expect(try yaml("true \n") == .true)
        #expect(try yaml("\ntrue \n") == .true)

        #expect(try yaml("false") == .boolean(false))
        #expect(try yaml("False").boolean == false)
        #expect(try yaml("FALSE") == .false)
        #expect(try yaml("faLSE") == .string("faLSE"))
        #expect(try yaml("false#") == .string("false#"))
        #expect(try yaml("false#string") == .string("false#string"))
        #expect(try yaml("false #comment") == .false)
        #expect(try yaml("false  #") == .false)
        #expect(try yaml("false  ") == .false)
        #expect(try yaml("false\n") == .false)
        #expect(try yaml("false \n") == .false)
        #expect(try yaml("\nfalse \n") == .false)

        let value: YAML = .true
        #expect(value == .true)
        #expect(value.boolean == true)
    }

    @Test func testInt() throws {
        #expect(try yaml("0") == .integer(0))
        #expect(try yaml("+0").integer == 0)
        #expect(try yaml("-0") == 0)
        #expect(try yaml("2") == 2)
        #expect(try yaml("+2") == 2)
        #expect(try yaml("-2") == -2)
        #expect(try yaml("00123") == 123)
        #expect(try yaml("+00123") == 123)
        #expect(try yaml("-00123") == -123)
        #expect(try yaml("0o10") == 8)
        #expect(try yaml("0o010") == 8)
        #expect(try yaml("0o0010") == 8)
        #expect(try yaml("0x10") == 16)
        #expect(try yaml("0x1a") == 26)
        #expect(try yaml("0x01a") == 26)
        #expect(try yaml("0x001a") == 26)
        #expect(try yaml("10:10") == 610)
        #expect(try yaml("10:10:10") == 36610)

        #expect(try yaml("2") == 2)
        #expect(try yaml("2.0") == 2.0)
        #expect(try yaml("2.5") != 2)
        #expect(try yaml("2.5").integer == nil)

        let value1: YAML = 2
        #expect(value1 == 2)
        #expect(value1.integer == 2)
        #expect(value1.double == nil)
    }

    @Test func testDouble() throws {
        #expect(try yaml(".inf") == .double(Double.infinity))
        #expect(try yaml(".Inf").double == Double.infinity)
        #expect(try yaml(".INF").double == Double.infinity)
        #expect(try yaml(".iNf") == ".iNf")
        #expect(try yaml(".inf#") == ".inf#")
        #expect(try yaml(".inf# string") == ".inf# string")
        #expect(try yaml(".inf # comment").double == Double.infinity)
        #expect(try yaml(".inf .inf") == ".inf .inf")
        #expect(try yaml("+.inf # comment").double == Double.infinity)

        #expect(try yaml("-.inf") == .double(-Double.infinity))
        #expect(try yaml("-.Inf").double == -Double.infinity)
        #expect(try yaml("-.INF").double == -Double.infinity)
        #expect(try yaml("-.iNf") == "-.iNf")
        #expect(try yaml("-.inf#") == "-.inf#")
        #expect(try yaml("-.inf# string") == "-.inf# string")
        #expect(try yaml("-.inf # comment").double == -Double.infinity)
        #expect(try yaml("-.inf -.inf") == "-.inf -.inf")

        #expect(try yaml(".nan") != .double(Double.nan))
        #expect(try yaml(".nan").double!.isNaN)
        #expect(try yaml(".NaN").double!.isNaN)
        #expect(try yaml(".NAN").double!.isNaN)
        #expect(try yaml(".Nan").double == nil)
        #expect(try yaml(".nan#") == ".nan#")
        #expect(try yaml(".nan# string") == ".nan# string")
        #expect(try yaml(".nan # comment").double!.isNaN)
        #expect(try yaml(".nan .nan") == ".nan .nan")

        #expect(try yaml("0.") == .double(0))
        #expect(try yaml(".0").double == 0)
        #expect(try yaml("+0.") == 0.0)
        #expect(try yaml("+.0") == 0.0)
        #expect(try yaml("+.") != 0.0)
        #expect(try yaml("-0.") == 0.0)
        #expect(try yaml("-.0") == 0.0)
        #expect(try yaml("-.") != 0)
        #expect(try yaml("2.") == 2.0)
        /* Disabled for Linux */
#if !os(Linux) && !os(Android)
        #expect(try yaml(".2") == 0.2)
        #expect(try yaml("+2.") == 2.0)
        #expect(try yaml("+.2") == 0.2)
        #expect(try yaml("-2.") == -2.0)
        #expect(try yaml("-.2") == -0.2)
        #expect(try yaml("1.23015e+3") == 1.23015e+3)
        #expect(try yaml("12.3015e+02") == 12.3015e+02)
        #expect(try yaml("1230.15") == 1230.15)
        #expect(try yaml("+1.23015e+3") == 1.23015e+3)
        #expect(try yaml("+12.3015e+02") == 12.3015e+02)
        #expect(try yaml("+1230.15") == 1230.15)
        #expect(try yaml("-1.23015e+3") == -1.23015e+3)
        #expect(try yaml("-12.3015e+02") == -12.3015e+02)
        #expect(try yaml("-1230.15") == -1230.15)
        #expect(try yaml("-01230.15") == -1230.15)
        #expect(try yaml("-12.3015e02") == -12.3015e+02)
#endif

        #expect(try yaml("2") == 2)
        #expect(try yaml("2.0") == 2.0)
        #expect(try yaml("2.5") == 2.5)
        #expect(try yaml("2.5").integer == nil)

        let value1: YAML = 0.2
        #expect(value1 == 0.2)
        #expect(value1.double == 0.2)
    }

    @Test func testString() throws {
        #expect(try yaml("Behrang") == .string("Behrang"))
        #expect(try yaml("\"Behrang\"") == .string("Behrang"))
        #expect(try yaml("\"B\\\"ehran\\\"g\"") == .string("B\"ehran\"g"))
        #expect(try yaml("Behrang Noruzi Niya").string ==
                  "Behrang Noruzi Niya")
        #expect(try yaml("Radin Noruzi Niya") == "Radin Noruzi Niya")
        #expect(try yaml("|") == "")
        #expect(try yaml("| ") == "")
        #expect(try yaml("|  # comment") == "")
        #expect(try yaml("|  # comment\n") == "")

        #expect(throws: (any Error).self) { try yaml("|\nRadin") }
        #expect(try yaml("|\n Radin") == "Radin")
        #expect(try yaml("|  \n Radin") == "Radin")
        #expect(try yaml("|  # comment\n Radin") == "Radin")
        #expect(try yaml("|\n  Radin") == "Radin")
        #expect(try yaml("|2\n  Radin") == "Radin")
        #expect(try yaml("|1\n  Radin") == " Radin")
        #expect(try yaml("|1\n\n  Radin") == "\n Radin")
        #expect(try yaml("|\n\n  Radin") == "\nRadin")
        #expect((try? yaml("|3\n\n  Radin")) == nil)
        #expect((try? yaml("|3\n    \n   Radin")) == nil)
        #expect(try yaml("|3\n   \n   Radin") == "\nRadin")
        #expect(try yaml("|\n  \n\n \n  Radin\n\n \n\n  Noruzi Niya") ==
                  "\n\n\nRadin\n\n\n\nNoruzi Niya")
        #expect(try yaml("|\n  \n\n \n  Radin\n\n \n\n  Noruzi Niya\n  #1") ==
                  "\n\n\nRadin\n\n\n\nNoruzi Niya\n#1")
        #expect(try yaml("|\n  \n\n \n  Radin\n\n \n\n  Noruzi Niya\n  #1" +
                                 "\n # Comment") == "\n\n\nRadin\n\n\n\nNoruzi Niya\n#1\n")
        #expect(try yaml("|\n Radin\n") == "Radin\n")
        #expect(try yaml("|\n Radin\n\n") == "Radin\n")
        #expect(try yaml("|\n Radin\n \n ") == "Radin\n")
        #expect(try yaml("|\n Radin\n  \n  ") == "Radin\n")
        #expect(try yaml("|-\n Radin\n  \n  ") == "Radin")
        #expect(try yaml("|+\n Radin\n") == "Radin\n")
        #expect(try yaml("|+\n Radin\n\n") == "Radin\n\n")
        #expect(try yaml("|+\n Radin\n \n ") == "Radin\n\n")
        #expect(try yaml("|+\n Radin\n  \n  ") == "Radin\n \n ")
        #expect(try yaml("|2+\n  Radin\n  \n  ") == "Radin\n\n")
        #expect(try yaml("|+2\n  Radin\n  \n  ") == "Radin\n\n")
        #expect(try yaml("|-2\n  Radin\n  \n  ") == "Radin")
        #expect(try yaml("|2-\n  Radin\n  \n  ") == "Radin")
        #expect(throws: (any Error).self) { try yaml("|22\n  Radin\n  \n  ") }
        #expect(throws: (any Error).self) { try yaml("|--\n  Radin\n  \n  ") }
        #expect(try yaml(">+\n  trimmed\n  \n \n\n  as\n  space\n\n   \n") ==
                  "trimmed\n\n\nas space\n\n \n")
        #expect(try yaml(">-\n  trimmed\n  \n \n\n  as\n  space") ==
                  "trimmed\n\n\nas space")
        #expect(try yaml(">\n  foo \n \n  \t bar\n\n  baz\n") ==
                  "foo \n\n\t bar\n\nbaz\n")

        #expect(throws: (any Error).self) { try yaml(">\n  \n Behrang") }
        #expect(try yaml(">\n  \n  Behrang") == "\nBehrang")
        #expect(try yaml(">\n\n folded\n line\n\n next\n line\n   * bullet\n\n" +
                                 "   * list\n   * lines\n\n last\n line\n\n# Comment") ==
            .string("\nfolded line\nnext line\n  * bullet\n\n  * list\n  * lines" +
                    "\n\nlast line\n"))

        #expect(try yaml("\"\n  foo \n \n  \t bar\n\n  baz\n\"") ==
                  " foo\nbar\nbaz ")
        #expect(try yaml("\"folded \nto a space,\t\n \nto a line feed," +
                                 " or \t\\\n \\ \tnon-content\"") ==
                  "folded to a space,\nto a line feed, or \t \tnon-content")
        #expect(try yaml("\" 1st non-empty\n\n 2nd non-empty" +
                                 " \n\t3rd non-empty \"") ==
                  " 1st non-empty\n2nd non-empty 3rd non-empty ")

        #expect(try yaml("'here''s to \"quotes\"'") == "here's to \"quotes\"")
        #expect(try yaml("' 1st non-empty\n\n 2nd non-empty" +
                                 " \n\t3rd non-empty '") ==
                  " 1st non-empty\n2nd non-empty 3rd non-empty ")

        #expect(try yaml("x\n y\nz") == "x y z")
        #expect(try yaml(" x\ny\n z") == "x y z")
        #expect(try yaml("a: x\n y\n  z") == ["a": "x y z"])
        #expect(throws: (any Error).self) { try yaml("a: x\ny\n  z") }
        #expect(try yaml("- a: x\n   y\n    z") == [["a": "x y z"]])
        #expect(try yaml("- a:\n   x\n    y\n   z") == [["a": "x y z"]])
        #expect(try yaml("- a:     \n   x\n    y\n   z") == [["a": "x y z"]])
        #expect(try yaml("- a: # comment\n   x\n    y\n   z") ==
                  [["a": "x y z"]])

        let value1: YAML = "Radin"
        #expect(value1 == "Radin")
        #expect(value1.string == "Radin")

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
        #expect(value2.count == 6)
        #expect(value2[0] == "::vector")
        #expect(value2[5]?[0] == "::vector")
        #expect(value2[5]?[4] == "http://example.com/foo#bar")
    }

    @Test func testDictionary() throws {
        #expect(try #".object([.string("x"): .integer(1)])"# == yaml(#"x: 1"#).description)

        // TODO: integer and boolean keys
        //XCTAssertEqual(#".object([.integer(2): .integer(1)])"#, try yaml(#"2: 1"#).description)
        //XCTAssertEqual(#".object([.boolean(false): .integer(1)])"#, try yaml(#"false: 1"#).description)

        #expect(try yaml(#"{"x": 1}"#) == ["x":1])
        #expect(try yaml(#"x: 1"#) == ["x":1])
        //XCTAssertEqual(try yaml(#"1: 1"#), [YAML.Scalar(.init(1)):1])
    }

    @Test func testFlowSeq() throws {
        #expect(try yaml("[]") == .array([]))
        #expect(try yaml("[]").count == 0)
        #expect(try yaml("[ true ]") == [YAML.true])
        #expect(try yaml("[ true ]") == .array([true]))
        #expect(try yaml("[ true ]") == [true])
        #expect(try yaml("[ true ]")[0] == true)
        #expect(try yaml("[true, false, true]") == [true, false, true])
        #expect(try yaml("[Behrang, Radin]") == ["Behrang", "Radin"])
        #expect(try yaml("[true, [false, true]]") == [true, [false, true]])
        #expect(try yaml("[true, true  ,false,  false  ,  false]") ==
                  [true, true, false, false, false])
        #expect(try yaml("[true, .NaN]") != [true, .double(Double.nan)])
        #expect(try yaml("[~, null, TRUE, False, .INF, -.inf, 0, 123, -456" +
                                 ", 0o74, 0xFf, 1.23, -4.5]") ==
                  [nil, nil, true, false,
                   .double(Double.infinity), .double(-Double.infinity),
                   0, 123, -456, 60, 255, 1.23, -4.5])
        #expect(throws: (any Error).self) { try yaml("x:\n y:\n  z: [\n1]") }
        #expect(throws: (any Error).self) { try yaml("x:\n y:\n  z: [\n  1]") }
        #expect(try yaml("x:\n y:\n  z: [\n   1]") == ["x": ["y": ["z": [1]]]])
    }

    @Test func testBlockSeq() throws {
        #expect(try yaml("- 1\n- 2") == [1, 2])
        #expect(try yaml("- 1\n- 2")[1] == 2)
        #expect(try yaml("- x: 1") == [["x": 1]])
        #expect(try yaml("- x: 1\n  y: 2")[0] == ["x": 1, "y": 2])
        #expect(try yaml("- 1\n    \n- x: 1\n  y: 2") == [1, ["x": 1, "y": 2]])
        #expect(try yaml("- x:\n  - y: 1") == [["x": [["y": 1]]]])
    }

    @Test func testFlowMap() throws {
        #expect(try yaml("{}") == [:])
        #expect(try yaml("{\"x\":1}")["x"] == 1)
        #expect(try yaml("{x: 1}") == ["x": 1])
        #expect(throws: (any Error).self) { try yaml("{x: 1, x: 2}") }
        #expect(try yaml("{x: 1}")["x"] == 1)
        #expect(throws: (any Error).self) { try yaml("{x:1}") }
        #expect(try yaml("{\"x\":1, 'y': true}")["y"] == true)
        #expect(try yaml("{\"x\":1, 'y': true, z: null}")["z"] == .null)
        #expect(try yaml("{first name: \"Behrang\"," +
                                 " last name: 'Noruzi Niya'}") ==
                  ["first name": "Behrang", "last name": "Noruzi Niya"])
        #expect(try yaml("{fn: Behrang, ln: Noruzi Niya}")["ln"] ==
                  "Noruzi Niya")
        #expect(try yaml("{fn: Behrang\n ,\nln: Noruzi Niya}")["ln"] ==
                  "Noruzi Niya")
    }

    @Test func testBlockMap() throws {
        #expect(try yaml("x: 1\ny: 2") == YAML.object(["x": .integer(1), "y": .integer(2)]))
        #expect(throws: (any Error).self) { try yaml("x: 1\nx: 2") }
        #expect(try yaml("x: 1\n? y\n: 2") == ["x": 1, "y": 2])
        #expect(throws: (any Error).self) { try yaml("x: 1\n? x\n: 2") }
        #expect(throws: (any Error).self) { try yaml("x: 1\n?  y\n:\n2") }
        #expect(try yaml("x: 1\n?  y\n:\n 2") == ["x": 1, "y": 2])
        #expect(try yaml("x: 1\n?  y") == ["x": 1, "y": nil])
        #expect(try yaml("?  y") == ["y": nil])
        #expect(try yaml(" \n  \n \n  \n\nx: 1  \n   \ny: 2" +
                                 "\n   \n  \n ")["y"] == 2)
        #expect(try yaml("x:\n a: 1 # comment \n b: 2\ny: " +
                                 "\n  c: 3\n  ")["y"]?["c"] == 3)
        #expect(try yaml("# comment \n\n  # x\n  # y \n  \n  x: 1" +
                                 "  \n  y: 2") == ["x": 1, "y": 2])
    }

    @Test func testDirectives() throws {
        #expect(throws: (any Error).self) { try yaml("%YAML 1.2\n1") }
        #expect(try yaml("%YAML   1.2\n---1") == 1)
        #expect(try yaml("%YAML   1.2  #\n---1") == 1)
        #expect(throws: (any Error).self) { try yaml("%YAML   1.2\n%YAML 1.2\n---1") }
        #expect(throws: (any Error).self) { try yaml("%YAML 1.0\n---1") }
        #expect(throws: (any Error).self) { try yaml("%YAML 1\n---1") }
        #expect(throws: (any Error).self) { try yaml("%YAML 1.3\n---1") }
        #expect(throws: (any Error).self) { try yaml("%YAML \n---1") }
    }

    @Test func testReserves() throws {
        #expect(throws: (any Error).self) { try yaml("`reserved") }
        #expect(throws: (any Error).self) { try yaml("@behrangn") }
        #expect(throws: (any Error).self) { try yaml("twitter handle: @behrangn") }
    }

    @Test func testAliases() throws {
        #expect(try yaml("x: &a 1\ny: *a") == ["x": 1, "y": 1])
        #expect(throws: (any Error).self) { try yamlMulti("x: &a 1\ny: *a\n---\nx: *a") }
        #expect(throws: (any Error).self) { try yaml("x: *a") }
    }

    @Test func testUnicodeSurrogates() throws {
        #expect(try yaml("x: Dog‼🐶\ny: 𝒂𝑡") == ["x": "Dog‼🐶", "y": "𝒂𝑡"])
    }


    // MARK: Example Tests

    @Test func testExample0() throws {
        var value = try yaml(
            "- just: write some\n" +
            "- yaml: \n" +
            "  - [here, and]\n" +
            "  - {it: updates, in: real-time}\n"
        )
        #expect(value.count == 2)
        #expect(value[0]?["just"] == "write some")
        #expect(value[1]?["yaml"]?[0]?[1] == "and")
        #expect(value[1]?["yaml"]?[1]?["in"] == "real-time")

        #expect(value == [
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

        value = nil
        #expect(value == nil)
    }

    @Test func testExample1() throws {
        let value = try yaml(
            "- Mark McGwire\n" +
            "- Sammy Sosa\n" +
            "- Ken Griffey\n"
        )
        #expect(value.count == 3)
        #expect(value[1] == "Sammy Sosa")
        #expect(value == [
            "Mark McGwire",
            "Sammy Sosa",
            "Ken Griffey",
        ])
    }

    @Test func testExample2() throws {
        let value = try yaml(
            "hr:  65    # Home runs\n" +
            "avg: 0.278 # Batting average\n" +
            "rbi: 147   # Runs Batted In\n"
        )
        #expect(value.count == 3)
        #expect(value["avg"] == 0.278)

        #expect(value == [
            "hr": 65,
            "avg": 0.278,
            "rbi": 147,
        ])

    }

    @Test func testExample3() throws {
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
        #expect(value.count == 2)
        #expect(value["national"]?.count == 3)
        #expect(value["national"]?[2] == "Atlanta Braves")

        #expect(value == [
            "american": ["Boston Red Sox", "Detroit Tigers", "New York Yankees"],
            "national": ["New York Mets", "Chicago Cubs", "Atlanta Braves"],
        ])
    }

    @Test func testExample4() throws {
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
        #expect(value.count == 2)
        #expect(abs((value[1]?["avg"]?.double ?? .nan) - 0.288) < 0.00001)

        #expect(value == [
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

    @Test func testExample5() throws {
        let value = try yaml(
            "- [name        , hr, avg  ]\n" +
            "- [Mark McGwire, 65, 0.278]\n" +
            "- [Sammy Sosa  , 63, 0.288]\n"
        )
        #expect(value.count == 3)
        #expect(value[2]?.count == 3)
        #expect(abs((value[2]?[2]?.double ?? .nan) - 0.288) < 0.00001)
    }

    @Test func testExample6() throws {
        let value = try yaml(
            "Mark McGwire: {hr: 65, avg: 0.278}\n" +
            "Sammy Sosa: {\n" +
            "    hr: 63,\n" +
            "    avg: 0.288\n" +
            "  }\n"
        )
        #expect(value["Mark McGwire"]?["hr"] == 65)
        #expect(value["Sammy Sosa"]?["hr"] == 63)
    }

    @Test func testExample7() throws {
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
        #expect(value.count == 2)
        #expect(value[0].count == 3)
        #expect(value[0][1] == "Sammy Sosa")
        #expect(value[1].count == 2)
        #expect(value[1][1] == "St Louis Cardinals")
    }

    @Test func testExample8() throws {
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
        #expect(value.count == 2)
        #expect(value[0]["player"] == "Sammy Sosa")
        #expect(value[0]["time"] == 72200)
        #expect(value[1]["player"] == "Sammy Sosa")
        #expect(value[1]["time"] == 72227)
    }

    @Test func testExample9() throws {
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
        #expect(value["hr"]?[1] == "Sammy Sosa")
        #expect(value["rbi"]?[1] == "Ken Griffey")
    }

    @Test func testExample10() throws {
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
        #expect(value["hr"]?.count == 2)
        #expect(value["hr"]?[1] == "Sammy Sosa")
        #expect(value["rbi"]?.count == 2)
        #expect(value["rbi"]?[0] == "Sammy Sosa")
    }

    @Test func testExample11() throws {
        _ = try yaml(
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
    }

    @Test func testExample12() throws {
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
        #expect(value.count == 3)
        #expect(value[1]?.count == 2)
        #expect(value[1]?["item"] == "Basketball")
        #expect(value[1]?["quantity"] == 4)
        _ = try yaml("quantity")
    }

    @Test func testExample13() throws {
        let value = try yaml(
            "# ASCII Art\n" +
            "--- |\n" +
            "  \\//||\\/||\n" +
            "  // ||  ||__\n"
        )
        #expect(value == "\\//||\\/||\n// ||  ||__\n")
    }

    @Test func testExample14() throws {
        let value = try yaml(
            "--- >\n" +
            "  Mark McGwire's\n" +
            "  year was crippled\n" +
            "  by a knee injury.\n"
        )
        #expect(value == "Mark McGwire's year was crippled by a knee injury.\n")
    }

    @Test func testExample15() throws {
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
        #expect(value == .string("Sammy Sosa completed another fine season with great stats.\n\n" +
                    "  63 Home Runs\n  0.288 Batting Average\n\nWhat a year!\n"))
    }

    @Test func testExample16() throws {
        let value = try yaml(
            "name: Mark McGwire\n" +
            "accomplishment: >\n" +
            "  Mark set a major league\n" +
            "  home run record in 1998.\n" +
            "stats: |\n" +
            "  65 Home Runs\n" +
            "  0.278 Batting Average\n"
        )
        #expect(value["accomplishment"] == "Mark set a major league home run record in 1998.\n")
        #expect(value["stats"] == "65 Home Runs\n0.278 Batting Average\n")
    }

    @Test func testExample17() throws {
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
        // #expect(value["unicode"] == "Sosa did fine.\u{263A}")
        #expect(value["control"] == "\u{8}1998\t1999\t2000\n")
        // FIXME: Failing with Xcode8b6
        // #expect(value["hex esc"] == "\u{d}\u{a} is \r\n")
        #expect(value["single"] == "\"Howdy!\" he cried.")
        #expect(value["quoted"] == " # Not a 'comment'.")
        #expect(value["tie-fighter"] == "|\\-*-/|")
    }

    @Test func testExample18() throws {
        let value = try yaml(
            "plain:\n" +
            "  This unquoted scalar\n" +
            "  spans many lines.\n" +
            "\n" +
            "quoted: \"So does this\n" +
            "  quoted scalar.\\n\"\n"
        )
        #expect(value.count == 2)
        #expect(value["plain"] == "This unquoted scalar spans many lines.")
        #expect(value["quoted"] == "So does this quoted scalar.\n")
    }

    @Test func testExample19() throws {
        let value = try yaml(
            "canonical: 12345\n" +
            "decimal: +12345\n" +
            "octal: 0o14\n" +
            "hexadecimal: 0xC\n"
        )
        #expect(value.count == 4)
        #expect(value["canonical"] == 12345)
        #expect(value["decimal"] == 12345)
        #expect(value["octal"] == 12)
        #expect(value["hexadecimal"] == 12)
    }

    @Test func testExample20() throws {
        let value = try yaml(
            "canonical: 1.23015e+3\n" +
            "exponential: 12.3015e+02\n" +
            "fixed: 1230.15\n" +
            "negative infinity: -.inf\n" +
            "not a number: .NaN\n"
        )
        #expect(value.count == 5)
        /* Disabled for Linux */
#if !os(Linux) && !os(Android)
        #expect(value["canonical"] == 1.23015e+3)
        #expect(value["exponential"] == 1.23015e+3)
        #expect(value["fixed"] == 1.23015e+3)
#endif
        #expect(value["negative infinity"] == .double(-Double.infinity))
        #expect(value["not a number"]?.double?.isNaN == true)
    }

    @Test func testExample21() throws {
        let value = try yaml(
            "null:\n" +
            "booleans: [ true, false ]\n" +
            "string: '012345'\n"
        )
        #expect(value.count == 3)
        #expect(value["null"] == .null)
        #expect(value["booleans"] == [true, false])
        #expect(value["string"] == "012345")
    }

    @Test func testExample22() throws {
        let value = try yaml(
            "canonical: 2001-12-15T02:59:43.1Z\n" +
            "iso8601: 2001-12-14t21:59:43.10-05:00\n" +
            "spaced: 2001-12-14 21:59:43.10 -5\n" +
            "date: 2002-12-14\n"
        )
        #expect(value.count == 4)
        #expect(value["canonical"] == "2001-12-15T02:59:43.1Z")
        #expect(value["iso8601"] == "2001-12-14t21:59:43.10-05:00")
        #expect(value["spaced"] == "2001-12-14 21:59:43.10 -5")
        #expect(value["date"] == "2002-12-14")
    }

    static let exampleYaml = """
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

    @Test func testYamlHomepage() throws {
        let value = try yaml(YAMLTests.exampleYaml)
        #expect(value.count == 6)
        #expect(value["YAML"] == "YAML Ain't Markup Language")
        #expect(value["What It Is"] == "YAML is a human friendly data serialization standard for all programming languages.")
        #expect(value["YAML Resources"]?.count == 8)
        #expect(value["YAML Resources"]?["YAML 1.2 (3rd Edition)"] ==
                  "http://yaml.org/spec/1.2/spec.html")
        #expect(value["YAML Resources"]?["YAML IRC Channel"] ==
                  "#yaml on irc.freenode.net")
        #expect(value["Projects"]?.count == 12)
        #expect(value["Projects"]?["C/C++ Libraries"]?[2] == "yaml-cpp")
        #expect(value["Projects"]?["Perl Modules"]?.count == 5)
        #expect(value["Projects"]?["Perl Modules"]?[0] == "YAML")
        #expect(value["Projects"]?["Perl Modules"]?[1] == "YAML::XS")
        #expect(value["Related Projects"]?.count == 6)
        #expect(value["News"]?.count == 2)
    }

    @Test func testPerformanceExample() throws {
        _ = try? yaml(YAMLTests.exampleYaml)
    }
}
