//
//  JSONParser.swift
//
//  Created by Marc Prud'hommeaux on 8/20/15.
//
import Quanta
import struct Foundation.Data

/// A JSON tree node, which can contain a `Scalar` (`String`, `Double`, `Bool`, or `Null`), `[JSON]`, or `[String: JSON]`
public struct JSON : Isomorph, Sendable, Hashable {
    public typealias Scalar = ScalarOf<StringLiteralType, FloatLiteralType>
    public typealias Object = [String: Self]
    public typealias RawValue = Either<Scalar>.Or<Object.Quanta>

    /// A JSON `null`
    public static let null = JSON(nilLiteral: ())

    /// A JSON `true`
    public static let `true` = JSON(booleanLiteral: true)

    /// A JSON `false`
    public static let `false` = JSON(booleanLiteral: false)

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    /// Creates a JSON scalar from the given string
    public init<S: StringProtocol>(_ string: S) {
        self = JSON(stringLiteral: String(string))
    }

    /// Creates a JSON scalar from the given number
    public init<N: BinaryFloatingPoint>(_ number: N) {
        self = JSON(floatLiteral: Double(number))
    }

    /// Creates a JSON scalar from the given boolean
    public init(_ boolean: Bool) {
        self = JSON(booleanLiteral: boolean)
    }

    /// Returns true if this represents the JSON literal `null`.
    public var isNull: Bool {
        self == JSON.null
    }
}


// MARK: JSON Initializers

extension JSON : ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.rawValue = .init(.init(.init(.init(ScalarNull.none))))
    }
}

extension JSON : ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.rawValue = .init(.init(value))
    }
}

extension JSON : ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.rawValue = .init(.init(.init(value)))
    }
}

extension JSON : ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.rawValue = .init(.init(.init(value)))
    }
}

extension JSON : ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = .init(.init(value))
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.rawValue = .init(.init(value))
    }

    public init(unicodeScalarLiteral value: String) {
        self.rawValue = .init(.init(value))
    }
}

extension JSON : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self.rawValue = .init(Object.Quanta(rawValue: .init(elements)))
    }
}

extension JSON : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (JSON.Object.Key, JSON)...) {
        self.rawValue = .init(Object.Quanta(rawValue: .init(Dictionary(uniqueKeysWithValues: elements))))
    }
}

/// Convenience accessors for the payloads of the various `JSON` types
public extension JSON {
    static func str(_ str: String) -> Self { .init(str) }
    static func num(_ num: Double) -> Self { .init(num) }
    static func bol(_ bol: Bool) -> Self { .init(bol) }
    static func arr(_ arr: [JSON]) -> Self { .init(.init(Object.Quanta(rawValue: .init(arr)))) }
    static func obj(_ obj: [String: JSON]) -> Self { .init(.init(Object.Quanta(rawValue: .init(obj)))) }

    /// Returns the underlying String payload if this is a `JSON.str`, otherwise `.none`
    @inlinable var str: String? {
        rawValue.infer()?.infer()
    }

    /// Returns the underlying Boolean payload if this is a `JSON.bol`, otherwise `.none`
    @inlinable var bol: Bool? {
        rawValue.infer()?.infer()
    }

    /// Returns the underlying Double payload if this is a `JSON.num`, otherwise `.none`
    @inlinable var num: Double? {
        rawValue.infer()?.infer()
    }

    /// Returns the underlying JObj payload if this is a `JSON.obj`, otherwise `.none`
    @inlinable var obj: Object? {
        rawValue.infer()?.rawValue.infer()
    }

    /// Returns the underlying Array payload if this is a `JSON.arr`, otherwise `.none`
    @inlinable var arr: [JSON]? {
        rawValue.infer()?.rawValue.infer()
    }

    /// JSON has a string subscript when it is an object type; setting a value on a non-obj type has no effect
    @inlinable subscript(key: String) -> JSON? {
        obj?[key]
    }

    /// JSON has a save indexed subscript when it is an array type; setting a value on a non-array type has no effect
    @inlinable subscript(index: Int) -> JSON? {
        arr?[index]
    }

    /// The number of elements this contains: either the count of the underyling array or dictiionary, or 0 if `null`, or else 1 for a scalar.
    @inlinable var count: Int {
        switch rawValue {
        case .a:
            return isNull ? 0 : 1
        case .b(let collection):
            switch collection.rawValue {
            case .a(let x): return x.count
            case .b(let x): return x.count
            }
        }
    }
}

extension JSON : Encodable {
    /// Encodes to a JSON-compatible encoder.
    @inlinable public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self.rawValue {
        case .a(let scalar):
            switch scalar {
            case .a(let double): try container.encode(double as Double)
            case .b(let scalar):
                switch scalar {
                case .a(let string): try container.encode(string as String)
                case .b(let scalar):
                    switch scalar {
                    case .a(let boolean): try container.encode(boolean as Bool)
                    case .b(let null): assert(null as ScalarNull == .none); try container.encodeNil()
                    }
                }
            }

        case .b(let quanta):
            switch quanta.rawValue {
            case .a(let array): try container.encode(array)
            case .b(let dictionary): try container.encode(dictionary)
            }
        }
    }
}

extension JSON : Decodable {
    @inlinable public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        func decode<T: Decodable>() throws -> T { try container.decode(T.self) }
        if container.decodeNil() {
            self = JSON.null
        } else {
            do {
                self = try JSON(booleanLiteral: container.decode(Bool.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try JSON(floatLiteral: container.decode(Double.self))
                } catch DecodingError.typeMismatch {
                    do {
                        self = try JSON(stringLiteral: container.decode(String.self))
                    } catch DecodingError.typeMismatch {
                        do {
                            self = try JSON(.init(decode() as Object.Quanta))
                        } catch DecodingError.typeMismatch {
                            throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
                        }
                    }
                }
            }
        }
    }
}

