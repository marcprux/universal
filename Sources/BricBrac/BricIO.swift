//
//  BricIO.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 6/17/15.
//  Copyright © 2010-2020 io.glimpse. All rights reserved.
//

extension Bric : TextOutputStreamable {
    /// Streamable protocol implementation that writes the Bric as JSON to the given Target
    public func write<Target : TextOutputStream>(to target: inout Target) {
        writeJSON(&target)
    }

    /// Serializes this Bric as an ECMA-404 JSON Data Interchange Format string.
    ///
    /// - Parameter space: the number of indentation spaces to use for pretty-printing
    /// - Parameter maxline: fit pretty-printed output on a single line if it is less than maxline
    /// - Parameter mapper: When set, .Obj instances will be passed through the given mapper to filter, re-order, or modify the values
    public func stringify(space: Int = 0, maxline: Int = 0, bufferSize: Int? = nil, mapper: @escaping ([String: Bric])->AnyIterator<(key: String, value: Bric)> = { AnyIterator($0.makeIterator()) })->String {
        var str = String()
        if let bufferSize = bufferSize {
            str.reserveCapacity(bufferSize)
        }
        let spacer = String(repeating: " ", count: space)
        self.writeJSON(&str, spacer: spacer, maxline: maxline, mapper: mapper)
        return str
    }

    // the emission state; note that indexes go from -1...count, since the edges are markers for container open/close tokens
    fileprivate enum State {
        case arr(index: Int, array: [Bric])
        case obj(index: Int, object: [(key: String, value: Bric)])
    }

    public func writeJSON<Target: TextOutputStream>(_ output: inout Target, spacer: String = "", maxline: Int = 0, mapper: @escaping ([String: Bric])->AnyIterator<(key: String, value: Bric)> = { AnyIterator($0.makeIterator()) }) {
        if maxline <= 0 {
            writeJSON(&output, writer: FormattingJSONWriter<Target>(spacer: spacer), mapper: mapper)
        } else {
            writeJSON(&output, writer: BufferedJSONWriter(spacer: spacer, maxline: maxline), mapper: mapper)
        }
    }

