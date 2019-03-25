//
//  Structures.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 11/4/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

// General data structes need for `Brac` and `Curio` schema support

/// A WrapperType is able to map itself through a wrapped optional
public protocol WrapperType {
    associatedtype Wrapped
    init(_ some: Wrapped)
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

/// Wrappable can contain zero or one instances (covers both `Optional` and `Indirect`)
public protocol Wrappable {
    associatedtype Wrapped
    init(_ some: Wrapped)
}


extension Optional : WrapperType { }
extension Optional : Wrappable { }

public typealias Indirect = IndirectEnum

public extension Optional {
    /// Wrap this optional in an indirection
    public func indirect() -> Optional<Indirect<Wrapped>> {
        return self.flatMap(Indirect.init(rawValue:))
    }
}

/// An Indirect is a simple wrapper for an underlying value stored via an indirect enum in order to permit recursive value types
public struct IndirectStruct<Wrapped> : WrapperType, Wrappable {
    /// The underlying holder of the value; must be a type that can handle recursive types, which is why it is an `Array` and not a `CollectionOfOne`
    private var wrapper: [Wrapped]

    public var value: Wrapped {
        get { return self.wrapper[0] }
        set { self.wrapper[0] = newValue }
    }

    /// Construct a non-`nil` instance that stores `value`.
    public init(_ value: Wrapped) {
        self.wrapper = [value]
    }

    public func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U? {
        return try f(value)
    }
}

/// An Indirect is a simple wrapper for an underlying value stored via an indirect enum in order to permit recursive value types
public indirect enum IndirectEnum<Wrapped> : WrapperType, Wrappable {
    case some(Wrapped)

    /// Construct a non-`nil` instance that stores `some`.
    public init(_ some: Wrapped) {
        self = .some(some)
    }

    public var value: Wrapped {
        get {
            switch self {
            case .some(let v): return v
            }
        }

        set {
            self = .some(newValue)
        }
    }

    public func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U? {
        return try f(value)
    }
}

extension Indirect : RawRepresentable {
    public typealias RawValue = Wrapped

    /// Constructor for RawRepresentable
    public init(rawValue some: Wrapped) {
        self.init(some)
    }

    public var rawValue: Wrapped { return value }
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

extension Indirect : Equatable where Wrapped : Equatable {
    public static func ==(lhs: IndirectEnum, rhs: IndirectEnum) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Indirect : Hashable where Wrapped : Hashable {
    public var hashValue: Int {
        return value.hashValue
    }
}


/// An empty struct that marks an explicit nil reference; this is as opposed to an Optional which can be absent, whereas an ExplicitNull requires that the value be exactly "null"
public struct ExplicitNull : Codable, Equatable, Hashable, ExpressibleByNilLiteral {
    public static let null = ExplicitNull()

    public init(nilLiteral: ()) { }
    public init() { }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(ExplicitNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ExplicitNull"))
        }
    }
}

/// A Nullable is a type that can be either explicitly null or a given type
public typealias Nullable<T> = OneOf2<T, ExplicitNull>

extension OneOf2 : ExpressibleByNilLiteral where T2 == ExplicitNull {
    public init(nilLiteral: ()) { self = .v2(nil) }
}

public extension OneOf2Type where T2 == ExplicitNull /* i.e., Nullable */ {
    public var isExplicitNull: Bool { return self.v2 == ExplicitNull.null }
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
    var values: T { get }
}

/// MARK: OneOf implementations

/// The protocol of a type that can contain one out of 1 or more exclusive options
public protocol OneOfN : SomeOf {
    associatedtype T1
    init(t1: T1)
    init(_ t1: T1)
    func extract() -> T1?
}

public extension OneOfN {
    public var v1: T1? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// The protocol of a type that can contain one out of 2 or more exclusive options
public protocol OneOf2Type : OneOfN {
    associatedtype T2
    init(t2: T2)
    init(_ t2: T2)
    func extract() -> T2?
}

public extension OneOf2Type {
    public var v2: T2? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2
public indirect enum OneOf2<T1, T2> : OneOf2Type {
    case v1(T1), v2(T2)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?) { return (extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }

    /// Extract the underlying value to a common implementor type (typically a common protocol)
    /// Sadly, this doesn't work: “Type 'T1' constrained to non-protocol, non-class type 'T'”
//    public func implementing<T>() -> T where T1 : T, T2 : T {
//        switch self {
//        case .v1(let x): return x
//        case .v2(let x): return x
//        }
//    }
}

extension OneOf2 : Bricable where T1: Bricable, T2: Bricable {
    public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        }
    }
}

extension OneOf2 : Bracable where T1: Bracable, T2: Bracable {
    public static func brac(bric: Bric) throws -> OneOf2 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            ])
    }
}

