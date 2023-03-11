//
//  Either.swift
//  Universal
//
//  Created by Marc Prud'hommeaux on 11/4/15.
//
import Swift

/// A type that can contain one of two other types.
///
/// A correct `EitherOr` implementation vows that either `a == nil && b != nil` or `a != nil && b == nil`.
public protocol EitherOr {
    associatedtype A
    init(_ rawValue: A)
    /// If this type wraps a `A`
    func infer() -> A?

    associatedtype B
    init(_ rawValue: B)
    /// If this type wraps a `B`
    func infer() -> B?
}

/// The basis of one of multiple possible types: `Either<A>.Or<B>`, `Either<A>.Or<B>.Or<C>`, etc.
///
/// A choice between two different types is expressed by `Either<A>.Or<B>`.
/// For example:
///
/// ```
/// let stringOrInt: Either<String>.Or<Int>
/// ```
///
/// Additional types can be expressed by chaining `Or` types.
/// ```
/// let stringOrIntOrBool: Either<String>.Or<Int>.Or<Bool>
/// let dateOrURLOrDataOrUUID: Either<Date>.Or<URL>.Or<Data>.Or<UUID>
/// ```
///
/// `Either.Or` adopts `Codable` when its associated types adopt `Codable`.
/// Decoding is accomplished by trying to decode each encapsulated
/// type separately and accepting the first successfully decoded result.
///
/// This can present an issue for types that can encode to the same serialized data,
/// such as `Either<Double>.Or<Float>`, since encoded the `Float` side will then
/// be decoded as the `Double` side, which might be unexpected since it will
/// fail an equality check. To work around this, the encapsulated types
/// would need a type discriminator field to ensure that both sides
/// are mutually exclusive for decoding.
///
/// In short, given `typealias DoubleOrFloat = Either<Double>.Or<Float>`: `try DoubleOrFloat(Float(1.0)).encoded().decoded() != DoubleOrFloat(Float(1.0))`
public struct Either<A> : EitherOr, Isomorph {
    public typealias RawValue = A
    public var rawValue: RawValue

    public init(rawValue: A) { self.rawValue = rawValue }
    public init(_ rawValue: A) { self.rawValue = rawValue }

    /// A sum type: `Either<A>.Or<B>` can hold either an `A` or a `B`.
    /// E.g., `Either<Int>.Or<String>.Or<Bool>` can hold either an `Int` or a `String` or a `Bool`
    public enum Or<B> : EitherOr {
        public typealias A = RawValue
        public typealias B = B
        public typealias Or<C> = Either<A>.Or<Either<B>.Or<C>>

        case a(A)
        case b(B)

        public init(_ a: A) { self = .a(a) }
        public init(_ b: B) { self = .b(b) }
    }
}

extension Either {
    public func or<B>(_ value: B) -> Either<A>.Or<B> where A == Optional<B> {
        rawValue.map({ .init($0) }) ?? .init(value)
    }
}

extension Either {
    public typealias B = Never

    public init(_ rawValue: Never) {
        fatalError("not possible")
    }

    public var a: A? { rawValue }
    public var b: B? { infer() }

    @inlinable public func infer() -> B? {
        nil
    }
}

extension Either.Or {
    public var a: A? { infer() }
    public var b: B? { infer() }

    @inlinable public func infer() -> A? {
        if case .a(let a) = self { return a } else { return nil }
    }

    @inlinable public func infer() -> B? {
        if case .b(let b) = self { return b } else { return nil }
    }

}

extension Either.Or {
    /// Maps each side of an `Either.Or` through the given function
    @inlinable public func map<T, U>(_ af: (A) -> T, _ bf: (B) -> U) -> Either<T>.Or<U> {
        switch self {
        case .a(let a): return .a(af(a))
        case .b(let b): return .b(bf(b))
        }
    }
}

extension Either.Or {
    /// Returns a flipped view of the `Either.Or`, where `A` becomes `B` and `B` becomes `A`.
    @inlinable public var swapped: Either<B>.Or<A> {
        get {
            switch self {
            case .a(let a): return .b(a)
            case .b(let b): return .a(b)
            }
        }

        set {
            switch newValue {
            case .a(let a): self = .b(a)
            case .b(let b): self = .a(b)
            }
        }
    }
}

extension Either.Or where A == B {
    /// The underlying read-only value of either p or b
    @inlinable public var value: A {
        get {
            switch self {
            case .a(let a): return a
            case .b(let b): return b
            }
        }
    }

