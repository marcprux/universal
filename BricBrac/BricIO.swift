//
//  BricIO.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 6/17/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

extension Bric : Streamable {

    /// Streamable protocol implementation that writes the Bric as JSON to the given Target
    public func writeTo<Target : OutputStreamType>(inout target: Target) {
        writeJSON(&target)
    }

    /// Serializes this Bric as an ECMA-404 JSON Data Interchange Format string.
    ///
    /// - Parameter space: the number of indentation spaces to use for pretty-printing
    /// - Parameter maxline: fit pretty-printed output on a single line if it is less than maxline
    /// - Parameter mapper: When set, .Obj instances will be passed through the given mapper to filter, re-order, or modify the values
    @warn_unused_result
    public func stringify(space space: Int = 0, maxline: Int = 0, bufferSize: Int? = nil, mapper: [String: Bric]->AnyGenerator<(String, Bric)> = { anyGenerator($0.generate()) })->String {
        var str = String()
        if let bufferSize = bufferSize {
            str.reserveCapacity(bufferSize)
        }
        let spacer = String(count: space, repeatedValue: Character(" "))
        self.writeJSON(&str, spacer: spacer, maxline: maxline, mapper: mapper)
        return str
    }

    // the emission state; note that indexes go from -1...count, since the edges are markers for container open/close tokens
    private enum State {
        case Arr(index: Int, array: [Bric])
        case Obj(index: Int, object: [(String, Bric)])
    }

    public func writeJSON<Target: OutputStreamType>(inout output: Target, spacer: String = "", maxline: Int = 0, mapper: [String: Bric]->AnyGenerator<(String, Bric)> = { anyGenerator($0.generate()) }) {
        if maxline <= 0 {
            writeJSON(&output, writer: FormattingJSONWriter<Target>(spacer: spacer), mapper: mapper)
        } else {
            writeJSON(&output, writer: BufferedJSONWriter(spacer: spacer, maxline: maxline), mapper: mapper)
        }
    }

    /// A non-recursive streaming JSON stringifier
    public func writeJSON<Target: OutputStreamType, Writer: JSONWriter where Writer.Target == Target>(inout output: Target, writer: Writer, mapper: [String: Bric]->AnyGenerator<(String, Bric)> = { anyGenerator($0.generate()) }) {
        // the current stack of containers; we use this instead of recursion to track where we are in the process
        var stack: [State] = []

        writer.writeStart(&output)

        func processBric(bric: Bric) {
            switch bric {
            case .Nul:
                writer.writeNull(&output)
            case .Bol(let bol):
                writer.writeBoolean(&output, boolean: bol)
            case .Str(let str):
                writer.writeString(&output, string: str)
            case .Num(let num):
                writer.writeNumber(&output, number: num)
            case .Arr(let arr):
                stack.append(State.Arr(index: -1, array: arr))
            case .Obj(let obj):
                let keyValues = Array(mapper(obj))
                stack.append(State.Obj(index: -1, object: keyValues))
            }
        }

        func processArrayElement(index: Int, array: [Bric]) {
            if index == -1 {
                writer.writeArrayOpen(&output)
                return
            } else if index == array.count {
                if index > 0 { writer.writeIndentation(&output, level: stack.count) }
                writer.writeArrayClose(&output)
                return
            } else if index > 0 {
                writer.writeArrayDelimiter(&output)
            }

            let element = array[index]
            writer.writeIndentation(&output, level: stack.count)

            processBric(element)
        }

        func processObjectElement(index: Int, object: [(String, Bric)]) {
            if index == -1 {
                writer.writeObjectOpen(&output)
                return
            } else if index == object.count {
                if index > 0 { writer.writeIndentation(&output, level: stack.count) }
                writer.writeObjectClose(&output)
                return
            } else if index > 0 {
                writer.writeObjectDelimiter(&output)
            }

            let element = object[index]
            writer.writeIndentation(&output, level: stack.count)
            writer.writeString(&output, string: element.0)
            writer.writeObjectSeparator(&output)
            writer.writePadding(&output, count: 1)

            processBric(element.1)
        }

        processBric(self) // now process ourself as the root bric

        // walk through the stack and process each element in turn; note that the processing of elements may itself increase the stack
        while !stack.isEmpty {
            switch stack.removeLast() {
            case .Arr(let index, let array):
                if index < array.count {
                    stack.append(.Arr(index: index+1, array: array))
                }
                processArrayElement(index, array: array)
            case .Obj(let index, let object):
                if index < object.count {
                    stack.append(.Obj(index: index+1, object: object))
                }
                processObjectElement(index, object: object)
            }
        }

        writer.writeEnd(&output)
    }
}

