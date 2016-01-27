//
//  Brac.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 6/20/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//


/// Adoption of Bracable signals that the type can be instantiated from some Bric
public protocol Bracable {
    /// Try to construct an instance of the type from the `Bric` parameter
    static func brac(bric: Bric) throws -> Self
}

extension Bric : Bracable {
    /// Bric always bracs to itself
    public static func brac(bric: Bric) throws -> Bric {
        return bric
    }
}

extension String: Bracable {
    /// A String is Brac'd to a `Bric.Str` or else throws an error
    public static func brac(bric: Bric) throws -> String {
        if case .Str(let str) = bric {
            return str
        } else {
            return try bric.invalidType()
        }
    }
}

extension Bool: Bracable {
    /// A Bool is Brac'd to a `Bric.Bol` or else throws an error
    public static func brac(bric: Bric) throws -> Bool {
        if case .Bol(let bol) = bric {
            return bol
        } else {
            return try bric.invalidType()
        }
    }
}


/// Covenience extension for String so either strings or enum strings can be used to bric and brac
extension String : RawRepresentable {
    public typealias RawValue = String
    public init?(rawValue: String) { self = rawValue }
    public var rawValue: String { return self }
}


public extension Bric {
    /// Bracs this type as Void, throwing an error if the underlying type is not null
    public func bracNul() throws -> Bric.NulType {
        guard case .Nul = self else { return try invalidType() }
        return Bric.NulType()
    }

    /// Bracs this type as Number, throwing an error if the underlying type is not a number
    public func bracNum() throws -> Bric.NumType {
        guard case .Num(let x) = self else { return try invalidType() }
        return x
    }

    /// Bracs this type as String, throwing an error if the underlying type is not a string
    public func bracStr() throws -> Bric.StrType {
        guard case .Str(let x) = self else { return try invalidType() }
        return x
    }

    /// Bracs this type as Bool, throwing an error if the underlying type is not a boolean
    public func bracBol() throws -> Bric.BolType {
        guard case .Bol(let x) = self else { return try invalidType() }
        return x
    }

    /// Bracs this type as an Object, throwing an error if the underlying type is not an object
    public func bracObj() throws -> Bric.ObjType {
        guard case .Obj(let x) = self else { return try invalidType() }
        return x
    }

    /// Bracs this type as an Array, throwing an error if the underlying type is not an array
    public func bracArr() throws -> Bric.ArrType {
        guard case .Arr(let x) = self else { return try invalidType() }
        return x
    }

}

/// Extensions for Bracing instances by key and inferred return type
public extension Bric {

    internal func objectKey<R: RawRepresentable where R.RawValue == String>(key: R) throws -> Optional<Bric> {
        guard case .Obj(let dict) = self else {
            throw BracError.KeyWithoutObject(key: key.rawValue, path: [])
        }
        return dict[key.rawValue]
    }

    /// Reads a required Bric instance from the given key in an object bric
    public func bracKey<T: Bracable, R: RawRepresentable where R.RawValue == String>(key: R) throws -> T {
        if let value = try objectKey(key) {
            return try bracpath([Bric.Ref(key: key)], T.brac(value))
        } else {
            throw BracError.MissingRequiredKey(type: T.self, key: key.rawValue, path: [])
        }
    }

    /// Reads one level of wrapped instance(s) from the given key in an object bric
    public func bracKey<T: BracLayer, R: RawRepresentable where R.RawValue == String, T.BracSub : Bracable>(key: R) throws -> T {
        return try T.brac(bracpath([Bric.Ref(key: key)], objectKey(key) ?? nil))
    }

    /// Reads two levels of wrapped instance(s) from the given key in an object bric
    public func bracKey<T: BracLayer, R: RawRepresentable where R.RawValue == String, T.BracSub : BracLayer, T.BracSub.BracSub : Bracable>(key: R) throws -> T {
        return try T.brac(bracpath([Bric.Ref(key: key)], objectKey(key) ?? nil))
    }

