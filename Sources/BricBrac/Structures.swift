//
//  Structures.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 11/4/15.
//  Copyright © 2010-2020 io.glimpse. All rights reserved.
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
/// An Indirect is a simple wrapper for an underlying value stored via an indirect enum in order to permit recursive value types
@propertyWrapper public indirect enum Indirect<Wrapped> : WrapperType {
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

        _modify {
            switch self {
            case .some(var x):
                yield &x
                self = .some(x)
            }
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
//    @inlinable // FIXME(sil-serialize-all)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// similar to Optional codability at:
// https://github.com/apple/swift/blob/325a63a1bd59eb2b12ba310ffa93e83d1336885f/stdlib/public/core/Codable.swift.gyb#L1842
// FIXME: doesn't work when nested
extension Indirect : Decodable where Wrapped : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let element = try container.decode(Wrapped.self)
        self.init(element)
    }
}

extension Indirect : Equatable where Wrapped : Equatable { }
extension Indirect : Hashable where Wrapped : Hashable { }


/// An single-element enumeration that marks an explicit nil reference; this is as opposed to an Optional which can be absent, whereas an ExplicitNull requires that the value be exactly "null"
public enum ExplicitNull : Codable, Hashable, ExpressibleByNilLiteral, CaseIterable {
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

/// A RawCodable is a simple `RawRepresentable` wrapper except its coding
/// will store the underlying value directly rather than keyed as "rawValue",
/// thus requiring that the `init(rawValue:)` be non-failable; it is useful
/// as a codable typesafe wrapper for some general type like UUID where the
/// Codable implementation does not automatically use the underlying type (like
/// it does with primitives and Strings)
public protocol RawCodable : RawRepresentable, Codable where RawValue : Codable {
    init(rawValue: RawValue)
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


/// A Nullable is a type that can be either explicitly null or a given type.
public typealias Nullable<T> = OneOf2<ExplicitNull, T> // note that type order is important, since "null" in `OneOf2<ExplicitNull, <Optional<String>>>` will fall back to matching both the `ExplicitNull` and the `Optional<String>` types

public extension OneOfNType where T1 == ExplicitNull /* e.g., Nullable */ {
    /// A nullable `.null`, similar to `Optional.none`
    static var null: Self { return .init(.null) }

    /// Returns `true` if explicitly `null`
    var isExplicitNull: Bool { infer() == ExplicitNull.null }
}

public extension OneOf2 where T1 == ExplicitNull /* i.e., Nullable */ {
    /// The `null` side of the `Nullable`.
    var nullValue: ExplicitNull? { v1 }
    /// The non-`null` side of the `Nullable`.
    var fullValue: T2? { v2 }
}

public extension Optional where Wrapped == ExplicitNull {
    /// Converts an `.some(ExplicitNull.null)` to `false` and `.none` to `true`
    var explicitNullAsFalse: Bool {
        get { self == ExplicitNull.null ? false : true }
        set { self = newValue == true ? .none : .some(ExplicitNull.null) }
    }
}

public extension WrapperType where Self : ExpressibleByNilLiteral {
    /// Returns this wrapped instance as a `Nullablle`
    var asNullable: Nullable<Wrapped> {
        get { flatMap({ .init($0) }) ?? .null }
        set { self = newValue.fullValue.flatMap({ .init($0) }) ?? nil }
    }

    /// Returns this wrapped instance as an `Optional<Nullablle>`, where an underlying `null` is converted to `none`.
    var asNullableOptional: Nullable<Wrapped>? {
        get { flatMap({ .init($0) }) }
        set { self = newValue?.fullValue.flatMap({ .init($0) }) ?? nil }
    }

}

public extension Nullable {
    /// A nullable `.full`, similar to `Optional.some`
    static func full(_ some: T2) -> Self { return .v2(some) }
}

/// An Object Bric type that cannot contain anything
public struct HollowBric : Bricable, Bracable {
    public init() {
    }

    public func bric() -> Bric {
        return [:]
    }

    public static func brac(bric: Bric) throws -> HollowBric {
        return HollowBric()
    }
}

public func ==(lhs: HollowBric, rhs: HollowBric) -> Bool {
    return true
}

// Swift 4 TODO: Variadic Generics: https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#variadic-generics

public protocol SomeOf {
    associatedtype T

    /// Returns a tuple of the possible value types for this OneOf
    var tupleValue: T { get }
}

/// MARK: OneOf implementations

/// The protocol of a type that can contain one out of 1 or more exclusive options
public protocol OneOfNType : SomeOf {
    associatedtype T1
    init(t1: T1)
    init(_ t1: T1)
    func infer() -> T1?
}

public extension OneOfNType {
    @inlinable var v1: T1? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// The protocol of a type that can contain one out of 2 or more exclusive options
public protocol OneOf2Type : OneOfNType {
    associatedtype T2
    init(t2: T2)
    init(_ t2: T2)
    func infer() -> T2?
}

/// Construct a `OneOf2Type` from T1.
@inlinable public func oneOf<T: OneOf2Type>(_ value: T.T1) -> T { .init(value) }

/// Construct a `OneOf2Type` from T2.
@inlinable public func oneOf<T: OneOf2Type>(_ value: T.T2) -> T { .init(value) }

public extension OneOf2Type {
    @inlinable var v2: T2? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2
public indirect enum OneOf2<T1, T2> : OneOf2Type {
    case v1(T1), v2(T2)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable subscript<U1, U2>(oneOf keyPaths: (KeyPath<T1, U1>, KeyPath<T2, U2>)) -> OneOf2<U1, U2> {
        get {
            switch self {
            case .v1(let x): return .init(x[keyPath: keyPaths.0])
            case .v2(let x): return .init(x[keyPath: keyPaths.1])
            }
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?) {
        switch self {
        case .v1(let v): return (v, nil)
        case .v2(let v): return (nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
}

extension OneOf2 : Bricable where T1: Bricable, T2: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        }
    }
}

extension OneOf2 : Bracable where T1: Bracable, T2: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf2 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            ])
    }
}

extension OneOf2 : Encodable where T1 : Encodable, T2 : Encodable {
    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf2 : Decodable where T1 : Decodable, T2 : Decodable {
    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf2 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf2]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            ].joined())
    }
}

extension OneOf2 : RawRepresentable where T1 : RawRepresentable, T2 : RawRepresentable, T1.RawValue == T2.RawValue {
    public typealias RawValue = T1.RawValue

    public init?(rawValue: RawValue) {
        if let t1 = T1(rawValue: rawValue) { self = .init(t1: t1) }
        else if let t2 = T2(rawValue: rawValue) { self = .init(t2: t2) }
        else { return nil }
    }

    public var rawValue: RawValue {
        self[routing: (\.rawValue, \.rawValue)]
    }
}

extension OneOf2 : Equatable where T1 : Equatable, T2 : Equatable { }
extension OneOf2 : Hashable where T1 : Hashable, T2 : Hashable { }
extension OneOf2 : Identifiable where T1 : Identifiable, T2 : Identifiable {
    public var id: OneOf2<T1.ID, T2.ID> { map2({ $0.id }, { $0.id }) }
}

public extension OneOf2 {
    /// Apply the separate mapping functions for the individual options.
    /// - Parameters:
    ///   - f1: the function to apply to `T1`
    ///   - f2: the function to apply to `T2`
    @inlinable func map2<U1, U2>(_ f1: (T1) throws -> (U1), _ f2: (T2) throws -> (U2)) rethrows -> OneOf2<U1, U2> {
        switch self {
        case .v1(let t1): return try .init(f1(t1))
        case .v2(let t2): return try .init(f2(t2))
        }
    }

    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            }
        }
    }

    /// When `T1` can be derived from `T2`, always treat this `OneOf2` as a `T1` instance.
    subscript(subsumeByV1 constructor: (T2) -> T1) -> T1 {
        get {
            switch self {
            case .v1(let x): return x
            case .v2(let x): return constructor(x)
            }
        }

        set {
            self = .v1(newValue)
        }
    }

    /// When `T2` can be derived from `T1`, always treat this `OneOf2` as a `T2` instance.
    subscript(subsumeByV2 constructor: (T1) -> T2) -> T2 {
        get {
            switch self {
            case .v1(let x): return constructor(x)
            case .v2(let x): return x
            }
        }

        set {
            self = .v2(newValue)
        }
    }
}


/// A `OneOrAny` is either a specific value or a generic `Bric` instance.
/// This can be useful for deserialization where you want to handle a certain
/// case while falling back to a general structure.
public typealias OneOrAny<T> = OneOf2<T, Bric>

/// A `OneOrMany` is either a single value or any array or zero or multiple values
public typealias OneOrMany<T> = OneOf2<T, [T]>

extension OneOrMany : ExpressibleByArrayLiteral where T2 == [T1] {
    public init(arrayLiteral elements: T1...) {
        self.init(array: elements)
    }
}