extension Bric : CustomDebugStringConvertible {
    public var debugDescription: String {
        return stringify()
    }
}


/// **bricolage (brēˌkō-läzhˈ, brĭkˌō-)** *n. Something made or put together using whatever materials happen to be available*
///
/// Bricolage is the target storage for a JSON parser; for typical parsing, the storage is just `Bric`, but
/// other storages are possible:
///
/// * `EmptyBricolage`: doesn't store any data, and exists for fast validation of a document
/// * `CocoaBricolage`: storage that is compatible with Cocoa's `NSJSONSerialization` APIs
///
/// Note that nothing prevents `Bricolage` storage from being lossy, such as numeric types overflowing 
/// or losing precision from number strings
public protocol Bricolage {
    typealias NulType
    typealias StrType
    typealias NumType
    typealias BolType
    typealias ArrType
    typealias ObjType

    init(nul: NulType)
    init(str: StrType)
    init(num: NumType)
    init(bol: BolType)
    init(arr: ArrType)
    init(obj: ObjType)

    @warn_unused_result
    static func createNull() -> NulType
    @warn_unused_result
    static func createTrue() -> BolType
    @warn_unused_result
    static func createFalse() -> BolType
    @warn_unused_result
    static func createObject() -> ObjType
    @warn_unused_result
    static func createArray() -> ArrType
    @warn_unused_result
    static func createString(scalars: [UnicodeScalar]) -> StrType?
    @warn_unused_result
    static func createNumber(scalars: [UnicodeScalar]) -> NumType?
    @warn_unused_result
    static func putKeyValue(obj: ObjType, key: StrType, value: Self) -> ObjType
    @warn_unused_result
    static func putElement(arr: ArrType, element: Self) -> ArrType
}

/// An empty implementation of JSON storage which can be used for fast validation
public struct EmptyBricolage: Bricolage {
    public typealias NulType = Void
    public typealias BolType = Void
    public typealias StrType = Void
    public typealias NumType = Void
    public typealias ArrType = Void
    public typealias ObjType = Void

    public init(nul: NulType) { }
    public init(bol: BolType) { }
    public init(str: StrType) { }
    public init(num: NumType) { }
    public init(arr: ArrType) { }
    public init(obj: ObjType) { }

    public static func createNull() -> NulType { }
    public static func createTrue() -> BolType { }
    public static func createFalse() -> BolType { }
    public static func createString(scalars: [UnicodeScalar]) -> StrType? { return StrType() }
    public static func createNumber(scalars: [UnicodeScalar]) -> NumType? { return NumType() }
    public static func createArray() -> ArrType { }
    public static func createObject() -> ObjType { }
    public static func putElement(arr: ArrType, element: EmptyBricolage) -> ArrType { }
    public static func putKeyValue(obj: ObjType, key: StrType, value: EmptyBricolage) -> ObjType { }
}

/// Storage for JSON that maintains the raw underlying JSON values, which means that long number
/// strings and object-key ordering information is preserved (although whitespace is still lost)
public enum FidelityBricolage : Bricolage {
    public typealias NulType = Void
    public typealias BolType = Bool
    public typealias StrType = Array<UnicodeScalar>
    public typealias NumType = Array<UnicodeScalar>
    public typealias ArrType = Array<FidelityBricolage>
    public typealias ObjType = Array<(StrType, FidelityBricolage)>

    case Nul(NulType)
    case Bol(BolType)
    case Str(StrType)
    case Num(NumType)
    case Arr(ArrType)
    case Obj(ObjType)

    public init(nul: NulType) { self = .Nul(nul) }
    public init(bol: BolType) { self = .Bol(bol) }
    public init(str: StrType) { self = .Str(str) }
    public init(num: NumType) { self = .Num(num) }
    public init(arr: ArrType) { self = .Arr(arr) }
    public init(obj: ObjType) { self = .Obj(obj) }