    /// Reads three levels of wrapped instance(s) from the given key in an object bric
    public func bracKey<T: BracLayer, R: RawRepresentable where R.RawValue == String, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : Bracable>(key: R) throws -> T {
        return try T.brac(bracpath([Bric.Ref(key: key)], objectKey(key) ?? nil))
    }

    /// Reads four levels of wrapped instance(s) from the given key in an object bric
    public func bracKey<T: BracLayer, R: RawRepresentable where R.RawValue == String, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : Bracable>(key: R) throws -> T {
        return try T.brac(bracpath([Bric.Ref(key: key)], objectKey(key) ?? nil))
    }

    /// Reads five levels of wrapped instance(s) from the given key in an object bric
    public func bracKey<T: BracLayer, R: RawRepresentable where R.RawValue == String, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub.BracSub : Bracable>(key: R) throws -> T {
        return try T.brac(bracpath([Bric.Ref(key: key)], objectKey(key) ?? nil))
    }

    /// Reads any one of the given Brics, throwing an error if the successfull number of instances is outside of the given range of acceptable passes
    public func bracRange<T: Bracable>(range: Range<Int>, bracers: [() throws -> T]) throws -> [T] {
        var values: [T] = []
        var errors: [ErrorType] = []
        for f in bracers {
            do {
                values.append(try f())
            } catch {
                errors.append(error)
            }
        }

        if values.count < range.startIndex {
            throw BracError.MultipleErrors(errors: errors, path: [])
        } else if values.count > range.endIndex  {
            throw BracError.MultipleMatches(type: T.self, path: [])
        } else {
            return values
        }
    }

    /// Reads any one of the given Brics, throwing an error if all of the closures also threw an error or more than one succeeded
    public func bracOne<T: Bracable>(oneOf: [() throws -> T]) throws -> T {
        return try bracRange(1...1, bracers: oneOf)[0]
    }

//    /// Reads any one of the given Brics, throwing an error if all of the closures also threw an error or more than one succeeded
//    public func bracOne<T: Bracable>(@autoclosure oneOf: () throws -> T) throws -> T {
//        return try bracRange(1...1, bracers: [oneOf])[0]
//    }

//    /// Reads any one of the given Brics, throwing an error if all of the closures also threw an error or more than one succeeded
//    public func bracOne<T: Bracable>(@autoclosure oneOf: () throws -> T, @autoclosure _ oneOf2: () throws -> T) throws -> T {
//        return try bracRange(1...1, bracers: [oneOf, oneOf2])[0]
//    }

    /// Reads any one of the given Brics, throwing an error if all of the closures also threw an error
    public func bracAny<T: Bracable>(anyOf: [() throws -> T]) throws -> NonEmptyCollection<T, [T]> {
        let elements = try bracRange(1...anyOf.count, bracers: anyOf)
        return NonEmptyCollection(elements[0], tail: Array(elements.dropFirst()))
    }

    /// Reads all of the given Brics, throwing an error if any of the closures threw an error
    public func bracAll<T: Bracable>(allOf: [() throws -> T]) throws -> [T] {
        return try bracRange(allOf.count...allOf.count, bracers: allOf)
    }

    /// Bracs the T with the given factory
    public func brac2<T1, T2>(t1: Bric throws -> T1, _ t2: Bric throws -> T2) throws -> (T1, T2) {
        return try (t1(self), t2(self))
    }

    /// Returns a dictionary of keys to raw Brics for all keys that are not present in the given RawType (e.g., an enum of keys)
    /// This is useful for maintaining the underlying Brics of any object keys that are not strictly enumerated
    public func bracDisjoint<R: RawRepresentable where R.RawValue == String>(keys: R.Type) throws -> Dictionary<String, Bric> {
        guard case .Obj(var dict) = self else { return try invalidType() }
        for key in dict.keys {
            if R(rawValue: key) != nil {
                dict.removeValueForKey(key)
            }
        }
        return dict
    }