/// Common case of OneOf2<String, [String]>, where we can get or set values as an array
extension OneOrMany where T2 == [T1] {
    /// Initializes this OneOf with the given array
    public init(array: Array<T1>) {
        if array.count == 1 {
            self = .v1(array[0])
        } else {
            self = .v2(array)
        }
    }

    /// The number of elements in .v2; .v1 always returns 1
    @inlinable public var count: Int {
        switch self {
        case .v1: return 1
        case .v2(let x): return x.count
        }
    }

    /// View of the underlying value(s) as an array regardless of whether it is the single or multiple case.
    /// Any time the array is set to a single value it will set the first case, everything else sets the second case.
    @inlinable public var array: [T1] {
        get {
            array(expanding: { [$0] })
        }

        set {
            if let singleValue = newValue.first, newValue.count == 1 {
                self = .v1(singleValue)
            } else {
                self = .v2(newValue)
            }
        }
    }

    /// Returns this value as an array, using the expansion function to convert from a single item to multiple items.
    /// - Parameter expanding: the function to expand the array
    @inlinable public func array(expanding: (T1) -> T2) -> T2 {
        switch self {
        case .v1(let one):
            return expanding(one)
        case .v2(let many):
            return many
        }
    }
}

/// Reversed the OneOf2 ordering
public extension OneOf2 {
    /// Returns a swapped instance of this OneOf2<T1, T2> as a OneOf2<T2, T1>
    @inlinable var swapped: OneOf2<T2, T1> {
        get {
            switch self {
            case .v1(let x): return OneOf2<T2, T1>(x)
            case .v2(let x): return OneOf2<T2, T1>(x)
            }
        }

        set {
            switch newValue {
            case .v1(let x): self = OneOf2<T1, T2>(x)
            case .v2(let x): self = OneOf2<T1, T2>(x)
            }
        }
    }
}

/// The protocol of a type that can contain one out of 3 or more exclusive options
public protocol OneOf3Type : OneOf2Type {
    associatedtype T3
    init(t3: T3)
    init(_ t3: T3)
    func infer() -> T3?
}

public extension OneOf3Type {
    @inlinable var v3: T3? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// Construct a `OneOf3Type` from T3.
@inlinable public func oneOf<T: OneOf3Type>(_ value: T.T3) -> T { .init(value) }

/// A simple union type that can be one of either T1 or T2 or T3
public indirect enum OneOf3<T1, T2, T3> : OneOf3Type {
    case v1(T1), v2(T2), v3(T3)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable public init(t3: T3) { self = .v3(t3) }
    @inlinable public init(_ t3: T3) { self = .v3(t3) }

    /// Split the tuple into nested OneOf2 instances
    @inlinable public func split() -> OneOf2<OneOf2<T1, T2>, T3> {
        switch self {
        case .v1(let v): return .v1(.v1(v))
        case .v2(let v): return .v1(.v2(v))
        case .v3(let v): return .v2(v)
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?, T3?) {
        switch self {
        case .v1(let v): return (v, nil, nil)
        case .v2(let v): return (nil, v, nil)
        case .v3(let v): return (nil, nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    @inlinable public func infer() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
}

extension OneOf3 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        }
    }
}

extension OneOf3 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf3 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            ])
    }
}

extension OneOf3 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable {

    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf3 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable {

    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf3 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable, T3 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf3]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            T3.allCases.map(AllCases.Element.init(t3:)),
            ].joined())
    }
}

extension OneOf3 : RawRepresentable where T1 : RawRepresentable, T2 : RawRepresentable, T3 : RawRepresentable, T1.RawValue == T2.RawValue, T2.RawValue == T3.RawValue {
    public typealias RawValue = T1.RawValue

    public init?(rawValue: RawValue) {
        if let t1 = T1(rawValue: rawValue) { self = .init(t1: t1) }
        else if let t2 = T2(rawValue: rawValue) { self = .init(t2: t2) }
        else if let t3 = T3(rawValue: rawValue) { self = .init(t3: t3) }
        else { return nil }
    }

    public var rawValue: RawValue {
        self[routing: (\.rawValue, \.rawValue, \.rawValue)]
    }
}

extension OneOf3 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable { }
extension OneOf3 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable { }
extension OneOf3 : Identifiable where T1 : Identifiable, T2 : Identifiable, T3 : Identifiable {
    public var id: OneOf3<T1.ID, T2.ID, T3.ID> { map3({ $0.id }, { $0.id }, { $0.id }) }
}

public extension OneOf3 {
    /// Apply the separate mapping functions for the individual options.
    /// - Parameters:
    ///   - f1: the function to apply to `T1`
    ///   - f2: the function to apply to `T2`
    ///   - f3: the function to apply to `T3`
    @inlinable func map3<U1, U2, U3>(_ f1: (T1) throws -> (U1), _ f2: (T2) throws -> (U2), _ f3: (T3) throws -> (U3)) rethrows -> OneOf3<U1, U2, U3> {
        switch self {
        case .v1(let t1): return try .init(f1(t1))
        case .v2(let t2): return try .init(f2(t2))
        case .v3(let t3): return try .init(f3(t3))
        }
    }

    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>, kp3: KeyPath<T3, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = Self(x3)
            }
        }
    }
}

/// The protocol of a type that can contain one out of 4 or more exclusive options
public protocol OneOf4Type : OneOf3Type {
    associatedtype T4
    init(t4: T4)
    init(_ t4: T4)
    func infer() -> T4?
}

public extension OneOf4Type {
    @inlinable var v4: T4? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// Construct a `OneOf4Type` from T4.
@inlinable public func oneOf<T: OneOf4Type>(_ value: T.T4) -> T { .init(value) }

/// A simple union type that can be one of either T1 or T2 or T3 or T4
public indirect enum OneOf4<T1, T2, T3, T4> : OneOf4Type {
    case v1(T1), v2(T2), v3(T3), v4(T4)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable public init(t3: T3) { self = .v3(t3) }
    @inlinable public init(_ t3: T3) { self = .v3(t3) }

    @inlinable public init(t4: T4) { self = .v4(t4) }
    @inlinable public init(_ t4: T4) { self = .v4(t4) }

    /// Split the tuple into nested OneOf2 instances
    @inlinable public func split() -> OneOf2<OneOf2<OneOf2<T1, T2>, T3>, T4> {
        switch self {
        case .v1(let v): return .v1(.v1(.v1(v)))
        case .v2(let v): return .v1(.v1(.v2(v)))
        case .v3(let v): return .v1(.v2(v))
        case .v4(let v): return .v2(v)
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?, T3?, T4?) {
        switch self {
        case .v1(let v): return (v, nil, nil, nil)
        case .v2(let v): return (nil, v, nil, nil)
        case .v3(let v): return (nil, nil, v, nil)
        case .v4(let v): return (nil, nil, nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    @inlinable public func infer() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    @inlinable public func infer() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }

}

extension OneOf4 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        }
    }
}

extension OneOf4 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf4 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            ])
    }
}

extension OneOf4 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable {

    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        case .v4(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf4 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable, T4 : Decodable {

    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf4 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable, T3 : CaseIterable, T4 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf4]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            T3.allCases.map(AllCases.Element.init(t3:)),
            T4.allCases.map(AllCases.Element.init(t4:)),
            ].joined())
    }
}

extension OneOf4 : RawRepresentable where T1 : RawRepresentable, T2 : RawRepresentable, T3 : RawRepresentable, T4 : RawRepresentable, T1.RawValue == T2.RawValue, T2.RawValue == T3.RawValue, T3.RawValue == T4.RawValue {
    public typealias RawValue = T1.RawValue

    public init?(rawValue: RawValue) {
        if let t1 = T1(rawValue: rawValue) { self = .init(t1: t1) }
        else if let t2 = T2(rawValue: rawValue) { self = .init(t2: t2) }
        else if let t3 = T3(rawValue: rawValue) { self = .init(t3: t3) }
        else if let t4 = T4(rawValue: rawValue) { self = .init(t4: t4) }
        else { return nil }
    }

    public var rawValue: RawValue {
        self[routing: (\.rawValue, \.rawValue, \.rawValue, \.rawValue)]
    }
}

extension OneOf4 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable { }
extension OneOf4 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable { }
extension OneOf4 : Identifiable where T1 : Identifiable, T2 : Identifiable, T3 : Identifiable, T4 : Identifiable {
    public var id: OneOf4<T1.ID, T2.ID, T3.ID, T4.ID> { map4({ $0.id }, { $0.id }, { $0.id }, { $0.id }) }
}

