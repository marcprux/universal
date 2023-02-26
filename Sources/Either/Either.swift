//
//  Either.swift
//  MarcUp
//
//  Created by Marc Prud'hommeaux on 11/4/15.
//

// General data structes need for `Brac` and `Curio` schema support

/// A WrapperType is able to map itself through a wrapped optional
public protocol WrapperType {
    associatedtype Wrapped
    init(_ some: Wrapped)
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

public extension WrapperType where Self : ExpressibleByNilLiteral {
    /// The underlying type that is contained in this wrapper.
    @inlinable var flatValue: Wrapped? {
        get { self.flatMap({ $0 }) }
        _modify {
            var val = self.flatMap({ $0 })
            yield &val
            if let val = val {
                self = Self(val)
            } else {
                self = nil
            }
        }
    }
}

extension Optional : WrapperType { }

public extension Optional {
    /// Wrap this optional in an indirection
    @inlinable func indirect() -> Optional<Indirect<Wrapped>> {
        return self.flatMap(Indirect.init(rawValue:))
    }
}


/// Useful extension for when a `OneOfX<A, B, …, Never>` wants to be treated as `Codable`
extension Never : Decodable {
    /// Throws an error, since it should never be decodable
    public init(from decoder: Decoder) throws {
        throw NeverCodableError.decodableNever
    }
}

/// Useful extension for when a `OneOfX<A, B, …, Never>` wants to be treated as `Codable`
extension Never : Encodable {
    /// Throws an error, since it should never be encodable
    public func encode(to encoder: Encoder) throws {
        throw NeverCodableError.encodableNever
    }
}


/// The error that is thrown when a `Never` type is encoded or decoded
enum NeverCodableError : Error {
    /// The error that is thrown when a `Never` type is encoded
    case encodableNever
    /// The error that is thrown when a `Never` type is decoded
    case decodableNever
}

/// An Indirect is a simple wrapper for an underlying value stored via an indirect enum in order to permit recursive value types
@propertyWrapper @frozen public indirect enum Indirect<Wrapped> : WrapperType, RawIsomorphism {
    case some(Wrapped)

    /// Construct a non-`nil` instance that stores `some`.
    @inlinable public init(_ some: Wrapped) {
        self = .some(some)
    }

    /// The underlying value of this `IndirectEnum`.
    @inlinable public var wrappedValue: Wrapped {
        get {
            switch self {
            case .some(let v): return v
            }
        }

        set {
            self = .some(newValue)
        }
    }

    @inlinable public func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U? {
        return try f(wrappedValue)
    }
}

extension Indirect : RawRepresentable {
    public typealias RawValue = Wrapped

    /// Constructor for RawRepresentable
    @inlinable public init(rawValue some: Wrapped) {
        self.init(some)
    }

    @inlinable public var rawValue: Wrapped { return wrappedValue }
}

// similar to Optional codability at:
// https://github.com/apple/swift/blob/325a63a1bd59eb2b12ba310ffa93e83d1336885f/stdlib/public/core/Codable.swift.gyb#L1825
extension Indirect : Encodable where Wrapped : Encodable {
    @inlinable public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// similar to Optional codability at:
// https://github.com/apple/swift/blob/325a63a1bd59eb2b12ba310ffa93e83d1336885f/stdlib/public/core/Codable.swift.gyb#L1842
// FIXME: doesn't work when nested
extension Indirect : Decodable where Wrapped : Decodable {
    @inlinable public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let element = try container.decode(Wrapped.self)
        self.init(element)
    }
}

extension Indirect : Equatable where Wrapped : Equatable { }
extension Indirect : Hashable where Wrapped : Hashable { }


/// A type that permits items to be initialized non-optionally
public protocol RawInitializable : RawRepresentable {
    init(rawValue: RawValue)
}

public extension RawInitializable {
    /// Defer optional initializer to the guaranteed initializer.
    init?(rawValue: RawValue) {
        self.init(rawValue: rawValue)
    }
}

/// A `RawRepresentable` and `RawInitializable` that guarantees that the contents of `rawValue` are fully equivalent to the wrapper itself, thereby enabling isomorphic behaviors such as encoding & decoding itself as it's underlying value or converting between separate `RawIsomorphism` with the same underlying `RawValue` .
public protocol RawIsomorphism : RawInitializable {
}


/// A RawCodable is a simple `RawRepresentable` wrapper except its coding
/// will store the underlying value directly rather than keyed as "rawValue",
/// thus requiring that the `init(rawValue:)` be non-failable; it is useful
/// as a codable typesafe wrapper for some general type like UUID where the
/// Codable implementation does not automatically use the underlying type (like
/// it does with primitives and Strings)
public protocol RawCodable : RawIsomorphism, Codable where RawValue : Codable {
}

public extension RawCodable {
    /// A `RawCodable` deserializes from the underlying type's decoding with any intermediate wrapper
    init(from decoder: Decoder) throws {
        try self.init(rawValue: RawValue(from: decoder))
    }