    /// A non-recursive streaming JSON stringifier
    public func writeJSON<Target: TextOutputStream, Writer: JSONWriter>(_ output: inout Target, writer: Writer, mapper: @escaping ([String: Bric])->AnyIterator<(key: String, value: Bric)> = { AnyIterator($0.makeIterator()) }) where Writer.Target == Target {
        // the current stack of containers; we use this instead of recursion to track where we are in the process
        var stack: [State] = []

        writer.writeStart(&output)

        func processBric(_ bric: Bric) {
            switch bric {
            case .nul:
                writer.writeNull(&output)
            case .bol(let bol):
                writer.writeBoolean(&output, boolean: bol)
            case .str(let str):
                writer.writeString(&output, string: str)
            case .num(let num):
                writer.writeNumber(&output, number: num)
            case .arr(let arr):
                stack.append(State.arr(index: -1, array: arr))
            case .obj(let obj):
                let keyValues = Array(mapper(obj))
                stack.append(State.obj(index: -1, object: keyValues))
            }
        }

        func processArrayElement(_ index: Int, array: [Bric]) {
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

        func processObjectElement(_ index: Int, object: [(key: String, value: Bric)]) {
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
            case .arr(let index, let array):
                if index < array.count {
                    stack.append(.arr(index: index+1, array: array))
                }
                processArrayElement(index, array: array)
            case .obj(let index, let object):
                if index < object.count {
                    stack.append(.obj(index: index+1, object: object))
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

/// The various types that are encodable to bricolage
public enum BricolageEncodable {
    case null
    case bool(Bool)
    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case uint(UInt)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    case string(String)
    case float(Float)
    case double(Double)
}


/// **bricolage (brēˌkō-läzhˈ, brĭkˌō-)** *n. Something made or put together using whatever materials happen to be available*
///
/// Bricolage is the target storage for a JSON parser; for typical parsing, the storage is just `Bric`, but
/// other storages are possible:
///
/// * `EmptyBricolage`: doesn't store any data, and exists for fast validation of a document
/// * `FoundationBricolage`: storage that is compatible with Cocoa's `NSJSONSerialization` APIs
///
/// Note that nothing prevents `Bricolage` storage from being lossy, such as numeric types overflowing 
/// or losing precision from number strings
public protocol Bricolage {
    associatedtype NulType
    associatedtype StrType
    associatedtype NumType
    associatedtype BolType
    associatedtype ArrType
    associatedtype ObjType

    init(nul: NulType)
    init(str: StrType)
    init(num: NumType)
    init(bol: BolType)
    init(arr: ArrType)
    init(obj: ObjType)
    init?(encodable: BricolageEncodable)
    
    static func createNull() -> NulType
    
    static func createTrue() -> BolType
    
    static func createFalse() -> BolType
    
    static func createObject() -> ObjType
    
    static func createArray() -> ArrType
    
    static func createString(_ scalars: [UnicodeScalar]) -> StrType?
    
    static func createNumber(_ scalars: [UnicodeScalar]) -> NumType?
    
    static func putKeyValue(_ obj: ObjType, key: StrType, value: Self) -> ObjType
    
    static func putElement(_ arr: ArrType, element: Self) -> ArrType
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
    public init(encodable: BricolageEncodable) { }

    public static func createNull() -> NulType { }
    public static func createTrue() -> BolType { }
    public static func createFalse() -> BolType { }
    public static func createString(_ scalars: [UnicodeScalar]) -> StrType? { return StrType() }
    public static func createNumber(_ scalars: [UnicodeScalar]) -> NumType? { return NumType() }
    public static func createArray() -> ArrType { }
    public static func createObject() -> ObjType { }
    public static func putElement(_ arr: ArrType, element: EmptyBricolage) -> ArrType { }
    public static func putKeyValue(_ obj: ObjType, key: StrType, value: EmptyBricolage) -> ObjType { }
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

    case nul(NulType)
    case bol(BolType)
    case str(StrType)
    case num(NumType)
    case arr(ArrType)
    case obj(ObjType)

    public init(nul: NulType) { self = .nul(nul) }
    public init(bol: BolType) { self = .bol(bol) }
    public init(str: StrType) { self = .str(str) }
    public init(num: NumType) { self = .num(num) }
    public init(arr: ArrType) { self = .arr(arr) }
    public init(obj: ObjType) { self = .obj(obj) }
    public init?(encodable: BricolageEncodable) { return nil } // cannot encode to fidelity

    public static func createNull() -> NulType { }
    public static func createTrue() -> BolType { return true }
    public static func createFalse() -> BolType { return false }
    public static func createObject() -> ObjType { return ObjType() }
    public static func createArray() -> ArrType { return ArrType() }
    public static func createString(_ scalars: [UnicodeScalar]) -> StrType? { return scalars }
    public static func createNumber(_ scalars: [UnicodeScalar]) -> NumType? { return scalars }
    public static func putElement(_ arr: ArrType, element: FidelityBricolage) -> ArrType { return arr + [element] }
    public static func putKeyValue(_ obj: ObjType, key: StrType, value: FidelityBricolage) -> ObjType { return obj + [(key, value)] }
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
        case .nul:
            return B(nul: B.createNull())
        case .bol(let bol):
            return B(bol: bol ? B.createTrue() : B.createFalse())
        case .str(let str):
            return B.createString(str).flatMap({ B(str: $0) }) ?? B(nul: B.createNull())
        case .num(let num):
            return B.createNumber(num).flatMap({ B(num: $0) }) ?? B(nul: B.createNull())
        case .arr(let arr):
            var array = B.createArray()
            for x in arr {
                array = B.putElement(array, element: x.bricolage())
            }
            return B(arr: array)
        case .obj(let obj):
            var object = B.createObject()
            for x in obj {
                if let key = B.createString(x.0) {
                    object = B.putKeyValue(object, key: key, value: x.1.bricolage())
                }
            }
            return B(obj: object)
        }
    }
}

extension FidelityBricolage : ExpressibleByNilLiteral {
    public init(nilLiteral: ()) { self = .nul(FidelityBricolage.createNull()) }
}

extension FidelityBricolage : ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bol(value ? FidelityBricolage.createTrue() : FidelityBricolage.createFalse())
    }
}

extension FidelityBricolage : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .str(Array(value.unicodeScalars))
    }

    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .str(Array(value.unicodeScalars))
    }

    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .str(Array(value.unicodeScalars))
    }
}