public extension OneOf4 {
    /// Apply the separate mapping functions for the individual options.
    /// - Parameters:
    ///   - f1: the function to apply to `T1`
    ///   - f2: the function to apply to `T2`
    ///   - f3: the function to apply to `T3`
    ///   - f4: the function to apply to `T4`
    @inlinable func map4<U1, U2, U3, U4>(_ f1: (T1) throws -> (U1), _ f2: (T2) throws -> (U2), _ f3: (T3) throws -> (U3), _ f4: (T4) throws -> (U4)) rethrows -> OneOf4<U1, U2, U3, U4> {
        switch self {
        case .v1(let t1): return try .init(f1(t1))
        case .v2(let t2): return try .init(f2(t2))
        case .v3(let t3): return try .init(f3(t3))
        case .v4(let t4): return try .init(f4(t4))
        }
    }

    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>, kp3: KeyPath<T3, T>, kp4: KeyPath<T4, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = Self(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = Self(x4)
            }
        }
    }
}

/// The protocol of a type that can contain one out of 5 or more exclusive options
public protocol OneOf5Type : OneOf4Type {
    associatedtype T5
    init(t5: T5)
    init(_ t5: T5)
    func infer() -> T5?
}

/// Construct a `OneOf5Type` from T5.
@inlinable public func oneOf<T: OneOf5Type>(_ value: T.T5) -> T { .init(value) }

public extension OneOf5Type {
    @inlinable var v5: T5? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5
public indirect enum OneOf5<T1, T2, T3, T4, T5> : OneOf5Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable public init(t3: T3) { self = .v3(t3) }
    @inlinable public init(_ t3: T3) { self = .v3(t3) }

    @inlinable public init(t4: T4) { self = .v4(t4) }
    @inlinable public init(_ t4: T4) { self = .v4(t4) }

    @inlinable public init(t5: T5) { self = .v5(t5) }
    @inlinable public init(_ t5: T5) { self = .v5(t5) }

    /// Split the tuple into nested OneOf2 instances
    @inlinable public func split() -> OneOf2<OneOf2<OneOf2<OneOf2<T1, T2>, T3>, T4>, T5> {
        switch self {
        case .v1(let v): return .v1(.v1(.v1(.v1(v))))
        case .v2(let v): return .v1(.v1(.v1(.v2(v))))
        case .v3(let v): return .v1(.v1(.v2(v)))
        case .v4(let v): return .v1(.v2(v))
        case .v5(let v): return .v2(v)
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?, T3?, T4?, T5?) {
        switch self {
        case .v1(let v): return (v, nil, nil, nil, nil)
        case .v2(let v): return (nil, v, nil, nil, nil)
        case .v3(let v): return (nil, nil, v, nil, nil)
        case .v4(let v): return (nil, nil, nil, v, nil)
        case .v5(let v): return (nil, nil, nil, nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    @inlinable public func infer() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    @inlinable public func infer() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    @inlinable public func infer() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
}

extension OneOf5 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        case .v5(let t5): return t5.bric()
        }
    }
}

extension OneOf5 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf5 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            ])
    }
}

extension OneOf5 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable, T5 : Encodable {

    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        case .v4(let x): try x.encode(to: encoder)
        case .v5(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf5 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable, T4 : Decodable, T5 : Decodable {

    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v5(T5(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf5 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable, T3 : CaseIterable, T4 : CaseIterable, T5 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf5]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            T3.allCases.map(AllCases.Element.init(t3:)),
            T4.allCases.map(AllCases.Element.init(t4:)),
            T5.allCases.map(AllCases.Element.init(t5:)),
            ].joined())
    }
}

extension OneOf5 : RawRepresentable where T1 : RawRepresentable, T2 : RawRepresentable, T3 : RawRepresentable, T4 : RawRepresentable, T5 : RawRepresentable, T1.RawValue == T2.RawValue, T2.RawValue == T3.RawValue, T3.RawValue == T4.RawValue, T4.RawValue == T5.RawValue {
    public typealias RawValue = T1.RawValue

    public init?(rawValue: RawValue) {
        if let t1 = T1(rawValue: rawValue) { self = .init(t1: t1) }
        else if let t2 = T2(rawValue: rawValue) { self = .init(t2: t2) }
        else if let t3 = T3(rawValue: rawValue) { self = .init(t3: t3) }
        else if let t4 = T4(rawValue: rawValue) { self = .init(t4: t4) }
        else if let t5 = T5(rawValue: rawValue) { self = .init(t5: t5) }
        else { return nil }
    }

    public var rawValue: RawValue {
        self[routing: (\.rawValue, \.rawValue, \.rawValue, \.rawValue, \.rawValue)]
    }
}

extension OneOf5 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable { }
extension OneOf5 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable { }
extension OneOf5 : Identifiable where T1 : Identifiable, T2 : Identifiable, T3 : Identifiable, T4 : Identifiable, T5 : Identifiable {
    public var id: OneOf5<T1.ID, T2.ID, T3.ID, T4.ID, T5.ID> { map5({ $0.id }, { $0.id }, { $0.id }, { $0.id }, { $0.id }) }
}


public extension OneOf5 {
    /// Apply the separate mapping functions for the individual options.
    /// - Parameters:
    ///   - f1: the function to apply to `T1`
    ///   - f2: the function to apply to `T2`
    ///   - f3: the function to apply to `T3`
    ///   - f4: the function to apply to `T4`
    ///   - f5: the function to apply to `T5`
    @inlinable func map5<U1, U2, U3, U4, U5>(_ f1: (T1) throws -> (U1), _ f2: (T2) throws -> (U2), _ f3: (T3) throws -> (U3), _ f4: (T4) throws -> (U4), _ f5: (T5) throws -> (U5)) rethrows -> OneOf5<U1, U2, U3, U4, U5> {
        switch self {
        case .v1(let t1): return try .init(f1(t1))
        case .v2(let t2): return try .init(f2(t2))
        case .v3(let t3): return try .init(f3(t3))
        case .v4(let t4): return try .init(f4(t4))
        case .v5(let t5): return try .init(f5(t5))
        }
    }

    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>, kp3: KeyPath<T3, T>, kp4: KeyPath<T4, T>, kp5: KeyPath<T5, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>, kp5: WritableKeyPath<T5, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = Self(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = Self(x4)
            case .v5(var x5): x5[keyPath: keys.kp5] = newValue; self = Self(x5)
            }
        }
    }
}


/// The protocol of a type that can contain one out of 6 or more exclusive options
public protocol OneOf6Type : OneOf5Type {
    associatedtype T6
    init(t6: T6)
    init(_ t6: T6)
    func infer() -> T6?
}

/// Construct a `OneOf6Type` from T6.
@inlinable public func oneOf<T: OneOf6Type>(_ value: T.T6) -> T { .init(value) }

public extension OneOf6Type {
    @inlinable var v6: T6? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}


/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9
public indirect enum OneOf6<T1, T2, T3, T4, T5, T6> : OneOf6Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable public init(t3: T3) { self = .v3(t3) }
    @inlinable public init(_ t3: T3) { self = .v3(t3) }

    @inlinable public init(t4: T4) { self = .v4(t4) }
    @inlinable public init(_ t4: T4) { self = .v4(t4) }

    @inlinable public init(t5: T5) { self = .v5(t5) }
    @inlinable public init(_ t5: T5) { self = .v5(t5) }

    @inlinable public init(t6: T6) { self = .v6(t6) }
    @inlinable public init(_ t6: T6) { self = .v6(t6) }

    /// Split the tuple into nested OneOf2 instances
    @inlinable public func split() -> OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<T1, T2>, T3>, T4>, T5>, T6> {
        switch self {
        case .v1(let v): return .v1(.v1(.v1(.v1(.v1(v)))))
        case .v2(let v): return .v1(.v1(.v1(.v1(.v2(v)))))
        case .v3(let v): return .v1(.v1(.v1(.v2(v))))
        case .v4(let v): return .v1(.v1(.v2(v)))
        case .v5(let v): return .v1(.v2(v))
        case .v6(let v): return .v2(v)
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?, T3?, T4?, T5?, T6?) {
        switch self {
        case .v1(let v): return (v, nil, nil, nil, nil, nil)
        case .v2(let v): return (nil, v, nil, nil, nil, nil)
        case .v3(let v): return (nil, nil, v, nil, nil, nil)
        case .v4(let v): return (nil, nil, nil, v, nil, nil)
        case .v5(let v): return (nil, nil, nil, nil, v, nil)
        case .v6(let v): return (nil, nil, nil, nil, nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    @inlinable public func infer() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    @inlinable public func infer() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    @inlinable public func infer() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    @inlinable public func infer() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
}

extension OneOf6 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        case .v5(let t5): return t5.bric()
        case .v6(let t6): return t6.bric()
        }
    }
}

extension OneOf6 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf6 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            ])
    }
}