    public static func createNull() -> NulType { }
    public static func createTrue() -> BolType { return true }
    public static func createFalse() -> BolType { return false }
    public static func createObject() -> ObjType { return ObjType() }
    public static func createArray() -> ArrType { return ArrType() }
    public static func createString(scalars: [UnicodeScalar]) -> StrType? { return scalars }
    public static func createNumber(scalars: [UnicodeScalar]) -> NumType? { return scalars }
    public static func putElement(var arr: ArrType, element: FidelityBricolage) -> ArrType {
        arr.append(element)
        return arr
    }
    public static func putKeyValue(var obj: ObjType, key: StrType, value: FidelityBricolage) -> ObjType {
        obj.append((key, value))
        return obj
    }
}

public protocol Bricolagable : Bricable {
    func bricolage<B: Bricolage>() -> B
}

extension Bricolagable {
    public func bric() -> Bric { return bricolage() }
}

extension FidelityBricolage : Bricolagable {
    public func bricolage<B: Bricolage>() -> B {
        switch self {
        case .Nul:
            return B(nul: B.createNull())
        case .Bol(let bol):
            return B(bol: bol ? B.createTrue() : B.createFalse())
        case .Str(let str):
            return B.createString(str).flatMap({ B(str: $0) }) ?? B(nul: B.createNull())
        case .Num(let num):
            return B.createNumber(num).flatMap({ B(num: $0) }) ?? B(nul: B.createNull())
        case .Arr(let arr):
            var array = B.createArray()
            for x in arr {
                array = B.putElement(array, element: x.bricolage())
            }
            return B(arr: array)
        case .Obj(let obj):
            var object = B.createObject()
            for x in obj {
                object = B.putKeyValue(object, key: B.createString(x.0)!, value: x.1.bricolage())
            }
            return B(obj: object)
        }
    }
}

extension FidelityBricolage : NilLiteralConvertible {
    public init(nilLiteral: ()) { self = .Nul() }
}

extension FidelityBricolage : BooleanLiteralConvertible {
    public init(booleanLiteral value: Bool) {
        self = .Bol(value ? FidelityBricolage.createTrue() : FidelityBricolage.createFalse())
    }
}

extension FidelityBricolage : StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self = .Str(Array(value.unicodeScalars))
    }

    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .Str(Array(value.unicodeScalars))
    }

    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .Str(Array(value.unicodeScalars))
    }
}

extension FidelityBricolage : IntegerLiteralConvertible {
    public init(integerLiteral value: Int) {
        self = .Num(Array(String(value).unicodeScalars))
    }
}

extension FidelityBricolage : FloatLiteralConvertible {
    public init(floatLiteral value: Double) {
        self = .Num(Array(String(value).unicodeScalars))
    }
}

extension FidelityBricolage : ArrayLiteralConvertible {
    public init(arrayLiteral elements: FidelityBricolage...) {
        self = .Arr(elements)
    }
}

extension FidelityBricolage : DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, FidelityBricolage)...) {
        self = .Obj(elements.map({ (key, value) in (Array(key.unicodeScalars), value) }))
    }
}

/// Storage for JSON that is tailored for Swift-fluent access
extension Bric: Bricolage {
    public typealias Storage = Bric

    public typealias NulType = Void
    public typealias BolType = Bool
    public typealias StrType = String
    public typealias NumType = Double
    public typealias ArrType = Array<Bric>
    public typealias ObjType = Dictionary<StrType, Bric>

    public init(nul: NulType) { self = .Nul }
    public init(bol: BolType) { self = .Bol(bol) }
    public init(str: StrType) { self = .Str(str) }
    public init(num: NumType) { self = .Num(num) }
    public init(arr: ArrType) { self = .Arr(arr) }
    public init(obj: ObjType) { self = .Obj(obj) }

    public static func createNull() -> NulType { }
    public static func createTrue() -> BolType { return true }
    public static func createFalse() -> BolType { return false }
    public static func createObject() -> ObjType { return ObjType() }
    public static func createArray() -> ArrType { return ArrType() }
    public static func createString(scalars: [UnicodeScalar]) -> StrType? { return String(scalars: scalars) }
    public static func createNumber(scalars: [UnicodeScalar]) -> NumType? { return Double(String(scalars: scalars)) }
    public static func putElement(var arr: ArrType, element: Bric) -> ArrType {
        arr.append(element)
        return arr
    }
    public static func putKeyValue(var object: ObjType, key: StrType, value: Bric) -> ObjType {
        object[key] = value
        return object
    }
}