extension OneOf2 : Encodable where T1 : Encodable, T2 : Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf2 : Decodable where T1 : Decodable, T2 : Decodable {

    public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

extension OneOf2 : Equatable where T1 : Equatable, T2 : Equatable {
    public static func ==(lhs: OneOf2, rhs: OneOf2) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf2 : Hashable where T1 : Hashable, T2 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        }
    }
}

public extension OneOf2 {
    /// Enables reading & writing multiple different keyPaths that lead to the same type
    public subscript<T>(traversing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = .init(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = .init(x2)
            }
        }
    }
}

/// Common case of OneOf2<String, [String]>, where we can get or set values as an array
extension OneOf2 where T2 == Array<T1> {
    /// Access the underlying values as an array regardless of whether it is the single or multiple case
    public var array: [T1] {
        get {
            switch self {
            case .v1(let x):
                return [x]
            case .v2(let x):
                return x
            }
        }

        set {
            if let singleValue = newValue.first, newValue.count == 1 {
                self = .v1(singleValue)
            } else {
                self = .v2(newValue)
            }
        }
    }
}

/// Reversed the OneOf2 ordering
extension OneOf2 {
    /// Returns a swapped instance of this OneOf2<T1, T2> as a OneOf2<T2, T1>
    public var swapped: OneOf2<T2, T1> {
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
    func extract() -> T3?
}

public extension OneOf3Type {
    public var v3: T3? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3
public indirect enum OneOf3<T1, T2, T3> : OneOf3Type {
    case v1(T1), v2(T2), v3(T3)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?) { return (extract(), extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    public func extract() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
}

extension OneOf3 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable {
    public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        }
    }
}

extension OneOf3 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable {
    public static func brac(bric: Bric) throws -> OneOf3 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            ])
    }
}

extension OneOf3 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf3 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable {

    public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

extension OneOf3 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable {
    public static func ==(lhs: OneOf3, rhs: OneOf3) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        case (.v3(let a), .v3(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf3 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        case .v3(let x): return x.hashValue
        }
    }
}

public extension OneOf3 {
    /// Enables reading & writing multiple different keyPaths that lead to the same type
    public subscript<T>(traversing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>)) -> T {
        get {
            switch self {
            case .v1(let x1): return x1[keyPath: keys.kp1]
            case .v2(let x2): return x2[keyPath: keys.kp2]
            case .v3(let x3): return x3[keyPath: keys.kp3]
            }
        }

        set {
            switch self {
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = .init(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = .init(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = .init(x3)
            }
        }
    }
}

/// The protocol of a type that can contain one out of 4 or more exclusive options
public protocol OneOf4Type : OneOf3Type {
    associatedtype T4
    init(t4: T4)
    init(_ t4: T4)
    func extract() -> T4?
}

public extension OneOf4Type {
    public var v4: T4? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}


/// A simple union type that can be one of either T1 or T2 or T3 or T4
public indirect enum OneOf4<T1, T2, T3, T4> : OneOf4Type {
    case v1(T1), v2(T2), v3(T3), v4(T4)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?) { return (extract(), extract(), extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    public func extract() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    public func extract() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }

}

extension OneOf4 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable {
    public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        }
    }
}

extension OneOf4 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable {
    public static func brac(bric: Bric) throws -> OneOf4 {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            ])
    }
}

extension OneOf4 : Encodable where T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .v1(let x): try x.encode(to: encoder)
        case .v2(let x): try x.encode(to: encoder)
        case .v3(let x): try x.encode(to: encoder)
        case .v4(let x): try x.encode(to: encoder)
        }
    }
}

extension OneOf4 : Decodable where T1 : Decodable, T2 : Decodable, T3 : Decodable, T4 : Decodable {