extension OneOf6 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable, T5 : Encodable, T6 : Encodable {

    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        case .v4(let x): try x.encode(to: encoder)
        case .v5(let x): try x.encode(to: encoder)
        case .v6(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf6 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable, T4 : Decodable, T5 : Decodable, T6 : Decodable {

    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v5(T5(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v6(T6(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf6 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable, T3 : CaseIterable, T4 : CaseIterable, T5 : CaseIterable, T6 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf6]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            T3.allCases.map(AllCases.Element.init(t3:)),
            T4.allCases.map(AllCases.Element.init(t4:)),
            T5.allCases.map(AllCases.Element.init(t5:)),
            T6.allCases.map(AllCases.Element.init(t6:)),
            ].joined())
    }
}

extension OneOf6 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable { }
extension OneOf6 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable { }

public extension OneOf6 {
    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>, kp3: KeyPath<T3, T>, kp4: KeyPath<T4, T>, kp5: KeyPath<T5, T>, kp6: KeyPath<T6, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>, kp5: WritableKeyPath<T5, T>, kp6: WritableKeyPath<T6, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = Self(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = Self(x4)
            case .v5(var x5): x5[keyPath: keys.kp5] = newValue; self = Self(x5)
            case .v6(var x6): x6[keyPath: keys.kp6] = newValue; self = Self(x6)
            }
        }
    }
}


/// The protocol of a type that can contain one out of 7 or more exclusive options
public protocol OneOf7Type : OneOf6Type {
    associatedtype T7
    init(t7: T7)
    init(_ t7: T7)
    func infer() -> T7?
}

/// Construct a `OneOf7Type` from T7.
@inlinable public func oneOf<T: OneOf7Type>(_ value: T.T7) -> T { .init(value) }

public extension OneOf7Type {
    @inlinable var v7: T7? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}



/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9
public indirect enum OneOf7<T1, T2, T3, T4, T5, T6, T7> : OneOf7Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6), v7(T7)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable public init(t3: T3) { self = .v3(t3) }
    @inlinable public init(_ t3: T3) { self = .v3(t3) }

    @inlinable public init(t4: T4) { self = .v4(t4) }
    @inlinable public init(_ t4: T4) { self = .v4(t4) }

    @inlinable public init(t5: T5) { self = .v5(t5) }
    @inlinable public init(_ t5: T5) { self = .v5(t5) }

    @inlinable public init(t6: T6) { self = .v6(t6) }
    @inlinable public init(_ t6: T6) { self = .v6(t6) }

    @inlinable public init(t7: T7) { self = .v7(t7) }
    @inlinable public init(_ t7: T7) { self = .v7(t7) }

    /// Split the tuple into nested OneOf2 instances
    @inlinable public func split() -> OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<T1, T2>, T3>, T4>, T5>, T6>, T7> {
        switch self {
        case .v1(let v): return .v1(.v1(.v1(.v1(.v1(.v1(v))))))
        case .v2(let v): return .v1(.v1(.v1(.v1(.v1(.v2(v))))))
        case .v3(let v): return .v1(.v1(.v1(.v1(.v2(v)))))
        case .v4(let v): return .v1(.v1(.v1(.v2(v))))
        case .v5(let v): return .v1(.v1(.v2(v)))
        case .v6(let v): return .v1(.v2(v))
        case .v7(let v): return .v2(v)
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?, T3?, T4?, T5?, T6?, T7?) {
        switch self {
        case .v1(let v): return (v, nil, nil, nil, nil, nil, nil)
        case .v2(let v): return (nil, v, nil, nil, nil, nil, nil)
        case .v3(let v): return (nil, nil, v, nil, nil, nil, nil)
        case .v4(let v): return (nil, nil, nil, v, nil, nil, nil)
        case .v5(let v): return (nil, nil, nil, nil, v, nil, nil)
        case .v6(let v): return (nil, nil, nil, nil, nil, v, nil)
        case .v7(let v): return (nil, nil, nil, nil, nil, nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    @inlinable public func infer() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    @inlinable public func infer() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    @inlinable public func infer() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    @inlinable public func infer() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
    @inlinable public func infer() -> T7? { if case .v7(let v7) = self { return v7 } else { return nil } }
}

extension OneOf7 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        case .v5(let t5): return t5.bric()
        case .v6(let t6): return t6.bric()
        case .v7(let t7): return t7.bric()
        }
    }
}

extension OneOf7 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable, T7: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf7 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            { try .v7(T7.brac(bric: bric)) },
            ])
    }
}

extension OneOf7 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable, T5 : Encodable, T6 : Encodable, T7 : Encodable {

    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        case .v4(let x): try x.encode(to: encoder)
        case .v5(let x): try x.encode(to: encoder)
        case .v6(let x): try x.encode(to: encoder)
        case .v7(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf7 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable, T4 : Decodable, T5 : Decodable, T6 : Decodable, T7 : Decodable {

    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v5(T5(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v6(T6(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v7(T7(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf7 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable, T3 : CaseIterable, T4 : CaseIterable, T5 : CaseIterable, T6 : CaseIterable, T7 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf7]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            T3.allCases.map(AllCases.Element.init(t3:)),
            T4.allCases.map(AllCases.Element.init(t4:)),
            T5.allCases.map(AllCases.Element.init(t5:)),
            T6.allCases.map(AllCases.Element.init(t6:)),
            T7.allCases.map(AllCases.Element.init(t7:)),
            ].joined())
    }
}

extension OneOf7 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable, T7 : Equatable { }
extension OneOf7 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable, T7 : Hashable { }

public extension OneOf7 {
    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>, kp3: KeyPath<T3, T>, kp4: KeyPath<T4, T>, kp5: KeyPath<T5, T>, kp6: KeyPath<T6, T>, kp7: KeyPath<T7, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            case .v7(let x7): return x7[keyPath: keys.kp7]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>, kp5: WritableKeyPath<T5, T>, kp6: WritableKeyPath<T6, T>, kp7: WritableKeyPath<T7, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            case .v7(let x7): return x7[keyPath: keys.kp7]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = Self(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = Self(x4)
            case .v5(var x5): x5[keyPath: keys.kp5] = newValue; self = Self(x5)
            case .v6(var x6): x6[keyPath: keys.kp6] = newValue; self = Self(x6)
            case .v7(var x7): x7[keyPath: keys.kp7] = newValue; self = Self(x7)
            }
        }
    }
}


/// The protocol of a type that can contain one out of 8 or more exclusive options
public protocol OneOf8Type : OneOf7Type {
    associatedtype T8
    init(t8: T8)
    init(_ t8: T8)
    func infer() -> T8?
}

/// Construct a `OneOf8Type` from T8.
@inlinable public func oneOf<T: OneOf8Type>(_ value: T.T8) -> T { .init(value) }

public extension OneOf8Type {
    @inlinable var v8: T8? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9
public indirect enum OneOf8<T1, T2, T3, T4, T5, T6, T7, T8> : OneOf8Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6), v7(T7), v8(T8)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable public init(t3: T3) { self = .v3(t3) }
    @inlinable public init(_ t3: T3) { self = .v3(t3) }

    @inlinable public init(t4: T4) { self = .v4(t4) }
    @inlinable public init(_ t4: T4) { self = .v4(t4) }

    @inlinable public init(t5: T5) { self = .v5(t5) }
    @inlinable public init(_ t5: T5) { self = .v5(t5) }

    @inlinable public init(t6: T6) { self = .v6(t6) }
    @inlinable public init(_ t6: T6) { self = .v6(t6) }

    @inlinable public init(t7: T7) { self = .v7(t7) }
    @inlinable public init(_ t7: T7) { self = .v7(t7) }

    @inlinable public init(t8: T8) { self = .v8(t8) }
    @inlinable public init(_ t8: T8) { self = .v8(t8) }

    /// Split the tuple into nested OneOf2 instances
    @inlinable public func split() -> OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<T1, T2>, T3>, T4>, T5>, T6>, T7>, T8> {
        switch self {
        case .v1(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v1(v)))))))
        case .v2(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v2(v)))))))
        case .v3(let v): return .v1(.v1(.v1(.v1(.v1(.v2(v))))))
        case .v4(let v): return .v1(.v1(.v1(.v1(.v2(v)))))
        case .v5(let v): return .v1(.v1(.v1(.v2(v))))
        case .v6(let v): return .v1(.v1(.v2(v)))
        case .v7(let v): return .v1(.v2(v))
        case .v8(let v): return .v2(v)
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?, T3?, T4?, T5?, T6?, T7?, T8?) {
        switch self {
        case .v1(let v): return (v, nil, nil, nil, nil, nil, nil, nil)
        case .v2(let v): return (nil, v, nil, nil, nil, nil, nil, nil)
        case .v3(let v): return (nil, nil, v, nil, nil, nil, nil, nil)
        case .v4(let v): return (nil, nil, nil, v, nil, nil, nil, nil)
        case .v5(let v): return (nil, nil, nil, nil, v, nil, nil, nil)
        case .v6(let v): return (nil, nil, nil, nil, nil, v, nil, nil)
        case .v7(let v): return (nil, nil, nil, nil, nil, nil, v, nil)
        case .v8(let v): return (nil, nil, nil, nil, nil, nil, nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    @inlinable public func infer() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    @inlinable public func infer() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    @inlinable public func infer() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    @inlinable public func infer() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
    @inlinable public func infer() -> T7? { if case .v7(let v7) = self { return v7 } else { return nil } }
    @inlinable public func infer() -> T8? { if case .v8(let v8) = self { return v8 } else { return nil } }
}

extension OneOf8 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        case .v5(let t5): return t5.bric()
        case .v6(let t6): return t6.bric()
        case .v7(let t7): return t7.bric()
        case .v8(let t8): return t8.bric()
        }
    }
}

