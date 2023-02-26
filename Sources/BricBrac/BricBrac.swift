////
////  MarcUp.swift
////  MarcUp
////
////  Created by Marc Prud'hommeaux on 7/18/15.
////
//
////@_exported import XOr
////@_exported import JSum
////@_exported import XML
////@_exported import YAML
////@_exported import JSON
//
///// A MarcUp is a user-defined type that can serialize/deserialize to/from some Bric
///// In addition to conforming to Bricable and Bracable, it also provides Equatable implementations
///// and the ability to perform a deep copy with `bricbrac()`; note that standard primitives like String and Bool
///// conform to both Bricable and Bracable but not to MarcUp because we don't want to conflict with their own
///// Equatable and Hashable implementations
//public protocol MarcUp: Bricable, Bracable {
////    /// Perform semantic validation of the MarcUp; this could verify requirements that
////    /// cannot be addressed by the type system, such as string and array length requirements
////    func validate() throws
//}
//
//public extension MarcUp {
//    /// Returns a deep copy of this instance
//    func bricbrac() throws -> Self { return try Self.brac(bric: self.bric()) }
//
////    /// The default validation method does nothing
////    func validate() { }
//}
//
//
///// A MarcUp that only bracs elements that do not conform to the underlying type
///// Useful for handling "not" elements of the JSON Schema spec
//public struct NotBrac<T> : ExpressibleByNilLiteral {
//    public init() { }
//    public init(nilLiteral: ()) { }
//}
//
//extension NotBrac : Encodable where T : Encodable {
//    /// Encoding a NotBrac is a no-op
//    public func encode(to encoder: Encoder) throws { }
//}
//
//extension NotBrac : Decodable where T : Decodable {
//    public init(from decoder: Decoder) throws {
//        do {
//            _ = try T.init(from: decoder)
//        } catch {
//            self = NotBrac()
//        }
//        throw BracError.shouldNotBracError(type: T.self, path: [])
//    }
//}
//
////extension NotBrac : Bricable where T : Bricable {
////    /// this type does not bric to anything
////    public func bric() -> Bric { return .nul }
////}
//
//extension NotBrac : Bracable where T : Bracable {
//    public static func brac(bric: JSum) throws -> NotBrac {
//        do {
//            _ = try T.brac(bric: bric)
//        } catch {
//            return NotBrac()
//        }
//        throw BracError.shouldNotBracError(type: T.self, path: [])
//    }
//}
//
//extension NotBrac : Equatable where T : Equatable {
//    public static func ==<T>(lhs: NotBrac<T>, rhs: NotBrac<T>) -> Bool {
//        return true // two Nots are always equal because their existance just signifies the absence of the underlying type to deserialize
//    }
//}
//
//
