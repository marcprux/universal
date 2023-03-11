//
//  PLIST.swift
//
//  Created by Marc Prud'hommeaux on 3/10/23.
//
import Either
import struct Foundation.Data
import struct Foundation.Date
import class Foundation.PropertyListSerialization
import class Foundation.NSDictionary
import class Foundation.NSArray

/// A PLIST, which can contain a `Scalar` (`Date`, `Data`, `String`, `Double`, `Int`, or `Bool`), `[PLIST]`, or `[String: PLIST]`
public struct PLIST : Isomorph, Sendable, Hashable {
    public typealias ContainerType = Either<Date>.Or<Data>.Or<StringLiteralType>
    public typealias NumericType = Either<IntegerLiteralType>.Or<FloatLiteralType>
    //public typealias Scalar = ScalarOf<ContainerType, NumericType>
    public typealias Scalar = Either<ContainerType>.Or<NumericType>.Or<BooleanLiteralType>

    public typealias Object = [String: PLIST]
    public typealias RawValue = Either<Scalar>.Or<Object.ValueContainer>

    /// A PLIST `true`
    public static let `true` = PLIST(.init(true))

    /// A PLIST `false`
    public static let `false` = PLIST(.init(false))

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    /// Creates a PLIST scalar from the given string
    public init<S: StringProtocol>(_ string: S) {
        self.rawValue = .init(.init(.init(.init(string))))
    }

    /// Creates a PLIST scalar from the given number
    public init<N: BinaryFloatingPoint>(_ number: N) {
        self.rawValue = .init(.init(Double(number)))
    }

    /// Creates a PLIST scalar from the given boolean
    public init(_ boolean: Bool) {
        self.rawValue = .init(.init(boolean))
    }
}

extension PLIST {
    public enum PLISTCodingError : Error {
        case cannotCodeNull
    }

    public enum PLISTParseError : Error {
        case invalidPLIST(String)
        case cannotConvert(String)
        case invalidKeyType(String)
    }

    /// Parses the given PLIST data.
    public static func parse(_ plistData: Data) throws -> PLIST {
        /// Attempt to convert the given value to a PLIST
        func convert(_ value: Any) throws -> PLIST {
            if let value = value as? Bool {
                return PLIST.boolean(value)
            } else if let value = value as? Double {
                return PLIST.float(value)
            } else if let value = value as? Int {
                return PLIST.int(value)
            } else if let value = value as? String {
                return PLIST.string(value)
            } else if let value = value as? Date {
                return PLIST.date(value)
            } else if let value = value as? Data {
                return PLIST.data(value)
            } else if let value = value as? [Any] {
                return PLIST.array(try value.map(convert))
            } else if let value = value as? [String : Any] {
                return PLIST.dictionary(try value.mapValues(convert))
            } else {
                throw PLISTParseError.cannotConvert(String(describing: type(of: value)))
            }
        }

        var fmt: PropertyListSerialization.PropertyListFormat = .xml
        let result = try PropertyListSerialization.propertyList(from: plistData, options: [], format: &fmt)
        if let result = result as? NSDictionary {
            var obj = Object()
            for (key, value) in result {
                guard let key = key as? String else {
                    throw PLISTParseError.invalidKeyType(String(describing: type(of: value)))
                }
                obj[key] = try convert(value)
            }
            return PLIST.dictionary(obj)
        } else if let result = result as? NSArray {
            var arr: [PLIST] = []
            for value in result {
                arr.append(try convert(value))
            }
            return PLIST.array(arr)
        } else {
            throw PLISTParseError.invalidPLIST(String(describing: type(of: result)))
        }
    }
}

/// Convenience accessors for the payloads of the various `PLIST` types
public extension PLIST {
    static func string(_ str: String) -> Self { .init(str) }
    static func float(_ flt: Double) -> Self { .init(.init(.init(flt))) }
    static func int(_ int: Int) -> Self { .init(.init(.init(int))) }
    static func date(_ date: Date) -> Self { .init(.init(.init(.init(date)))) }
    static func data(_ data: Data) -> Self { .init(.init(.init(.init(.init(data))))) }
    static func boolean(_ bol: Bool) -> Self { .init(.init(.init(bol))) }
    static func array(_ arr: [PLIST]) -> Self { .init(.init(Object.ValueContainer(rawValue: .init(arr)))) }
    static func dictionary(_ obj: [String: PLIST]) -> Self { .init(.init(Object.ValueContainer(rawValue: .init(obj)))) }

    /// Returns the underlying String payload if this is a `PLIST.str`, otherwise `.none`
    @inlinable var string: String? {
        rawValue.infer()?.infer()?.infer()
    }

    /// Returns the underlying String payload if this is a `PLIST.data`, otherwise `.none`
    @inlinable var data: Data? {
        rawValue.infer()?.infer()?.infer()
    }

    /// Returns the underlying String payload if this is a `PLIST.date`, otherwise `.none`
    @inlinable var date: Date? {
        rawValue.infer()?.infer()?.infer()
    }

    /// Returns the underlying Boolean payload if this is a `PLIST.boolean`, otherwise `.none`
    @inlinable var boolean: Bool? {
        rawValue.infer()?.infer()?.infer()
    }

    /// Returns the underlying Double payload if this is a `PLIST.float`, otherwise `.none`
    @inlinable var float: Double? {
        rawValue.infer()?.infer()?.infer()
    }

