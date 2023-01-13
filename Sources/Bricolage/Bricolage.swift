//
//  BricIO.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 6/17/15.
//
import XOr

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

public protocol Bricolagable {
    func bricolage<B: Bricolage>() -> B
}

extension FidelityBricolage {
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

public extension Decoder {
    /// Throw an error if any unrecognized properties are present.
    /// - Parameters:
    ///   - keys: The list of keys to permit
    ///   - keySet: any additional keys to allow
    ///   - handler: the handler for missing keys; this defaults to throwing a `DecodingError.dataCorrupted`, but it could be changed to instead log a warning or attempt an alternate decoding method
    /// - Throws: an error if any keys exist that are not in the properties list
    @inlinable func forbidAdditionalProperties<S: Sequence, Key: CodingKey>(notContainedIn keys: S, or keySet: Set<String> = [], handler: (Decoder, [String]) throws -> () = { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: $0.codingPath, debugDescription: "Additional properties forbidden: \($1)")) }) throws where S.Element == Key {
        let unkeyed = try self.singleValueContainer()
        let raw = try unkeyed.decode([String: AnyDecodable].self)

        let keyStrings = keySet.union(keys.map(\.stringValue))

        let missingKeys = raw.keys.filter({ !keyStrings.contains($0) })
        if missingKeys.isEmpty == false {
            try handler(self, missingKeys)
        }
    }
}

/// An empty type that decodes from anything, used for creating a validation map
@usableFromInline
internal struct AnyDecodable : Decodable {
    @usableFromInline
    init(from decoder: Decoder) { }
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
public class FilterEncoder { // }: Combine.TopLevelEncoder // no need to import Combine just for this
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

