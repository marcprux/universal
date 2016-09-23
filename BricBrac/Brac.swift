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

/// Object keyed subscription helpers for fluent dictionary-like access to Bric
public extension Bric {

    /// Bric has a string subscript when it is an object type
    public subscript(key: String)->Bric? {
        get { return try? brac(key: key) }

        set {
            switch self {
            case .obj(var ob): ob[key] = newValue; self = .obj(ob)
            default: break
            }
        }
    }
}

extension String: Bracable {
    /// A String is Brac'd to a `Bric.str` or else throws an error
    public static func brac(bric: Bric) throws -> String {
        if case .str(let str) = bric {
            return str
        } else {
            return try bric.invalidType()
        }
    }
}

extension Bool: Bracable {
    /// A Bool is Brac'd to a `Bric.bol` or else throws an error
    public static func brac(bric: Bric) throws -> Bool {
        if case .bol(let bol) = bric {
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
    public func bracNul() throws -> Void {
        guard case .nul = self else { return try invalidType() }
    }

    /// Bracs this type as Number, throwing an error if the underlying type is not a number
    public func bracNum() throws -> Double {
        guard case .num(let x) = self else { return try invalidType() }
        return x
    }

    /// Bracs this type as String, throwing an error if the underlying type is not a string
    public func bracStr() throws -> String {
        guard case .str(let x) = self else { return try invalidType() }
        return x
    }

    /// Bracs this type as Bool, throwing an error if the underlying type is not a boolean
    public func bracBol() throws -> Bool {
        guard case .bol(let x) = self else { return try invalidType() }
        return x
    }

    /// Bracs this type as an Object, throwing an error if the underlying type is not an object
    public func bracObj() throws -> [String: Bric] {
        guard case .obj(let x) = self else { return try invalidType() }
        return x
    }

    /// Bracs this type as an Array, throwing an error if the underlying type is not an array
    public func bracArr() throws -> [Bric] {
        guard case .arr(let x) = self else { return try invalidType() }
        return x
    }

}

/// Extensions for Bracing instances by key and inferred return type
public extension Bric {

    internal func objectKey<R: RawRepresentable>(_ key: R) throws -> Optional<Bric> where R.RawValue == String {
        guard case .obj(let dict) = self else {
            throw BracError.keyWithoutObject(key: key.rawValue, path: [])
        }
        return dict[key.rawValue]
    }

    /// Reads a required Bric instance from the given key in an object bric
    public func brac<T: Bracable, R: RawRepresentable>(key: R) throws -> T where R.RawValue == String {
        if let value = try objectKey(key) {
            return try bracPath(key, T.brac(bric: value))
        } else {
            throw BracError.missingRequiredKey(type: T.self, key: key.rawValue, path: [])
        }
    }

    /// Reads one level of wrapped instance(s) from the given key in an object bric
    public func brac<T: BracLayer, R: RawRepresentable>(key: R) throws -> T where R.RawValue == String, T.BracSub : Bracable {
        return try bracPath(key, T.brac(bric: objectKey(key) ?? nil))
    }

    /// Reads two levels of wrapped instance(s) from the given key in an object bric
    public func brac<T: BracLayer, R: RawRepresentable>(key: R) throws -> T where R.RawValue == String, T.BracSub : BracLayer, T.BracSub.BracSub : Bracable {
        return try bracPath(key, T.brac(bric: objectKey(key) ?? nil))
    }

    /// Reads three levels of wrapped instance(s) from the given key in an object bric
    public func brac<T: BracLayer, R: RawRepresentable>(key: R) throws -> T where R.RawValue == String, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : Bracable {
        return try bracPath(key, T.brac(bric: objectKey(key) ?? nil))
    }

    /// Reads four levels of wrapped instance(s) from the given key in an object bric
    public func brac<T: BracLayer, R: RawRepresentable>(key: R) throws -> T where R.RawValue == String, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : Bracable {
        return try bracPath(key, T.brac(bric: objectKey(key) ?? nil))
    }

    /// Reads five levels of wrapped instance(s) from the given key in an object bric
    public func brac<T: BracLayer, R: RawRepresentable>(key: R) throws -> T where R.RawValue == String, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub.BracSub : Bracable {
        return try bracPath(key, T.brac(bric: objectKey(key) ?? nil))
    }

    /// Reads any one of the given Brics, throwing an error if the successful number of instances is outside of the given range of acceptable passes
    public func brac<T: Bracable>(range: ClosedRange<Int>, bracers: [() throws -> T]) throws -> [T] {
        var values: [T] = []
        var errors: [Error] = []
        for f in bracers {
            do {
                values.append(try f())
            } catch {
                errors.append(error)
            }
        }

        if values.count < range.lowerBound {
            throw BracError.multipleErrors(errors: errors, path: [])
        } else if values.count > range.upperBound  {
            throw BracError.multipleMatches(type: T.self, path: [])
        } else {
            return values
        }
    }

    /// Reads any one of the given Brics, throwing an error if all of the closures also threw an error or more than one succeeded
    public func brac<T: Bracable>(oneOf: [() throws -> T]) throws -> T {
        return try brac(range: 1...1, bracers: oneOf).first!
    }

    /// Reads at least one of the given Brics, throwing an error if none of the brics passed
    public func brac<T1, T2>(anyOf b1: (Bric) throws -> T1, _ b2: (Bric) throws -> T2) throws -> (T1?, T2?) {
        var errs: [Error] = []

        var t1: T1?
        do { t1 = try b1(self) } catch { errs.append(error) }
        var t2: T2?
        do { t2 = try b2(self) } catch { errs.append(error) }

        if t1 == nil && t2 == nil {
            throw BracError.multipleErrors(errors: errs, path: [])
        } else {
            return (t1, t2)
        }
    }

    /// Reads at least one of the given Brics, throwing an error if none of the brics passed
    public func brac<T1, T2, T3>(anyOf b1: (Bric) throws -> T1, _ b2: (Bric) throws -> T2, _ b3: (Bric) throws -> T3) throws -> (T1?, T2?, T3?) {
        var errs: [Error] = []

        var t1: T1?
        do { t1 = try b1(self) } catch { errs.append(error) }
        var t2: T2?
        do { t2 = try b2(self) } catch { errs.append(error) }
        var t3: T3?
        do { t3 = try b3(self) } catch { errs.append(error) }

        if t1 == nil && t2 == nil && t3 == nil {
            throw BracError.multipleErrors(errors: errs, path: [])
        } else {
            return (t1, t2, t3)
        }
    }

    /// Reads at least one of the given Brics, throwing an error if none of the brics passed
    public func brac<T1, T2, T3, T4>(anyOf b1: (Bric) throws -> T1, _ b2: (Bric) throws -> T2, _ b3: (Bric) throws -> T3, _ b4: (Bric) throws -> T4) throws -> (T1?, T2?, T3?, T4?) {
        var errs: [Error] = []

        var t1: T1?
        do { t1 = try b1(self) } catch { errs.append(error) }
        var t2: T2?
        do { t2 = try b2(self) } catch { errs.append(error) }
        var t3: T3?
        do { t3 = try b3(self) } catch { errs.append(error) }
        var t4: T4?
        do { t4 = try b4(self) } catch { errs.append(error) }

        if t1 == nil && t2 == nil && t3 == nil && t4 == nil {
            throw BracError.multipleErrors(errors: errs, path: [])
        } else {
            return (t1, t2, t3, t4)
        }
    }

    /// Reads at least one of the given Brics, throwing an error if none of the brics passed
    public func brac<T1, T2, T3, T4, T5>(anyOf b1: (Bric) throws -> T1, _ b2: (Bric) throws -> T2, _ b3: (Bric) throws -> T3, _ b4: (Bric) throws -> T4, _ b5: (Bric) throws -> T5) throws -> (T1?, T2?, T3?, T4?, T5?) {
        var errs: [Error] = []

        var t1: T1?
        do { t1 = try b1(self) } catch { errs.append(error) }
        var t2: T2?
        do { t2 = try b2(self) } catch { errs.append(error) }
        var t3: T3?
        do { t3 = try b3(self) } catch { errs.append(error) }
        var t4: T4?
        do { t4 = try b4(self) } catch { errs.append(error) }
        var t5: T5?
        do { t5 = try b5(self) } catch { errs.append(error) }

        if t1 == nil && t2 == nil && t3 == nil && t4 == nil && t5 == nil {
            throw BracError.multipleErrors(errors: errs, path: [])
        } else {
            return (t1, t2, t3, t4, t5)
        }
    }

//    public func brac<T: Bracable>(anyOf: [() throws -> T]) throws -> NonEmptyCollection<T, [T]> {
//        let elements = try bracRange(1...anyOf.count, bracers: anyOf)
//        return NonEmptyCollection(elements[0], tail: Array(elements.dropFirst()))
//    }

    /// Reads all of the given Brics, throwing an error if any of the closures threw an error
    public func brac<T: Bracable>(allOf: [() throws -> T]) throws -> [T] {
        return try brac(range: allOf.count...allOf.count, bracers: allOf)
    }

    /// Bracs the T with the given factory
    public func brac<T1, T2>(both t1: (Bric) throws -> T1, _ t2: (Bric) throws -> T2) throws -> (T1, T2) {
        return try (t1(self), t2(self))
    }

    /// Returns a dictionary of keys to raw Brics for all keys that are not present in the given RawType (e.g., an enum of keys)
    /// This is useful for maintaining the underlying Brics of any object keys that are not strictly enumerated
    public func brac<R: RawRepresentable>(disjoint keys: R.Type) throws -> Dictionary<String, Bric> where R.RawValue == String {
        guard case .obj(let d) = self else { return try invalidType() }
        var dict = d
        for key in dict.keys {
            if R(rawValue: key) != nil {
                dict.removeValue(forKey: key)
            }
        }
        return dict
    }

    /// Validates that only the given keys exists in the current dictionary bric; useful for forbidding additionalProperties
    public func exclusive<T>(keys: [String], _ f: @autoclosure () throws -> T) throws -> T {
        guard case .obj(let dict) = self else { return try invalidType() }
        let unrecognized = Set(dict.keys).subtracting(keys)
        if !unrecognized.isEmpty {
            let errs: [Error] = Array(unrecognized).map({ BracError.unrecognizedKey(key: $0, path: []) })
            if errs.count == 1 {
                throw errs[0]
            } else {
                throw BracError.multipleErrors(errors: errs, path: [])
            }
        }
        return try f()
    }

    /// Validates that only the given keys exists in the current dictionary bric; useful for forbidding additionalProperties
    public func prohibit<R: RawRepresentable>(additionalKeys keys: R.Type) throws where R.RawValue == String {
        guard case .obj(let dict) = self else { return try invalidType() }
        var errs: [Error] = []
        for key in dict.keys {
            if keys.init(rawValue: key) == nil {
                errs.append(BracError.unrecognizedKey(key: key, path: []))
            }
        }
        if errs.count == 1 {
            throw errs[0]
        } else if errs.count > 1 {
            throw BracError.multipleErrors(errors: errs, path: [])
        }
    }

    // TODO: remove

    public func assertNoAdditionalProperties<R: RawRepresentable>(_ keys: R.Type) throws where R.RawValue == String {
        return try prohibit(additionalKeys: keys)
    }
}

// MARK: BracLayer wrapper Brac


/// A BracLayer can wrap around some instances; it is used to allow brac'ing from an arbitrarily nested container types
/// This allows us to have a single handlers for multiple permutations of wrappers, such as
/// Array<String>, Optional<Array<Bool>>, Array<Optional<Bool>>, and Array<Optional<Set<CollectionOfOne<Int>>>>
public protocol BracLayer {
    /// The type that is being wrapped by this layer
    associatedtype BracSub

    /// Construct an instance of self by invoking the function on the given bric
    static func brac(map bric: Bric, f: (Bric) throws -> BracSub) throws -> Self
}

public extension BracLayer where Self.BracSub : Bracable {
    /// Try to construct an instance of the wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.brac(map: bric, f: Self.BracSub.brac)
    }
}

public extension BracLayer where Self.BracSub : BracLayer, Self.BracSub.BracSub : Bracable {
    /// Try to construct an instance of the twofold-wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.brac(map: bric) {
            try Self.BracSub.brac(map: $0, f: Self.BracSub.BracSub.brac)
        }
    }
}

