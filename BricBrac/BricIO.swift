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
    /// :param: mapper When set, .Obj instances will be passed through the given mapper to filter, re-order, or modify the values
    @warn_unused_result
    public func stringify(space space: Int = 0, bufferSize: Int? = nil, recursive: Bool = false, mapper: [String: Bric]->AnyGenerator<(String, Bric)> = { anyGenerator($0.generate()) })->String {
        if recursive {
            return stringifyRecursive(level: 1, space: space, mapper: mapper)
        } else {
            var str = String()
            if let bufferSize = bufferSize {
                str.reserveCapacity(bufferSize)
            }
            self.writeJSON(&str, space: space, mapper: mapper)
            return str
        }
    }

    // the emission state; note that indexes go from -1...count, since the edges are markers for container open/close tokens
    private enum State {
        case Arr(index: Int, array: [Bric])
        case Obj(index: Int, object: [(String, Bric)])
    }

    /// A non-recursive streaming JSON stringifier
    public func writeJSON<Target: OutputStreamType>(inout output: Target, space: Int = 0, mapper: [String: Bric]->AnyGenerator<(String, Bric)> = { anyGenerator($0.generate()) }) {
        // the current stack of containers; we use this instead of recursion to track where we are in the process
        var stack: [State] = []

        func indent(level: Int) {
            if space != 0 {
                output.write("\n")
            }
            for _ in 0..<space*level {
                output.write(" ")
            }
        }

        func quoteString(str: String) {
            output.write("\"")
            for c in str.unicodeScalars {
                switch c {
                case "\\": output.write("\\\\")
                case "\n": output.write("\\n")
                case "\r": output.write("\\r")
                case "\t": output.write("\\t")
                case "\"": output.write("\\\"")
                // case "/": output.write("\\/") // you may escape slashes, but we don't (neither does JSC's JSON.stringify)
                case UnicodeScalar(0x08): output.write("\\b") // backspace
                case UnicodeScalar(0x0C): output.write("\\f") // formfeed
                default: output.write(String(c))
                }
            }
            output.write("\"")
        }


        func processBric(bric: Bric) {
            switch bric {
            case .Nul:
                output.write("null")
            case .Bol(let bol):
                if bol == true {
                    output.write("true")
                } else {
                    output.write("false")
                }
            case .Str(let str):
                quoteString(str)
            case .Num(let num):
                let str = String(num) // FIXME: this outputs exponential notation for some large numbers
                // when a string ends in ".0", we just append the rounded int FIXME: better string formatting
                if str.hasSuffix(".0") {
                    output.write(str[str.startIndex..<str.endIndex.predecessor().predecessor()])
                } else {
                    output.write(str)
                }
            case .Arr(let arr):
                stack.append(State.Arr(index: -1, array: arr))
            case .Obj(let obj):
                let keyValues = Array(mapper(obj))
                stack.append(State.Obj(index: -1, object: keyValues))
            }
        }

        func processArrayElement(index: Int, array: [Bric]) {
            if index == -1 {
                output.write("[")
                return
            } else if index == array.count {
                if index > 0 { indent(stack.count) }
                output.write("]")
                return
            } else if index > 0 {
                output.write(",")
            }

            let element = array[index]
            indent(stack.count)

            processBric(element)
        }

        func processObjectElement(index: Int, object: [(String, Bric)]) {
            if index == -1 {
                output.write("{")
                return
            } else if index == object.count {
                if index > 0 { indent(stack.count) }
                output.write("}")
                return
            } else if index > 0 {
                output.write(",")
            }

            let element = object[index]
            indent(stack.count)
            quoteString(element.0)
            output.write(":")
            if space > 0 { output.write(" ") }

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
    }

    // OLD slow version
    /// Serializes this Bric as an ECMA-404 JSON Data Interchange Format string.
    ///
    /// :param: mapper When set, .Obj instances will be passed through the given mapper to filter, re-order, or modify the values
    ///
    /// *Note* This is about 2x-3x slower than NSJSONSerialization
    @warn_unused_result
    private func stringifyRecursive(level level: Int = 1, space: Int? = nil, mapper: [String: Bric]->AnyGenerator<(String, Bric)> = { anyGenerator($0.generate()) })->String {
        func quoteString(str: String)->String {
            return "\"" + str.replace("\"", replacement: "\\\"") + "\""
        }

        let pre1 = String(count: (space ?? 0)*(level-1), repeatedValue: Character(" "))
        let pre2 = String(count: (space ?? 0)*(level), repeatedValue: Character(" "))
        let post = (space != nil) ? "\n" : ""
        let colon = (space != nil) ? " : " : ":"
        let comma = ","

        switch self {
        case .Nul:
            return "null"
        case .Bol(let bol):
            return bol ? "true" : "false"
        case .Str(let str):
            return quoteString(str)
        case .Num(let num):
            return num == Double(Int(num)) ? String(Int(num)) : String(num) // FIXME: "0.6000000000000001" outputs as "0.6"
        case .Arr(let arr):
            var buffer = ""
            for e in arr {
                if !buffer.isEmpty { buffer += comma }
                buffer += post + pre2 + e.stringifyRecursive(level: level+1, space: space, mapper: mapper)
            }
            return "[" + buffer + post + pre1 + "]"
        case .Obj(let obj):
            var buffer = ""
            for (key, value) in mapper(obj) {
                if !buffer.isEmpty { buffer += comma }
                buffer += post + pre2 + quoteString(key) + colon + value.stringifyRecursive(level: level+1, space: space, mapper: mapper)
            }
            return "{" + buffer + post + pre1 + "}"
        }
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

//public protocol FluentBricolageType : Bricolage {
//}
//
//public extension FluentBricolageType where ArrType : RangeReplaceableCollectionType, ArrType.Generator.Element == Self {
//    static func putElement(var arr: ArrType, element: Self) -> ArrType {
//        arr.append(element)
//        return arr
//    }
//}
//
//public enum FluentBricolage<BolType : BooleanLiteralConvertible, StrType : StringLiteralConvertible, ArrType : RangeReplaceableCollectionType where BolType.BooleanLiteralType == Bool, StrType.StringLiteralType == String> : FluentBricolageType {
//    public typealias NulType = Void
//    public typealias NumType = Array<UnicodeScalar>
//    public typealias ObjType = Array<(StrType, FluentBricolage)>
//
//    case Nul(NulType)
//    case Bol(BolType)
//    case Str(StrType)
//    case Num(NumType)
//    case Arr(ArrType)
//    case Obj(ObjType)
//
//    public init(nul: NulType) { self = .Nul(nul) }
//    public init(bol: BolType) { self = .Bol(bol) }
//    public init(str: StrType) { self = .Str(str) }
//    public init(num: NumType) { self = .Num(num) }
//    public init(arr: ArrType) { self = .Arr(arr) }
//    public init(obj: ObjType) { self = .Obj(obj) }
//
//    public static func createNull() -> NulType { }
//    public static func createTrue() -> BolType { return BolType(booleanLiteral: true) }
//    public static func createFalse() -> BolType { return BolType(booleanLiteral: false) }
//    public static func createObject() -> ObjType { return ObjType() }
//    public static func createArray() -> ArrType { return ArrType() }
//    public static func createString(scalars: [UnicodeScalar]) -> StrType? { return StrType(stringLiteral: String(String.UnicodeScalarView() + scalars)) }
//    public static func createNumber(scalars: [UnicodeScalar]) -> NumType? { return scalars }
//
////    public static func putElement(var arr: ArrType, element: FluentBricolage) -> ArrType {
////        arr.append(element)
//////        arr.append(element)
////        return arr
////    }
//
//    public static func putKeyValue(var obj: ObjType, key: StrType, value: FluentBricolage) -> ObjType {
//        obj.append((key, value))
//        return obj
//    }
//}
//
//public typealias FluentBric = FluentBricolage<Bool, String, Array<FluentBric>>

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

extension Bric {
    /// Parses the given JSON string and returns some Bric
    public static func parse(string: String, options: JSONParser.Options = .Strict) throws -> Bric {
        return try Bric.parseBricolage(Array(string.unicodeScalars), options: options)
        // the following also works fine, but converting to an array first is dramatically faster (over 2x faster for caliper.json)
        // return try Bric.parseBricolage(string.unicodeScalars, options: options)
    }

    /// Parses the given JSON array of unicode scalars and returns some Bric
    public static func parse(scalars: [UnicodeScalar], options: JSONParser.Options = .Strict) throws -> Bric {
        return try Bric.parseJSON(scalars, options: options)
    }
}


extension Bric {
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
//        var view = String.UnicodeScalarView()
//        view.reserveCapacity(scalars.count)
//        view.extend(scalars)
//        self = String(view)
        self = String(String.UnicodeScalarView() + scalars) // seems a tiny bit faster
    }
}