extension OneOf8 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable, T7: Bracable, T8: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf8 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            { try .v7(T7.brac(bric: bric)) },
            { try .v8(T8.brac(bric: bric)) },
            ])
    }
}

extension OneOf8 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable, T5 : Encodable, T6 : Encodable, T7 : Encodable, T8 : Encodable {

    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        case .v4(let x): try x.encode(to: encoder)
        case .v5(let x): try x.encode(to: encoder)
        case .v6(let x): try x.encode(to: encoder)
        case .v7(let x): try x.encode(to: encoder)
        case .v8(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf8 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable, T4 : Decodable, T5 : Decodable, T6 : Decodable, T7 : Decodable, T8 : Decodable {

    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v5(T5(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v6(T6(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v7(T7(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v8(T8(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf8 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable, T3 : CaseIterable, T4 : CaseIterable, T5 : CaseIterable, T6 : CaseIterable, T7 : CaseIterable, T8 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf8]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            T3.allCases.map(AllCases.Element.init(t3:)),
            T4.allCases.map(AllCases.Element.init(t4:)),
            T5.allCases.map(AllCases.Element.init(t5:)),
            T6.allCases.map(AllCases.Element.init(t6:)),
            T7.allCases.map(AllCases.Element.init(t7:)),
            T8.allCases.map(AllCases.Element.init(t8:)),
            ].joined())
    }
}

extension OneOf8 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable, T7 : Equatable, T8 : Equatable { }
extension OneOf8 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable, T7 : Hashable, T8 : Hashable { }


public extension OneOf8 {
    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>, kp3: KeyPath<T3, T>, kp4: KeyPath<T4, T>, kp5: KeyPath<T5, T>, kp6: KeyPath<T6, T>, kp7: KeyPath<T7, T>, kp8: KeyPath<T8, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            case .v7(let x7): return x7[keyPath: keys.kp7]
            case .v8(let x8): return x8[keyPath: keys.kp8]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>, kp5: WritableKeyPath<T5, T>, kp6: WritableKeyPath<T6, T>, kp7: WritableKeyPath<T7, T>, kp8: WritableKeyPath<T8, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            case .v7(let x7): return x7[keyPath: keys.kp7]
            case .v8(let x8): return x8[keyPath: keys.kp8]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = Self(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = Self(x4)
            case .v5(var x5): x5[keyPath: keys.kp5] = newValue; self = Self(x5)
            case .v6(var x6): x6[keyPath: keys.kp6] = newValue; self = Self(x6)
            case .v7(var x7): x7[keyPath: keys.kp7] = newValue; self = Self(x7)
            case .v8(var x8): x8[keyPath: keys.kp8] = newValue; self = Self(x8)
            }
        }
    }
}


/// The protocol of a type that can contain one out of 9 or more exclusive options
public protocol OneOf9Type : OneOf8Type {
    associatedtype T9
    init(t9: T9)
    init(_ t9: T9)
    func infer() -> T9?
}

/// Construct a `OneOf9Type` from T9.
@inlinable public func oneOf<T: OneOf9Type>(_ value: T.T9) -> T { .init(value) }

public extension OneOf9Type {
    @inlinable var v9: T9? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9
public indirect enum OneOf9<T1, T2, T3, T4, T5, T6, T7, T8, T9> : OneOf9Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6), v7(T7), v8(T8), v9(T9)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable public init(t3: T3) { self = .v3(t3) }
    @inlinable public init(_ t3: T3) { self = .v3(t3) }

    @inlinable public init(t4: T4) { self = .v4(t4) }
    @inlinable public init(_ t4: T4) { self = .v4(t4) }

    @inlinable public init(t5: T5) { self = .v5(t5) }
    @inlinable public init(_ t5: T5) { self = .v5(t5) }

    @inlinable public init(t6: T6) { self = .v6(t6) }
    @inlinable public init(_ t6: T6) { self = .v6(t6) }

    @inlinable public init(t7: T7) { self = .v7(t7) }
    @inlinable public init(_ t7: T7) { self = .v7(t7) }

    @inlinable public init(t8: T8) { self = .v8(t8) }
    @inlinable public init(_ t8: T8) { self = .v8(t8) }

    @inlinable public init(t9: T9) { self = .v9(t9) }
    @inlinable public init(_ t9: T9) { self = .v9(t9) }

    /// Split the tuple into nested OneOf2 instances
    @inlinable public func split() -> OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<T1, T2>, T3>, T4>, T5>, T6>, T7>, T8>, T9> {
        switch self {
        case .v1(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v1(.v1(v))))))))
        case .v2(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v1(.v2(v))))))))
        case .v3(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v2(v)))))))
        case .v4(let v): return .v1(.v1(.v1(.v1(.v1(.v2(v))))))
        case .v5(let v): return .v1(.v1(.v1(.v1(.v2(v)))))
        case .v6(let v): return .v1(.v1(.v1(.v2(v))))
        case .v7(let v): return .v1(.v1(.v2(v)))
        case .v8(let v): return .v1(.v2(v))
        case .v9(let v): return .v2(v)
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?, T3?, T4?, T5?, T6?, T7?, T8?, T9?) {
        switch self {
        case .v1(let v): return (v, nil, nil, nil, nil, nil, nil, nil, nil)
        case .v2(let v): return (nil, v, nil, nil, nil, nil, nil, nil, nil)
        case .v3(let v): return (nil, nil, v, nil, nil, nil, nil, nil, nil)
        case .v4(let v): return (nil, nil, nil, v, nil, nil, nil, nil, nil)
        case .v5(let v): return (nil, nil, nil, nil, v, nil, nil, nil, nil)
        case .v6(let v): return (nil, nil, nil, nil, nil, v, nil, nil, nil)
        case .v7(let v): return (nil, nil, nil, nil, nil, nil, v, nil, nil)
        case .v8(let v): return (nil, nil, nil, nil, nil, nil, nil, v, nil)
        case .v9(let v): return (nil, nil, nil, nil, nil, nil, nil, nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    @inlinable public func infer() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    @inlinable public func infer() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    @inlinable public func infer() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    @inlinable public func infer() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
    @inlinable public func infer() -> T7? { if case .v7(let v7) = self { return v7 } else { return nil } }
    @inlinable public func infer() -> T8? { if case .v8(let v8) = self { return v8 } else { return nil } }
    @inlinable public func infer() -> T9? { if case .v9(let v9) = self { return v9 } else { return nil } }
}

extension OneOf9 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable, T9: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        case .v5(let t5): return t5.bric()
        case .v6(let t6): return t6.bric()
        case .v7(let t7): return t7.bric()
        case .v8(let t8): return t8.bric()
        case .v9(let t9): return t9.bric()
        }
    }
}

extension OneOf9 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable, T7: Bracable, T8: Bracable, T9: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf9 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            { try .v7(T7.brac(bric: bric)) },
            { try .v8(T8.brac(bric: bric)) },
            { try .v9(T9.brac(bric: bric)) },
            ])
    }
}