public extension BracLayer where Self.BracSub : BracLayer, Self.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub : Bracable {
    /// Try to construct an instance of the threefold-wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.brac(map: bric) {
            try Self.BracSub.brac(map: $0) {
                try Self.BracSub.BracSub.brac(map: $0,
                    f: Self.BracSub.BracSub.BracSub.brac)
            }
        }
    }
}

public extension BracLayer where Self.BracSub : BracLayer, Self.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub.BracSub : Bracable {
    /// Try to construct an instance of the fourfold-wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.brac(map: bric) {
            try Self.BracSub.brac(map: $0) {
                try Self.BracSub.BracSub.brac(map: $0) {
                    try Self.BracSub.BracSub.BracSub.brac(map: $0,
                        f: Self.BracSub.BracSub.BracSub.BracSub.brac)
                }
            }
        }
    }
}

public extension BracLayer where Self.BracSub : BracLayer, Self.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub.BracSub : BracLayer, Self.BracSub.BracSub.BracSub.BracSub.BracSub : Bracable {
    /// Try to construct an instance of the fivefold-wrapped type from the `Bric` parameter
    public static func brac(bric: Bric) throws -> Self {
        return try Self.brac(map: bric) {
            try Self.BracSub.brac(map: $0) {
                try Self.BracSub.BracSub.brac(map: $0) {
                    try Self.BracSub.BracSub.BracSub.brac(map: $0) {
                        try Self.BracSub.BracSub.BracSub.BracSub.brac(map: $0,
                            f: Self.BracSub.BracSub.BracSub.BracSub.BracSub.brac)
                    }
                }
            }
        }
    }
}

