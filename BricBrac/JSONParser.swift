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
        case ArrayStart([UnicodeScalar])
        /// The end of an array was encountered (i.e. `]`)
        case ArrayEnd([UnicodeScalar])
        /// The start of an object was encountered (i.e. `{`)
        case ObjectStart([UnicodeScalar])
        /// The end of an object was encountered (i.e. `}`)
        case ObjectEnd([UnicodeScalar])
        /// A separator between Array or Object elements was encountered (i.e. `,`)
        case ElementSeparator([UnicodeScalar])
        /// A separator between an Object's key and value was encountered (i.e. `:`)
        case KeyValueSeparator([UnicodeScalar])
        /// A string was begun (i.e. `"`)
        case StringStart([UnicodeScalar])
        /// Some unescaped string contents was emitted with the given escape indices
        /// - SeeAlso: `unescape`
        case StringContent([UnicodeScalar], [Int])
        /// The string was closed (i.e. `"`)
        case StringEnd([UnicodeScalar])
        /// A complete number was processed
        case Number([UnicodeScalar])
        /// The `true` literal was encountered
        case True([UnicodeScalar])
        /// The `false` literal was encountered
        case False([UnicodeScalar])
        /// The `null` literal was encountered
        case Null([UnicodeScalar])
        /// Some whitespace happened
        case Whitespace([UnicodeScalar])

        public var debugDescription: Swift.String {
            switch self {
            case .ArrayStart: return "ArrayStart"
            case .ArrayEnd: return "ArrayEnd"
            case .ObjectStart: return "ObjectStart"
            case .ObjectEnd: return "ObjectEnd"
            case .ElementSeparator: return "ElementSeparator"
            case .KeyValueSeparator: return "KeyValueSeparator"
            case .StringStart: return "StringStart"
            case .StringContent: return "StringContent"
            case .StringEnd: return "StringEnd"
            case .Number: return "Number"
            case .True: return "True"
            case .False: return "False"
            case .Null: return "Null"
            case .Whitespace: return "Whitespace"
            }
        }

        /// Returns the underlying array of unicode scalars represented by this instance
        public var value: [UnicodeScalar] {
            switch self {
            case .ArrayStart(let s): return s
            case .ArrayEnd(let s): return s
            case .ObjectStart(let s): return s
            case .ObjectEnd(let s): return s
            case .ElementSeparator(let s): return s
            case .KeyValueSeparator(let s): return s
            case .StringStart(let s): return s
            case .StringContent(let s, _): return s
            case .StringEnd(let s): return s
            case .Number(let s): return s
            case .True(let s): return s
            case .False(let s): return s
            case .Null(let s): return s
            case .Whitespace(let s): return s
            }
        }


        // cache of singleton scalar constants for fast delegate passing
        private static let ArrayStartScalars: [UnicodeScalar] = ["["]
        private static let ArrayEndScalars: [UnicodeScalar] = ["]"]
        private static let ObjectStartScalars: [UnicodeScalar] = ["{"]
        private static let ObjectEndScalars: [UnicodeScalar] = ["}"]
        private static let StringStartScalars: [UnicodeScalar] = ["\""]
        private static let StringEndScalars: [UnicodeScalar] = ["\""]
        private static let ElementSeparatorScalars: [UnicodeScalar] = [","]
        private static let KeyValueSeparatorScalars: [UnicodeScalar] = [":"]
        private static let NullScalars: [UnicodeScalar] = ["n", "u", "l", "l"]
        private static let TrueScalars: [UnicodeScalar] = ["t", "r", "u", "e"]
        private static let FalseScalars: [UnicodeScalar] = ["f", "a", "l", "s", "e"]
    }

    /// Customization of the JSON parson process
    public struct Options : OptionSetType {
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

    private enum State {
        case Idle, String(StringParse), Number(NumberParse), Literal, ArrayOpen, ArrayElement, ObjectOpen, ObjectKey, ObjectElement

        var isValue: Bool {
            switch self {
            case .ArrayElement, .ObjectElement, .String, .Number, .Literal: return true
            default: return false
            }
        }

        var isContainer: Bool {
            switch self {
            case .ArrayElement, .ObjectElement: return true
            default: return false
            }
        }
    }

    /// Options for parsing
    private let options: Options

    /// The delegate that will receive callback events
    public var delegate: (Event) throws -> ()

    /// The current row and column of the parser (for error reporting purposes)
    public private(set) var row = 1, col = 0

    /// The current state
    private var state = State.Idle

    /// The current processing result, such as a number being parsed or a string being assembled
    private var processing = State.Idle

    /// The current pending result, such as a parsed string that is waiting to be added to an array
    private var pending = State.Idle

    /// The current container (and array or object)
    private var container = State.Idle

    /// The current stack of container states (arrays and objects)
    private var stack: [State] = []

    private var trailingComma = false

    /// The current buffer for a running string, number, or true/false/null literal
    private var buffer: Array<UnicodeScalar> = []

    public init(options: Options, delegate: (Event) throws -> () = { _ in }) {
        self.options = options
        self.delegate = delegate
    }


    private func pushContainer(parse: State, _ value: State) throws {
        stack.append(state)
        if container.isContainer {
            stack.append(container)
        }
        container = value // e.g., .Arr(createArray())
        state = parse // .ArrayStart
        pending = .Idle

        if case .ObjectOpen = state {
            try delegate(.ObjectStart(Event.ObjectStartScalars))
        } else if case .ArrayOpen = state {
            try delegate(.ArrayStart(Event.ArrayStartScalars))
        }
    }

    private func popContainer() throws {
        let x = stack.removeLast()

        if case .ObjectElement = container {
            try delegate(.ObjectEnd(Event.ObjectEndScalars))
        } else if case .ArrayElement = container {
            try delegate(.ArrayEnd(Event.ArrayEndScalars))
        }

        pending = container
        if x.isContainer {
            container = x
            state = stack.removeLast()
        } else {
            container = .Idle
            state = x
        }
    }

    private func err(msg: String) -> ParseError {
        return ParseError(msg: msg, line: row, column: col)
    }

    private func pushObjectKey() throws {
        if stack.isEmpty { throw err("Object key assignment with no container") }
        if !pending.isValue { throw err("Object key assignment with no value") }
        guard case .ObjectElement = container else { throw err("Object key assignment outside of object") }
        container = .ObjectElement
        state = stack.removeLast()
    }

    private func appendArrayValue() throws {
        if pending.isValue {
            if case .ArrayElement = container {
                container = .ArrayElement
            } else {
                throw err("Array append outside of array")
            }
        }

        pending = .Idle
    }

    private func clearBuffer() {
        buffer.removeAll(keepCapacity: true)
    }

    private func flushString() throws {
        if case .String(let escapes) = processing {
            try delegate(.StringContent(buffer, escapes))
            pending = .String(escapes)
            clearBuffer()
        }
        processing = .Idle
    }

    /// Takes any outstanding number buffer and flushes it
    private func flushNumber() throws {
        guard case .Number(let num) = processing else { return }

        try delegate(.Number(buffer))

        if num.digitCount == 0 { throw err("Expected a digit, got: \(buffer)") }

        // we can only have a leading number with 0.1 and -0.5; 00.3 and -000.7 are illegal
        if num.leadingZeros > 0 && num.digitCount > 1 && num.fraction != (num.signed ? 2 : 1) && !options.contains(.AllowLeadingZeros) {
            throw err("Leading zero in number")
        }

        if num.trailingDigits == 0 { throw err("Number did not end in a digit") }
        pending = .Number(num)
        clearBuffer()
        self.processing = .Idle
    }
    
    
    public func parseString(string: String) throws -> Int {
        return try parse(string.unicodeScalars, complete: true)
    }

    public func parseArray(scalars: Array<UnicodeScalar>) throws -> Int {
        return try parse(scalars, complete: true)
    }

    /// Feeds a single scalar to the parser
    ///
    /// - SeeAlso: `parse`
    public func parseScalar(scalar: UnicodeScalar) throws -> Int {
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
    public func parse<S: SequenceType where S.Generator.Element == UnicodeScalar>(scalars: S, complete: Bool = false) throws -> Int {
        var index = 0

        func processingNumber() -> Bool { if case .Number = processing { return true } else { return false } }
        func processingString() -> Bool { if case .String = processing { return true } else { return false } }

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
                        try delegate(.Whitespace([trailing]))
                    }
                    buffer.removeAll(keepCapacity: false)
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
                if case .Number(var num) = processing {
                    num.loc += 1

                    switch sval {
                    case 0x30...0x39: // digit
                        if sval == 0x30 && num.leadingZeros == num.digitCount && num.fraction == nil {
                            num.leadingZeros += 1 // count the number of leading zeros for validation later
                        }
                        num.digitCount += 1
                        num.trailingDigits += 1
                        processing = .Number(num)
                        buffer.append(scalar)
                        continue
                    case 0x2E: // .
                        if num.fraction != nil {
                            throw err("Too many dots in the number")
                        } else {
                            num.fraction = num.loc
                        }
                        num.trailingDigits = 0
                        processing = .Number(num)
                        buffer.append(scalar)
                        continue
                    case 0x45, 0x65: // e E
                        if num.exponent > 0 || num.digitCount == 0 {
                            throw err("Too many exponent signs in the number")
                        } else {
                            num.exponent = num.loc
                        }
                        num.trailingDigits = 0
                        processing = .Number(num)
                        buffer.append(scalar)
                        continue
                    case 0x2B, 0x2D: // + -
                        if num.exponent != num.loc.predecessor() {
                            throw err("Sign not following exponent")
                        }
                        num.trailingDigits = 0
                        processing = .Number(num)
                        buffer.append(scalar)
                        continue
                    default:  // anything else: stop parsing the number
                        try flushNumber() // scalar not consummed: flush the number and fall through to further handling
                    }
                }


                switch sval {
                case _ where processingString(): // currently processing a string: append characters
                    if case .String(var escapeIndices) = processing {
                        func trailingEscapes() -> Int {
                            var slashes = 0
                            for c in buffer.reverse() {
                                if c == "\\" { slashes += 1 } else { break }
                            }
                            return slashes
                        }

                        if sval == 0x22 && trailingEscapes() % 2 == 0 { // close quote
                            try flushString()
                            try delegate(.StringEnd(Event.StringEndScalars))
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
                            processing = .String(escapeIndices)
                        }
                    }

                case 0x22: // open quote: start processing a string
                    if pending.isValue { throw err("String found with pending result value") }
                    processing = .String(StringParse([]))
                    try delegate(.StringStart(Event.StringEndScalars))

                case 0x0020, 0x0009, 0x000A, 0x000D: // space, tab, newline, carriage return
                    try delegate(.Whitespace([scalar]))

                case 0x7B: // open curly brace
                    if case .ObjectOpen = state { throw err("Object start within object start") }
                    if pending.isValue { throw err("Object start with pending result value") }
                    try pushContainer(.ObjectOpen, .ObjectElement)

                case 0x5B: // open square bracket
                    if case .ObjectOpen = state { throw err("Array start within object start") }
                    if pending.isValue { throw err("Array start with pending result value") }
                    try pushContainer(.ArrayOpen, .ArrayElement)

                case 0x7D: // close curly brace
                    if case .ObjectKey = state {
                        try pushObjectKey()
                    }

                    if case .ObjectOpen = state {
                        try popContainer()
                    } else {
                        throw err("Unmatched close object brace")
                    }


                case 0x5D: // close square bracket
                    if case .ArrayOpen = state {
                        try appendArrayValue()
                        try popContainer()
                    } else {
                        throw err("Unmatched close array brace")
                    }

                case 0x2C: // comma
                    if case .ObjectOpen = state { throw err("Comma within object start") }
                    if !pending.isValue { throw err("Comma found with no pending result") }

                    if case .ObjectKey = state { // : assignment
                        try pushObjectKey()
                        pending = .Idle
                    } else if case .ArrayOpen = state { // [ array
                        try appendArrayValue()
                    } else {
                        throw err("Comma not contained in array or object")
                    }

                    try delegate(.ElementSeparator(Event.ElementSeparatorScalars))
                    trailingComma = true

                case 0x3A: // colon
                    if case .ObjectOpen = state {
                        guard case .String = pending else { throw err("Missing object key") }
                        stack.append(state)
                        pending = .Idle
                        state = .ObjectKey
                        try delegate(.KeyValueSeparator(Event.KeyValueSeparatorScalars))
                    } else {
                        throw err("Object key assignment outside of an object")
                    }

                case 0x30...0x39, 0x2B, 0x2D, 0x2E, 0x45 where processingNumber(), 0x65 where processingNumber(): // digit, +, -, (.), (e), (E)
                    if case .ObjectOpen = state { throw err("Number within object start") }
                    if pending.isValue { throw err("Number found with pending result value") }

                    if !processingNumber() {
                        let dc = sval >= 0x30 && sval <= 0x39 ? 1 : 0
                        let num: NumberParse = (0, nil, nil, dc, dc, sval == 0x30 ? 1 : 0, sval == 0x2D || sval == 0x2E)
                        processing = .Number(num)
                    }

                    buffer.append(scalar)

                default:
                    if case .ObjectOpen = state { throw err("Invalid character within object start") }
                    if pending.isValue { throw err("Character found with pending result value") }

                    // finally, check for the JSON literals "true", "false", and "null"

                    buffer.append(scalar) // tack on to the current buffer to check for literals
                    var gen = buffer.generate()
                    let lit = (gen.next(), gen.next(), gen.next(), gen.next(), gen.next())

                    switch lit {
                    case (.Some("n"), .None, .None, .None, .None): break // n
                    case (.Some("n"), .Some("u"), .None, .None, .None): break // nu
                    case (.Some("n"), .Some("u"), .Some("l"), .None, .None): break // nul
                    case (.Some("n"), .Some("u"), .Some("l"), .Some("l"), .None): // null
                        pending = .Literal
                        try delegate(.Null(Event.NullScalars))
                        clearBuffer()
                        break

                    case (.Some("t"), .None, .None, .None, .None): break // t
                    case (.Some("t"), .Some("r"), .None, .None, .None): break // tr
                    case (.Some("t"), .Some("r"), .Some("u"), .None, .None): break // tru
                    case (.Some("t"), .Some("r"), .Some("u"), .Some("e"), .None): // true
                        pending = .Literal
                        try delegate(.True(Event.TrueScalars))
                        clearBuffer()
                        break

                    case (.Some("f"), .None, .None, .None, .None): break // f
                    case (.Some("f"), .Some("a"), .None, .None, .None): break // fa
                    case (.Some("f"), .Some("a"), .Some("l"), .None, .None): break // fal
                    case (.Some("f"), .Some("a"), .Some("l"), .Some("s"), .None): break // fals
                    case (.Some("f"), .Some("a"), .Some("l"), .Some("s"), .Some("e")): // false
                        pending = .Literal
                        try delegate(.False(Event.FalseScalars))
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
                    try delegate(.Whitespace([scalar]))
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
    public static func unescape<C: RangeReplaceableCollectionType where C.Generator.Element == UnicodeScalar, C.SubSequence.Generator.Element == UnicodeScalar, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(scalars: C, escapeIndices: [C.Index], line: Int, column: Int) throws -> C {
        // when the string has no escapes, we can just pass it directly
        if escapeIndices.isEmpty { return scalars }

        let start = scalars.startIndex, end = scalars.endIndex

        // perform backslash escaping
        var slice = C()
        slice.reserveCapacity(start.distanceTo(end))

        var loc = start
        var highSurrogate: UInt32? = nil

        for i in escapeIndices {
            slice.appendContentsOf(scalars[loc..<i.predecessor()])
            loc = i
            let s: UnicodeScalar = scalars[i]

            switch s.value {
            case 0x22: // " -> quote
                slice.append(s)
                loc = loc.successor()
            case 0x5C: // \ -> backslash
                slice.append(s)
                loc = loc.successor()
            case 0x2F: // / -> slash
                slice.append(s)
                loc = loc.successor()
            case 0x62:  // \b -> backspace
                slice.append(UnicodeScalar(0x08))
                loc = loc.successor()
            case 0x66: // \f -> formfeed
                slice.append(UnicodeScalar(0x0C))
                loc = loc.successor()
            case 0x6e: // \n -> newline
                slice.append("\n")
                loc = loc.successor()
            case 0x72: // \r -> carriage return
                slice.append("\r")
                loc = loc.successor()
            case 0x74: // \t -> tab
                slice.append("\t")
                loc = loc.successor()
            case 0x75: // \u -> unicode hex characters follow
                if i.distanceTo(end) < 4 {
                    throw ParseError(msg: "Unterminated hex escape", line: line, column: column + start.distanceTo(i))
                }

                var hex: UInt32 = 0
                for (b, h) in [
                    (12, scalars[i.advancedBy(1)].value),
                    (8, scalars[i.advancedBy(2)].value),
                    (4, scalars[i.advancedBy(3)].value),
                    (0, scalars[i.advancedBy(4)].value)
                    ] {
                        switch h {
                        case 0x30...0x39: hex += (h - 0x30) << UInt32(b) // 0-9
                        case 0x41...0x46: hex += (10 + h - 0x41) << UInt32(b) // A-F
                        case 0x61...0x66: hex += (10 + h - 0x61) << UInt32(b) // a-f
                        default: throw ParseError(msg: "Invalid hex digit in unicode escape", line: line, column: column + start.distanceTo(i))
                        }
                }

                if hex >= 0xD800 && hex <= 0xDBFF { // high surrogates
                    highSurrogate = hex // save the high surrogate and move along
                } else if hex >= 0xDC00 && hex <= 0xDFFF { // low surrogates
                    if let highSurrogate = highSurrogate {
                        let codepoint: UInt32 = ((highSurrogate - 0xD800) << 10) + (hex - 0xDC00) + 0x010000
                        slice.append(UnicodeScalar(codepoint))
                    } else {
                        throw ParseError(msg: "Low surrogate not preceeded by high surrogate", line: line, column: column + start.distanceTo(i))
                    }
                    highSurrogate = nil
                } else if hex >= 0x0000 && hex <= 0xFFFF { // basic codeplane
                    slice.append(UnicodeScalar(hex))
                } else {
                    throw ParseError(msg: "Hex escape not in a valid codeplane", line: line, column: column + start.distanceTo(i))
                }

                loc = loc.advancedBy(5, limit: end) // skip past the escapes

            default:
                throw ParseError(msg: "Illegal string escape: \(s)", line: line, column: column + start.distanceTo(i))
            }
        }
        
        slice.appendContentsOf(scalars[loc..<end]) // append the remainder
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
    public static func formatJSON(json: String, indent: Int? = nil) throws -> String {
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
    public static func processJSON<S: OutputStreamType>(src: [UnicodeScalar], inout out: S, indent: Int? = nil) throws {
        let parser = JSONParser(options: Options.Strict)

        var depth = 0

        func pad() {
            if let indent = indent where indent > 0 {
                out.write("\n")
                let space: UnicodeScalar = " "
                out.write(String(count: depth * indent, repeatedValue: space))
            }
        }

        func put(scalars: [UnicodeScalar]) {
            out.write(String(String.UnicodeScalarView() + scalars))
        }

        parser.delegate = { event in
            switch event {
            case .ObjectStart(let s):
                put(s)
                depth += 1
                pad()
            case .ObjectEnd(let s):
                depth -= 1
                pad()
                put(s)
            case .ArrayStart(let s):
                put(s)
                depth += 1
                pad()
            case .ArrayEnd(let s):
                depth -= 1
                pad()
                put(s)
            case .Whitespace(let s):
                // copy the raw whitespace when we aren't formatting
                if indent == nil { put(s) }
            case .ElementSeparator(let s):
                put(s)
                pad()
            case .KeyValueSeparator(let s):
                if indent > 0 { out.write(" ") }
                put(s)
                if indent > 0 { out.write(" ") }
            default: // everything else just outputs the underlying value directly
                put(event.value)
            }
        }
        
        try parser.parse(src, complete: true)
    }
}

/// A parsing error with information about the location of the failure in the JSON
public struct ParseError : ErrorType, CustomDebugStringConvertible {
    public let msg: String
    public let line: Int
    public let column: Int

    public var debugDescription: String {
        return msg + " (line: \(line) column: \(column))"
    }
}

private extension UnicodeScalar {
    /// Returns true iff this unicode scalar is a space, tab, carriage return, or newline
    private var isJSONWhitespace: Bool {
        return self == "\t" || self == "\n" || self == "\r" || self == " "
    }
}

extension JSONParser.Event : Equatable { }

public func ==(e1: JSONParser.Event, e2: JSONParser.Event) -> Bool {
    switch (e1, e2) {
    case (.ArrayStart(let x1), .ArrayStart(let x2)): return x1 == x2
    case (.ArrayEnd(let x1), .ArrayEnd(let x2)): return x1 == x2
    case (.ObjectStart(let x1), .ObjectStart(let x2)): return x1 == x2
    case (.ObjectEnd(let x1), .ObjectEnd(let x2)): return x1 == x2
    case (.StringStart(let x1), .StringStart(let x2)): return x1 == x2
    case (.StringContent(let s1, let e1), .StringContent(let s2, let e2)): return s1 == s2 && e1 == e2
    case (.StringEnd(let x1), .StringEnd(let x2)): return x1 == x2
    case (.Number(let n1), .Number(let n2)): return n1 == n2
    case (.True(let x1), .True(let x2)): return x1 == x2
    case (.False(let x1), .False(let x2)): return x1 == x2
    case (.Null(let x1), .Null(let x2)): return x1 == x2
    case (.Whitespace(let w1), .Whitespace(let w2)): return w1 == w2
    case (.ElementSeparator(let x1), .ElementSeparator(let x2)): return x1 == x2
    case (.KeyValueSeparator(let x1), .KeyValueSeparator(let x2)): return x1 == x2
    default: return false
    }
}

