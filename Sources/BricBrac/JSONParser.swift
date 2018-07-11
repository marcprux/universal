//
//  JSONParser.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 8/20/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

/// A non-recursive streaming parser for JSON (ECMA-404). The parser operates by being fed a complete or 
/// partial sequence of `UnicodeScalar`s and emits events for every JSON syntax component that is encountered.
public final class JSONParser {

    /// An event that is emitted during parsing
    public enum Event : CustomDebugStringConvertible {
        /// The start of an array was encountered (i.e. `[`)
        case arrayStart([UnicodeScalar])
        /// The end of an array was encountered (i.e. `]`)
        case arrayEnd([UnicodeScalar])
        /// The start of an object was encountered (i.e. `{`)
        case objectStart([UnicodeScalar])
        /// The end of an object was encountered (i.e. `}`)
        case objectEnd([UnicodeScalar])
        /// A separator between Array or Object elements was encountered (i.e. `,`)
        case elementSeparator([UnicodeScalar])
        /// A separator between an Object's key and value was encountered (i.e. `:`)
        case keyValueSeparator([UnicodeScalar])
        /// A string was begun (i.e. `"`)
        case stringStart([UnicodeScalar])
        /// Some unescaped string contents was emitted with the given escape indices
        /// - SeeAlso: `unescape`
        case stringContent([UnicodeScalar], [Int])
        /// The string was closed (i.e. `"`)
        case stringEnd([UnicodeScalar])
        /// A complete number was processed
        case number([UnicodeScalar])
        /// The `true` literal was encountered
        case `true`([UnicodeScalar])
        /// The `false` literal was encountered
        case `false`([UnicodeScalar])
        /// The `null` literal was encountered
        case null([UnicodeScalar])
        /// Some whitespace happened
        case whitespace([UnicodeScalar])

        public var debugDescription: Swift.String {
            switch self {
            case .arrayStart: return "ArrayStart"
            case .arrayEnd: return "ArrayEnd"
            case .objectStart: return "ObjectStart"
            case .objectEnd: return "ObjectEnd"
            case .elementSeparator: return "ElementSeparator"
            case .keyValueSeparator: return "KeyValueSeparator"
            case .stringStart: return "StringStart"
            case .stringContent: return "StringContent"
            case .stringEnd: return "StringEnd"
            case .number: return "Number"
            case .`true`: return "True"
            case .`false`: return "False"
            case .null: return "Null"
            case .whitespace: return "Whitespace"
            }
        }

        /// Returns the underlying array of unicode scalars represented by this instance
        public var value: [UnicodeScalar] {
            switch self {
            case .arrayStart(let s): return s
            case .arrayEnd(let s): return s
            case .objectStart(let s): return s
            case .objectEnd(let s): return s
            case .elementSeparator(let s): return s
            case .keyValueSeparator(let s): return s
            case .stringStart(let s): return s
            case .stringContent(let s, _): return s
            case .stringEnd(let s): return s
            case .number(let s): return s
            case .`true`(let s): return s
            case .`false`(let s): return s
            case .null(let s): return s
            case .whitespace(let s): return s
            }
        }


        // cache of singleton scalar constants for fast delegate passing
        fileprivate static let arrayStartScalars: [UnicodeScalar] = ["["]
        fileprivate static let arrayEndScalars: [UnicodeScalar] = ["]"]
        fileprivate static let objectStartScalars: [UnicodeScalar] = ["{"]
        fileprivate static let objectEndScalars: [UnicodeScalar] = ["}"]
        fileprivate static let stringStartScalars: [UnicodeScalar] = ["\""]
        fileprivate static let stringEndScalars: [UnicodeScalar] = ["\""]
        fileprivate static let elementSeparatorScalars: [UnicodeScalar] = [","]
        fileprivate static let keyValueSeparatorScalars: [UnicodeScalar] = [":"]
        fileprivate static let nullScalars: [UnicodeScalar] = ["n", "u", "l", "l"]
        fileprivate static let trueScalars: [UnicodeScalar] = ["t", "r", "u", "e"]
        fileprivate static let falseScalars: [UnicodeScalar] = ["f", "a", "l", "s", "e"]
    }