extension OneOf9 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable, T5 : Encodable, T6 : Encodable, T7 : Encodable, T8 : Encodable, T9 : Encodable {

    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        case .v4(let x): try x.encode(to: encoder)
        case .v5(let x): try x.encode(to: encoder)
        case .v6(let x): try x.encode(to: encoder)
        case .v7(let x): try x.encode(to: encoder)
        case .v8(let x): try x.encode(to: encoder)
        case .v9(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf9 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable, T4 : Decodable, T5 : Decodable, T6 : Decodable, T7 : Decodable, T8 : Decodable, T9 : Decodable {

    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v5(T5(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v6(T6(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v7(T7(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v8(T8(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v9(T9(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf9 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable, T3 : CaseIterable, T4 : CaseIterable, T5 : CaseIterable, T6 : CaseIterable, T7 : CaseIterable, T8 : CaseIterable, T9 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf9]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            T3.allCases.map(AllCases.Element.init(t3:)),
            T4.allCases.map(AllCases.Element.init(t4:)),
            T5.allCases.map(AllCases.Element.init(t5:)),
            T6.allCases.map(AllCases.Element.init(t6:)),
            T7.allCases.map(AllCases.Element.init(t7:)),
            T8.allCases.map(AllCases.Element.init(t8:)),
            T9.allCases.map(AllCases.Element.init(t9:)),
            ].joined())
    }
}

extension OneOf9 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable, T7 : Equatable, T8 : Equatable, T9 : Equatable { }
extension OneOf9 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable, T7 : Hashable, T8 : Hashable, T9 : Hashable { }


public extension OneOf9 {
    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>, kp3: KeyPath<T3, T>, kp4: KeyPath<T4, T>, kp5: KeyPath<T5, T>, kp6: KeyPath<T6, T>, kp7: KeyPath<T7, T>, kp8: KeyPath<T8, T>, kp9: KeyPath<T9, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            case .v7(let x7): return x7[keyPath: keys.kp7]
            case .v8(let x8): return x8[keyPath: keys.kp8]
            case .v9(let x9): return x9[keyPath: keys.kp9]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>, kp5: WritableKeyPath<T5, T>, kp6: WritableKeyPath<T6, T>, kp7: WritableKeyPath<T7, T>, kp8: WritableKeyPath<T8, T>, kp9: WritableKeyPath<T9, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            case .v7(let x7): return x7[keyPath: keys.kp7]
            case .v8(let x8): return x8[keyPath: keys.kp8]
            case .v9(let x9): return x9[keyPath: keys.kp9]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = Self(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = Self(x4)
            case .v5(var x5): x5[keyPath: keys.kp5] = newValue; self = Self(x5)
            case .v6(var x6): x6[keyPath: keys.kp6] = newValue; self = Self(x6)
            case .v7(var x7): x7[keyPath: keys.kp7] = newValue; self = Self(x7)
            case .v8(var x8): x8[keyPath: keys.kp8] = newValue; self = Self(x8)
            case .v9(var x9): x9[keyPath: keys.kp9] = newValue; self = Self(x9)
            }
        }
    }
}


/// The protocol of a type that can contain one out of 10 or more exclusive options
public protocol OneOf10Type : OneOf9Type {
    associatedtype T10
    init(t10: T10)
    init(_ t10: T10)
    func infer() -> T10?
}

/// Construct a `OneOf10Type` from T10.
@inlinable public func oneOf<T: OneOf10Type>(_ value: T.T10) -> T { .init(value) }

public extension OneOf10Type {
    @inlinable var v10: T10? { get { return infer() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9 or T10
public indirect enum OneOf10<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> : OneOf10Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6), v7(T7), v8(T8), v9(T9), v10(T10)

    @inlinable public init(t1: T1) { self = .v1(t1) }
    @inlinable public init(_ t1: T1) { self = .v1(t1) }

    @inlinable public init(t2: T2) { self = .v2(t2) }
    @inlinable public init(_ t2: T2) { self = .v2(t2) }

    @inlinable public init(t3: T3) { self = .v3(t3) }
    @inlinable public init(_ t3: T3) { self = .v3(t3) }

    @inlinable public init(t4: T4) { self = .v4(t4) }
    @inlinable public init(_ t4: T4) { self = .v4(t4) }

    @inlinable public init(t5: T5) { self = .v5(t5) }
    @inlinable public init(_ t5: T5) { self = .v5(t5) }

    @inlinable public init(t6: T6) { self = .v6(t6) }
    @inlinable public init(_ t6: T6) { self = .v6(t6) }

    @inlinable public init(t7: T7) { self = .v7(t7) }
    @inlinable public init(_ t7: T7) { self = .v7(t7) }

    @inlinable public init(t8: T8) { self = .v8(t8) }
    @inlinable public init(_ t8: T8) { self = .v8(t8) }

    @inlinable public init(t9: T9) { self = .v9(t9) }
    @inlinable public init(_ t9: T9) { self = .v9(t9) }

    @inlinable public init(t10: T10) { self = .v10(t10) }
    @inlinable public init(_ t10: T10) { self = .v10(t10) }

    /// Split the tuple into nested OneOf2 instances
    @inlinable public func split() -> OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<OneOf2<T1, T2>, T3>, T4>, T5>, T6>, T7>, T8>, T9>, T10> {
        switch self {
        case .v1(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v1(.v1(.v1(v)))))))))
        case .v2(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v1(.v1(.v2(v)))))))))
        case .v3(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v1(.v2(v))))))))
        case .v4(let v): return .v1(.v1(.v1(.v1(.v1(.v1(.v2(v)))))))
        case .v5(let v): return .v1(.v1(.v1(.v1(.v1(.v2(v))))))
        case .v6(let v): return .v1(.v1(.v1(.v1(.v2(v)))))
        case .v7(let v): return .v1(.v1(.v1(.v2(v))))
        case .v8(let v): return .v1(.v1(.v2(v)))
        case .v9(let v): return .v1(.v2(v))
        case .v10(let v): return .v2(v)
        }
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    @inlinable public var tupleValue: (T1?, T2?, T3?, T4?, T5?, T6?, T7?, T8?, T9?, T10?) {
        switch self {
        case .v1(let v): return (v, nil, nil, nil, nil, nil, nil, nil, nil, nil)
        case .v2(let v): return (nil, v, nil, nil, nil, nil, nil, nil, nil, nil)
        case .v3(let v): return (nil, nil, v, nil, nil, nil, nil, nil, nil, nil)
        case .v4(let v): return (nil, nil, nil, v, nil, nil, nil, nil, nil, nil)
        case .v5(let v): return (nil, nil, nil, nil, v, nil, nil, nil, nil, nil)
        case .v6(let v): return (nil, nil, nil, nil, nil, v, nil, nil, nil, nil)
        case .v7(let v): return (nil, nil, nil, nil, nil, nil, v, nil, nil, nil)
        case .v8(let v): return (nil, nil, nil, nil, nil, nil, nil, v, nil, nil)
        case .v9(let v): return (nil, nil, nil, nil, nil, nil, nil, nil, v, nil)
        case .v10(let v): return (nil, nil, nil, nil, nil, nil, nil, nil, nil, v)
        }
    }

    @inlinable public func infer() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    @inlinable public func infer() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    @inlinable public func infer() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    @inlinable public func infer() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    @inlinable public func infer() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    @inlinable public func infer() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
    @inlinable public func infer() -> T7? { if case .v7(let v7) = self { return v7 } else { return nil } }
    @inlinable public func infer() -> T8? { if case .v8(let v8) = self { return v8 } else { return nil } }
    @inlinable public func infer() -> T9? { if case .v9(let v9) = self { return v9 } else { return nil } }
    @inlinable public func infer() -> T10? { if case .v10(let v10) = self { return v10 } else { return nil } }
}

extension OneOf10 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable, T9: Bricable, T10: Bricable {
    @inlinable public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        case .v5(let t5): return t5.bric()
        case .v6(let t6): return t6.bric()
        case .v7(let t7): return t7.bric()
        case .v8(let t8): return t8.bric()
        case .v9(let t9): return t9.bric()
        case .v10(let t10): return t10.bric()
        }
    }
}

extension OneOf10 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable, T7: Bracable, T8: Bracable, T9: Bracable, T10: Bracable {
    @inlinable public static func brac(bric: Bric) throws -> OneOf10 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            { try .v7(T7.brac(bric: bric)) },
            { try .v8(T8.brac(bric: bric)) },
            { try .v9(T9.brac(bric: bric)) },
            { try .v10(T10.brac(bric: bric)) },
            ])
    }
}

extension OneOf10 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable, T5 : Encodable, T6 : Encodable, T7 : Encodable, T8 : Encodable, T9 : Encodable, T10 : Encodable {

