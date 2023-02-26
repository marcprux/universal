//
//  Either.swift
//  MarcUp
//
//  Created by Marc Prud'hommeaux on 11/4/15.
//
import Swift

/// The basis of one of multiple possible types, equivalent to an
/// `Either` sum type.
///
/// A choice between two different types is expressed by `Either<P>.Or<Q>`.
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
public indirect enum Either<P> : RawRepresentable {
    public typealias Value = P
    case p(P)

    public var rawValue: P {
        get {
            switch self {
            case .p(let value): return value
            }
        }

        set {
            self = .p(newValue)
        }
    }

    public init(rawValue: P) { self = .p(rawValue) }
    public init(_ rawValue: P) { self = .p(rawValue) }

    /// A sum type: `Either<P>.Or<Q>` can hold either an `P` or a `Q`.
    /// E.g., `Either<Int>.Or<String>.Or<Bool>` can hold either an `Int` or a `String` or a `Bool`
    public indirect enum Or<Q> : EitherType {
        public typealias P = Value
        public typealias Q = Q
        public typealias Or<R> = Either<P>.Or<Either<Q>.Or<R>>

        case p(P)
        case q(Q)

        public init(_ p: P) { self = .p(p) }
        public init(_ q: Q) { self = .q(q) }

        public var p: P? { infer() }
        public var q: Q? { infer() }

        @inlinable public func infer() -> P? {
            if case .p(let p) = self { return p } else { return nil }
        }

        @inlinable public func infer() -> Q? {
            if case .q(let q) = self { return q } else { return nil }
        }
    }
}

extension Either.Or {
    /// Maps each side of an `Either.Or` through the given function
    @inlinable public func map<T, U>(_ pf: (P) -> T, _ qf: (Q) -> U) -> Either<T>.Or<U> {
        switch self {
        case .p(let p): return .p(pf(p))
        case .q(let q): return .q(qf(q))
        }
    }
}

extension Either.Or {
    /// Returns a flipped view of the `Either.Or`, where `P` becomes `Q` and `Q` becomes `P`.
    @inlinable public var swapped: Either<Q>.Or<P> {
        get {
            switch self {
            case .p(let p): return .q(p)
            case .q(let q): return .p(q)
            }
        }

        set {
            switch newValue {
            case .p(let p): self = .q(p)
            case .q(let q): self = .p(q)
            }
        }
    }
}

extension Either.Or where P == Q {
    /// The underlying read-only value of either p or q
    @inlinable public var value: P {
        get {
            switch self {
            case .p(let p): return p
            case .q(let q): return q
            }
        }
    }

    /// The underlying value of the p or q, when `P == Q`, where mutation always sets `.p`.
    @inlinable public var pvalue: P {
        get {
            switch self {
            case .p(let p): return p
            case .q(let q): return q
            }
        }

        set {
            self = .p(newValue)
        }
    }

    /// The underlying value of the p or q, when `P == Q`, where mutation always sets `.q`.
    @inlinable public var qvalue: P {
        get {
            switch self {
            case .q(let q): return q
            case .p(let p): return p
            }
        }

        set {
            self = .q(newValue)
        }
    }
}

extension Either : Equatable where P : Equatable { }
extension Either.Or : Equatable where P : Equatable, Q : Equatable { }

extension Either : Hashable where P : Hashable { }
extension Either.Or : Hashable where P : Hashable, Q : Hashable { }

extension Either : Encodable where P : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension Either.Or : Encodable where P : Encodable, Q : Encodable {
    public func encode(to encoder: Encoder) throws {
        // we differ from the default Encodable behavior of enums in that we encode the underlying values directly, without referencing the case names
        var container = encoder.singleValueContainer()
        switch self {
        case .p(let x): try container.encode(x)
        case .q(let x): try container.encode(x)
        }
    }
}


extension Either : Decodable where P : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let element = try container.decode(P.self)
        self.init(rawValue: element)
    }
}