extension FidelityBricolage : ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .num(Array(String(value).unicodeScalars))
    }
}

extension FidelityBricolage : ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .num(Array(String(value).unicodeScalars))
    }
}

extension FidelityBricolage : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: FidelityBricolage...) {
        self = .arr(elements)
    }
}

extension FidelityBricolage : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, FidelityBricolage)...) {
        self = .obj(elements.map({ (key, value) in (Array(key.unicodeScalars), value) }))
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

    public init(nul: NulType) { self = .nul }
    public init(bol: BolType) { self = .bol(bol) }
    public init(str: StrType) { self = .str(str) }
    public init(num: NumType) { self = .num(num) }
    public init(arr: ArrType) { self = .arr(arr) }
    public init(obj: ObjType) { self = .obj(obj) }
    public init(encodable: BricolageEncodable) {
        switch encodable {
        case .null: self = .nul
        case .bool(let x): self = .bol(x)
        case .int(let x): self = .num(Double(x))
        case .int8(let x): self = .num(Double(x))
        case .int16(let x): self = .num(Double(x))
        case .int32(let x): self = .num(Double(x))
        case .int64(let x): self = .num(Double(x))
        case .uint(let x): self = .num(Double(x))
        case .uint8(let x): self = .num(Double(x))
        case .uint16(let x): self = .num(Double(x))
        case .uint32(let x): self = .num(Double(x))
        case .uint64(let x): self = .num(Double(x))
        case .string(let x): self = .str(x)
        case .float(let x): self = .num(Double(x))
        case .double(let x): self = .num(x)
        }
    }

    public static func createNull() -> NulType { }
    public static func createTrue() -> BolType { return true }
    public static func createFalse() -> BolType { return false }
    public static func createObject() -> ObjType { return ObjType() }
    public static func createArray() -> ArrType { return ArrType() }
    public static func createString(_ scalars: [UnicodeScalar]) -> StrType? { return String(scalars: scalars) }
    public static func createNumber(_ scalars: [UnicodeScalar]) -> NumType? { return Double(String(scalars: scalars)) }
    public static func putElement(_ arr: ArrType, element: Bric) -> ArrType { return arr + [element] }
    public static func putKeyValue(_ object: ObjType, key: StrType, value: Bric) -> ObjType {
        var obj = object
        obj[key] = value
        return obj
    }
}

extension Bricolage {
    /// Parses the given JSON string and returns some Bric
    public static func parse(_ string: String, options: JSONParser.Options = .Strict) throws -> Self {
        return try parseBricolage(Array(string.unicodeScalars), options: options)
        // the following also works fine, but converting to an array first is dramatically faster (over 2x faster for caliper.json)
        // return try Bric.parseBricolage(string.unicodeScalars, options: options)
    }

    /// Parses the given JSON array of unicode scalars and returns some Bric
    public static func parse(_ scalars: [UnicodeScalar], options: JSONParser.Options = .Strict) throws -> Self {
        return try parseJSON(scalars, options: options)
    }
}


extension Bricolage {
    /// Validates the given JSON string and throws an error if there was a problem
    public static func validate(_ string: String, options: JSONParser.Options) throws {
        try JSONParser(options: options).parse(Array(string.unicodeScalars), complete: true)
    }