    /// Returns the underlying Int payload if this is a `PLIST.int`, otherwise `.none`
    @inlinable var int: Int? {
        rawValue.infer()?.infer()?.infer()
    }

    /// Returns the underlying JObj payload if this is a `PLIST.dictionary`, otherwise `.none`
    @inlinable var dictionary: Object? {
        rawValue.infer()?.rawValue.infer()
    }

    /// Returns the underlying Array payload if this is a `PLIST.array`, otherwise `.none`
    @inlinable var array: [PLIST]? {
        rawValue.infer()?.rawValue.infer()
    }

    /// PLIST has a string subscript when it is an object type; setting a value on a non-obj type has no effect
    @inlinable subscript(key: String) -> PLIST? {
        get {
            dictionary?[key]
        }

//        set {
//            guard var object = object else { return }
//            object[key] = newValue
//            self = .object(object)
//        }
    }

    @inlinable subscript(index: Int) -> PLIST? {
        get {
            array?[index]
        }

        set {
            guard let newValue else { return }
            guard var array = array else { return }
            array[index] = newValue
            self = .array(array)
        }
    }

//    /// The number of elements this contains: either the count of the underyling array or dictiionary, or 0 if `null`, or else 1 for a scalar.
//    @inlinable var count: Int {
//        switch rawValue {
//        case .a:
//            return isNull ? 0 : 1
//        case .b(let collection):
//            switch collection.rawValue {
//            case .a(let x): return x.count
//            case .b(let x): return x.count
//            }
//        }
//    }
}

// MARK: PLIST Initializers

extension PLIST : ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.rawValue = .init(.init(value))
    }
}

extension PLIST : ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.rawValue = .init(.init(.init(value)))
    }
}

extension PLIST : ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.rawValue = .init(.init(value))
    }
}

extension PLIST : ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = .init(.init(.init(value)))
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.rawValue = .init(.init(.init(value)))
    }

    public init(unicodeScalarLiteral value: String) {
        self.rawValue = .init(.init(.init(value)))
    }
}

extension PLIST : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: PLIST...) {
        self.rawValue = .init(Object.ValueContainer(rawValue: .init(elements)))
    }
}

extension PLIST : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (PLIST.Object.Key, PLIST)...) {
        self.rawValue = .init(Object.ValueContainer(rawValue: .init(Dictionary(uniqueKeysWithValues: elements))))
    }
}


extension PLIST : Encodable {
    /// Encodes to a JSON-compatible encoder.
    @inlinable public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        func handle(_ date: Date) throws -> Void {
            try container.encode(date)
        }

        func handle(_ data: Data) throws -> Void {
            try container.encode(data)
        }

        func handle(_ string: String) throws -> Void {
            try container.encode(string)
        }

        func handle(_ int: Int) throws -> Void {
            try container.encode(int)
        }

        func handle(_ double: Double) throws -> Void {
            try container.encode(double)
        }

        func handle(_ bool: Bool) throws -> Void {
            try container.encode(bool)
        }

        func handle(_ array: [PLIST]) throws -> Void {
            try container.encode(array)
        }

        func handle(_ dictionary: [String: PLIST]) throws -> Void {
            try container.encode(dictionary)
        }

        func handle(_ numeric: NumericType) throws -> Void {
            switch numeric {
            case .a(let a): return try handle(a)
            case .b(let b): return try handle(b)
            }
        }

        func handle(_ stringOrData: Either<Data>.Or<StringLiteralType>) throws -> Void {
            switch stringOrData {
            case .a(let a): return try handle(a)
            case .b(let b): return try handle(b)
            }
        }

        func handle(_ container: ContainerType) throws -> Void {
            switch container {
            case .a(let a): return try handle(a)
            case .b(let b): return try handle(b)
            }
        }

        func handle(_ numberOrBool: (Either<NumericType>.Or<BooleanLiteralType>)) throws -> Void {
            switch numberOrBool {
            case .a(let a): return try handle(a)
            case .b(let b): return try handle(b)
            }
        }

        func handle(_ scalar: Scalar) throws -> Void {
            switch scalar {
            case .a(let a): return try handle(a)
            case .b(let b): return try handle(b)
            }
        }

        func handle(_ valueContainer: Object.ValueContainer) throws -> Void {
            switch valueContainer.rawValue {
            case .a(let a): return try handle(a)
            case .b(let b): return try handle(b)
            }
        }

        switch self.rawValue {
        case .a(let a): return try handle(a)
        case .b(let b): return try handle(b)
        }
    }
}

extension PLIST : Decodable {
    @inlinable public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        func decode<T: Decodable>() throws -> T { try container.decode(T.self) }
        if container.decodeNil() {
            throw PLISTCodingError.cannotCodeNull
        } else {
            do {
                self = try PLIST.boolean(container.decode(Bool.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try PLIST.int(container.decode(Int.self))
                } catch DecodingError.typeMismatch {
                    do {
                        self = try PLIST.float(container.decode(Double.self))
                    } catch DecodingError.typeMismatch {
                        do {
                            self = try PLIST.date(container.decode(Date.self))
                        } catch DecodingError.typeMismatch {
                            do {
                                self = try PLIST.data(container.decode(Data.self))
                            } catch DecodingError.typeMismatch {
                                do {
                                    self = try PLIST.string(container.decode(String.self))
                                } catch DecodingError.typeMismatch {
                                    do {
                                        self = try PLIST(.init(decode() as Object.ValueContainer))
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
    }
}