    /// A `RawCodable` serializes to the underlying type's encoding with any intermediate wrapper
    func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

/// Conformance requirements of `RawIsomorphism` to `CaseIterable` when the `rawValue` is a `CaseIterable`.
///
/// ```swift
/// struct DemoChoice : RawIsomorphism, CaseIterable { let rawValue: SomeEnum }
/// ```
extension RawIsomorphism where RawValue : CaseIterable {
    public static var allCases: [Self] {
        RawValue.allCases.map(Self.init(rawValue:))
    }
}

public extension RawIsomorphism {
    /// Converts between two `RawCodable` types that have the same underlying value
    @inlinable func morphed<T: RawIsomorphism>() -> T where T.RawValue == Self.RawValue {
        T(rawValue: self.rawValue)
    }
}

public extension Optional where Wrapped == ExplicitNull {
    /// Converts an `.some(ExplicitNull.null)` to `false` and `.none` to `true`
    var explicitNullAsFalse: Bool {
        get { self == ExplicitNull.null ? false : true }
        set { self = newValue == true ? .none : .some(ExplicitNull.null) }
    }
}

public extension WrapperType where Self : ExpressibleByNilLiteral {
//    /// Returns this wrapped instance as a `Nullablle`
//    var asNullable: Nullable<Wrapped> {
//        get { flatMap({ .init($0) }) ?? .null }
//        set { self = newValue.q.flatMap({ .init($0) }) ?? nil }
//    }

    /// Returns this wrapped instance as an `Optional<Nullablle>`, where an underlying `null` is converted to `none`.
    var asNullableOptional: Nullable<Wrapped>? {
        get { flatMap({ .init($0) }) }
        set { self = newValue?.q.flatMap({ .init($0) }) ?? nil }
    }
}

public extension WrapperType where Wrapped : Equatable, Self : ExpressibleByNilLiteral {
    /// Convenience for mapping between a sub-set of cases for the given optional. For example, given
    /// `enum EnumX { case left, middle, right }` and `enum EnumY { case top, middle, bottom }`
    /// one could map between `middle` values with:
    /// ```optionalX[narrowMap: [.middle: .middle]]```
    @inlinable subscript<Value: Equatable>(narrowMap valueMapping: KeyValuePairs<Wrapped, Value>) -> Value? {
        get {
            guard let wrappedValue = self.flatValue else {
                return nil
            }
            for (key, value) in valueMapping {
                if wrappedValue == key {
                    return value
                }
            }
            return nil
        }

        set {
            if let newValue = newValue {
                for (key, value) in valueMapping {
                    if newValue == value {
                        self = .init(key)
                        return
                    }
                }
            }
            self = nil // fall back to nil
        }
    }
}


/// An single-element enumeration that marks an explicit nil reference; this is as opposed to an Optional which can be absent, whereas an ExplicitNull requires that the value be exactly "null"
@frozen public enum ExplicitNull : Codable, Hashable, ExpressibleByNilLiteral, CaseIterable {
    case null

    public init(nilLiteral: ()) { self = .null }
    public init() { self = .null }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(ExplicitNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ExplicitNull"))
        }
        self = .null
    }
}

/// A Nullable is a type that can be either explicitly null or a given type.
public typealias Nullable<T> = XOr<ExplicitNull>.Or<T> // note that type order is important, since "null" in `OneOf2<ExplicitNull, <Optional<String>>>` will fall back to matching both the `ExplicitNull` and the `Optional<String>` types

public extension Nullable {
    /// A nullable `.full`, similar to `Optional.some`
    static func full(_ some: Q) -> Self { return .q(some) }
}