    /// Validates that only the given keys exists in the current dictionary bric; useful for forbidding additionalProperties
    public func exclusiveKeys<T>(keys: [String], @autoclosure _ f: () throws -> T) throws -> T {
        guard case .Obj(let dict) = self else { return try invalidType() }
        let unrecognized = Set(dict.keys).subtract(keys)
        if !unrecognized.isEmpty {
            let errs: [ErrorType] = Array(unrecognized).map({ BracError.UnrecognizedKey(key: $0, path: []) })
            if errs.count == 1 {
                throw errs[0]
            } else {
                throw BracError.MultipleErrors(errors: errs, path: [])
            }
        }
        return try f()
    }


    /// Validates that only the given keys exists in the current dictionary bric; useful for forbidding additionalProperties
    public func prohibitExtraKeys<R: RawRepresentable where R.RawValue == String>(keys: R.Type) throws {
        guard case .Obj(let dict) = self else { return try invalidType() }
        var errs: [ErrorType] = []
        for key in dict.keys {
            if keys.init(rawValue: key) == nil {
                errs.append(BracError.UnrecognizedKey(key: key, path: []))
            }
        }
        if errs.count == 1 {
            throw errs[0]
        } else if errs.count > 1 {
            throw BracError.MultipleErrors(errors: errs, path: [])
        }
    }

    // TODO: remove

    public func assertNoAdditionalProperties<R: RawRepresentable where R.RawValue == String>(keys: R.Type) throws {
        return try prohibitExtraKeys(keys)
    }

}

// MARK: BracLayer wrapper Brac


/// A BracLayer can wrap around some instances; it is used to allow brac'ing from an arbitrarily nested container types
/// This allows us to have a single handlers for multiple permutations of wrappers, such as
/// Array<String>, Optional<Array<Bool>>, Array<Optional<Bool>>, and Array<Optional<Set<CollectionOfOne<Int>>>>
public protocol BracLayer {
    /// The type that is being wrapped by this layer
    typealias BracSub

    /// Construct an instance of self by invoking the function on the given bric
    static func bracMap(bric: Bric, f: Bric throws -> BracSub) throws -> Self
}

public extension BracLayer where Self.BracSub : Bracable {
    /// Try to construct an instance of the wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.bracMap(bric, f: Self.BracSub.brac)
    }
}

public extension BracLayer where Self.BracSub : BracLayer, Self.BracSub.BracSub : Bracable {
    /// Try to construct an instance of the twofold-wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.bracMap(bric) {
            try Self.BracSub.bracMap($0, f: Self.BracSub.BracSub.brac)
        }
    }
}

public extension BracLayer where Self.BracSub : BracLayer, Self.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub : Bracable {
    /// Try to construct an instance of the threefold-wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.bracMap(bric) {
            try Self.BracSub.bracMap($0) {
                try Self.BracSub.BracSub.bracMap($0,
                    f: Self.BracSub.BracSub.BracSub.brac)
            }
        }
    }
}

public extension BracLayer where Self.BracSub : BracLayer, Self.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub.BracSub : Bracable {
    /// Try to construct an instance of the fourfold-wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.bracMap(bric) {
            try Self.BracSub.bracMap($0) {
                try Self.BracSub.BracSub.bracMap($0) {
                    try Self.BracSub.BracSub.BracSub.bracMap($0,
                        f: Self.BracSub.BracSub.BracSub.BracSub.brac)
                }
            }
        }
    }
}

public extension BracLayer where Self.BracSub : BracLayer, Self.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub.BracSub.BracSub : Bracable {
    /// Try to construct an instance of the fivefold-wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.bracMap(bric) {
            try Self.BracSub.bracMap($0) {
                try Self.BracSub.BracSub.bracMap($0) {
                    try Self.BracSub.BracSub.BracSub.bracMap($0) {
                        try Self.BracSub.BracSub.BracSub.BracSub.bracMap($0,
                            f: Self.BracSub.BracSub.BracSub.BracSub.BracSub.brac)
                    }
                }
            }
        }
    }
}

