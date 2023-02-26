/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
@_exported import Either

/// Quantum is `Either` a single `Scalar` (e.g., string, boolean, or number) `Or` a `Quanta<Quantum>` (i.e., an array or `Key`-keyed map of this `Quantum`)
public typealias Quantum<Scalar, Key : Hashable, Value> = Either<Scalar>.Or<Quanta<Key, Value>>

/// A scalar that can contain a string type, a numeric type, a boolean type, and a null type.
public typealias StrNumBoolNull<StrType, NumType, BoolType, NullType> = Either<StrType>.Or<NumType>.Or<BoolType>.Or<NullType>

/// The base of a scalar type, which contains fixed boolean and null type and variable string and numeric types.
//public typealias ScalarOf<StrType, NumType> = StrNumBoolNull<StrType, NumType, BooleanLiteralType, Never?>
public typealias ScalarOf<StrType, NumType> = Either<StrType>.Or<Either<NumType>.Or<Either<BooleanLiteralType>.Or<Never?>>>




/// A sequence of either keyed or unkeyed values.
///
/// A `Quanta` is used to abstract an `Array` and `Dictionary`, and is used as the collection half of `Quantum`.
public struct Quanta<Key : Hashable, Value> : Isomorph {
    public typealias RawValue = Either<[Value]>.Or<[Key: Value]>

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension Quanta : Sequence {
    /// Extracts and transforms all the values in the `Quanta`. Note that ordering will be unstable and indeterminate for dictionary values.
    public func mapValues<U>(_ transform: (Value) -> U) -> [U] {
        rawValue.map({ $0.map(transform) }, { Array($0.mapValues(transform).values) }).value
    }

    public func makeIterator() -> RawValue.Iterator {
        rawValue.makeIterator()
    }
}

extension Quanta : Equatable where Value : Equatable { }
extension Quanta : Hashable where Value : Hashable { }

extension Quanta : Encodable where Value : Encodable, Key : Encodable {
    /// `Quanta` serializes to the underlying type's encoding with any intermediate wrapper
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}
extension Quanta : Decodable where Value : Decodable, Key : Decodable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: RawValue(from: decoder))
    }
}

extension Quanta : Sendable where Value : Sendable, Key : Sendable { }