    public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

extension OneOf4 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable {
    public static func ==(lhs: OneOf4, rhs: OneOf4) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        case (.v3(let a), .v3(let b)): return a == b
        case (.v4(let a), .v4(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf4 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        case .v3(let x): return x.hashValue
        case .v4(let x): return x.hashValue
        }
    }
}

public extension OneOf4 {
    /// Enables reading & writing multiple different keyPaths that lead to the same type
    public subscript<T>(traversing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>)) -> T {
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
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = .init(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = .init(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = .init(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = .init(x4)
            }
        }
    }
}

/// The protocol of a type that can contain one out of 5 or more exclusive options
public protocol OneOf5Type : OneOf4Type {
    associatedtype T5
    init(t5: T5)
    init(_ t5: T5)
    func extract() -> T5?
}

public extension OneOf5Type {
    public var v5: T5? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5
public indirect enum OneOf5<T1, T2, T3, T4, T5> : OneOf5Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    public init(t5: T5) { self = .v5(t5) }
    public init(_ t5: T5) { self = .v5(t5) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?, T5?) { return (extract(), extract(), extract(), extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    public func extract() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    public func extract() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    public func extract() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
}

extension OneOf5 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable {
    public func bric() -> Bric {
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
    public static func brac(bric: Bric) throws -> OneOf5 {
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

    public func encode(to encoder: Encoder) throws {
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

    public init(from decoder: Decoder) throws {
        var errors: [Error] = []
        do { self = try .v1(T1(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v2(T2(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v3(T3(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v4(T4(from: decoder)); return } catch { errors.append(error) }
        do { self = try .v5(T5(from: decoder)); return } catch { errors.append(error) }
        throw OneOfDecodingError(errors: errors)
    }
}

extension OneOf5 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable {
    public static func ==(lhs: OneOf5, rhs: OneOf5) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        case (.v3(let a), .v3(let b)): return a == b
        case (.v4(let a), .v4(let b)): return a == b
        case (.v5(let a), .v5(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf5 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        case .v3(let x): return x.hashValue
        case .v4(let x): return x.hashValue
        case .v5(let x): return x.hashValue
        }
    }
}

public extension OneOf5 {
    /// Enables reading & writing multiple different keyPaths that lead to the same type
    public subscript<T>(traversing keys: (kp1: WritableKeyPath<T1, T>, kp2: WritableKeyPath<T2, T>, kp3: WritableKeyPath<T3, T>, kp4: WritableKeyPath<T4, T>, kp5: WritableKeyPath<T5, T>)) -> T {
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
            case .v1(var x1): x1[keyPath: keys.kp1] = newValue; self = .init(x1)
            case .v2(var x2): x2[keyPath: keys.kp2] = newValue; self = .init(x2)
            case .v3(var x3): x3[keyPath: keys.kp3] = newValue; self = .init(x3)
            case .v4(var x4): x4[keyPath: keys.kp4] = newValue; self = .init(x4)
            case .v5(var x5): x5[keyPath: keys.kp5] = newValue; self = .init(x5)
            }
        }
    }
}


/// The protocol of a type that can contain one out of 6 or more exclusive options
public protocol OneOf6Type : OneOf5Type {
    associatedtype T6
    init(t6: T6)
    init(_ t6: T6)
    func extract() -> T6?
}

public extension OneOf6Type {
    public var v6: T6? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}


/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9
public indirect enum OneOf6<T1, T2, T3, T4, T5, T6> : OneOf6Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    public init(t5: T5) { self = .v5(t5) }
    public init(_ t5: T5) { self = .v5(t5) }

    public init(t6: T6) { self = .v6(t6) }
    public init(_ t6: T6) { self = .v6(t6) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?, T5?, T6?) { return (extract(), extract(), extract(), extract(), extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    public func extract() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    public func extract() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    public func extract() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    public func extract() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
}

extension OneOf6 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable {
    public func bric() -> Bric {
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
    public static func brac(bric: Bric) throws -> OneOf6 {
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

    public func encode(to encoder: Encoder) throws {
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

    public init(from decoder: Decoder) throws {
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

extension OneOf6 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable {
    public static func ==(lhs: OneOf6, rhs: OneOf6) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        case (.v3(let a), .v3(let b)): return a == b
        case (.v4(let a), .v4(let b)): return a == b
        case (.v5(let a), .v5(let b)): return a == b
        case (.v6(let a), .v6(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf6 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        case .v3(let x): return x.hashValue
        case .v4(let x): return x.hashValue
        case .v5(let x): return x.hashValue
        case .v6(let x): return x.hashValue
        }
    }
}


/// The protocol of a type that can contain one out of 7 or more exclusive options
public protocol OneOf7Type : OneOf6Type {
    associatedtype T7
    init(t7: T7)
    init(_ t7: T7)
    func extract() -> T7?
}

public extension OneOf7Type {
    public var v7: T7? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}



/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9
public indirect enum OneOf7<T1, T2, T3, T4, T5, T6, T7> : OneOf7Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6), v7(T7)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    public init(t5: T5) { self = .v5(t5) }
    public init(_ t5: T5) { self = .v5(t5) }

    public init(t6: T6) { self = .v6(t6) }
    public init(_ t6: T6) { self = .v6(t6) }

    public init(t7: T7) { self = .v7(t7) }
    public init(_ t7: T7) { self = .v7(t7) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?, T5?, T6?, T7?) { return (extract(), extract(), extract(), extract(), extract(), extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    public func extract() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    public func extract() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    public func extract() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    public func extract() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
    public func extract() -> T7? { if case .v7(let v7) = self { return v7 } else { return nil } }
}

extension OneOf7 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable {
    public func bric() -> Bric {
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
    public static func brac(bric: Bric) throws -> OneOf7 {
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

    public func encode(to encoder: Encoder) throws {
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

    public init(from decoder: Decoder) throws {
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

extension OneOf7 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable, T7 : Equatable {
    public static func ==(lhs: OneOf7, rhs: OneOf7) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        case (.v3(let a), .v3(let b)): return a == b
        case (.v4(let a), .v4(let b)): return a == b
        case (.v5(let a), .v5(let b)): return a == b
        case (.v6(let a), .v6(let b)): return a == b
        case (.v7(let a), .v7(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf7 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable, T7 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        case .v3(let x): return x.hashValue
        case .v4(let x): return x.hashValue
        case .v5(let x): return x.hashValue
        case .v6(let x): return x.hashValue
        case .v7(let x): return x.hashValue
        }
    }
}

/// The protocol of a type that can contain one out of 8 or more exclusive options
public protocol OneOf8Type : OneOf7Type {
    associatedtype T8
    init(t8: T8)
    init(_ t8: T8)
    func extract() -> T8?
}

public extension OneOf8Type {
    public var v8: T8? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9
public indirect enum OneOf8<T1, T2, T3, T4, T5, T6, T7, T8> : OneOf8Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6), v7(T7), v8(T8)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    public init(t5: T5) { self = .v5(t5) }
    public init(_ t5: T5) { self = .v5(t5) }

    public init(t6: T6) { self = .v6(t6) }
    public init(_ t6: T6) { self = .v6(t6) }

    public init(t7: T7) { self = .v7(t7) }
    public init(_ t7: T7) { self = .v7(t7) }

    public init(t8: T8) { self = .v8(t8) }
    public init(_ t8: T8) { self = .v8(t8) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?, T5?, T6?, T7?, T8?) { return (extract(), extract(), extract(), extract(), extract(), extract(), extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    public func extract() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    public func extract() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    public func extract() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    public func extract() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
    public func extract() -> T7? { if case .v7(let v7) = self { return v7 } else { return nil } }
    public func extract() -> T8? { if case .v8(let v8) = self { return v8 } else { return nil } }
}

extension OneOf8 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable {
    public func bric() -> Bric {
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
    public static func brac(bric: Bric) throws -> OneOf8 {
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

    public func encode(to encoder: Encoder) throws {
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

    public init(from decoder: Decoder) throws {
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

extension OneOf8 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable, T7 : Equatable, T8 : Equatable {
    public static func ==(lhs: OneOf8, rhs: OneOf8) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        case (.v3(let a), .v3(let b)): return a == b
        case (.v4(let a), .v4(let b)): return a == b
        case (.v5(let a), .v5(let b)): return a == b
        case (.v6(let a), .v6(let b)): return a == b
        case (.v7(let a), .v7(let b)): return a == b
        case (.v8(let a), .v8(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf8 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable, T7 : Hashable, T8 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        case .v3(let x): return x.hashValue
        case .v4(let x): return x.hashValue
        case .v5(let x): return x.hashValue
        case .v6(let x): return x.hashValue
        case .v7(let x): return x.hashValue
        case .v8(let x): return x.hashValue
        }
    }
}


/// The protocol of a type that can contain one out of 9 or more exclusive options
public protocol OneOf9Type : OneOf8Type {
    associatedtype T9
    init(t9: T9)
    init(_ t9: T9)
    func extract() -> T9?
}

public extension OneOf9Type {
    public var v9: T9? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9
public indirect enum OneOf9<T1, T2, T3, T4, T5, T6, T7, T8, T9> : OneOf9Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6), v7(T7), v8(T8), v9(T9)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    public init(t5: T5) { self = .v5(t5) }
    public init(_ t5: T5) { self = .v5(t5) }

    public init(t6: T6) { self = .v6(t6) }
    public init(_ t6: T6) { self = .v6(t6) }

    public init(t7: T7) { self = .v7(t7) }
    public init(_ t7: T7) { self = .v7(t7) }

    public init(t8: T8) { self = .v8(t8) }
    public init(_ t8: T8) { self = .v8(t8) }

    public init(t9: T9) { self = .v9(t9) }
    public init(_ t9: T9) { self = .v9(t9) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?, T5?, T6?, T7?, T8?, T9?) { return (extract(), extract(), extract(), extract(), extract(), extract(), extract(), extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    public func extract() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    public func extract() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    public func extract() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    public func extract() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
    public func extract() -> T7? { if case .v7(let v7) = self { return v7 } else { return nil } }
    public func extract() -> T8? { if case .v8(let v8) = self { return v8 } else { return nil } }
    public func extract() -> T9? { if case .v9(let v9) = self { return v9 } else { return nil } }
}

extension OneOf9 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable, T9: Bricable {
    public func bric() -> Bric {
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
    public static func brac(bric: Bric) throws -> OneOf9 {
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

    public func encode(to encoder: Encoder) throws {
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

    public init(from decoder: Decoder) throws {
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

extension OneOf9 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable, T7 : Equatable, T8 : Equatable, T9 : Equatable {
    public static func ==(lhs: OneOf9, rhs: OneOf9) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        case (.v3(let a), .v3(let b)): return a == b
        case (.v4(let a), .v4(let b)): return a == b
        case (.v5(let a), .v5(let b)): return a == b
        case (.v6(let a), .v6(let b)): return a == b
        case (.v7(let a), .v7(let b)): return a == b
        case (.v8(let a), .v8(let b)): return a == b
        case (.v9(let a), .v9(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf9 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable, T7 : Hashable, T8 : Hashable, T9 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        case .v3(let x): return x.hashValue
        case .v4(let x): return x.hashValue
        case .v5(let x): return x.hashValue
        case .v6(let x): return x.hashValue
        case .v7(let x): return x.hashValue
        case .v8(let x): return x.hashValue
        case .v9(let x): return x.hashValue
        }
    }
}

/// The protocol of a type that can contain one out of 10 or more exclusive options
public protocol OneOf10Type : OneOf9Type {
    associatedtype T10
    init(t10: T10)
    init(_ t10: T10)
    func extract() -> T10?
}

public extension OneOf10Type {
    public var v10: T10? { get { return extract() } set { if let newValue = newValue { self = Self.init(newValue)} } }
}

/// A simple union type that can be one of either T1 or T2 or T3 or T4 or T5 or T6 or T7 or T8 or T9 or T10
public indirect enum OneOf10<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> : OneOf10Type {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5), v6(T6), v7(T7), v8(T8), v9(T9), v10(T10)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    public init(t5: T5) { self = .v5(t5) }
    public init(_ t5: T5) { self = .v5(t5) }

    public init(t6: T6) { self = .v6(t6) }
    public init(_ t6: T6) { self = .v6(t6) }

    public init(t7: T7) { self = .v7(t7) }
    public init(_ t7: T7) { self = .v7(t7) }

    public init(t8: T8) { self = .v8(t8) }
    public init(_ t8: T8) { self = .v8(t8) }

    public init(t9: T9) { self = .v9(t9) }
    public init(_ t9: T9) { self = .v9(t9) }

    public init(t10: T10) { self = .v10(t10) }
    public init(_ t10: T10) { self = .v10(t10) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?, T5?, T6?, T7?, T8?, T9?, T10?) { return (extract(), extract(), extract(), extract(), extract(), extract(), extract(), extract(), extract(), extract()) }

    public func extract() -> T1? { if case .v1(let v1) = self { return v1 } else { return nil } }
    public func extract() -> T2? { if case .v2(let v2) = self { return v2 } else { return nil } }
    public func extract() -> T3? { if case .v3(let v3) = self { return v3 } else { return nil } }
    public func extract() -> T4? { if case .v4(let v4) = self { return v4 } else { return nil } }
    public func extract() -> T5? { if case .v5(let v5) = self { return v5 } else { return nil } }
    public func extract() -> T6? { if case .v6(let v6) = self { return v6 } else { return nil } }
    public func extract() -> T7? { if case .v7(let v7) = self { return v7 } else { return nil } }
    public func extract() -> T8? { if case .v8(let v8) = self { return v8 } else { return nil } }
    public func extract() -> T9? { if case .v9(let v9) = self { return v9 } else { return nil } }
    public func extract() -> T10? { if case .v10(let v10) = self { return v10 } else { return nil } }
}

extension OneOf10 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable, T9: Bricable, T10: Bricable {
    public func bric() -> Bric {
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
    public static func brac(bric: Bric) throws -> OneOf10 {
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

    public func encode(to encoder: Encoder) throws {
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

    public init(from decoder: Decoder) throws {
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

extension OneOf10 : Equatable where T1 : Equatable, T2 : Equatable, T3 : Equatable, T4 : Equatable, T5 : Equatable, T6 : Equatable, T7 : Equatable, T8 : Equatable, T9 : Equatable, T10 : Equatable {
    public static func ==(lhs: OneOf10, rhs: OneOf10) -> Bool {
        switch (lhs, rhs) {
        case (.v1(let a), .v1(let b)): return a == b
        case (.v2(let a), .v2(let b)): return a == b
        case (.v3(let a), .v3(let b)): return a == b
        case (.v4(let a), .v4(let b)): return a == b
        case (.v5(let a), .v5(let b)): return a == b
        case (.v6(let a), .v6(let b)): return a == b
        case (.v7(let a), .v7(let b)): return a == b
        case (.v8(let a), .v8(let b)): return a == b
        case (.v9(let a), .v9(let b)): return a == b
        case (.v10(let a), .v10(let b)): return a == b
        default: return false
        }
    }
}

extension OneOf10 : Hashable where T1 : Hashable, T2 : Hashable, T3 : Hashable, T4 : Hashable, T5 : Hashable, T6 : Hashable, T7 : Hashable, T8 : Hashable, T9 : Hashable, T10 : Hashable {
    public var hashValue: Int {
        switch self {
        case .v1(let x): return x.hashValue
        case .v2(let x): return x.hashValue
        case .v3(let x): return x.hashValue
        case .v4(let x): return x.hashValue
        case .v5(let x): return x.hashValue
        case .v6(let x): return x.hashValue
        case .v7(let x): return x.hashValue
        case .v8(let x): return x.hashValue
        case .v9(let x): return x.hashValue
        case .v10(let x): return x.hashValue
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
    public var values: (T1, T2) { return (v1, v2) }
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

/// Stopgap implementation of AllOf3 via typealias to mutliple AllOf2
public typealias AllOf3<T1, T2, T3> = AllOf2<T1, AllOf2<T2, T3>>

/// Stopgap implementation of AllOf4 via typealias to mutliple AllOf2
public typealias AllOf4<T1, T2, T3, T4> = AllOf2<T1, AllOf3<T2, T3, T4>>

/// Stopgap implementation of AllOf5 via typealias to mutliple AllOf2
public typealias AllOf5<T1, T2, T3, T4, T5> = AllOf2<T1, AllOf4<T2, T3, T4, T5>>

/// Stopgap implementation of AllOf6 via typealias to mutliple AllOf2
public typealias AllOf6<T1, T2, T3, T4, T5, T6> = AllOf2<T1, AllOf5<T2, T3, T4, T5, T6>>

/// Stopgap implementation of AllOf7 via typealias to mutliple AllOf2
public typealias AllOf7<T1, T2, T3, T4, T5, T6, T7> = AllOf2<T1, AllOf6<T2, T3, T4, T5, T6, T7>>

/// Stopgap implementation of AllOf8 via typealias to mutliple AllOf2
public typealias AllOf8<T1, T2, T3, T4, T5, T6, T7, T8> = AllOf2<T1, AllOf7<T2, T3, T4, T5, T6, T7, T8>>

/// Stopgap implementation of AllOf9 via typealias to mutliple AllOf2
public typealias AllOf9<T1, T2, T3, T4, T5, T6, T7, T8, T9> = AllOf2<T1, AllOf8<T2, T3, T4, T5, T6, T7, T8, T9>>

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
    public var values: (T1?, T2?) { return (v1, v2) }
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
    public var dtm: BricDateTime? {
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

    public var hashValue: Int { return year }

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
    public func toFormattedString(timesep: String = "T", utctz: String? = "Z", padsec: Int = 3) -> String {
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
    public func toISO8601String() -> String {
        return toFormattedString()
    }

    /// Attempt to parse the given String as an ISO-8601 date-time structure
    public func parseISO8601String(_ str: String) -> Self? {
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