extension Wrappable {
    /// Returns this wrapper around the bracMap, or returns `.None` if the parameter is `Bric.Nul`
    public static func bracMap(bric: Bric, f: Bric throws -> Wrapped) throws -> Self {
        if case .Nul = bric { return nil } // an optional is allowed to be nil
        return Self(try f(bric))
    }
}

extension Optional : BracLayer {
    public typealias BracSub = Wrapped // inherits bracMap via Wrappable conformance
}

extension Indirect : BracLayer {
    public typealias BracSub = Wrapped // inherits bracMap via Wrappable conformance
}

extension RawRepresentable where RawValue : Bracable {

    /// Returns this RawRepresentable around the brac, or throws an error if the parameter cannot be used to create the RawRepresentable
    public static func brac(bric: Bric) throws -> Self {
        let rawValue = try RawValue.brac(bric)
        if let x = Self(rawValue: rawValue) {
            return x
        } else {
            return try bric.invalidRawValue(rawValue)
        }
    }

}

extension RangeReplaceableCollectionType {
    /// Returns this collection around the bracMaps, or throws an error if the parameter is not `Bric.Arr`
    public static func bracMap(bric: Bric, f: Bric throws -> Generator.Element) throws -> Self {
        if case .Arr(let arr) = bric { return try Self() + arr.map(f) }
        return try bric.invalidType()
    }
}

extension Array : BracLayer {
    public typealias BracSub = Element // inherits bracMap via default RangeReplaceableCollectionType conformance
}

extension ArraySlice : BracLayer {
    public typealias BracSub = Element // inherits bracMap via default RangeReplaceableCollectionType conformance
}

extension ContiguousArray : BracLayer {
    public typealias BracSub = Element // inherits bracMap via default RangeReplaceableCollectionType conformance
}

extension CollectionOfOne : BracLayer {
    public typealias BracSub = Element

    public static func bracMap(bric: Bric, f: Bric throws -> BracSub) throws -> CollectionOfOne {
        if case .Arr(let x) = bric {
            if x.count != 1 { throw BracError.InvalidArrayLength(required: 1...1, actual: x.count, path: []) }
            return CollectionOfOne(try f(x[0]))
        }
        return try bric.invalidType()
    }
}

extension EmptyCollection : BracLayer {
    public typealias BracSub = Element

    public static func bracMap(bric: Bric, f: Bric throws -> BracSub) throws -> EmptyCollection {
        if case .Arr(let x) = bric {
            // really kind of pointless: why would anyone mandate an array size zero?
            if x.count != 0 { throw BracError.InvalidArrayLength(required: 0...0, actual: x.count, path: []) }
            return EmptyCollection()
        }
        return try bric.invalidType()
    }
}

extension NonEmptyCollection : BracLayer {
    public typealias BracSub = Element

    /// Returns this collection around the bracMaps, or throws an error if the parameter is not `Bric.Arr` or the array does not have at least a single element
    public static func bracMap(bric: Bric, f: Bric throws -> Element) throws -> NonEmptyCollection {
        if case .Arr(let arr) = bric {
            guard let first = arr.first else {
                throw BracError.InvalidArrayLength(required: 1..<Int.max, actual: 0, path: [])
            }
            return try NonEmptyCollection(f(first), tail: Tail.bracMap(Bric.Arr(Array(arr.dropFirst())), f: f))
        }
        return try bric.invalidType()
    }
}


extension Dictionary : BracLayer {
    public typealias BracSub = Value

