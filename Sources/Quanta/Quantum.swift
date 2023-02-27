/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
@_exported import Either

public extension Dictionary {
    /// A sequence of either keyed or unkeyed values, defined as `Either<[Value]>.Or<[Key: Value]>`.
    ///
    /// A `Quanta` is used to abstract an `Array` and `Dictionary`.
    struct Quanta : Isomorph {
        public typealias RawValue = Either<[Value]>.Or<[Key: Value]>

        public var rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

/// A Scalar's null value is an `Optional<Never>.none`
///
/// Note: this type was chosen over `Void` since it is `Codable`. The result is the same in that there is only a single valid instance.
public typealias ScalarNull = Optional<Never>

/// The base of a scalar type, which contains fixed boolean and null type and variable string and numeric types.
public typealias ScalarOf<StringType, NumericType> = Either<Either<NumericType>.Or<StringType>>.Or<Either<BooleanLiteralType>.Or<ScalarNull>>


extension Dictionary.Quanta : Sequence {
    /// Extracts and transforms all the values in the `Quanta`. Note that ordering will be unstable and indeterminate for dictionary values.
    public func mapValues<U>(_ transform: (Value) -> U) -> [U] {
        rawValue.map({ $0.map(transform) }, { Array($0.mapValues(transform).values) }).value
    }

    public func makeIterator() -> RawValue.Iterator {
        rawValue.makeIterator()
    }
}

extension Dictionary.Quanta : Equatable where Value : Equatable { }
extension Dictionary.Quanta : Hashable where Value : Hashable { }

extension Dictionary.Quanta : Encodable where Value : Encodable, Key : Encodable {
    /// `Quanta` serializes to the underlying type's encoding with any intermediate wrapper
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}
extension Dictionary.Quanta : Decodable where Value : Decodable, Key : Decodable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: RawValue(from: decoder))
    }
}

extension Dictionary.Quanta : Sendable where Value : Sendable, Key : Sendable { }