extension Bricolage {
    /// Parses the given JSON string and returns some Bric
    public static func parse(string: String, options: JSONParser.Options = .Strict) throws -> Self {
        return try parseBricolage(Array(string.unicodeScalars), options: options)
        // the following also works fine, but converting to an array first is dramatically faster (over 2x faster for caliper.json)
        // return try Bric.parseBricolage(string.unicodeScalars, options: options)
    }

    /// Parses the given JSON array of unicode scalars and returns some Bric
    public static func parse(scalars: [UnicodeScalar], options: JSONParser.Options = .Strict) throws -> Self {
        return try parseJSON(scalars, options: options)
    }
}


extension Bricolage {
    /// Validates the given JSON string and throws an error if there was a problem
    public static func validate(string: String, options: JSONParser.Options) throws {
        try JSONParser(options: options).parse(Array(string.unicodeScalars), complete: true)
    }

    /// Validates the given array of JSON unicode scalars and throws an error if there was a problem
    public static func validate(scalars: [UnicodeScalar], options: JSONParser.Options) throws {
        try JSONParser(options: options).parse(scalars, complete: true)
    }
}

private enum Container<T : Bricolage> {
    case Object(T.ObjType, T.StrType?)
    case Array(T.ArrType)
}

extension Bricolage {
    public static func parseJSON(scalars: [UnicodeScalar], options opts: JSONParser.Options) throws -> Self {
        return try parseBricolage(scalars, options: opts)
    }

    public static func parseBricolage<S: SequenceType where S.Generator.Element == UnicodeScalar>(scalars: S, options opts: JSONParser.Options) throws -> Self {
        typealias T = Self
        var current: T = T(nul: T.createNull()) // the current object being processed

        // the delegate merely remembers the last top-most bric element (which will hold all the children)
        var parser = bricolageParser(options: opts) { (bric, level) in
            if level == 0 { current = bric }
            return bric
        }

        assert(isUniquelyReferencedNonObjC(&parser))
        try parser.parse(scalars, complete: true)
        assert(isUniquelyReferencedNonObjC(&parser)) // leak prevention
        return current
    }


    /// Creates and returns a parser that will emit fully-formed Bricolage instances to the given delegate
    /// Note that the delegate will emit the same Bricolage instance once the instance has been realized,
    /// as well as once a container has been completed.
    /// 
    /// - param options: the options for the JSON parser to use
    /// - param delegate: a closure through which each Bricolage instance will pass, returning the 
    ///   actual Bricolage instance that should be added to the stack
    ///
    /// - returns: a configured JSON parser with the Bricolage delegate
    public static func bricolageParser(options opts: JSONParser.Options, delegate: (Self, level: Int) -> Self) -> JSONParser {

        typealias T = Self

        // the stack holds all of the currently-open containers; in order to handle parsing
        // top-level non-containers, the top of the stack is always an array that should
        // contain only a single element
        var stack: [Container<T>] = []

        let parser = JSONParser(options: opts)

        parser.delegate = { [unowned parser] event in

            func err(msg: String) -> ParseError { return ParseError(msg: msg, line: parser.row, column: parser.col) }

            func closeContainer() throws {
                if stack.count <= 0 { throw err("Cannot close top-level container") }
                switch stack.removeLast() {
                case .Object(let x, _): try pushValue(T(obj: x))
                case .Array(let x): try pushValue(T(arr: x))
                }
            }

            func pushValue(x: T) throws {
                // inform the delegate that we have seen a fully-formed Bric
                let value = delegate(x, level: stack.count)

                switch stack.last {
                case .Some(.Object(let x, let key)):
                    if let key = key {
                        stack[stack.endIndex.predecessor()] = .Object(T.putKeyValue(x, key: key, value: value), .None)
                    } else {
                        throw err("Put object with no key type")
                    }
                case .Some(.Array(let x)):
                    stack[stack.endIndex.predecessor()] = .Array(T.putElement(x, element: value))
                case .None:
                    break
                }
            }

           switch event {
            case .ObjectStart:
                stack.append(.Object(T.createObject(), .None))
            case .ObjectEnd:
                try closeContainer()
            case .ArrayStart:
                stack.append(.Array(T.createArray()))
            case .ArrayEnd:
                try closeContainer()
            case .StringContent(let s, let e):
                let escaped = try JSONParser.unescape(s, escapeIndices: e, line: parser.row, column: parser.col)
                if let str = T.createString(escaped) {
                    if case .Some(.Object(let x, let key)) = stack.last where key == nil {
                        stack[stack.endIndex.predecessor()] = .Object(x, str)
                        delegate(T(str: str), level: stack.count)
                    } else {
                        try pushValue(T(str: str))
                    }
                } else {
                    throw err("Unable to create string")
                }
            case .Number(let n):
                if let num = T.createNumber(Array(n)) {
                    try pushValue(T(num: num))
                } else {
                    throw err("Unable to create number")
                }
            case .True:
                try pushValue(T(bol: T.createTrue()))
            case .False:
                try pushValue(T(bol: T.createFalse()))
            case .Null:
                try pushValue(T(nul: T.createNull()))
           case .Whitespace, .ElementSeparator, .KeyValueSeparator, .StringStart, .StringEnd:
                break // whitespace is ignored in document parsing
            }
        }

        return parser
    }
}