    public static func bracMap(bric: Bric, f: Bric throws -> BracSub) throws -> Dictionary {
        if case .Obj(let x) = bric {
            var d = Dictionary()
            for (k, v) in x {
                if let k = k as? Dictionary.Key {
                    d[k] = try f(v) // keys need to be Strings
                } else {
                    return try bric.invalidType()
                }
            }
            return d
        }
        return try bric.invalidType()
    }
}

extension Set : BracLayer {
    public typealias BracSub = Generator.Element

    public static func bracMap(bric: Bric, f: Bric throws -> BracSub) throws -> Set {
        if case .Arr(let x) = bric { return Set(try x.map(f)) }
        return try bric.invalidType()
    }
}


// MARK: Numeric Brac



/// A BracableNumberConvertible is any numeric type that can be converted into a Double
public protocol BracableNumberConvertible : Bracable {
    /// Converts the given Double to the type, throwing an error on overflow
    static func fromBricNum(num: Double) throws -> Self
}

extension BracableNumberConvertible {
    /// Converts the given numeric bric to this numeric type, throwing an error if the Bric was not a number or overflows the bounds
    public static func brac(bric: Bric) throws -> Self {
        if case .Num(let num) = bric {
            return try fromBricNum(num)
        } else {
            return try bric.invalidType()
        }
    }

    private static func overflow<T>(value: Double) throws -> T {
        throw BracError.NumericOverflow(type: T.self, value: value, path: [])
    }
}


/// RawRepresentable Bric methods that enable an Double value to automatically bric & brac
extension Double : BracableNumberConvertible {
    public static func fromBricNum(num: Double) -> Double { return Double(num) }
}

/// RawRepresentable Bric methods that enable an Float value to automatically bric & brac
extension Float : BracableNumberConvertible {
    public static func fromBricNum(num: Double) -> Float { return Float(num) }
}

/// RawRepresentable Bric methods that enable an Int value to automatically bric & brac
extension Int : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> Int {
        return num >= Double(Int.max) || num <= Double(Int.min) ? try overflow(num) : Int(num)
    }
}

/// RawRepresentable Bric methods that enable an Int8 value to automatically bric & brac
extension Int8 : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> Int8 {
        return num >= Double(Int8.max) || num <= Double(Int8.min) ? try overflow(num) : Int8(num)
    }
}

/// RawRepresentable Bric methods that enable an Int16 value to automatically bric & brac
extension Int16 : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> Int16 {
        return num >= Double(Int16.max) || num <= Double(Int16.min) ? try overflow(num) : Int16(num)
    }
}

/// RawRepresentable Bric methods that enable an Int32 value to automatically bric & brac
extension Int32 : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> Int32 {
        return num >= Double(Int32.max) || num <= Double(Int32.min) ? try overflow(num) : Int32(num)
    }
}