extension Wrappable {
    /// Returns this wrapper around the bracMap, or returns `.None` if the parameter is `Bric.nul`
    public static func brac(map bric: Bric, f: (Bric) throws -> Wrapped) throws -> Self {
        if case .nul = bric { return nil } // an optional is allowed to be nil
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
        let rawValue = try RawValue.brac(bric: bric)
        if let x = Self(rawValue: rawValue) {
            return x
        } else {
            return try bric.invalidRawValue(rawValue)
        }
    }

}

extension RangeReplaceableCollection {
    /// Returns this collection around the bracMaps, or throws an error if the parameter is not `Bric.arr`
    public static func brac(map bric: Bric, f: (Bric) throws -> Iterator.Element) throws -> Self {
        if case .arr(let arr) = bric {
            var ret = Self()
            for (i, x) in arr.enumerated() {
                ret.append(try bracIndex(i, f(x)))
            }
            return ret
        }
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

    public static func brac(map bric: Bric, f: (Bric) throws -> BracSub) throws -> CollectionOfOne {
        if case .arr(let x) = bric {
            if x.count != 1 { throw BracError.invalidArrayLength(required: 1...1, actual: x.count, path: []) }
            return CollectionOfOne(try f(x[0]))
        }
        return try bric.invalidType()
    }
}

extension EmptyCollection : BracLayer {
    public typealias BracSub = Element