extension Either.Or : Decodable where P : Decodable, Q : Decodable {
    /// `Either.Or` implements decodable for brute-force trying to decode first `A` and then `B`
    public init(from decoder: Decoder) throws {
        do {
            self = try .p(.init(from: decoder))
        } catch let e1 {
            do {
                self = try .q(.init(from: decoder))
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

extension Either : Error where P : Error { }
extension Either.Or : Error where P : Error, Q : Error { }

extension Either : Sendable where P : Sendable { }
extension Either.Or : Sendable where P : Sendable, Q : Sendable { }


/// A `OneOrMany` is either a single element or a sequence of elements
public typealias ElementOrSequence<Seq: Sequence> = Either<Seq.Element>.Or<Seq>

/// A `OneOrMany` is either a single value or any array of zero or multiple values
public typealias ElementOrArray<Element> = ElementOrSequence<Array<Element>>

extension ElementOrSequence : ExpressibleByArrayLiteral where Q : RangeReplaceableCollection, Q.Element == P {
    /// Initialized this sequence with either a single element or mutiple elements depending on the array contents.
    public init(arrayLiteral elements: Q.Element...) {
        self = elements.count == 1 ? .p(elements[0]) : .q(.init(elements))
    }
}

extension ElementOrSequence where Q : Collection, Q : ExpressibleByArrayLiteral, P == Q.ArrayLiteralElement, P == Q.Element {

    /// The number of elements in .q; .p always returns 1
    public var count: Int {
        switch self {
        case .p: return 1
        case .q(let x): return x.count
        }
    }

    /// The array of instances, whose setter will opt for the single option
    public var collectionSingle: Q {
        get { map({ p in Q(arrayLiteral: p) }, { q in q }).value }
        set { self = newValue.count == 1 ? .p(newValue.first!) : .q(newValue) }
    }

    /// The array of instances, whose setter will opt for the multiple option
    public var collectionMulti: Q {
        get { map({ p in Q(arrayLiteral: p) }, { q in q }).value }
        set { self = .q(newValue) }
    }
}

/// An `XResult` is similar to a `Foundation.Result` except it uses `Either` arity
public typealias XResult<Success, Failure: Error> = Either<Failure>.Or<Success>

public extension XResult where P : Error {
    typealias Success = Q
    typealias Failure = P

    /// An `Either` whose first element is an error type can be converted to a `Result`.
    /// Note that the arity is the opposite of `Result`: `Either`'s first type will be `Error`.
    @inlinable var result: Result<Success, Failure> {
        get {
            switch self {
            case .p(let error): return .failure(error)
            case .q(let value): return .success(value)
            }
        }

        set {
            switch newValue {
            case .success(let value): self = .q(value)
            case .failure(let error): self = .p(error)
            }
        }
    }

    /// Unwraps the success value or throws a failure if it is an error
    @inlinable func get() throws -> Q {
        try result.get()
    }
}

// MARK: Inferrence support

public protocol EitherType {
    associatedtype P
    init(_ rawValue: P)
    /// If this type wraps a `P`
    func infer() -> P?

    associatedtype Q
    init(_ rawValue: Q)
    /// If this type wraps a `Q`
    func infer() -> Q?
}

extension Either.Or where Q : EitherType {
    public init(_ rawValue: Q.P) { self = .init(.init(rawValue)) }
    public init(_ rawValue: Q.Q) { self = .init(.init(rawValue)) }

    /// `Q.P` if that is the case
    public func infer() -> Q.P? { infer()?.infer() }
    /// `Q.Q` if that is the case
    public func infer() -> Q.Q? { infer()?.infer() }
}

extension Either.Or where Q : EitherType, Q.P : EitherType {
    public init(_ rawValue: Q.P.P) { self = .init(.init(.init(rawValue))) }
    public init(_ rawValue: Q.P.Q) { self = .init(.init(.init(rawValue))) }

    /// `Q.P.P` if that is the case
    public func infer() -> Q.P.P? { infer()?.infer()?.infer() }
    /// `Q.P.Q` if that is the case
    public func infer() -> Q.P.Q? { infer()?.infer()?.infer() }
}

extension Either.Or where Q : EitherType, Q.Q : EitherType {
    public init(_ rawValue: Q.Q.P) { self = .init(.init(.init(rawValue))) }
    public init(_ rawValue: Q.Q.Q) { self = .init(.init(.init(rawValue))) }

    /// `Q.Q.P` if that is the case
    public func infer() -> Q.Q.P? { infer()?.infer()?.infer() }
    /// `Q.Q.Q` if that is the case
    public func infer() -> Q.Q.Q? { infer()?.infer()?.infer() }
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
public protocol Alias : Isomorph, Codable where RawValue : Codable {
}

public extension Alias {
    /// An `Alias` deserializes from the underlying type's decoding with any intermediate wrapper
    init(from decoder: Decoder) throws {
        try self.init(rawValue: RawValue(from: decoder))
    }

    /// An `Alias` serializes to the underlying type's encoding with any intermediate wrapper
    func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

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
public typealias Nullable<T> = Either<ExplicitNull>.Or<T> // note that type order is important, since "null" in `OneOf2<ExplicitNull, <Optional<String>>>` will fall back to matching both the `ExplicitNull` and the `Optional<String>` types

public extension Nullable {
    /// A nullable `.full`, similar to `Optional.some`
    static func full(_ some: Q) -> Self { return .q(some) }
}

@available(*, deprecated, renamed: "Either")
public typealias XOr = Either