    /// Validates the given array of JSON unicode scalars and throws an error if there was a problem
    public static func validate(_ scalars: [UnicodeScalar], options: JSONParser.Options) throws {
        try JSONParser(options: options).parse(scalars, complete: true)
    }
}

private enum Container<T : Bricolage> {
    case object(T.ObjType, T.StrType?)
    case array(T.ArrType)
}

extension Bricolage {
    public static func parseJSON(_ scalars: [UnicodeScalar], options opts: JSONParser.Options) throws -> Self {
        return try parseBricolage(scalars, options: opts)
    }

    public static func parseBricolage<S: Sequence>(_ scalars: S, options opts: JSONParser.Options) throws -> Self where S.Iterator.Element == UnicodeScalar {
        typealias T = Self
        var current: T = T(nul: T.createNull()) // the current object being processed

        // the delegate merely remembers the last top-most bric element (which will hold all the children)
        var parser = bricolageParser(options: opts) { (bric, level) in
            if level == 0 { current = bric }
            return bric
        }

        assert(isKnownUniquelyReferenced(&parser))
        try parser.parse(scalars, complete: true)
        assert(isKnownUniquelyReferenced(&parser)) // leak prevention
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
    public static func bricolageParser(options opts: JSONParser.Options, delegate: @escaping (Self, _ level: Int) -> Self) -> JSONParser {

        typealias T = Self

        // the stack holds all of the currently-open containers; in order to handle parsing
        // top-level non-containers, the top of the stack is always an array that should
        // contain only a single element
        var stack: [Container<T>] = []

        let parser = JSONParser(options: opts)

        parser.delegate = { [unowned parser] event in

            func err(_ msg: String) -> ParseError { return ParseError(msg: msg, line: parser.row, column: parser.col) }

            func closeContainer() throws {
                if stack.count <= 0 { throw err("Cannot close top-level container") }
                switch stack.removeLast() {
                case .object(let x, _): try pushValue(T(obj: x))
                case .array(let x): try pushValue(T(arr: x))
                }
            }

            func pushValue(_ x: T) throws {
                // inform the delegate that we have seen a fully-formed Bric
                let value = delegate(x, stack.count)

                switch stack.last {
                case .some(.object(let x, let key)):
                    if let key = key {
                        stack[(stack.endIndex - 1)] = .object(T.putKeyValue(x, key: key, value: value), .none)
                    } else {
                        throw err("Put object with no key type")
                    }
                case .some(.array(let x)):
                    stack[(stack.endIndex - 1)] = .array(T.putElement(x, element: value))
                case .none:
                    break
                }
            }

           switch event {
            case .objectStart:
                stack.append(.object(T.createObject(), .none))
            case .objectEnd:
                try closeContainer()
            case .arrayStart:
                stack.append(.array(T.createArray()))
            case .arrayEnd:
                try closeContainer()
            case .stringContent(let s, let e):
                let escaped = try JSONParser.unescape(s, escapeIndices: e, line: parser.row, column: parser.col)
                if let str = T.createString(escaped) {
                    if case .some(.object(let x, let key)) = stack.last , key == nil {
                        stack[(stack.endIndex - 1)] = .object(x, str)
                        _ = delegate(T(str: str), stack.count)
                    } else {
                        try pushValue(T(str: str))
                    }
                } else {
                    throw err("Unable to create string")
                }
            case .number(let n):
                if let num = T.createNumber(Array(n)) {
                    try pushValue(T(num: num))
                } else {
                    throw err("Unable to create number")
                }
            case .`true`:
                try pushValue(T(bol: T.createTrue()))
            case .`false`:
                try pushValue(T(bol: T.createFalse()))
            case .null:
                try pushValue(T(nul: T.createNull()))
           case .whitespace, .elementSeparator, .keyValueSeparator, .stringStart, .stringEnd:
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
    associatedtype Target

    func writeStart(_ output: inout Target)
    func writeEnd(_ output: inout Target)

    func writeIndentation(_ output: inout Target, level: Int)
    func writeNull(_ output: inout Target)
    func writeBoolean(_ output: inout Target, boolean: Bool)
    func writeNumber(_ output: inout Target, number: Double)
    func writeString(_ output: inout Target, string: String)

    func writePadding(_ output: inout Target, count: Int)

    func writeArrayOpen(_ output: inout Target)
    func writeArrayClose(_ output: inout Target)
    func writeArrayDelimiter(_ output: inout Target)

    func writeObjectOpen(_ output: inout Target)
    func writeObjectClose(_ output: inout Target)
    func writeObjectSeparator(_ output: inout Target)
    func writeObjectDelimiter(_ output: inout Target)

    func emit(_ output: inout Target, string: String)
}

/// Default implementations of common JSONWriter functions when the target is an output stream
public extension JSONWriter {
    func writeStart(_ output: inout Target) {

    }

    func writeEnd(_ output: inout Target) {
        
    }

    func writeString(_ output: inout Target, string: String) {
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

    func writeNull(_ output: inout Target) {
        emit(&output, string: "null")
    }

    func writeBoolean(_ output: inout Target, boolean: Bool) {
        if boolean == true {
            emit(&output, string: "true")
        } else {
            emit(&output, string: "false")
        }
    }

    func writeNumber(_ output: inout Target, number: Double) {
        // TODO: output exactly the same as the ECMA spec: http://es5.github.io/#x15.7.4.2
        // see also: http://www.netlib.org/fp/dtoa.c
        let str = String(number) // FIXME: this outputs exponential notation for some large numbers
        // when a string ends in ".0", we just append the rounded int FIXME: better string formatting
        let suffix = str.suffix(2)
        if suffix.first == "." && suffix.last == "0" {
            emit(&output, string: String(str.dropLast(2)))
        } else {
            emit(&output, string: str)
        }
    }


    func writeArrayOpen(_ output: inout Target) {
        emit(&output, string: "[")
    }

    func writeArrayClose(_ output: inout Target) {
        emit(&output, string: "]")
    }

    func writeArrayDelimiter(_ output: inout Target) {
        emit(&output, string: ",")
    }

    func writeObjectOpen(_ output: inout Target) {
        emit(&output, string: "{")
    }

    func writeObjectClose(_ output: inout Target) {
        emit(&output, string: "}")
    }

    func writeObjectSeparator(_ output: inout Target) {
        emit(&output, string: ":")
    }

    func writeObjectDelimiter(_ output: inout Target) {
        emit(&output, string: ",")
    }
}

public struct FormattingJSONWriter<Target: TextOutputStream> : JSONWriter {
    let spacer: String

    public func writeIndentation(_ output: inout Target, level: Int) {
        if !spacer.isEmpty {
            emit(&output, string: "\n")
            for _ in 0..<level {
                emit(&output, string: spacer)
            }
        }
    }

    public func writePadding(_ output: inout Target, count: Int) {
        if !spacer.isEmpty {
            emit(&output, string: String(repeating: " ", count: count))
        }
    }

    public func emit(_ output: inout Target, string: String) {
        output.write(string)
    }
}

public enum BufferedJSONWriterToken {
    case str(String)
    case indent(Int)
}

/// A `JSONWriter` implementation that buffers the output in order to apply advanced formatting
open class BufferedJSONWriter<Target: TextOutputStream> : JSONWriter {
    open var tokens: [BufferedJSONWriterToken] = []
    let spacer: String
    let maxline: Int
    let pad: String = " "

    public init(spacer: String, maxline: Int) {
        self.spacer = spacer
        self.maxline = maxline
    }

    open func writeIndentation(_: inout Target, level: Int) {
        tokens.append(.indent(level))
    }

    open func writePadding(_ output: inout Target, count: Int) {
        for _ in 0..<count {
            emit(&output, string: pad)
        }
    }

    open func emit<T: TextOutputStream>(_: inout T, string: String) {
        // we don't actually write to the output here, but instead buffer all the tokens so we can later reformat them
        tokens.append(.str(string))
    }

    open func writeEnd(_ output: inout Target) {
        // once we reach the end, compact and flush
        flush(&output)
    }

    /// Compact the tokens into peers that will fit on a single line of `maxline` length or less
    open func compact() {
        if tokens.isEmpty { return }

        func rangeBlock(_ index: Int, level: Int) -> CountableClosedRange<Int>? {
            let match = tokens.dropFirst(index).firstIndex(where: {
                if case .indent(let lvl) = $0 , lvl == (level - 1) {
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

        func toklen(_ token: BufferedJSONWriterToken) -> Int {
            switch token {
            case .indent: return pad.count // because indent will convert to a pad
            case .str(let str): return str.count
            }
        }

        func toklev(_ token: BufferedJSONWriterToken) -> Int {
            switch token {
            case .indent(let lvl): return lvl
            case .str: return 0
            }
        }

        func isStringToken(_ token: BufferedJSONWriterToken) -> Bool {
            switch token {
            case .indent: return false
            case .str: return true
            }
        }

        @discardableResult func compactRange(_ range: CountableClosedRange<Int>, level: Int) -> Bool {
            let strlen = tokens[range].reduce(0) { $0 + toklen($1) }
            let indentLen = level * spacer.count
            if strlen + indentLen > maxline { return false }

            // the sum of the contiguous tokens are less than max line; replace all indents with a single space
            for i in range {
                if !isStringToken(tokens[i]) {
                    tokens[i] = .str(pad)
                }
            }
            return true
        }

        func compactLevel(_ level: Int) {
            for index in tokens.indices {
                let item = tokens[index]
                switch item {
                case .indent(let lvl) where lvl == level:
                    if let range = rangeBlock(index, level: lvl) , range.upperBound > range.lowerBound {
                        compactRange(range, level: level)
                        return
                    }
                default:
                    break
                }
            }
        }

        let maxlev = tokens.map(toklev).reduce(0, max)
        for level in Array(0...maxlev).reversed() {
            compactLevel(level)
        }
    }

    open func flush<T: TextOutputStream>(_ output: inout T) {
        compact()
        for tok in tokens {
            switch tok {
            case .str(let str):
                output.write(str)
            case .indent(let level):
                output.write("\n")
                for _ in 0..<level {
                    output.write(spacer)
                }

            }
        }
        tokens.removeAll()
    }
}

public extension Encodable {
    /// Find every child of this encodable instance of the given type.
    func encodableChildrenOfType<T: Encodable>(_ type: T.Type) throws -> [T] {
        var values: [T] = []
        try FilterEncoder.encode(self, handler: { (key, value) in
            if let item = value as? T {
                values.append(item)
            }
        })
        return values
    }
}

/// Extension similar to the built-in `decodeIfPresent` methods in an `KeyedDecodingContainerProtocol`
/// implementation, but provides support for correct `Nullable` type decoding, working around the issue
/// where `decodeIfPresent` will consume a `null` value before passing it to the underlying type which,
/// like `ExplicitNull`, might want to provide significance to `null` values.
public extension KeyedDecodingContainerProtocol {

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: Bool.Type, forKey key: Self.Key) throws -> Bool? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: String.Type, forKey key: Self.Key) throws -> String? {
       try decodeIfPresent(type, forKey: key)
   }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: Double.Type, forKey key: Self.Key) throws -> Double? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: Float.Type, forKey key: Self.Key) throws -> Float? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: Int.Type, forKey key: Self.Key) throws -> Int? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: Int8.Type, forKey key: Self.Key) throws -> Int8? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: Int16.Type, forKey key: Self.Key) throws -> Int16? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: Int32.Type, forKey key: Self.Key) throws -> Int32? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: Int64.Type, forKey key: Self.Key) throws -> Int64? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: UInt.Type, forKey key: Self.Key) throws -> UInt? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: UInt8.Type, forKey key: Self.Key) throws -> UInt8? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: UInt16.Type, forKey key: Self.Key) throws -> UInt16? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: UInt32.Type, forKey key: Self.Key) throws -> UInt32? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional(_ type: UInt64.Type, forKey key: Self.Key) throws -> UInt64? {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decodeIfPresent`
    @inlinable func decodeOptional<T>(_ type: T.Type, forKey key: Self.Key) throws -> T? where T : Decodable {
        try decodeIfPresent(type, forKey: key)
    }

    /// Pass-through to `decode` if the `ExplicitNull` is present in the container; permits the distinction between `null` and `undefined`.
    @inlinable func decodeOptional(_ type: ExplicitNull.Type, forKey key: Self.Key) throws -> ExplicitNull? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<Bool>.Type, forKey key: Self.Key) throws -> Nullable<Bool>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<String>.Type, forKey key: Self.Key) throws -> Nullable<String>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<Double>.Type, forKey key: Self.Key) throws -> Nullable<Double>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<Float>.Type, forKey key: Self.Key) throws -> Nullable<Float>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<Int>.Type, forKey key: Self.Key) throws -> Nullable<Int>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<Int8>.Type, forKey key: Self.Key) throws -> Nullable<Int8>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<Int16>.Type, forKey key: Self.Key) throws -> Nullable<Int16>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<Int32>.Type, forKey key: Self.Key) throws -> Nullable<Int32>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<Int64>.Type, forKey key: Self.Key) throws -> Nullable<Int64>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<UInt>.Type, forKey key: Self.Key) throws -> Nullable<UInt>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<UInt8>.Type, forKey key: Self.Key) throws -> Nullable<UInt8>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<UInt16>.Type, forKey key: Self.Key) throws -> Nullable<UInt16>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<UInt32>.Type, forKey key: Self.Key) throws -> Nullable<UInt32>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional(_ type: Nullable<UInt64>.Type, forKey key: Self.Key) throws -> Nullable<UInt64>? {
        contains(key) ? try decode(type, forKey: key) : .none
    }

    /// Pass-through to `decode` if the `Nullable` is present in the container
    @inlinable func decodeOptional<T>(_ type: Nullable<T>.Type, forKey key: Self.Key) throws -> Nullable<T>? where T : Decodable {
        contains(key) ? try decode(type, forKey: key) : .none
    }
}

/// A no-op encoder that simply passes every encodable element through the specific callback filter.
public class FilterEncoder {
    public typealias Element = (key: [CodingKey], value: Encodable?)

    public static func encode<T: Encodable>(_ value: T, handler: @escaping (Element) -> ()) throws {
        let encoding = FilterEncoding(codingPath: [], to: handler)
        try value.encode(to: encoding)
    }

    private struct FilterEncoding: Encoder {
        let codingPath: [CodingKey]
        private let filter: (Element) -> ()

        init(codingPath: [CodingKey], to filter: @escaping (Element) -> ()) {
            self.codingPath = codingPath
            self.filter = filter
        }

        let userInfo: [CodingUserInfoKey : Any] = [:]

        func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
            return KeyedEncodingContainer(FilterKeyedEncoding<Key>(codingPath: codingPath, to: filter))
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            return FilterUnkeyedEncoding(codingPath: codingPath, to: filter)
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            let container = FilterSingleValueEncoding(codingPath: codingPath, to: filter)
            return container
        }
    }

    private struct FilterKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {
        let codingPath: [CodingKey]
        private let filter: (Element) -> ()

        init(codingPath: [CodingKey], to filter: @escaping (Element) -> ()) {
            self.codingPath = codingPath
            self.filter = filter
        }

        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            filter((key: codingPath, value: value))
            try value.encode(to: FilterEncoding(codingPath: codingPath, to: filter))
        }

        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
            return KeyedEncodingContainer(FilterKeyedEncoding<NestedKey>(codingPath: codingPath + [key], to: filter))
        }

        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            return FilterUnkeyedEncoding(codingPath: codingPath + [key], to: filter)
        }

        func superEncoder() -> Encoder {
            let superKey = Key(stringValue: "super")!
            return superEncoder(forKey: superKey)
        }

        func superEncoder(forKey key: Key) -> Encoder {
            return FilterEncoding(codingPath: codingPath + [key], to: filter)
        }

        func encodeNil(forKey key: Key) throws { filter((key: codingPath + [key], value: nil)) }
        func encode(_ value: Bool, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: String, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: Double, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: Float, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: Int, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: Int8, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: Int16, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: Int32, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: Int64, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: UInt, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: UInt8, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: UInt16, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: UInt32, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
        func encode(_ value: UInt64, forKey key: Key) throws { filter((key: codingPath + [key], value: value)) }
    }

    private struct FilterUnkeyedEncoding: UnkeyedEncodingContainer {
        let codingPath: [CodingKey]
        private let filter: (Element) -> ()
        private(set) var count: Int = 0

        init(codingPath: [CodingKey], to filter: @escaping (Element) -> ()) {
            self.codingPath = codingPath
            self.filter = filter
        }

        private mutating func nextIndexedKey() -> CodingKey {
            let nextCodingKey = IndexedCodingKey(intValue: count)!
            count += 1
            return nextCodingKey
        }

        private struct IndexedCodingKey: CodingKey {
            let intValue: Int?
            let stringValue: String

            init?(intValue: Int) {
                self.intValue = intValue
                self.stringValue = intValue.description
            }

            init?(stringValue: String) {
                return nil
            }
        }

        mutating func encode<T: Encodable>(_ value: T) throws {
            let encoding = FilterEncoding(codingPath: codingPath + [nextIndexedKey()], to: filter)
            filter((key: encoding.codingPath, value: value))
            try value.encode(to: encoding)
        }

        mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
            return KeyedEncodingContainer(FilterKeyedEncoding<NestedKey>(codingPath: codingPath + [nextIndexedKey()], to: filter))
        }

        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            return FilterUnkeyedEncoding(codingPath: codingPath + [nextIndexedKey()], to: filter)
        }

        mutating func superEncoder() -> Encoder {
            return FilterEncoding(codingPath: [nextIndexedKey()], to: filter)
        }

        mutating func encodeNil() throws { filter((key: codingPath + [nextIndexedKey()], value: nil)) }
        mutating func encode(_ value: Bool) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: String) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: Double) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: Float) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: Int) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: Int8) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: Int16) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: Int32) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: Int64) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: UInt) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: UInt8) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: UInt16) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: UInt32) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
        mutating func encode(_ value: UInt64) throws { filter((key: codingPath + [nextIndexedKey()], value: value)) }
    }

    private struct FilterSingleValueEncoding: SingleValueEncodingContainer {
        private let filter: (Element) -> ()
        let codingPath: [CodingKey]

        init(codingPath: [CodingKey], to filter: @escaping (Element) -> ()) {
            self.codingPath = codingPath
            self.filter = filter
        }

        func encode<T: Encodable>(_ value: T) throws {
            let encoding = FilterEncoding(codingPath: codingPath, to: filter)
            try value.encode(to: encoding)
            filter((key: encoding.codingPath, value: value))
        }

        func encodeNil() throws { filter((key: codingPath, value: nil)) }
        func encode(_ value: Bool) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: String) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: Double) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: Float) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: Int) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: Int8) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: Int16) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: Int32) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: Int64) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: UInt) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: UInt8) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: UInt16) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: UInt32) throws { filter((key: codingPath, value: value)) }
        func encode(_ value: UInt64) throws { filter((key: codingPath, value: value)) }
    }
}