/// RawRepresentable Bric methods that enable an Int64 value to automatically bric & brac
extension Int64 : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> Int64 {
        return num >= Double(Int64.max) || num <= Double(Int64.min) ? try overflow(num) : Int64(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt value to automatically bric & brac
extension UInt : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> UInt {
        return num >= Double(UInt.max) || num <= Double(UInt.min) ? try overflow(num) : UInt(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt8 value to automatically bric & brac
extension UInt8 : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> UInt8 {
        return num >= Double(UInt8.max) || num <= Double(UInt8.min) ? try overflow(num) : UInt8(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt16 value to automatically bric & brac
extension UInt16 : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> UInt16 {
        return num >= Double(UInt16.max) || num <= Double(UInt16.min) ? try overflow(num) : UInt16(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt32 value to automatically bric & brac
extension UInt32 : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> UInt32 {
        return num >= Double(UInt32.max) || num <= Double(UInt32.min) ? try overflow(num) : UInt32(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt64 value to automatically bric & brac
extension UInt64 : BracableNumberConvertible {
    public static func fromBricNum(num: Double) throws -> UInt64 {
        return num >= Double(UInt64.max) || num <= Double(UInt64.min) ? try overflow(num) : UInt64(num)
    }
}



// MARK: Error Handling


public enum BracError: ErrorType, CustomDebugStringConvertible {
    /// A required key was not found in the given instance
    case MissingRequiredKey(type: Any.Type, key: String, path: Bric.Pointer)

    /// The type of the given Bric was invalid
    case InvalidType(type: Any.Type, actual: String, path: Bric.Pointer)

    /// The value of the RawValue could not be converted
    case InvalidRawValue(type: Any.Type, value: Any, path: Bric.Pointer)

    /// The numeric value overflows the storage of the target number
    case NumericOverflow(type: Any.Type, value: Double, path: Bric.Pointer)

    /// The array required a certain element but contained the wrong number
    case InvalidArrayLength(required: Range<Int>, actual: Int, path: Bric.Pointer)

    /// The type needed to be an object
    case KeyWithoutObject(key: String, path: Bric.Pointer)

    /// The enumeration value of the Bric could not be found
    case BadEnum(bric: Bric, path: Bric.Pointer)

    /// An unrecognized key was found in the input dictionary
    case UnrecognizedKey(key: String, path: Bric.Pointer)

    /// An unrecognized key was found in the input dictionary
    case ShouldNotBracError(type: Any.Type, path: Bric.Pointer)

    /// Too many matches were found for the given schema
    case MultipleMatches(type: Any.Type, path: Bric.Pointer)

    /// An unrecognized key was found in the input dictionary
    case MultipleErrors(errors: Array<ErrorType>, path: Bric.Pointer)

    public var debugDescription: String {
        func atPath(path: Bric.Pointer) -> String {
            if path.isEmpty {
                return ""
            }

            let parts: [String] = path.map {
                switch $0 {
                case .Key(let key): return key.replace("~", replacement: "~0").replace("/", replacement: "~1")
                case .Index(let idx): return String(idx)
                }
            }

            return " at /" + parts.joinWithSeparator("/")
        }

        switch self {
        case .MissingRequiredKey(let type, let key, let path): return "Missing key for \(type): «\(key)»\(atPath(path))"
        case .UnrecognizedKey(let key, let path): return "Unrecognized key: «\(key)»\(atPath(path))"
        case .InvalidType(let type, let actual, let path): return "Invalid type: expected \(type), found \(actual)\(atPath(path))"
        case .InvalidRawValue(let type, let value, let path): return "Invalid value for \(type): \(value)\(atPath(path))"
        case .NumericOverflow(let type, let value, let path): return "Numeric overflow: \(type) cannot contain \(value)\(atPath(path))"
        case .InvalidArrayLength(let range, let actual, let path): return "Invalid array length: array with count \(actual) not within required range \(range)\(atPath(path))"
        case .KeyWithoutObject(let key, let path): return "Object key «\(key)» requested in non-object\(atPath(path))"
        case .BadEnum(let bric, let path): return "Invalid enum value «\(bric)»\(atPath(path))"
        case .ShouldNotBracError(let type, let path): return "Should not have parsed «\(type)»\(atPath(path))"
        case .MultipleMatches(let type, let path): return "Too many matches «\(type)»\(atPath(path))"
        case .MultipleErrors(let errs, let path): return "Errors\(atPath(path)): \(errs)"
        }
    }

    /// The RFC 6901 JSON Pointer path to where the error occurred in the source JSON
    public var path: Bric.Pointer {
        get {
            switch self {
            case .MissingRequiredKey(_, _, let path): return path
            case .InvalidType(_, _, let path): return path
            case .InvalidRawValue(_, _, let path): return path
            case .NumericOverflow(_, _, let path): return path
            case .InvalidArrayLength( _, _, let path): return path
            case .KeyWithoutObject(_, let path): return path
            case .BadEnum(_, let path): return path
            case .UnrecognizedKey(_, let path): return path
            case .ShouldNotBracError(_, let path): return path
            case .MultipleMatches(_, let path): return path
            case .MultipleErrors(_, let path): return path
            }
        }

        set {
            switch self {
            case .MissingRequiredKey(let type, let key, _): self = .MissingRequiredKey(type: type, key: key, path: newValue)
            case .InvalidType(let type, let actual, _): self = .InvalidType(type: type, actual: actual, path: newValue)
            case .InvalidRawValue(let type, let value, _): self = .InvalidRawValue(type: type, value: value, path: newValue)
            case .NumericOverflow(let type, let value, _): self = .NumericOverflow(type: type, value: value, path: newValue)
            case .InvalidArrayLength(let range, let actual, _): self = .InvalidArrayLength(required: range, actual: actual, path: newValue)
            case .KeyWithoutObject(let key, _): self = .KeyWithoutObject(key: key, path: newValue)
            case .BadEnum(let bric, _): self = .BadEnum(bric: bric, path: newValue)
            case .UnrecognizedKey(let key, _): self = .UnrecognizedKey(key: key, path: newValue)
            case .ShouldNotBracError(let type, _): self = .ShouldNotBracError(type: type, path: newValue)
            case .MultipleMatches(let count, _): self = .MultipleMatches(type: count, path: newValue)
            case .MultipleErrors(let errors, _): self = .MultipleErrors(errors: errors, path: newValue)
            }
        }
    }

    /// Returns the same error with the given path prepended
    public func prependPath(prepend: Bric.Pointer) -> BracError {
        var err = self
        err.path = prepend + err.path
        return err
    }
}

public extension Bric {
    /// Utility function that simply throws an BracError.InvalidType
    public func invalidType<T>() throws -> T {
        switch self {
        case .Nul: throw BracError.InvalidType(type: T.self, actual: "nil", path: [])
        case .Arr: throw BracError.InvalidType(type: T.self, actual: "Array", path: [])
        case .Obj: throw BracError.InvalidType(type: T.self, actual: "Object", path: [])
        case .Str: throw BracError.InvalidType(type: T.self, actual: "String", path: [])
        case .Num: throw BracError.InvalidType(type: T.self, actual: "Double", path: [])
        case .Bol: throw BracError.InvalidType(type: T.self, actual: "Bool", path: [])
        }
    }

    /// Utility function that simply throws an BracError.InvalidType
    public func invalidRawValue<T>(value: Any) throws -> T {
        throw BracError.InvalidRawValue(type: T.self, value: value, path: [])
    }

}


/// Invokes the given autoclosure and returns the value, pre-pending the given path to any BracError
private func bracpath<T>(@autoclosure path: () -> Bric.Pointer, @autoclosure _ f: () throws -> T) throws -> T {
    do {
        return try f()
    } catch let err as BracError {
        throw err.prependPath(path())
    } catch {
        throw error
    }
}

/// Swaps the values of two Bricable & Bracable instances, throwing an error if any of the Brac fails.
///
/// - Requires: The two types be bric-serialization compatible.
///
/// - SeeAlso: `AnyObject`
public func bracSwap<B1, B2 where B1 : Bricable, B2: Bricable, B1: Bracable, B2: Bracable>(inout b1: B1, inout _ b2: B2) throws {
    let (brac1, brac2) = try (B1.brac(b2.bric()), B2.brac(b1.bric()))
    (b1, b2) = (brac1, brac2) // only perform the assignment if both the bracs succeed
}

/// Swaps the values of two optional Bricable & Bracable instances, throwing an error if any of the Brac fails
///
/// - Requires: The two types be bric-serialization compatible.
///
/// - SeeAlso: `AnyObject`
public func bracSwap<B1, B2 where B1 : Bricable, B2: Bricable, B1: Bracable, B2: Bracable>(inout b1: Optional<B1>, inout _ b2: Optional<B2>) throws {
    let (brac1, brac2) = try (B1.brac(b2.bric()), B2.brac(b1.bric()))
    (b1, b2) = (brac1, brac2) // only perform the assignment if both the bracs succeed
}