extension String {
    /// Convenience for creating a string from an array of UnicodeScalars
    init(scalars: [UnicodeScalar]) {
        self = String(String.UnicodeScalarView() + scalars) // seems a tiny bit faster
    }
}


public protocol JSONWriter {
    typealias Target

    func writeStart(inout output: Target)
    func writeEnd(inout output: Target)

    func writeIndentation(inout output: Target, level: Int)
    func writeNull(inout output: Target)
    func writeBoolean(inout output: Target, boolean: Bool)
    func writeNumber(inout output: Target, number: Double)
    func writeString(inout output: Target, string: String)

    func writePadding(inout output: Target, count: Int)

    func writeArrayOpen(inout output: Target)
    func writeArrayClose(inout output: Target)
    func writeArrayDelimiter(inout output: Target)

    func writeObjectOpen(inout output: Target)
    func writeObjectClose(inout output: Target)
    func writeObjectSeparator(inout output: Target)
    func writeObjectDelimiter(inout output: Target)

    func emit(inout output: Target, string: String)
}

/// Default implementations of common JSONWriter functions when the target is an output stream
public extension JSONWriter {
    func writeStart(inout output: Target) {

    }

    func writeEnd(inout output: Target) {
        
    }

    func writeString(inout output: Target, string: String) {
        emit(&output, string: "\"")
        for c in string.unicodeScalars {
            switch c {
            case "\\": emit(&output, string: "\\\\")
            case "\n": emit(&output, string: "\\n")
            case "\r": emit(&output, string: "\\r")
            case "\t": emit(&output, string: "\\t")
            case "\"": emit(&output, string: "\\\"")
                // case "/": emit(&output, string: "\\/") // you may escape slashes, but we don't (neither does JSC's JSON.stringify)
            case UnicodeScalar(0x08): emit(&output, string: "\\b") // backspace
            case UnicodeScalar(0x0C): emit(&output, string: "\\f") // formfeed
            default: emit(&output, string: String(c))
            }
        }
        emit(&output, string: "\"")
    }

    func writeNull(inout output: Target) {
        emit(&output, string: "null")
    }

    func writeBoolean(inout output: Target, boolean: Bool) {
        if boolean == true {
            emit(&output, string: "true")
        } else {
            emit(&output, string: "false")
        }
    }

    func writeNumber(inout output: Target, number: Double) {
        // TODO: output exactly the same as the ECMA spec: http://es5.github.io/#x15.7.4.2
        // see also: http://www.netlib.org/fp/dtoa.c
        let str = String(number) // FIXME: this outputs exponential notation for some large numbers
        // when a string ends in ".0", we just append the rounded int FIXME: better string formatting
        if str.hasSuffix(".0") {
            emit(&output, string: str[str.startIndex..<str.endIndex.predecessor().predecessor()])
        } else {
            emit(&output, string: str)
        }
    }


    func writeArrayOpen(inout output: Target) {
        emit(&output, string: "[")
    }

    func writeArrayClose(inout output: Target) {
        emit(&output, string: "]")
    }

    func writeArrayDelimiter(inout output: Target) {
        emit(&output, string: ",")
    }

    func writeObjectOpen(inout output: Target) {
        emit(&output, string: "{")
    }

