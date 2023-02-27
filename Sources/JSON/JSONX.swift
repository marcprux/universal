//
//  JSONParser.swift
//
//  Created by Marc Prud'hommeaux on 8/20/15.
//
import Quanta
import struct Foundation.UUID
import struct Foundation.URL
import struct Foundation.Date
import struct Foundation.Data
import struct Foundation.Decimal

/// A rich JSON type, which can contain a `Date` (ISO-8601), `Data` (base-64), `String`, `Integer`, `Double`, `Bool`, `Null`, `[Scalar]`, or `[String: Scalar]`
public struct JSONX : Isomorph, Sendable, Hashable, Codable {
    /// A rich JSON type, which can contain a `UUID`, `URL`, `Date` (ISO-8601), `Data` (base-64), `String`, `Integer`, `Double`, `Bool`, `Null`, `[Scalar]`, or `[String: Scalar]`
    public typealias Scalar = ScalarOf<Either<UUID>.Or<URL>.Or<Date>.Or<Data>.Or<String>, Either<Int>.Or<Decimal>>
    public typealias Object = [String: Self]
    public typealias RawValue = Either<Scalar>.Or<Object.Quanta>

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}