    /// Customization of the JSON parson process
    public struct Options : OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) { self.rawValue = rawValue }

        /// Permit arrays and objects to end with a trailing comma
        public static let AllowTrailingCommas = Options(rawValue: 1)

        /// Permit numbers to start with a zero
        public static let AllowLeadingZeros = Options(rawValue: 2)

        /// Permit non-whitespace trailing content
        public static let AllowTrailingContent = Options(rawValue: 3)

        /// Permit strings to contain unescaped tab characters
        public static let AllowTabsInStrings = Options(rawValue: 4)

        /// Permit strings to contain unescaped newine characters
        public static let AllowNewlinesInStrings = Options(rawValue: 5)

        public static let Strict: Options = []
        public static let Lenient: Options = [.AllowTrailingCommas, .AllowLeadingZeros, .AllowTrailingContent, .AllowTabsInStrings, .AllowNewlinesInStrings]

        public static let CocoaCompat: Options = [.AllowTrailingCommas]
        
        public static let Default = Strict
    }
    
    

    /// Number parsing state
    typealias NumberParse = (loc: Int, exponent: Int?, fraction: Int?, digitCount: Int, trailingDigits: Int, leadingZeros: Int, signed: Bool)

    /// String parsing state contains an array of the escape indices
    typealias StringParse = ([Int])

    fileprivate enum State {
        case idle, string(StringParse), number(NumberParse), literal, arrayOpen, arrayElement, objectOpen, objectKey, objectElement

        var isValue: Bool {
            switch self {
            case .arrayElement, .objectElement, .string, .number, .literal: return true
            default: return false
            }
        }

        var isContainer: Bool {
            switch self {
            case .arrayElement, .objectElement: return true
            default: return false
            }
        }
    }

    /// Options for parsing
    fileprivate let options: Options

    /// The delegate that will receive callback events
    public var delegate: (Event) throws -> ()

    /// The current row and column of the parser (for error reporting purposes)
    public fileprivate(set) var row = 1, col = 0

    /// The current state
    fileprivate var state = State.idle

    /// The current processing result, such as a number being parsed or a string being assembled
    fileprivate var processing = State.idle

    /// The current pending result, such as a parsed string that is waiting to be added to an array
    fileprivate var pending = State.idle

    /// The current container (and array or object)
    fileprivate var container = State.idle

    /// The current stack of container states (arrays and objects)
    fileprivate var stack: [State] = []

    fileprivate var trailingComma = false

    /// The current buffer for a running string, number, or true/false/null literal
    fileprivate var buffer: Array<UnicodeScalar> = []

    public init(options: Options, delegate: @escaping (Event) throws -> () = { _ in }) {
        self.options = options
        self.delegate = delegate
    }


    fileprivate func pushContainer(_ parse: State, _ value: State) throws {
        stack.append(state)
        if container.isContainer {
            stack.append(container)
        }
        container = value // e.g., .arr(createArray())
        state = parse // .ArrayStart
        pending = .idle

        if case .objectOpen = state {
            try delegate(.objectStart(Event.objectStartScalars))
        } else if case .arrayOpen = state {
            try delegate(.arrayStart(Event.arrayStartScalars))
        }
    }

    fileprivate func popContainer() throws {
        let x = stack.removeLast()

        if case .objectElement = container {
            try delegate(.objectEnd(Event.objectEndScalars))
        } else if case .arrayElement = container {
            try delegate(.arrayEnd(Event.arrayEndScalars))
        }

        pending = container
        if x.isContainer {
            container = x
            state = stack.removeLast()
        } else {
            container = .idle
            state = x
        }
    }

    fileprivate func err(_ msg: String) -> ParseError {
        return ParseError(msg: msg, line: row, column: col)
    }

    fileprivate func pushObjectKey() throws {
        if stack.isEmpty { throw err("Object key assignment with no container") }
        if !pending.isValue { throw err("Object key assignment with no value") }
        guard case .objectElement = container else { throw err("Object key assignment outside of object") }
        container = .objectElement
        state = stack.removeLast()
    }

    fileprivate func appendArrayValue() throws {
        if pending.isValue {
            if case .arrayElement = container {
                container = .arrayElement
            } else {
                throw err("Array append outside of array")
            }
        }

        pending = .idle
    }

    fileprivate func clearBuffer() {
        buffer.removeAll(keepingCapacity: true)
    }

    fileprivate func flushString() throws {
        if case .string(let escapes) = processing {
            try delegate(.stringContent(buffer, escapes))
            pending = .string(escapes)
            clearBuffer()
        }
        processing = .idle
    }

    /// Takes any outstanding number buffer and flushes it
    fileprivate func flushNumber() throws {
        guard case .number(let num) = processing else { return }

        try delegate(.number(buffer))

        if num.digitCount == 0 { throw err("Expected a digit, got: \(buffer)") }

        // we can only have a leading number with 0.1 and -0.5; 00.3 and -000.7 are illegal
        if num.leadingZeros > 0 && num.digitCount > 1 && num.fraction != (num.signed ? 2 : 1) && !options.contains(.AllowLeadingZeros) {
            throw err("Leading zero in number")
        }

        if num.trailingDigits == 0 { throw err("Number did not end in a digit") }
        pending = .number(num)
        clearBuffer()
        self.processing = .idle
    }
    
    
    @discardableResult public func parseString(_ string: String) throws -> Int {
        return try parse(string.unicodeScalars, complete: true)
    }

    @discardableResult public func parseArray(_ scalars: Array<UnicodeScalar>) throws -> Int {
        return try parse(scalars, complete: true)
    }

    /// Feeds a single scalar to the parser
    ///
    /// - SeeAlso: `parse`
    @discardableResult public func parseScalar(_ scalar: UnicodeScalar) throws -> Int {
        return try parse(CollectionOfOne(scalar), complete: false)
    }

    /// Feeds some scalars to the parser, triggering delegate callbacks for each parse event that occurs,
    /// returning the number of scalars consumed once a parse unit is complete (quoted string, closed container, 
    /// or recognized literal, but not a number which has no closing character)
    /// 
    /// - parameter scalars: The scalars to parse
    ///
    /// - parameter complete: If `true`, the scalars parameter completes the JSON document
    ///
    /// - Returns: The number of scalars that were consumed during the parse operation
    @discardableResult public func parse<S: Sequence>(_ scalars: S, complete: Bool = false) throws -> Int where S.Iterator.Element == UnicodeScalar {
        var index = 0

        func processingNumber() -> Bool { if case .number = processing { return true } else { return false } }
        func processingString() -> Bool { if case .string = processing { return true } else { return false } }

        var completing = false
        func completeBuffer() throws {
            completing = true

            if complete {
                try flushNumber() // flush any pending number if one exists

                if !options.contains(.AllowTrailingContent) {
                    if !stack.isEmpty { throw err("Unclosed container") }

                    // ensure that all that remains in whitespace in the buffer and the generator
                    for trailing in buffer {
                        if !trailing.isJSONWhitespace { throw err("Trailing content") }
                        try delegate(.whitespace([trailing]))
                    }
                    buffer.removeAll(keepingCapacity: false)
                }

                // make sure we had at least one valid JSON item
                if !pending.isValue { throw err("No valid JSON items") }
            }
        }

        for scalar in scalars {
            index += 1
            let sval = scalar.value

            // track the current line for error reporting purposes
            if sval == 0x000A {
                row += 1
                col = 0
            } else {
                col += 1
            }

            if !completing {
                if trailingComma && !processingString() && !scalar.isJSONWhitespace {
                    trailingComma = false

                    /// Ensure that there is no trailing comma before a container close
                    if !options.contains(.AllowTrailingCommas) && !scalar.isJSONWhitespace {
                        if sval == (0x5D) || sval == (0x7D) { throw err("Trailing comma") }
                    }
                }

                // if there are any outstanding numbers then process them
                // note that open numbers are different than open strings because we always know when a string
                // is closed (because it has an unescaped quote), whereas a number is only processed once we hit a
                // non-numeric character
                if case .number(var num) = processing {
                    num.loc += 1

                    switch sval {
                    case 0x30...0x39: // digit
                        if sval == 0x30 && num.leadingZeros == num.digitCount && num.fraction == nil {
                            num.leadingZeros += 1 // count the number of leading zeros for validation later
                        }
                        num.digitCount += 1
                        num.trailingDigits += 1
                        processing = .number(num)
                        buffer.append(scalar)
                        continue
                    case 0x2E: // .
                        if num.fraction != nil {
                            throw err("Too many dots in the number")
                        } else {
                            num.fraction = num.loc
                        }
                        num.trailingDigits = 0
                        processing = .number(num)
                        buffer.append(scalar)
                        continue
                    case 0x45, 0x65: // e E
                        if (num.exponent ?? 0) > 0 || num.digitCount == 0 {
                            throw err("Too many exponent signs in the number")
                        } else {
                            num.exponent = num.loc
                        }
                        num.trailingDigits = 0
                        processing = .number(num)
                        buffer.append(scalar)
                        continue
                    case 0x2B, 0x2D: // + -
                        if num.exponent != (num.loc - 1) {
                            throw err("Sign not following exponent")
                        }
                        num.trailingDigits = 0
                        processing = .number(num)
                        buffer.append(scalar)
                        continue
                    default:  // anything else: stop parsing the number
                        try flushNumber() // scalar not consummed: flush the number and fall through to further handling
                    }
                }


                switch sval {
                case _ where processingString(): // currently processing a string: append characters
                    if case .string(var escapeIndices) = processing {
                        func trailingEscapes() -> Int {
                            var slashes = 0
                            for c in buffer.reversed() {
                                if c == "\\" { slashes += 1 } else { break }
                            }
                            return slashes
                        }

                        if sval == 0x22 && trailingEscapes() % 2 == 0 { // close quote
                            try flushString()
                            try delegate(.stringEnd(Event.stringEndScalars))
                        } else {
                            if sval == 0x0009 && !options.contains(.AllowTabsInStrings) {
                                throw err("Strings may not contain tab characters")
                            } else if sval == 0x000A && !options.contains(.AllowNewlinesInStrings) {
                                throw err("Strings may not contain newlines")
                            }

                            if sval == 0x5C && trailingEscapes() % 2 == 0 {
                                // remember lone backslashes for eventual unescaping
                                escapeIndices.append(buffer.count + 1)
                            }

                            buffer.append(scalar)
                            processing = .string(escapeIndices)
                        }
                    }

                case 0x22: // open quote: start processing a string
                    if pending.isValue { throw err("String found with pending result value") }
                    processing = .string(StringParse([]))
                    try delegate(.stringStart(Event.stringEndScalars))

                case 0x0020, 0x0009, 0x000A, 0x000D: // space, tab, newline, carriage return
                    try delegate(.whitespace([scalar]))

                case 0x7B: // open curly brace
                    if case .objectOpen = state { throw err("Object start within object start") }
                    if pending.isValue { throw err("Object start with pending result value") }
                    try pushContainer(.objectOpen, .objectElement)

                case 0x5B: // open square bracket
                    if case .objectOpen = state { throw err("Array start within object start") }
                    if pending.isValue { throw err("Array start with pending result value") }
                    try pushContainer(.arrayOpen, .arrayElement)

                case 0x7D: // close curly brace
                    if case .objectKey = state {
                        try pushObjectKey()
                    }

                    if case .objectOpen = state {
                        try popContainer()
                    } else {
                        throw err("Unmatched close object brace")
                    }


                case 0x5D: // close square bracket
                    if case .arrayOpen = state {
                        try appendArrayValue()
                        try popContainer()
                    } else {
                        throw err("Unmatched close array brace")
                    }

                case 0x2C: // comma
                    if case .objectOpen = state { throw err("Comma within object start") }
                    if !pending.isValue { throw err("Comma found with no pending result") }

                    if case .objectKey = state { // : assignment
                        try pushObjectKey()
                        pending = .idle
                    } else if case .arrayOpen = state { // [ array
                        try appendArrayValue()
                    } else {
                        throw err("Comma not contained in array or object")
                    }

                    try delegate(.elementSeparator(Event.elementSeparatorScalars))
                    trailingComma = true

                case 0x3A: // colon
                    if case .objectOpen = state {
                        guard case .string = pending else { throw err("Missing object key") }
                        stack.append(state)
                        pending = .idle
                        state = .objectKey
                        try delegate(.keyValueSeparator(Event.keyValueSeparatorScalars))
                    } else {
                        throw err("Object key assignment outside of an object")
                    }

                case 0x30...0x39, 0x2B, 0x2D, 0x2E,
                     0x45 where processingNumber(),
                     0x65 where processingNumber(): // digit, +, -, (.), (e), (E)
                    if case .objectOpen = state { throw err("Number within object start") }
                    if pending.isValue { throw err("Number found with pending result value") }

                    if !processingNumber() {
                        let dc = sval >= 0x30 && sval <= 0x39 ? 1 : 0
                        let num: NumberParse = (0, nil, nil, dc, dc, sval == 0x30 ? 1 : 0, sval == 0x2D || sval == 0x2E)
                        processing = .number(num)
                    }

                    buffer.append(scalar)

                default:
                    if case .objectOpen = state { throw err("Invalid character within object start") }
                    if pending.isValue { throw err("Character found with pending result value") }

                    // finally, check for the JSON literals "true", "false", and "null"

                    buffer.append(scalar) // tack on to the current buffer to check for literals
                    var gen = buffer.makeIterator()
                    let lit = (gen.next(), gen.next(), gen.next(), gen.next(), gen.next())

                    switch lit {
                    case (.some("n"), .none, .none, .none, .none): break // n
                    case (.some("n"), .some("u"), .none, .none, .none): break // nu
                    case (.some("n"), .some("u"), .some("l"), .none, .none): break // nul
                    case (.some("n"), .some("u"), .some("l"), .some("l"), .none): // null
                        pending = .literal
                        try delegate(.null(Event.nullScalars))
                        clearBuffer()
                        break

                    case (.some("t"), .none, .none, .none, .none): break // t
                    case (.some("t"), .some("r"), .none, .none, .none): break // tr
                    case (.some("t"), .some("r"), .some("u"), .none, .none): break // tru
                    case (.some("t"), .some("r"), .some("u"), .some("e"), .none): // true
                        pending = .literal
                        try delegate(.`true`(Event.trueScalars))
                        clearBuffer()
                        break

                    case (.some("f"), .none, .none, .none, .none): break // f
                    case (.some("f"), .some("a"), .none, .none, .none): break // fa
                    case (.some("f"), .some("a"), .some("l"), .none, .none): break // fal
                    case (.some("f"), .some("a"), .some("l"), .some("s"), .none): break // fals
                    case (.some("f"), .some("a"), .some("l"), .some("s"), .some("e")): // false
                        pending = .literal
                        try delegate(.`false`(Event.falseScalars))
                        clearBuffer()
                        break

                    default:
                        clearBuffer()
                        throw err("Unrecognized token: \(scalar)")
                    }
                }

                if (!processingString() && !processingNumber() && stack.isEmpty && buffer.isEmpty) {
                    try completeBuffer() // no stack and no buffer: we are all done even if we have remaining characters
                    continue
                }
            } else if completing && complete {
                if scalar.isJSONWhitespace {
                    try delegate(.whitespace([scalar]))
                } else {
                    if !options.contains(.AllowTrailingContent) { throw err("Trailing content") }
                }
            } else {
                break // completing but we are not told to complete; break out and return
            }
        }

        if complete && !completing {
            try completeBuffer()
        }

        return index
    }

    /// Processes the given scalars as a JSON string, performing the appropriate unescaping and validation
    public static func unescape<C: RangeReplaceableCollection>(_ scalars: C, escapeIndices: [C.Index], line: Int, column: Int) throws -> C where C.Iterator.Element == UnicodeScalar {
        // when the string has no escapes, we can just pass it directly
        if escapeIndices.isEmpty { return scalars }

        let start = scalars.startIndex, end = scalars.endIndex

        // perform backslash escaping
        var slice = C()

        slice.reserveCapacity(scalars.distance(from: start, to: end))

        var loc = start
        var highSurrogate: UInt32? = nil

        for i in escapeIndices {
            slice.append(contentsOf: scalars[loc..<scalars.index(i, offsetBy: -1)])
            loc = i
            let s: UnicodeScalar = scalars[i]

            switch s.value {
            case 0x22: // " -> quote
                slice.append(s)
                loc = scalars.index(after: loc)
            case 0x5C: // \ -> backslash
                slice.append(s)
                loc = scalars.index(after: loc)
            case 0x2F: // / -> slash
                slice.append(s)
                loc = scalars.index(after: loc)
            case 0x62:  // \b -> backspace
                slice.append(UnicodeScalar(0x08))
                loc = scalars.index(after: loc)
            case 0x66: // \f -> formfeed
                slice.append(UnicodeScalar(0x0C))
                loc = scalars.index(after: loc)
            case 0x6e: // \n -> newline
                slice.append("\n")
                loc = scalars.index(after: loc)
            case 0x72: // \r -> carriage return
                slice.append("\r")
                loc = scalars.index(after: loc)
            case 0x74: // \t -> tab
                slice.append("\t")
                loc = scalars.index(after: loc)
            case 0x75: // \u -> unicode hex characters follow
                if scalars.distance(from: i, to: end) < 4 {
                    throw ParseError(msg: "Unterminated hex escape", line: line, column: column + scalars.distance(from: start, to: i))
                }

                var hex: UInt32 = 0
                let bh1: (UInt32, UInt32) = (UInt32(12), scalars[scalars.index(i, offsetBy: 1)].value)
                let bh2: (UInt32, UInt32) = (UInt32(8), scalars[scalars.index(i, offsetBy: 2)].value)
                let bh3: (UInt32, UInt32) = (UInt32(4), scalars[scalars.index(i, offsetBy: 3)].value)
                let bh4: (UInt32, UInt32) = (UInt32(0), scalars[scalars.index(i, offsetBy: 4)].value)
                for (b, h) in [bh1, bh2, bh3, bh4 ] {
                        switch h {
                        case 0x30...0x39: hex += (h - 0x30) << b // 0-9
                        case 0x41...0x46: hex += (10 + h - 0x41) << b // A-F
                        case 0x61...0x66: hex += (10 + h - 0x61) << b // a-f
                        default: throw ParseError(msg: "Invalid hex digit in unicode escape", line: line, column: column + scalars.distance(from: start, to: i))
                        }
                }

                if hex >= 0xD800 && hex <= 0xDBFF { // high surrogates
                    highSurrogate = hex // save the high surrogate and move along
                } else if hex >= 0xDC00 && hex <= 0xDFFF { // low surrogates
                    if let highSurrogate = highSurrogate {
                        let s1: UInt32 = (highSurrogate - 0xD800) << 10
                        let s2: UInt32 = hex - 0xDC00
                        let codepoint: UInt32 = s1 + s2 + 0x010000
                        slice.append(UnicodeScalar(codepoint)!)
                    } else {
                        throw ParseError(msg: "Low surrogate not preceeded by high surrogate", line: line, column: column + scalars.distance(from: start, to: i))
                    }
                    highSurrogate = nil
                } else if hex >= 0x0000 && hex <= 0xFFFF { // basic codeplane
                    slice.append(UnicodeScalar(hex)!)
                } else {
                    throw ParseError(msg: "Hex escape not in a valid codeplane", line: line, column: column + scalars.distance(from: start, to: i))
                }

                guard let loc2 = scalars.index(loc, offsetBy: 5, limitedBy: end) else { break } // skip past the escapes
                loc = loc2

            default:
                throw ParseError(msg: "Illegal string escape: \(s)", line: line, column: column + scalars.distance(from: start, to: i))
            }
        }

        slice.append(contentsOf: scalars[loc..<end]) // append the remainder
        return slice
    }
    
}