    func writeObjectClose(inout output: Target) {
        emit(&output, string: "}")
    }

    func writeObjectSeparator(inout output: Target) {
        emit(&output, string: ":")
    }

    func writeObjectDelimiter(inout output: Target) {
        emit(&output, string: ",")
    }
}

public struct FormattingJSONWriter<Target: OutputStreamType> : JSONWriter {
    let spacer: String

    public func writeIndentation(inout output: Target, level: Int) {
        if !spacer.isEmpty {
            emit(&output, string: "\n")
            for _ in 0..<level {
                emit(&output, string: spacer)
            }
        }
    }

    public func writePadding(inout output: Target, count: Int) {
        if !spacer.isEmpty {
            emit(&output, string: String(count: count, repeatedValue: Character(" ")))
        }
    }

    public func emit(inout output: Target, string: String) {
        output.write(string)
    }
}

public enum BufferedJSONWriterToken {
    case Str(String)
    case Indent(Int)
}

/// A `JSONWriter` implementation that buffers the output in order to apply advanced formatting
public class BufferedJSONWriter<Target: OutputStreamType> : JSONWriter {
    public var tokens: [BufferedJSONWriterToken] = []
    let spacer: String
    let maxline: Int
    let pad: String = " "

    public init(spacer: String, maxline: Int) {
        self.spacer = spacer
        self.maxline = maxline
    }

    public func writeIndentation(inout _: Target, level: Int) {
        tokens.append(.Indent(level))
    }

    public func writePadding(inout output: Target, count: Int) {
        for _ in 0..<count {
            emit(&output, string: pad)
        }
    }

    public func emit<T: OutputStreamType>(inout _: T, string: String) {
        // we don't actually write to the output here, but instead buffer all the tokens so we can later reformat them
        tokens.append(.Str(string))
    }

    public func writeEnd(inout output: Target) {
        // once we reach the end, compact and flush
        flush(&output)
    }

    /// Compact the tokens into peers that will fit on a single line of `maxline` length or less
    public func compact() {
        if tokens.isEmpty { return }

        func rangeBlock(index: Int, level: Int) -> Range<Int>? {
            let match = tokens.dropFirst(index).indexOf({
                if case .Indent(let lvl) = $0 where lvl == (level - 1) {
                    return true
                } else {
                    return false
                }
            })

            if let match = match {
                return index...match
            } else {
                return nil
            }
        }

        func toklen(token: BufferedJSONWriterToken) -> Int {
            switch token {
            case .Indent: return pad.characters.count // because indent will convert to a pad
            case .Str(let str): return str.characters.count
            }
        }

        func toklev(token: BufferedJSONWriterToken) -> Int {
            switch token {
            case .Indent(let lvl): return lvl
            case .Str: return 0
            }
        }

        func isStringToken(token: BufferedJSONWriterToken) -> Bool {
            switch token {
            case .Indent: return false
            case .Str: return true
            }
        }

        func compactRange(range: Range<Int>, level: Int) -> Bool {
            let strlen = tokens[range].reduce(0) { $0 + toklen($1) }
            let indentLen = level * spacer.characters.count
            if strlen + indentLen > maxline { return false }

            // the sum of the contiguous tokens are less than max line; replace all indents with a single space
            for i in range {
                if !isStringToken(tokens[i]) {
                    tokens[i] = .Str(pad)
                }
            }
            return true
        }

        func compactLevel(level: Int) {
            for var index = tokens.startIndex; index < tokens.endIndex; index = index.successor() {
                let item = tokens[index]
                switch item {
                case .Indent(let lvl) where lvl == level:
                    if let range = rangeBlock(index, level: lvl) where range.endIndex > range.startIndex {
                        compactRange(range, level: level)
                        index = range.endIndex // skip ahead
                    }
                default:
                    break
                }
            }
        }

        let maxlev = tokens.map(toklev).reduce(0, combine: max)
        for level in Array(0...maxlev).reverse() {
            compactLevel(level)
        }
    }

    public func flush<T: OutputStreamType>(inout output: T) {
        compact()
        for tok in tokens {
            switch tok {
            case .Str(let str):
                output.write(str)
            case .Indent(let level):
                output.write("\n")
                for _ in 0..<level {
                    output.write(spacer)
                }

            }
        }
        tokens.removeAll()
    }
}

