/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
import Either
import struct Foundation.Date
import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.UUID
import struct Foundation.Decimal

/// One or many of a thing
public enum Modicum<One, Many : Sequence> {
    case one(One)
    case many(Many)
}

extension Modicum : Equatable where One : Equatable, Many : Equatable { }
extension Modicum : Encodable where One : Encodable, Many : Encodable { }
extension Modicum : Decodable where One : Decodable, Many : Decodable { }
extension Modicum : Hashable where One : Hashable, Many : Hashable { }
extension Modicum : Sendable where One : Sendable, Many : Sendable { }

extension Modicum : Sequence {
    public func makeIterator() -> IndexingIterator<[Either<One>.Or<Many.Element>]> {
        switch self {
        case .one(let one): return [Either.Or(one)].makeIterator()
        case .many(let many): return many.map({ .init($0) }).makeIterator()
        }
    }
}

/// Either an Array or Dictionary of Values.
public typealias KeyableValues<Key : Hashable, Value> = Either<[Value]>.Or<[Key: Value]>

//extension KeyableValues {
//    public var values: [B.Value] {
//        switch self {
//        case .a(let a): return [a]
//        case .b(let b): return b.values
//        }
//    }
//}


/// A cluster it a value or a sequence of values or a map of keyed values.
public typealias Cluster<Key : Hashable, Value> = Modicum<Key, KeyableValues<Key, Value>>


/// A scalar that can contain a string type, a numeric type, a boolean type, and a null type.
public typealias StrNumBoolNull<StrType, NumType, BoolType, NullType> = Either<StrType>.Or<NumType>.Or<BoolType>.Or<NullType>

/// The base of a JSON scalar, which contains fixed boolean and null type and variable string and numeric types.
public typealias ScalarOf<StrType, NumType> = StrNumBoolNull<StrType, NumType, BooleanLiteralType, Never?>

/// A `String`, `Double`, `Bool`, or `Null` (represented by `Optional<Never>.none`)
public typealias Scalar = ScalarOf<StringLiteralType, FloatLiteralType>



// MARK: JSON Initializers

//extension JSON : ExpressibleByNilLiteral {
//    public init(nilLiteral: ()) {
//        self = .scalar(.init())
//    }
//}
//
//extension JSON : ExpressibleByIntegerLiteral {
//    public init(integerLiteral value: IntegerLiteralType) {
//        self = .scalar(.init(value))
//    }
//}
//
//extension JSON : ExpressibleByFloatLiteral {
//    public init(floatLiteral value: FloatLiteralType) {
//        self = .scalar(.init(.init(.init(value))))
//    }
//}
//
//extension JSON : ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral {
//    public init(stringLiteral value: StringLiteralType) {
//        self = .scalar(.init(value))
//    }
//
//    public init(extendedGraphemeClusterLiteral value: String) {
//        self = .scalar(.init(value))
//    }
//
//    public init(unicodeScalarLiteral value: String) {
//        self = .scalar(.init(value))
//    }
//}
//
//extension JSON : ExpressibleByArrayLiteral {
//    public init(arrayLiteral elements: JSON...) {
//        self = .array(elements)
//    }
//}




/// A JSum is a Joint Sum type, which is an enumeration that can represent one of:
///
/// - `JSum.bol`: `Bool`
/// - `JSum.str`: `String`
/// - `JSum.num`: `Double`
/// - `JSum.arr`: `Array<JSum>`
/// - `JSum.obj`: `Dictionary<String, JSum>`
/// - `JSum.nul`: `nil`
///
/// The type can be fluently represented with literals that closely match JSON, such as:
///
/// ```
/// let ob: JSum = [
///    "string": "hello",
///    "number": 1.23,
///    "null": nil,
///    "array": [1, nil, "foo"],
///    "object": [
///        "x": "a",
///        "y": 5,
///        "z": [:]
///    ]
/// ]
/// ```
///
/// JSum can be created by parsing JSON, YAML, or Property List sources.
///
/// They can also be used to instatiate a `Decodable` instance directly using the `Decodable.init(jsum:)` initializer.
@frozen public enum JSum : Hashable, Sendable {
    case arr([JSum]) // Array
    case obj(JObj) // Dictionary
    case str(String) // String
    case num(Double) // Number
    case bol(Bool) // Boolean
    case nul // Null
}

/// A `JObj` is the associated dictionary type for a `JSum.obj`, which is equivalent to a JSON "object".
public typealias JObj = [String: JSum]

public extension JSum {
    /// Returns the ``Bool`` value of type ``bol``.
    var bool: Bool? {
        switch self {
        case .bol(let b):
            return b
        default:
            return nil
        }
    }