    /// The underlying value of the p or b, when `P == B`, where mutation always sets `.p`.
    @inlinable public var avalue: A {
        get {
            switch self {
            case .a(let a): return a
            case .b(let b): return b
            }
        }

        set {
            self = .a(newValue)
        }
    }

    /// The underlying value of the p or b, when `A == B`, where mutation always sets `.b`.
    @inlinable public var bvalue: B {
        get {
            switch self {
            case .b(let b): return b
            case .a(let p): return p
            }
        }

        set {
            self = .b(newValue)
        }
    }
}

extension Either : Equatable where A : Equatable { }
extension Either.Or : Equatable where A : Equatable, B : Equatable { }

extension Either : Hashable where A : Hashable { }
extension Either.Or : Hashable where A : Hashable, B : Hashable { }

extension Either : Encodable where A : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension Either.Or : Encodable where A : Encodable, B : Encodable {
    public func encode(to encoder: Encoder) throws {
        // we differ from the default Encodable behavior of enums in that we encode the underlying values directly, without referencing the case names
        var container = encoder.singleValueContainer()
        switch self {
        case .a(let x): try container.encode(x)
        case .b(let x): try container.encode(x)
        }
    }
}


extension Either : Decodable where A : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let element = try container.decode(A.self)
        self.init(rawValue: element)
    }
}

extension Either.Or : Decodable where A : Decodable, B : Decodable {
    /// `Either.Or` implements decodable for brute-force trying to decode first `A` and then `B`
    public init(from decoder: Decoder) throws {
        do {
            self = try .a(.init(from: decoder))
        } catch let e1 {
            do {
                self = try .b(.init(from: decoder))
            } catch let e2 {
                throw EitherDecodingError(e1: e1, e2: e2)
            }
        }
    }

    /// An error that occurs when decoding fails for an `Either` type.
    /// This encapsulates all the errors that resulted in the decode arrempt.
    public struct EitherDecodingError : Error {
        public let e1, e2: Error
    }
}

extension Either : Error where A : Error { }
extension Either.Or : Error where A : Error, B : Error { }

extension Either : Sendable where A : Sendable { }
extension Either.Or : Sendable where A : Sendable, B : Sendable { }


// MARK: Inference support

extension Either.Or where B : EitherOr {
    public init(_ rawValue: B.A) { self = .init(.init(rawValue)) }
    public init(_ rawValue: B.B) { self = .init(.init(rawValue)) }

    /// `B.P` if that is the case
    public func infer() -> B.A? { infer()?.infer() }
    /// `B.B` if that is the case
    public func infer() -> B.B? { infer()?.infer() }
}

extension Either.Or where B : EitherOr, B.A : EitherOr {
    public init(_ rawValue: B.A.A) { self = .init(.init(.init(rawValue))) }
    public init(_ rawValue: B.A.B) { self = .init(.init(.init(rawValue))) }

    /// `B.P.P` if that is the case
    public func infer() -> B.A.A? { infer()?.infer() }
    /// `B.P.B` if that is the case
    public func infer() -> B.A.B? { infer()?.infer() }
}

extension Either.Or where B : EitherOr, B.B : EitherOr {
    public init(_ rawValue: B.B.A) { self = .init(.init(.init(rawValue))) }
    public init(_ rawValue: B.B.B) { self = .init(.init(.init(rawValue))) }

    /// `B.B.P` if that is the case
    public func infer() -> B.B.A? { infer()?.infer() }
    /// `B.B.B` if that is the case
    public func infer() -> B.B.B? { infer()?.infer() }
}

extension Either.Or where B : EitherOr, B.B : EitherOr, B.B.B : EitherOr {
    public init(_ rawValue: B.B.B.A) { self = .init(.init(.init(rawValue))) }
    public init(_ rawValue: B.B.B.B) { self = .init(.init(.init(rawValue))) }

    /// `B.B.P` if that is the case
    public func infer() -> B.B.B.A? { infer()?.infer() }
    /// `B.B.B` if that is the case
    public func infer() -> B.B.B.B? { infer()?.infer() }
}

