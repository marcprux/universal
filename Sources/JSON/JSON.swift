//
//  JSONParser.swift
//
//  Created by Marc Prud'hommeaux on 8/20/15.
//
import Quanta

/// A JSON tree node, which can contain a `Scalar` (`String`, `Double`, `Bool`, or `Null`), `[JSON]`, or `[String: JSON]`
public struct JSON : Isomorph, Sendable, Hashable {
    public typealias Scalar = ScalarOf<StringLiteralType, FloatLiteralType>
    public typealias RawValue = Quantum<String, Scalar, JSON>
    public typealias Object = [String: JSON]

    /// The single JSON type
    public static let null = JSON(nilLiteral: ())

    public static let `true` = JSON(booleanLiteral: true)
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
        self.rawValue = .init(.init(.init(.init(Never?.none))))
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

typealias KeyableValues<Key : Hashable, Value> = Either<[Value]>.Or<[Key: Value]>

extension JSON : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self.rawValue = .init(Quanta(rawValue: .init(elements)))
    }
}

extension JSON : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        self.rawValue = .init(Quanta(rawValue: .init(Dictionary(uniqueKeysWithValues: elements))))
    }
}

/// Convenience accessors for the payloads of the various `JSON` types
public extension JSON {
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

    /// Returns the underlying `nil` payload if this is a `JSON.nul`, otherwise `.none`
//    @inlinable var nul: Never? {
//        rawValue.infer()?.infer()?.infer()?.infer()
//    }

    /// JSON has a string subscript when it is an object type; setting a value on a non-obj type has no effect
    @inlinable subscript(key: String) -> JSON? {
        obj?[key]
    }

    /// JSON has a save indexed subscript when it is an array type; setting a value on a non-array type has no effect
    @inlinable subscript(index: Int) -> JSON? {
        arr?[index]
    }
}

extension JSON : Encodable {
    /// Encodes to a JSON-compatible encoder.
    @inlinable public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self.rawValue {
        case .a(let scalar):
            switch scalar {
            case .a(let string): try container.encode(string as String)
            case .b(let scalar):
                switch scalar {
                case .a(let double): try container.encode(double as Double)
                case .b(let scalar):
                    switch scalar {
                    case .a(let boolean): try container.encode(boolean as Bool)
                    case .b(let null): assert(null as Never? == .none); try container.encodeNil()
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

//extension JSON : Decodable {
//    @inlinable public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        func decode<T: Decodable>() throws -> T { try container.decode(T.self) }
//        if container.decodeNil() {
//            self = .nul
//        } else {
//            do {
//                self = try .bol(container.decode(Bool.self))
//            } catch DecodingError.typeMismatch {
//                do {
//                    self = try .num(container.decode(Double.self))
//                } catch DecodingError.typeMismatch {
//                    do {
//                        self = try .str(container.decode(String.self))
//                    } catch DecodingError.typeMismatch {
//                        do {
//                            self = try .arr(decode())
//                        } catch DecodingError.typeMismatch {
//                            do {
//                                self = try .obj(decode())
//                            } catch DecodingError.typeMismatch {
//                                throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