    public static func brac(map bric: Bric, f: (Bric) throws -> BracSub) throws -> EmptyCollection {
        if case .arr(let x) = bric {
            // really kind of pointless: why would anyone mandate an array size zero?
            if x.count != 0 { throw BracError.invalidArrayLength(required: 0...0, actual: x.count, path: []) }
            return EmptyCollection()
        }
        return try bric.invalidType()
    }
}

//extension NonEmptyCollection : BracLayer {
//    public typealias BracSub = Element
//
//    /// Returns this collection around the bracMaps, or throws an error if the parameter is not `Bric.arr` or the array does not have at least a single element
//    public static func bracMap(_ bric: Bric, f: (Bric) throws -> Element) throws -> NonEmptyCollection {
//        if case .arr(let arr) = bric {
//            guard let first = arr.first else {
//                throw BracError.invalidArrayLength(required: 1..<Int.max, actual: 0, path: [])
//            }
//            return try NonEmptyCollection(f(first), tail: Tail.bracMap(Bric.arr(Array(arr.dropFirst())), f: f))
//        }
//        return try bric.invalidType()
//    }
//}


extension Dictionary : BracLayer {
    public typealias BracSub = Value

    public static func brac(map bric: Bric, f: (Bric) throws -> BracSub) throws -> Dictionary {
        if case .obj(let x) = bric {
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
    public typealias BracSub = Iterator.Element

    public static func brac(map bric: Bric, f: (Bric) throws -> BracSub) throws -> Set {
        if case .arr(let x) = bric { return Set(try x.map(f)) }
        return try bric.invalidType()
    }
}


// MARK: Numeric Brac

/// A BracableNumberConvertible is any numeric type that can be converted into a Double
public protocol BracableNumberConvertible : Bracable {
    /// Converts the given Double to the type, throwing an error on overflow
    static func fromBric(num: Double) throws -> Self
}

extension BracableNumberConvertible {
    /// Converts the given numeric bric to this numeric type, throwing an error if the Bric was not a number or overflows the bounds
    public static func brac(bric: Bric) throws -> Self {
        if case .num(let num) = bric {
            return try fromBric(num: num)
        } else {
            return try bric.invalidType()
        }
    }

    fileprivate static func overflow<T>(_ value: Double) throws -> T {
        throw BracError.numericOverflow(type: T.self, value: value, path: [])
    }
}


/// RawRepresentable Bric methods that enable an Double value to automatically bric & brac
extension Double : BracableNumberConvertible {
    public static func fromBric(num: Double) -> Double { return Double(num) }
}

/// RawRepresentable Bric methods that enable an Float value to automatically bric & brac
extension Float : BracableNumberConvertible {
    public static func fromBric(num: Double) -> Float { return Float(num) }
}

/// RawRepresentable Bric methods that enable an Int value to automatically bric & brac
extension Int : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> Int {
        return num >= Double(Int.max) || num <= Double(Int.min) ? try overflow(num) : Int(num)
    }
}

/// RawRepresentable Bric methods that enable an Int8 value to automatically bric & brac
extension Int8 : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> Int8 {
        return num >= Double(Int8.max) || num <= Double(Int8.min) ? try overflow(num) : Int8(num)
    }
}

/// RawRepresentable Bric methods that enable an Int16 value to automatically bric & brac
extension Int16 : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> Int16 {
        return num >= Double(Int16.max) || num <= Double(Int16.min) ? try overflow(num) : Int16(num)
    }
}

