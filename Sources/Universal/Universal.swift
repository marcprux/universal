//
//  Universal.swift
//
//  Created by Marc Prud'hommeaux on 6/17/15.
//
@_exported import Either
@_exported import JSON
@_exported import PLIST
@_exported import XML
@_exported import YAML


/// A `BagOfSelf` is a type that can contain either `Scalar` values some collection (`Array` or `Dictionary`) containing `Self`.
public protocol BagOfSelf : RawRepresentable where RawValue == Either<Scalar>.Or<Dictionary<ObjectKey, Self>.ValueContainer> {
    /// The primitive type(s) supported by this bag.
    ///
    /// E.g., for XML this is just `String`, but for JSON it would be `Either<String>.Or<Double>.Or<Boolean>`.
    associatedtype Scalar

    /// The key type that is used to look up values in `Object`.
    ///
    /// In `JSON` this will be `String`, but in YAML it is `Scalar`.
    associatedtype ObjectKey : Hashable

    var attributes: [ObjectKey: Self]? { get }
    static func bagOfSelf(withAttributes: [ObjectKey: Self]) -> Self

    var children: [Self]? { get }
    static func bagOfSelf(withChildren: [Self]) -> Self
}


// MARK: Merging

extension BagOfSelf {
    /// Merges the other `BagOfSelf` into this `BagOfSelf`
    ///
    /// Array types are concatenated and object key are replaced/added from the other `BagOfSelf`.
    /// All other types are replaced directly.
    public mutating func merge(with other: Self) throws {
        try self.mergeSelf(with: other)
    }

    /// Returns a JSON consisting of this JSON merged with the other JSON.
    ///
    /// Array types are concatenated and object key are replaced/added from the other JSON.
    /// All other types are replaced directly.
    public func merged(with other: Self) throws -> Self {
        var merged = self
        try merged.mergeSelf(with: other)
        return merged
    }

    @usableFromInline mutating func mergeSelf(with otherSelf: Self) throws {
        if let oobj = otherSelf.attributes {
            if var sobj = self.attributes {
                for (okey, ovalue) in oobj {
                    sobj[okey] = try sobj[okey]?.merged(with: ovalue) ?? ovalue
                }
                self = .bagOfSelf(withAttributes: sobj)
            } else {
                self = otherSelf
            }
        } else if let oarr = otherSelf.children {
            if let sarr = self.children {
                self = .bagOfSelf(withChildren: sarr + oarr)
            } else {
                self = otherSelf
            }
        } else {
            // any other values result in simple value replacement
            self = otherSelf
        }
    }
}


// MARK: BagOfSelf implementations

extension JSON : BagOfSelf {
    public typealias ObjectKey = String

    public var children: [JSON]? {
        array
    }

    public static func bagOfSelf(withChildren array: [JSON]) -> Self {
        .array(array)
    }

    public var attributes: Object? {
        object
    }

    public static func bagOfSelf(withAttributes object: [ObjectKey: JSON]) -> Self {
        .object(object)
    }
}


extension YAML : BagOfSelf {
    public typealias ObjectKey = Scalar

    public var children: [YAML]? {
        array
    }

    public static func bagOfSelf(withChildren array: [YAML]) -> Self {
        .array(array)
    }

    public var attributes: Object? {
        object
    }

    public static func bagOfSelf(withAttributes object: [ObjectKey: YAML]) -> Self {
        .object(object)
    }
}


extension PLIST : BagOfSelf {
    public typealias ObjectKey = String

    public var children: [PLIST]? {
        array
    }

    public static func bagOfSelf(withChildren array: [PLIST]) -> Self {
        .array(array)
    }

    public var attributes: Object? {
        dictionary
    }

    public static func bagOfSelf(withAttributes dictionary: [ObjectKey: PLIST]) -> Self {
        .dictionary(dictionary)
    }
}


extension XML : BagOfSelf {
    public typealias ObjectKey = String

    public var children: [XML]? {
        array
    }

    public static func bagOfSelf(withChildren children: [XML]) -> Self {
        .array(children)
    }

    public var attributes: Object? {
        object
    }

    public static func bagOfSelf(withAttributes attributes: [ObjectKey: XML]) -> Self {
        .object(attributes)
    }
}

