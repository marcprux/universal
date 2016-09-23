//
//  BricBrac.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 7/18/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

/// A BricBrac is a user-defined type that can serialize/deserialize to/from some Bric
/// In addition to conforming to Bricable and Bracable, it also provides Equatable implementations
/// and the ability to perform a deep copy with `bricbrac()`; note that standard primitives like String and Bool
/// conform to both Bricable and Bracable but not to BricBrac because we don't want to conflict with their own
/// Equatable and Hashable implementations
public protocol BricBrac: Bricable, Bracable, Breqable, Equatable {
//    /// Perform semantic validation of the BricBrac; this could verify requirements that
//    /// cannot be addressed by the type system, such as string and array length requirements
//    func validate() throws
}

public extension BricBrac {
    /// Returns a deep copy of this instance
    func bricbrac() throws -> Self { return try Self.brac(bric: self.bric()) }

//    /// The default validation method does nothing
//    func validate() { }
}


/// A BricBrac that only bracs elements that do not conform to the underlying type
/// Useful for handling "not" elements of the JSON Schema spec
public struct NotBrac<T: Bricable> : BricBrac, ExpressibleByNilLiteral where T: Bracable {
    public init() { }
    public init(nilLiteral: ()) { }

    /// this type does not bric to anything
    public func bric() -> Bric { return .nul }

    public static func brac(bric: Bric) throws -> NotBrac {
        do {
            _ = try T.brac(bric: bric)
        } catch {
            return NotBrac()
        }
        throw BracError.shouldNotBracError(type: T.self, path: [])
    }
}

public func ==<T: Bricable>(lhs: NotBrac<T>, rhs: NotBrac<T>) -> Bool {
    return lhs.breq(rhs)
}