    /// Returns the ``Int`` value of type ``num``.
    var int: Int? {
        switch self {
        case .num(let f):
            if Double(Int(f)) == f {
                return Int(f)
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    /// Returns the ``Double`` value of type ``num``.
    var double: Double? {
        switch self {
        case .num(let f):
            return f
        default:
            return nil
        }
    }

    /// Returns the ``String`` value of type ``str``.
    var string: String? {
        switch self {
        case .str(let s):
            return s
        default:
            return nil
        }
    }

    /// Returns the ``Array<JSum>`` value of type ``arr``.
    var array: [JSum]? {
        switch self {
        case .arr(let array):
            return array
        default:
            return nil
        }
    }

    /// Returns the ``dictionary<String, JSum>`` value of type ``obj``.
    var dictionary: [JObj.Key: JSum]? {
        switch self {
        case .obj(let dictionary):
            return dictionary
        default:
            return nil
        }
    }

    /// Returns the number of elements for an ``arr`` or key/values for an ``obj``
    var count: Int? {
        switch self {
        case .arr(let array):
            return array.count
        case .obj(let dictionary):
            return dictionary.count
        default:
            return nil
        }
    }
}
extension JSum : ExpressibleByNilLiteral {
    /// Creates ``nul`` JSum
    @inlinable public init(nilLiteral: ()) {
        self = .nul
    }
}

extension JSum : ExpressibleByBooleanLiteral {
    /// Creates boolean JSum
    @inlinable public init(booleanLiteral value: BooleanLiteralType) {
        self = .bol(value)
    }
}

extension JSum : ExpressibleByFloatLiteral {
    /// Creates numeric JSum
    @inlinable public init(floatLiteral value: FloatLiteralType) {
        self = .num(value)
    }
}

extension JSum : ExpressibleByIntegerLiteral {
    /// Creates numeric JSum
    @inlinable public init(integerLiteral value: IntegerLiteralType) {
        self = .num(Double(value))
    }
}

extension JSum : ExpressibleByArrayLiteral {
    /// Creates an array of JSum
    @inlinable public init(arrayLiteral elements: JSum...) {
        self = .arr(elements)
    }
}

extension JSum : ExpressibleByStringLiteral {
    /// Creates String JSum
    @inlinable public init(stringLiteral value: String) {
        self = .str(value)
    }
}

extension JSum : ExpressibleByDictionaryLiteral {
    /// Creates a dictionary of `String` to `JSum`
    @inlinable public init(dictionaryLiteral elements: (String, JSum)...) {
        var d: Dictionary<String, JSum> = [:]
        for (k, v) in elements { d[k] = v }
        self = .obj(d)
    }
}

/// Convenience accessors for the payloads of the various `JSum` types
public extension JSum {
    /// Returns the underlying String payload if this is a `JSum.str`, otherwise `.none`
    @inlinable var str: String? {
        guard case .str(let str) = self else { return .none }
        return str
    }

    /// Returns the underlying Boolean payload if this is a `JSum.bol`, otherwise `.none`
    @inlinable var bol: Bool? {
        guard case .bol(let bol) = self else { return .none }
        return bol
    }

    /// Returns the underlying Double payload if this is a `JSum.num`, otherwise `.none`
    @inlinable var num: Double? {
        guard case .num(let num) = self else { return .none }
        return num
    }

    /// Returns the underlying JObj payload if this is a `JSum.obj`, otherwise `.none`
    @inlinable var obj: JObj? {
        guard case .obj(let obj) = self else { return .none }
        return obj
    }

    /// Returns the underlying Array payload if this is a `JSum.arr`, otherwise `.none`
    @inlinable var arr: [JSum]? {
        guard case .arr(let arr) = self else { return .none }
        return arr
    }

    /// Returns the underlying `nil` payload if this is a `JSum.nul`, otherwise `.none`
    @inlinable var nul: Void? {
        guard case .nul = self else { return .none }
        return ()
    }

    /// JSum has a string subscript when it is an object type; setting a value on a non-obj type has no effect
    @inlinable subscript(key: String) -> JSum? {
        get {
            guard case .obj(let obj) = self else { return .none }
            return obj[key]
        }

        set {
            guard case .obj(var obj) = self else { return }
            obj[key] = newValue
            self = .obj(obj)
        }
    }

    /// JSum has a save indexed subscript when it is an array type; setting a value on a non-array type has no effect
    @inlinable subscript(index: Int) -> JSum? {
        get {
            guard case .arr(let arr) = self else { return .none }
            if index < 0 || index >= arr.count { return .none }
            return arr[index]
        }

        set {
            guard case .arr(var arr) = self else { return }
            if index < 0 || index >= arr.count { return }
            arr[index] = newValue ?? JSum.nul
            self = .arr(arr)
        }
    }
}

extension JSum : Encodable {
    @inlinable public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .nul: try container.encodeNil()
        case .bol(let x): try container.encode(x)
        case .num(let x): try container.encode(x)
        case .str(let x): try container.encode(x)
        case .obj(let x): try container.encode(x)
        case .arr(let x): try container.encode(x)
        }
    }
}

extension JSum : Decodable {
    @inlinable public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        func decode<T: Decodable>() throws -> T { try container.decode(T.self) }
        if container.decodeNil() {
            self = .nul
        } else {
            do {
                self = try .bol(container.decode(Bool.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try .num(container.decode(Double.self))
                } catch DecodingError.typeMismatch {
                    do {
                        self = try .str(container.decode(String.self))
                    } catch DecodingError.typeMismatch {
                        do {
                            self = try .arr(decode())
                        } catch DecodingError.typeMismatch {
                            do {
                                self = try .obj(decode())
                            } catch DecodingError.typeMismatch {
                                throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
                            }
                        }
                    }
                }
            }
        }
    }
}