// … and so on …


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
@propertyWrapper @frozen public indirect enum Indirect<Wrapped> : WrapperType, Isomorph {
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


/// A `RawRepresentable` that guarantees that the contents of `rawValue` are fully equivalent to the wrapper itself, thereby enabling isomorphic behaviors such as encoding & decoding itself as it's underlying value or converting between separate `Isomorph` with the same underlying `RawValue` .
public protocol Isomorph : RawRepresentable {
    init(rawValue: RawValue)
}

@available(*, deprecated, renamed: "Alias")
public typealias RawCodable = Alias

/// An `Alias` is a simple `RawRepresentable` wrapper except its coding
/// will store the underlying value directly rather than keyed as "rawValue",
/// thus requiring that the `init(rawValue:)` be non-failable; it is useful
/// as a codable typesafe wrapper for some general type like UUID where the
/// Codable implementation does not automatically use the underlying type (like
/// it does with primitives and Strings)
public protocol Alias : Isomorph, Codable {
}

// This is the template for an implementation of Codable, but the default implementation in the protocol isn't used.

//extension Decodable where Self: Isomorph, Self.RawValue : Decodable {
//    /// An `Isomorph` deserializes from the underlying type's decoding with any intermediate wrapper
//    init(from decoder: Decoder) throws {
//        try self.init(rawValue: RawValue(from: decoder))
//    }
//}

//extension Isomorph where RawValue : Encodable {
//    /// An `Isomorph` serializes to the underlying type's encoding with any intermediate wrapper
//    func encode(to encoder: Encoder) throws {
//        try rawValue.encode(to: encoder)
//    }
//}

/// Conformance requirements of `Isomorph` to `CaseIterable` when the `rawValue` is a `CaseIterable`.
///
/// ```swift
/// struct DemoChoice : Isomorph, CaseIterable { let rawValue: SomeEnum }
/// ```
extension Isomorph where RawValue : CaseIterable {
    public static var allCases: [Self] {
        RawValue.allCases.map(Self.init(rawValue:))
    }
}

public extension Isomorph {
    /// Converts between two `Alias` types that have the same underlying value
    @inlinable func morphed<T: Isomorph>() -> T where T.RawValue == Self.RawValue {
        T(rawValue: self.rawValue)
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

extension Either.Or : IteratorProtocol where A : IteratorProtocol, B : IteratorProtocol {
    public typealias Element = Either<A.Element>.Or<B.Element>

    public mutating func next() -> Either<A.Element>.Or<B.Element>? {
        switch self {
        case .a(var p):
            defer { self = .a(p) }
            return p.next().map({ .init($0) })
        case .b(var b):
            defer { self = .b(b) }
            return b.next().map({ .init($0) })
        }
    }
}

extension Either.Or : Sequence where A : Sequence, B : Sequence {
    public typealias Iterator = Either<A.Iterator>.Or<B.Iterator>

    public func makeIterator() -> Iterator {
        switch self {
        case .a(let p): return .init(p.makeIterator())
        case .b(let b): return .init(b.makeIterator())
        }
    }
}


public extension Dictionary {
    /// A sequence of either keyed or unkeyed values, defined as `Either<[Value]>.Or<[Key: Value]>`.
    ///
    /// A `ValueContainer` is used to abstract an `Array` and `Dictionary`.
    struct ValueContainer : Isomorph {
        public typealias RawValue = Either<[Value]>.Or<[Key: Value]>

        public var rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: RawValue) {
            self.rawValue = rawValue
        }

        /// Returns all the values in the container in undefined order.
        public var values: [Value] {
            rawValue.map({ $0 }, { Array($0.values) }).value
        }
    }
}

/// A Scalar's null value is an `Optional<Never>.none`
///
/// Note: this type was chosen over `Void` since it is `Codable`. The result is the same in that there is only a single valid instance.
public typealias ScalarNull = Optional<Never>

/// The base of a scalar type, which contains fixed boolean and null type and variable string and numeric types.
public typealias ScalarOf<ContainerType, NumericType> = Either<Either<NumericType>.Or<ContainerType>>.Or<Either<BooleanLiteralType>.Or<ScalarNull>>


extension Dictionary.ValueContainer : Sequence {
    /// Extracts and transforms all the values in the `ValueContainer`. Note that ordering will be unstable and indeterminate for dictionary values.
    public func mapValues<U>(_ transform: (Value) -> U) -> [U] {
        rawValue.map({ $0.map(transform) }, { Array($0.mapValues(transform).values) }).value
    }

    public func makeIterator() -> RawValue.Iterator {
        rawValue.makeIterator()
    }
}

extension Dictionary.ValueContainer : Equatable where Value : Equatable { }
extension Dictionary.ValueContainer : Hashable where Value : Hashable { }

extension Dictionary.ValueContainer : Encodable where Value : Encodable, Key : Encodable {
    /// `ValueContainer` serializes to the underlying type's encoding with any intermediate wrapper
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}
extension Dictionary.ValueContainer : Decodable where Value : Decodable, Key : Decodable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: RawValue(from: decoder))
    }
}

extension Dictionary.ValueContainer : Sendable where Value : Sendable, Key : Sendable { }