/// JSON utilities
///
/// - Note: The formatting methods are twice as fast when the code is included in
///   the same module as JSONParser, probably due to whole-module optimization
public extension JSONParser {

    /// Process the JSON String with optional formatting
    ///
    /// - parameter json: the source JSON string to process
    /// - parameter indent: the number of spaces to indent the output, zero for compact, nil for exact whitespace preservation
    ///
    /// - Returns: The processed JSON String
    public static func formatJSON(_ json: String, indent: Int? = nil) throws -> String {
        var out = String()
        out.reserveCapacity(json.unicodeScalars.count)
        let src = Array(json.unicodeScalars)
        try processJSON(src, out: &out, indent: indent)
        return out
    }

    /// Process the JSON scalars to the given output stream with optional formatting
    ///
    /// - parameter json: the source JSON scalars to process
    /// - parameter out: the `OutputStreamType` to write the result
    /// - parameter indent: the number of spaces to indent the output, zero for compact, nil for exact whitespace preservation
    public static func processJSON<S: TextOutputStream>(_ src: [UnicodeScalar], out: inout S, indent: Int? = nil) throws {
        let parser = JSONParser(options: Options.Strict)

        var depth = 0

        func pad() {
            if let indent = indent , indent > 0 {
                out.write("\n")
                let space: UnicodeScalar = " "
                out.write(String(repeating: String(space), count: depth * indent))
            }
        }

        func put(_ scalars: [UnicodeScalar]) {
            out.write(String(String.UnicodeScalarView() + scalars))
        }

        parser.delegate = { event in
            switch event {
            case .objectStart(let s):
                put(s)
                depth += 1
                pad()
            case .objectEnd(let s):
                depth -= 1
                pad()
                put(s)
            case .arrayStart(let s):
                put(s)
                depth += 1
                pad()
            case .arrayEnd(let s):
                depth -= 1
                pad()
                put(s)
            case .whitespace(let s):
                // copy the raw whitespace when we aren't formatting
                if indent == nil { put(s) }
            case .elementSeparator(let s):
                put(s)
                pad()
            case .keyValueSeparator(let s):
                if (indent ?? 0) > 0 { put([" "]) }
                put(s)
                if (indent ?? 0) > 0 { put([" "]) }
            default: // everything else just outputs the underlying value directly
                put(event.value)
            }
        }
        
        try parser.parse(src, complete: true)
    }
}