/// RawRepresentable Bric methods that enable an Int32 value to automatically bric & brac
extension Int32 : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> Int32 {
        return num >= Double(Int32.max) || num <= Double(Int32.min) ? try overflow(num) : Int32(num)
    }
}

/// RawRepresentable Bric methods that enable an Int64 value to automatically bric & brac
extension Int64 : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> Int64 {
        return num >= Double(Int64.max) || num <= Double(Int64.min) ? try overflow(num) : Int64(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt value to automatically bric & brac
extension UInt : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> UInt {
        return num >= Double(UInt.max) || num <= Double(UInt.min) ? try overflow(num) : UInt(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt8 value to automatically bric & brac
extension UInt8 : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> UInt8 {
        return num >= Double(UInt8.max) || num <= Double(UInt8.min) ? try overflow(num) : UInt8(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt16 value to automatically bric & brac
extension UInt16 : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> UInt16 {
        return num >= Double(UInt16.max) || num <= Double(UInt16.min) ? try overflow(num) : UInt16(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt32 value to automatically bric & brac
extension UInt32 : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> UInt32 {
        return num >= Double(UInt32.max) || num <= Double(UInt32.min) ? try overflow(num) : UInt32(num)
    }
}

/// RawRepresentable Bric methods that enable an UInt64 value to automatically bric & brac
extension UInt64 : BracableNumberConvertible {
    public static func fromBric(num: Double) throws -> UInt64 {
        return num >= Double(UInt64.max) || num <= Double(UInt64.min) ? try overflow(num) : UInt64(num)
    }
}


// MARK: Error Handling


public enum BracError: Error, CustomDebugStringConvertible {
    /// A required key was not found in the given instance
    case missingRequiredKey(type: Any.Type, key: String, path: Bric.Pointer)

    /// The type of the given Bric was invalid
    case invalidType(type: Any.Type, actual: String, path: Bric.Pointer)

    /// The value of the RawValue could not be converted
    case invalidRawValue(type: Any.Type, value: Any, path: Bric.Pointer)

    /// The numeric value overflows the storage of the target number
    case numericOverflow(type: Any.Type, value: Double, path: Bric.Pointer)

    /// The array required a certain element but contained the wrong number
    case invalidArrayLength(required: ClosedRange<Int>, actual: Int, path: Bric.Pointer)

    /// The type needed to be an object
    case keyWithoutObject(key: String, path: Bric.Pointer)

    /// The enumeration value of the Bric could not be found
    case badEnum(bric: Bric, path: Bric.Pointer)

    /// An unrecognized key was found in the input dictionary
    case unrecognizedKey(key: String, path: Bric.Pointer)

    /// An unrecognized key was found in the input dictionary
    case shouldNotBracError(type: Any.Type, path: Bric.Pointer)

    /// Too many matches were found for the given schema
    case multipleMatches(type: Any.Type, path: Bric.Pointer)

    /// An unrecognized key was found in the input dictionary
    case multipleErrors(errors: Array<Error>, path: Bric.Pointer)

    public var debugDescription: String {
        return describeErrors(space: 2)
    }

    public func describeErrors(space: Int = 0) -> String {
        func at(path: Bric.Pointer) -> String {
            if path.isEmpty {
                return ""
            }

            let parts: [String] = path.map {
                switch $0 {
                case .key(let key): return key.replace(string: "~", with: "~0").replace(string: "/", with: "~1")
                case .index(let idx): return String(idx)
                }
            }

            return " at #/" + parts.joined(separator: "/")
        }

        switch self {
        case .missingRequiredKey(let type, let key, let path):
            return "Missing required property «\(key)» of type \(_typeName(type))\(at(path: path))"
        case .unrecognizedKey(let key, let path):
            return "Unrecognized key «\(key)»\(at(path: path))"
        case .invalidType(let type, let actual, let path):
            return "Invalid type\(at(path: path)): expected \(_typeName(type)), found \(_typeName(type(of: actual)))"
        case .invalidRawValue(let type, let value, let path):
            return "Invalid value “\(value)”\(at(path: path)) of type \(_typeName(type))"
        case .numericOverflow(let type, let value, let path):
            return "Numeric overflow\(at(path: path)): \(_typeName(type)) cannot contain \(value)"
        case .invalidArrayLength(let range, let actual, let path):
            return "Invalid array length \(actual)\(at(path: path)) expected \(range)"
        case .keyWithoutObject(let key, let path):
            return "Object key «\(key)» requested in non-object\(at(path: path))"
        case .badEnum(let bric, let path):
            return "Invalid enum value “\(bric)”\(at(path: path))"
        case .shouldNotBracError(let type, let path):
            return "Data matches schema from 'not'\(at(path: path)) of type \(_typeName(type)))"
        case .multipleMatches(let type, let path):
            return "Too many matches\(at(path: path)): «\(_typeName(type))»"
        case .multipleErrors(let errs, let path):
            let nberrs: [String] = errs.filter({ !($0 is BracError) }).map({ String(describing: $0) })
            let brerrs: [String] = errs.map({ $0 as? BracError }).flatMap({ $0?.prepend(path: path) }).map({ $0.describeErrors(space: space == 0 ? 0 : space + 2) })

            return "\(errs.count) errors\(at(path: path)):" + ([""] + nberrs + brerrs).joined(separator: "\n" + String(repeating: " ", count: space))
        }
    }

    /// The RFC 6901 JSON Pointer path to where the error occurred in the source JSON
    public var path: Bric.Pointer {
        get {
            switch self {
            case .missingRequiredKey(_, _, let path): return path
            case .invalidType(_, _, let path): return path
            case .invalidRawValue(_, _, let path): return path
            case .numericOverflow(_, _, let path): return path
            case .invalidArrayLength( _, _, let path): return path
            case .keyWithoutObject(_, let path): return path
            case .badEnum(_, let path): return path
            case .unrecognizedKey(_, let path): return path
            case .shouldNotBracError(_, let path): return path
            case .multipleMatches(_, let path): return path
            case .multipleErrors(_, let path): return path
            }
        }

        set {
            switch self {
            case .missingRequiredKey(let type, let key, _):
                self = .missingRequiredKey(type: type, key: key, path: newValue)
            case .invalidType(let type, let actual, _):
                self = .invalidType(type: type, actual: actual, path: newValue)
            case .invalidRawValue(let type, let value, _):
                self = .invalidRawValue(type: type, value: value, path: newValue)
            case .numericOverflow(let type, let value, _):
                self = .numericOverflow(type: type, value: value, path: newValue)
            case .invalidArrayLength(let range, let actual, _):
                self = .invalidArrayLength(required: range, actual: actual, path: newValue)
            case .keyWithoutObject(let key, _):
                self = .keyWithoutObject(key: key, path: newValue)
            case .badEnum(let bric, _):
                self = .badEnum(bric: bric, path: newValue)
            case .unrecognizedKey(let key, _):
                self = .unrecognizedKey(key: key, path: newValue)
            case .shouldNotBracError(let type, _):
                self = .shouldNotBracError(type: type, path: newValue)
            case .multipleMatches(let count, _):
                self = .multipleMatches(type: count, path: newValue)
            case .multipleErrors(let errors, _):
                self = .multipleErrors(errors: errors, path: newValue)
            }
        }
    }

    /// Returns the same error with the given path prepended
    public func prepend(path prepend: Bric.Pointer) -> BracError {
        var err = self
        err.path = prepend + err.path
        return err
    }
}

public extension Bric {
    /// Utility function that simply throws an BracError.InvalidType
    public func invalidType<T>() throws -> T {
        switch self {
        case .nul: throw BracError.invalidType(type: T.self, actual: "nil", path: [])
        case .arr: throw BracError.invalidType(type: T.self, actual: "Array", path: [])
        case .obj: throw BracError.invalidType(type: T.self, actual: "Object", path: [])
        case .str: throw BracError.invalidType(type: T.self, actual: "String", path: [])
        case .num: throw BracError.invalidType(type: T.self, actual: "Double", path: [])
        case .bol: throw BracError.invalidType(type: T.self, actual: "Bool", path: [])
        }
    }

    /// Utility function that simply throws an BracError.InvalidType
    public func invalidRawValue<T>(_ value: Any) throws -> T {
        throw BracError.invalidRawValue(type: T.self, value: value, path: [])
    }
}

/// Invokes the given autoclosure and returns the value, pre-pending the given path to any BracError
private func bracPath<T, R: RawRepresentable>(_ key: R, _ f: @autoclosure () throws -> T) throws -> T where R.RawValue == String {
    do {
        return try f()
    } catch let err as BracError {
        throw err.prepend(path: [Bric.Ref(key: key)])
    } catch {
        throw error
    }
}

/// Invokes the given autoclosure and returns the value, pre-pending the given path to any BracError
private func bracIndex<T>(_ index: Int, _ f: @autoclosure () throws -> T) throws -> T {
    do {
        return try f()
    } catch let err as BracError {
        throw err.prepend(path: [Bric.Ref(index: index)])
    } catch {
        throw error
    }
}

/// Swaps the values of two Bricable & Bracable instances, throwing an error if any of the Brac fails.
///
/// - Requires: The two types be bric-serialization compatible.
///
/// - SeeAlso: `AnyObject`
public func bracSwap<B1, B2>(_ b1: inout B1, _ b2: inout B2) throws where B1 : Bricable, B2: Bricable, B1: Bracable, B2: Bracable {
    let (brac1, brac2) = try (B1.brac(bric: b2.bric()), B2.brac(bric: b1.bric()))
    (b1, b2) = (brac1, brac2) // only perform the assignment if both the bracs succeed
}

/// Swaps the values of two optional Bricable & Bracable instances, throwing an error if any of the Brac fails
///
/// - Requires: The two types be bric-serialization compatible.
///
/// - SeeAlso: `AnyObject`
public func bracSwap<B1, B2>(_ b1: inout Optional<B1>, _ b2: inout Optional<B2>) throws where B1 : Bricable, B2: Bricable, B1: Bracable, B2: Bracable {
    let (brac1, brac2) = try (B1.brac(bric: b2.bric()), B2.brac(bric: b1.bric()))
    (b1, b2) = (brac1, brac2) // only perform the assignment if both the bracs succeed
}