    @inlinable public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        case .v4(let x): try x.encode(to: encoder)
        case .v5(let x): try x.encode(to: encoder)
        case .v6(let x): try x.encode(to: encoder)
        case .v7(let x): try x.encode(to: encoder)
        case .v8(let x): try x.encode(to: encoder)
        case .v9(let x): try x.encode(to: encoder)
        case .v10(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf10 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable, T4 : Decodable, T5 : Decodable, T6 : Decodable, T7 : Decodable, T8 : Decodable, T9 : Decodable, T10 : Decodable {

    @inlinable public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v5(T5(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v6(T6(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v7(T7(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v8(T8(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v9(T9(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v10(T10(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

/// One of a series of `CaseIterable`s is itself `CaseIterable`; `allCases` returns a lazy union of all sub-cases.
extension OneOf10 : CaseIterable where T1 : CaseIterable, T2 : CaseIterable, T3 : CaseIterable, T4 : CaseIterable, T5 : CaseIterable, T6 : CaseIterable, T7 : CaseIterable, T8 : CaseIterable, T9 : CaseIterable, T10 : CaseIterable {
    public typealias AllCases = FlattenSequence<[[OneOf10]]>
    @inlinable public static var allCases: AllCases {
        return ([
            T1.allCases.map(AllCases.Element.init(t1:)),
            T2.allCases.map(AllCases.Element.init(t2:)),
            T3.allCases.map(AllCases.Element.init(t3:)),
            T4.allCases.map(AllCases.Element.init(t4:)),
            T5.allCases.map(AllCases.Element.init(t5:)),
            T6.allCases.map(AllCases.Element.init(t6:)),
            T7.allCases.map(AllCases.Element.init(t7:)),
            T8.allCases.map(AllCases.Element.init(t8:)),
            T9.allCases.map(AllCases.Element.init(t9:)),
            T10.allCases.map(AllCases.Element.init(t10:)),
            ].joined())
    }
}

extension OneOf10 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable, T7 : Equatable, T8 : Equatable, T9 : Equatable, T10 : Equatable { }
extension OneOf10 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable, T7 : Hashable, T8 : Hashable, T9 : Hashable, T10 : Hashable { }



public extension OneOf10 {
    /// Enables reading multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: KeyPath<T1, T>, kp2: KeyPath<T2, T>, kp3: KeyPath<T3, T>, kp4: KeyPath<T4, T>, kp5: KeyPath<T5, T>, kp6: KeyPath<T6, T>, kp7: KeyPath<T7, T>, kp8: KeyPath<T8, T>, kp9: KeyPath<T9, T>, kp10: KeyPath<T10, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            case .v7(let x7): return x7[keyPath: keys.kp7]
            case .v8(let x8): return x8[keyPath: keys.kp8]
            case .v9(let x9): return x9[keyPath: keys.kp9]
            case .v10(let x10): return x10[keyPath: keys.kp10]
            }
        }
    }

    /// Enables reading & writing multiple different keyPaths that lead to the same type
    @inlinable subscript<T>(routing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>, kp5: WritableKeyPath<T5, T>, kp6: WritableKeyPath<T6, T>, kp7: WritableKeyPath<T7, T>, kp8: WritableKeyPath<T8, T>, kp9: WritableKeyPath<T9, T>, kp10: WritableKeyPath<T10, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            case .v4(let x4): return x4[keyPath: keys.kp4]
            case .v5(let x5): return x5[keyPath: keys.kp5]
            case .v6(let x6): return x6[keyPath: keys.kp6]
            case .v7(let x7): return x7[keyPath: keys.kp7]
            case .v8(let x8): return x8[keyPath: keys.kp8]
            case .v9(let x9): return x9[keyPath: keys.kp9]
            case .v10(let x10): return x10[keyPath: keys.kp10]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = Self(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = Self(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = Self(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = Self(x4)
            case .v5(var x5): x5[keyPath: keys.kp5] = newValue; self = Self(x5)
            case .v6(var x6): x6[keyPath: keys.kp6] = newValue; self = Self(x6)
            case .v7(var x7): x7[keyPath: keys.kp7] = newValue; self = Self(x7)
            case .v8(var x8): x8[keyPath: keys.kp8] = newValue; self = Self(x8)
            case .v9(var x9): x9[keyPath: keys.kp9] = newValue; self = Self(x9)
            case .v10(var x10): x10[keyPath: keys.kp10] = newValue; self = Self(x10)
            }
        }
    }
}


/// An error that indicates that multiple errors occured when decoding the type;
/// Each error should correspond to one of the choices for this type.
public struct OneOfDecodingError : Error {
    public let errors: [Error]
    public init(errors: [Error]) { self.errors = errors }
}




/// MARK: AllOf implementations

public protocol AllOf : SomeOf {
}

/// A simple sum type that must conform to both v1 and v2
public struct AllOf2<T1, T2> : AllOf {
    public var v1: T1
    public var v2: T2

    public init(v1: T1, v2: T2) {
        self.v1 = v1
        self.v2 = v2
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var tupleValue: (T1, T2) { return (v1, v2) }
}

extension AllOf2 : Encodable where T1 : Encodable, T2 : Encodable {
    public func encode(to encoder: Encoder) throws {
        try v1.encode(to: encoder)
        try v2.encode(to: encoder)
    }
}

extension AllOf2 : Decodable where T1 : Decodable, T2 : Decodable {
    public init(from decoder: Decoder) throws {
        let v1 = try T1(from: decoder)
        let v2 = try T2(from: decoder)
        self.init(v1: v1, v2: v2)
    }
}

extension AllOf2 : Equatable where T1 : Equatable, T2 : Equatable {
}

extension AllOf2 : Hashable where T1 : Hashable, T2 : Hashable {
}

public func allOf<T1, T2>(_ tuple: (T1, T2)) -> AllOf2<T1, T2> { .init(v1: tuple.0, v2: tuple.1) }

/// Stopgap implementation of AllOf3 via typealias to mutliple AllOf2
public typealias AllOf3<T1, T2, T3> = AllOf2<T1, AllOf2<T2, T3>>

public func allOf<T1, T2, T3>(_ tuple: (T1, T2, T3)) -> AllOf3<T1, T2, T3> { allOf((tuple.0, allOf((tuple.1, tuple.2)))) }

/// Stopgap implementation of AllOf4 via typealias to mutliple AllOf2
public typealias AllOf4<T1, T2, T3, T4> = AllOf2<T1, AllOf3<T2, T3, T4>>

public func allOf<T1, T2, T3, T4>(_ tuple: (T1, T2, T3, T4)) -> AllOf4<T1, T2, T3, T4> { allOf((tuple.0, allOf((tuple.1, tuple.2, tuple.3)))) }

/// Stopgap implementation of AllOf5 via typealias to mutliple AllOf2
public typealias AllOf5<T1, T2, T3, T4, T5> = AllOf2<T1, AllOf4<T2, T3, T4, T5>>

public func allOf<T1, T2, T3, T4, T5>(_ tuple: (T1, T2, T3, T4, T5)) -> AllOf5<T1, T2, T3, T4, T5> { allOf((tuple.0, allOf((tuple.1, tuple.2, tuple.3, tuple.4)))) }

/// Stopgap implementation of AllOf6 via typealias to mutliple AllOf2
public typealias AllOf6<T1, T2, T3, T4, T5, T6> = AllOf2<T1, AllOf5<T2, T3, T4, T5, T6>>

public func allOf<T1, T2, T3, T4, T5, T6>(_ tuple: (T1, T2, T3, T4, T5, T6)) -> AllOf6<T1, T2, T3, T4, T5, T6> { allOf((tuple.0, allOf((tuple.1, tuple.2, tuple.3, tuple.4, tuple.5)))) }

/// Stopgap implementation of AllOf7 via typealias to mutliple AllOf2
public typealias AllOf7<T1, T2, T3, T4, T5, T6, T7> = AllOf2<T1, AllOf6<T2, T3, T4, T5, T6, T7>>

public func allOf<T1, T2, T3, T4, T5, T6, T7>(_ tuple: (T1, T2, T3, T4, T5, T6, T7)) -> AllOf7<T1, T2, T3, T4, T5, T6, T7> { allOf((tuple.0, allOf((tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6)))) }

/// Stopgap implementation of AllOf8 via typealias to mutliple AllOf2
public typealias AllOf8<T1, T2, T3, T4, T5, T6, T7, T8> = AllOf2<T1, AllOf7<T2, T3, T4, T5, T6, T7, T8>>

public func allOf<T1, T2, T3, T4, T5, T6, T7, T8>(_ tuple: (T1, T2, T3, T4, T5, T6, T7, T8)) -> AllOf8<T1, T2, T3, T4, T5, T6, T7, T8> { allOf((tuple.0, allOf((tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7)))) }

/// Stopgap implementation of AllOf9 via typealias to mutliple AllOf2
public typealias AllOf9<T1, T2, T3, T4, T5, T6, T7, T8, T9> = AllOf2<T1, AllOf8<T2, T3, T4, T5, T6, T7, T8, T9>>

public func allOf<T1, T2, T3, T4, T5, T6, T7, T8, T9>(_ tuple: (T1, T2, T3, T4, T5, T6, T7, T8, T9)) -> AllOf9<T1, T2, T3, T4, T5, T6, T7, T8, T9> { allOf((tuple.0, allOf((tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8)))) }

/// Stopgap implementation of AllOf10 via typealias to mutliple AllOf2
public typealias AllOf10<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> = AllOf2<T1, AllOf9<T2, T3, T4, T5, T6, T7, T8, T9, T10>>



/// MARK: AnyOf implementations

public protocol AnyOf : SomeOf {
}

/// A simple sum type that must conform to either v1 or v2
public struct AnyOf2<T1, T2> : AnyOf {
    public var v1: T1?
    public var v2: T2?

    public init(v1: T1? = .none, v2: T2? = .none) {
        self.v1 = v1
        self.v2 = v2
    }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var tupleValue: (T1?, T2?) { return (v1, v2) }
}

extension AnyOf2 : Encodable where T1 : Encodable, T2 : Encodable {
    public func encode(to encoder: Encoder) throws {
        try v1?.encode(to: encoder)
        try v2?.encode(to: encoder)
    }
}

extension AnyOf2 : Decodable where T1 : Decodable, T2 : Decodable {
    public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        var v1: T1? = nil
        do { v1 = try T1(from: decoder) } catch { errors.append(error) }

        var v2: T2? = nil
        do { v2 = try T2(from: decoder) } catch { errors.append(error) }

        if v1 == nil && v2 == nil {
            throw AnyOfDecodingError(errors: errors)
        }
        self.init(v1: v1, v2: v2)
    }
}

extension AnyOf2 : Equatable where T1 : Equatable, T2 : Equatable {
}

extension AnyOf2 : Hashable where T1 : Hashable, T2 : Hashable {
}

/// Stopgap implementation of AnyOf3 via typealias to mutliple AnyOf2
public typealias AnyOf3<T1, T2, T3> = AnyOf2<T1, AnyOf2<T2, T3>>

/// Stopgap implementation of AnyOf4 via typealias to mutliple AnyOf2
public typealias AnyOf4<T1, T2, T3, T4> = AnyOf2<T1, AnyOf3<T2, T3, T4>>

/// Stopgap implementation of AnyOf5 via typealias to mutliple AnyOf2
public typealias AnyOf5<T1, T2, T3, T4, T5> = AnyOf2<T1, AnyOf4<T2, T3, T4, T5>>

/// Stopgap implementation of AnyOf6 via typealias to mutliple AnyOf2
public typealias AnyOf6<T1, T2, T3, T4, T5, T6> = AnyOf2<T1, AnyOf5<T2, T3, T4, T5, T6>>

/// Stopgap implementation of AnyOf7 via typealias to mutliple AnyOf2
public typealias AnyOf7<T1, T2, T3, T4, T5, T6, T7> = AnyOf2<T1, AnyOf6<T2, T3, T4, T5, T6, T7>>

/// Stopgap implementation of AnyOf8 via typealias to mutliple AnyOf2
public typealias AnyOf8<T1, T2, T3, T4, T5, T6, T7, T8> = AnyOf2<T1, AnyOf7<T2, T3, T4, T5, T6, T7, T8>>

/// Stopgap implementation of AnyOf9 via typealias to mutliple AnyOf2
public typealias AnyOf9<T1, T2, T3, T4, T5, T6, T7, T8, T9> = AnyOf2<T1, AnyOf8<T2, T3, T4, T5, T6, T7, T8, T9>>

/// Stopgap implementation of AnyOf10 via typealias to mutliple AnyOf2
public typealias AnyOf10<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> = AnyOf2<T1, AnyOf9<T2, T3, T4, T5, T6, T7, T8, T9, T10>>

/// An error that indicates that multiple errors occured when decoding the type;
/// Each error should correspond to one of the choices for this type.
public struct AnyOfDecodingError : Error {
    public let errors: [Error]
    public init(errors: [Error]) { self.errors = errors }
}


/// An ISO-8601 date-time structure, the common JSON format for dates and times
/// - See: https://en.wikipedia.org/wiki/ISO_8601
public protocol ISO8601DateTime {
    var year: Int { get set }
    var month: Int { get set }
    var day: Int { get set }
    var hour: Int { get set }
    var minute: Int { get set }
    var second: Double { get set }
    var zone: BricZone { get set }
}


public extension Bric {
    /// Returns the underlying `BricDateTime` for `Bric.str` cases that can be pased with `ISO8601FromString`, else nil
    var dtm: BricDateTime? {
        if let str = self.str {
            return BricDateTime(str)
        } else {
            return nil
        }
    }
}

public struct BricZone : Equatable, Codable, Hashable {
    public let hours: Int
    public let minutes: Int
}

public struct BricDateTime: ISO8601DateTime, Hashable, Equatable, Codable, CustomStringConvertible, Bricable, Bracable {
    public typealias BricDate = (year: Int, month: Int, day: Int)
    public typealias BricTime = (hour: Int, minute: Int, second: Double)

    public var year, month, day, hour, minute: Int
    public var second: Double
    public var zone: BricZone

    public init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Double, zone: (Int, Int)) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.zone = BricZone(hours: zone.0, minutes: zone.1)
    }

    /// Attempt to parse the given String as an ISO-8601 date-time structure
    public init?(_ str: String) {
        if let dtm = BricDateTime(year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, zone: (0, 0)).parseISO8601String(str) {
            self = dtm
        } else {
            return nil
        }
    }

    public var description: String { return toISO8601String() }

    /// BricDateTime instances are serialized to ISO-8601 strings
    public func bric() -> Bric {
        return Bric.str(toISO8601String())
    }

    /// BricDateTime instances are serialized to ISO-8601 strings
    public static func brac(bric: Bric) throws -> BricDateTime {
        guard case .str(let str) = bric else { return try bric.invalidType() }
        guard let dtm = BricDateTime(str) else { return try bric.invalidRawValue(str) }
        return dtm
    }

}

public extension ISO8601DateTime {

    /// Converts this datetime to a formatted string with the given time separator and designator for UTC (Zulu) time
    func toFormattedString(timesep: String = "T", utctz: String? = "Z", padsec: Int = 3) -> String {
        func pad(_ num: Int, _ len: Int) -> String {
            var str = String(num)
            while str.count < len {
                str = "0" + str
            }
            return str
        }

        /// Secs need to be padded to 2 at the beginning and 3 at the end, e.g.: 00.000
        func sec(_ secs: Double) -> String {
            var str = String(secs)
            let chars = str
            if padsec > 0 {
                if chars.count >= 2 && chars.dropFirst().first == "." { str = "0" + str }
                while str.count < (padsec + 3) { str += "0" }
            }
            return str
        }

        return pad(year, 4) + "-" + pad(month, 2) + "-" + pad(day, 2) + timesep + pad(hour, 2) + ":" + pad(minute, 2) + ":" + sec(second) + ((utctz != nil && zone.hours == 0 && zone.minutes == 0) ? utctz! : ((zone.hours >= 0 ? "+" : "") + pad(zone.hours, 2) + ":" + pad(zone.minutes, 2)))
    }

    /// Returns a string representation in accordance with ISO-8601
    func toISO8601String() -> String {
        return toFormattedString()
    }

    /// Attempt to parse the given String as an ISO-8601 date-time structure
    func parseISO8601String(_ str: String) -> Self? {
        var gen = str.makeIterator()

        func scan(_ skip: Int = 0, _ until: Character...) -> (String, Character?)? {
            var num = 0
            var buf = ""
            while let c = gen.next() {
                if until.contains(c) && num >= skip {
                    if buf.isEmpty { return nil }
                    return (buf, c)
                }
                num += 1
                buf.append(c)
            }
            if buf.isEmpty { return nil }
            return (buf, nil)
        }

        func str2int(_ str: String, _ stop: Character?) -> Int? { return Int(str) }

        guard let year = scan(1, "-").flatMap(str2int) else { return nil }
        guard let month = scan(0, "-").flatMap(str2int) , month >= 1 && month <= 12 else { return nil }
        guard let day = scan(0, "T").flatMap(str2int) , day >= 1 && day <= 31 else { return nil }

        if day == 31 && (month == 4 || month == 6 || month == 9 || month == 11) { return nil }

        // Feb leap year check
        if day > 28 && month == 2 && !((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) { return nil }

        guard let hour = scan(0, ":").flatMap(str2int) , hour >= 0 && hour <= 24 else { return nil }
        guard let minute = scan(0, ":").flatMap(str2int) , minute >= 0 && minute <= 59 else { return nil }

        // “ISO 8601 permits the hyphen (-) to be used as the minus (−) character when the character set is limited.”
        guard let secstop = scan(0, "Z", "+", "-", "−") else { return nil }

        guard let second = Double(secstop.0) , second >= 0.0 && second < 60.0 else { return nil }

        if hour == 24 && (minute > 0 || second > 0.0) { return nil } // 24 is only valid as 24:00:00.0

        let tzc = secstop.1
        var tzh = 0, tzm = 0
        if tzc != "Z" { // non-Zulu time
            guard let h = scan(0, ":").flatMap(str2int) , h >= 0 && h <= 23 else { return nil }
            tzh = h * (tzc == "-" || tzc == "−" ? -1 : +1)

            guard let m = scan(0).flatMap(str2int) , m >= 0 && m <= 59 else { return nil }
            tzm = m
        }

        if gen.next() != nil { return nil } // trailing characters

        // fill in the fields
        var dtm = self
        dtm.year = year
        dtm.month = month
        dtm.day = day
        dtm.hour = hour
        dtm.minute = minute
        dtm.second = second
        dtm.zone = BricZone(hours: tzh, minutes: tzm)
        return dtm
    }
}