/// A parsing error with information about the location of the failure in the JSON
public struct ParseError : Error, CustomDebugStringConvertible {
    public let msg: String
    public let line: Int
    public let column: Int

    public var debugDescription: String {
        return msg + " (line: \(line) column: \(column))"
    }
}

private extension UnicodeScalar {
    /// Returns true iff this unicode scalar is a space, tab, carriage return, or newline
    var isJSONWhitespace: Bool {
        return self == "\t" || self == "\n" || self == "\r" || self == " "
    }
}

extension JSONParser.Event : Equatable { }

public func ==(e1: JSONParser.Event, e2: JSONParser.Event) -> Bool {
    switch (e1, e2) {
    case (.arrayStart(let x1), .arrayStart(let x2)): return x1 == x2
    case (.arrayEnd(let x1), .arrayEnd(let x2)): return x1 == x2
    case (.objectStart(let x1), .objectStart(let x2)): return x1 == x2
    case (.objectEnd(let x1), .objectEnd(let x2)): return x1 == x2
    case (.stringStart(let x1), .stringStart(let x2)): return x1 == x2
    case (.stringContent(let s1, let e1), .stringContent(let s2, let e2)): return s1 == s2 && e1 == e2
    case (.stringEnd(let x1), .stringEnd(let x2)): return x1 == x2
    case (.number(let n1), .number(let n2)): return n1 == n2
    case (.`true`(let x1), .`true`(let x2)): return x1 == x2
    case (.`false`(let x1), .`false`(let x2)): return x1 == x2
    case (.null(let x1), .null(let x2)): return x1 == x2
    case (.whitespace(let w1), .whitespace(let w2)): return w1 == w2
    case (.elementSeparator(let x1), .elementSeparator(let x2)): return x1 == x2
    case (.keyValueSeparator(let x1), .keyValueSeparator(let x2)): return x1 == x2
    default: return false
    }
}

