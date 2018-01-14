//
//  Bric.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 3/12/15.
//  Copyright (c) 2015 glimpse.io. All rights reserved.
//
//  License: Apache
//

// MARK: Bric

/// A Bric is a bit of JSON encoded as an enumeration; it can represent a `Bool` (`Bric.bol`),
/// `String` (`Bric.str`), `Double` (`Bric.num`), `Array` (`Bric.arr`), `Dictionary` (`Bric.obj`),
/// or `nil` (`Bric.nul`)
public enum Bric {
    case arr([Bric]) // Array
    case obj([String: Bric]) // Dictionary
    case str(String) // String
    case num(Double) // Number
    case bol(Bool) // Boolean
    case nul // Null
}

extension Bric {
    /// Returns the underlying `String` for `Bric.str` cases, else nil
    public var str: String? { if case .str(let x) = self { return x } else { return nil } }
    /// Returns the underlying `Double` for `Bric.num` cases, else nil
    public var num: Double? { if case .num(let x) = self { return x } else { return nil } }
    /// Returns the underlying `Bool` for `Bric.bol` cases, else nil
    public var bol: Bool? { if case .bol(let x) = self { return x } else { return nil } }
    /// Returns the underlying `Void` for `Bric.nul` cases, else nil
    public var nul: Void? { if case .nul = self { return Void() } else { return nil } }
    /// Returns the underlying `Array<Bric>` for `Bric.arr` cases, else nil
    public var arr: [Bric]? { if case .arr(let x) = self { return x.map({ $0 as Bric }) } else { return nil } }
    /// Returns the underlying `Dictionary<String,Bric>` for `Bric.obj` cases, else nil
    public var obj: [String : Bric]? { if case .obj(let x) = self { return x } else { return nil } }
}

extension Bric : Equatable { }

/// Two Brics are the same when they represent the same type and have the same contents
public func ==(lhs: Bric, rhs: Bric) -> Bool {
    switch (lhs, rhs) {
    case let (.arr(arr1), .arr(arr2)): return arr1 == arr2
    case let (.obj(obj1), .obj(obj2)): return obj1 == obj2
    case let (.str(str1), .str(str2)): return str1 == str2
    case let (.num(num1), .num(num2)): return num1 == num2
    case let (.bol(bol1), .bol(bol2)): return bol1 == bol2
    case (.nul, .nul): return true
    default: return false
    }
}

extension Bric : Hashable {
    public var hashValue: Int {
        switch self {
        case .arr(let a): return a.reduce(0, { sum, bric in (37.multipliedReportingOverflow(by: (sum.addingReportingOverflow(bric.hashValue).partialValue)).partialValue) })
        case .obj(let o): return o.reduce(0, { sum, keyValue in (37.multipliedReportingOverflow(by: sum.addingReportingOverflow(keyValue.0.hashValue).partialValue.addingReportingOverflow(keyValue.1.hashValue).partialValue).partialValue) })
        case .str(let s): return s.hashValue
        case .num(let d): return d.hashValue
        case .bol(let b): return b.hashValue
        case .nul: return 0
        }
    }
}

extension Bric {
    /// The count of Bric is either the number of properties (for an object), number of elements (for an array), 0 for null, or 1 for string & number
    public var count: Int {
        switch self {
        case .obj(let ob): return ob.count
        case .arr(let arr): return arr.count
        case .nul: return 0
        default: return 1
        }
    }

    /// Appending elements of two Brics has different meanings depending on the underlying types:
    ///
    /// * Obj + Obj returns an Obj with the unified key-value pairs
    /// * Arr + Arr returns an Arr with all the elements of the two array
    /// * Arr + Bric returns an Arr with the bric appended to the end
    /// * Bric + Arr returns an Arr with the bric prepended at the beginning
    /// * Bric + Bric returns an Arr of the two brics
    ///
    /// - Warning: note that value types are always added as collections,
    ///   such that 1 + 1 yields [1, 1] and "foo" + "bar" yields ["foo", "bar"]
    public mutating func append(contentsOf bric: Bric) {
        switch (self, bric) {
        case (.obj(var obj1), .obj(let obj2)):
            for (k, v) in obj2 { obj1[k] = v }
            self = .obj(obj1)
        case (.arr(let arr1), .arr(let arr2)):
            self = .arr(arr1 + arr2)
        case (.arr(let arr1), _):
            self = .arr(arr1 + [bric])
        case (_, .arr(let arr2)):
            self = .arr([self] + arr2)
        default:
            self = .arr([self, bric])
        }
    }
}

public extension Bric {
    /// Copy the values of all enumerable own properties from one or more source objects to a target object,
    /// returning the union of the objects
    ///
    /// - See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign
    
    public func assign(bric: Bric) -> Bric {
        return merge(bric: bric, depth: 1)
    }

    /// Performs a deep merge of all the object & array elements of the given Bric
    
    public func merge(bric: Bric, depth: Int = Int.max) -> Bric {
        if depth <= 0 { return self }

        if case .arr(var a1) = self, case .arr(let a2) = bric {
            for (i, (e1, e2)) in zip(a1, a2).enumerated() {
                a1[i] = e1.merge(bric: e2, depth: depth - 1)
            }
            return .arr(a1)
        }

        guard case .obj(var dest) = self, case .obj(let src) = bric else { return self }
        for (srckey, srcval) in src {
            if let destval = dest[srckey] {
                dest[srckey] = destval.merge(bric: srcval, depth: depth - 1)
            } else {
                dest[srckey] = srcval
            }
        }
        return .obj(dest)
    }
}


/// Array indexed subscription helpers for fluent dictionary-like access to Bric
public extension Bric {

    /// Bric has an int subscript when it is an array type; safe indexing is used
    public subscript(index: Int)->Bric? {
        get {
            switch self {
            case .arr(let arr):
                return index < 0 || index >= arr.count ? .none : arr[index]
            default:
                return .none
            }
        }

        set {
            switch self {
            case .arr(var arr):
                if index < 0 || index >= arr.count {
                    return
                }
                arr[index] = newValue ?? .nul
                self = .arr(arr)
            default:
                break
            }
        }
    }
}

extension Bric : ExpressibleByNilLiteral {
    /// Creates some null Bric
    public init(nilLiteral: ()) {
        self = .nul
    }
}

extension Bric : ExpressibleByBooleanLiteral {
    /// Creates some boolean Bric
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bol(value)
    }
}

extension Bric : ExpressibleByFloatLiteral {
    /// Creates some numeric Bric
    public init(floatLiteral value: FloatLiteralType) {
        self = .num(value)
    }
}

extension Bric : ExpressibleByIntegerLiteral {
    /// Creates some numeric Bric
    public init(integerLiteral value: IntegerLiteralType) {
        self = .num(Double(value))
    }
}

extension Bric : ExpressibleByArrayLiteral {
    /// Creates an array of Bric
    public init(arrayLiteral elements: Bric...) {
        self = .arr(elements)
    }
}

extension Bric : ExpressibleByStringLiteral {
    /// Creates some String Bric
    public init(stringLiteral value: String) {
        self = .str(value)
    }

    /// Creates some String Bric
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .str(value)
    }

    /// Creates some String Bric
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .str(value)
    }
}

extension Bric : ExpressibleByDictionaryLiteral {
    /// Creates a dictonary of some Bric
    public init(dictionaryLiteral elements: (String, Bric)...) {
        var d: Dictionary<String, Bric> = [:]
        for (k, v) in elements { d[k] = v }
        self = .obj(d)
    }


    /// Creates a Bric.obj with the given key/value pairs
    public init<R: RawRepresentable>(object: [(R, Bric)]) where R.RawValue == String {
        var d: Dictionary<String, Bric> = [:]
        for (k, v) in object {
            if !k.rawValue.isEmpty {
                switch (k.rawValue, v) {
                case (_, .nul):
                    break // nil doens't get saved
                case (let key, _):
                    d[key] = v
                }
            } else {
                // empty key name: merge the Bric dictionary into the given dictionary
                if case .obj(let sub) = v {
                    for (subk, subv) in sub {
                        d[subk] = subv
                    }
                }
            }
        }
        self = .obj(d)
    }

    /// Creates a Bric.obj with the given dictionary where the key is a String RawRepresentable
    public init<R: RawRepresentable>(obj: [R: Bric]) where R.RawValue == String {
        self.init(object: Array(obj))
    }

    /// Creates a Bric.obj by merging any sub-objects into a single Bric Object
    public init(merge: [Bric]) {
        var d: Dictionary<String, Bric> = [:]
        for b in merge { // .reverse() { // reverse because initial elements take precedence
            if case .obj(let dict) = b {
                for (key, value) in dict {
                    if let oldValue = d[key] , oldValue != value {
                        print("warning: overwriting dictionary key «\(key)» value «\(oldValue)» with «\(value)»")
                    }
                    d[key] = value
                }
            }
        }
        self = .obj(d)
    }

    /// Returns a Bric Obj with the specified keys removed
    public func disjoint(keys: [String]) -> Bric {
        if case .obj(var dict) = self {
            for key in keys {
                dict.removeValue(forKey: key)
            }
            return .obj(dict)
        } else {
            return self
        }
    }
}

extension Bric {
    public init<R: RawRepresentable>(elements: [R: Bric]) where R.RawValue == String {
        var d: Dictionary<String, Bric> = [:]
        for (k, v) in elements { d[k.rawValue] = v }
        self = .obj(d)
    }
}

extension Bric {
    /// Construct a `Bric.num` from any supported numeric type
    public init(num: BricableDoubleConvertible) {
        self = .num(num.bricNum)
    }
}


// MARK: Bricable

/// A Bricable is a type that is able to serialize itself to Bric
public protocol Bricable {
    /// Returns the Bric'd form of this instance
    func bric() -> Bric
}

extension Bric : Bricable {
    /// A `Bric` instance simply brics to itself
    public func bric() -> Bric { return self }
}

extension String: Bricable {
    /// A String brics to a `Bric.str`
    public func bric() -> Bric { return .str(self) }
}

extension Bool: Bricable {
    /// A Bool brics to a `Bric.bol`
    public func bric() -> Bric { return .bol(self) }
}


// MARK: BricLayer wrapper Bric

/// A `BricLayer` acts as a wrapper around some eventually bricable instance by using the `bricMap` function.
/// `BricLayer`s are composable, meaning that a `BricLayer` can be nested up to five layers deep the the underlying
/// data will be wrapped accordingly.
public protocol BricLayer {
    /// The type that is being wrapped by this layer
    associatedtype BricSub

    /// Construct an instance of self by invoking the function on the given bric
    func bric(map f: (BricSub) -> Bric) -> Bric
}

public extension BricLayer where Self.BricSub : Bricable {
    /// Brics through one level of `BricLayer`
    public func bric() -> Bric {
        return bric(map: { $0.bric() })
    }
}

public extension BricLayer where Self.BricSub : BricLayer, Self.BricSub.BricSub : Bricable {
    /// Brics through two levels of `BricLayer`
    public func bric() -> Bric {
        return bric(map: { $0.bric(map: { $0.bric() }) })
    }
}

public extension BricLayer where Self.BricSub : BricLayer, Self.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub : Bricable {
    /// Brics through three levels of `BricLayer`
    public func bric() -> Bric {
        return bric(map: { $0.bric(map: { $0.bric(map: { $0.bric() }) }) })
    }
}

public extension BricLayer where Self.BricSub : BricLayer, Self.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub.BricSub : Bricable {
    /// Brics through four levels of `BricLayer`
    public func bric() -> Bric {
        return bric(map: { $0.bric(map: { $0.bric(map: { $0.bric(map: { $0.bric() }) }) }) })
    }
}

public extension BricLayer where Self.BricSub : BricLayer, Self.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub.BricSub.BricSub : Bricable {
    /// Brics through five levels of `BricLayer`
    public func bric() -> Bric {
        return bric(map: { $0.bric(map: { $0.bric(map: { $0.bric(map: { $0.bric(map: { $0.bric() }) }) }) }) })
    }
}


extension WrapperType {
    /// Maps the underlying layer, or `Bric.nul` if it is nil
    public func bric(map f: (Wrapped) -> Bric) -> Bric {
        if let x = flatMap({$0}) {
            return f(x)
        } else {
            return Bric.nul
        }
    }
}

extension Optional : BricLayer {
    public typealias BricSub = Wrapped // inherits bracMap via WrapperType conformance
}

extension Indirect : BricLayer {
    public typealias BricSub = Wrapped // inherits bracMap via WrapperType conformance
}

extension RawRepresentable where RawValue : Bricable {
    public func bric(map f: (RawValue) -> Bric) -> Bric {
        return f(rawValue)
    }
}

extension Sequence {
    /// All sequences bric to a `Bric.arr` array
    public func bric(map f: (Iterator.Element) -> Bric) -> Bric {
        return Bric.arr(map(f))
    }
}

extension Array : BricLayer {
    public typealias BricSub = Iterator.Element // inherits bricMap via SequenceType conformance
}

extension ArraySlice : BricLayer {
    public typealias BricSub = Iterator.Element // inherits bricMap via SequenceType conformance
}

extension ContiguousArray : BricLayer {
    public typealias BricSub = Iterator.Element // inherits bricMap via SequenceType conformance
}

extension Set : BricLayer {
    public typealias BricSub = Iterator.Element // inherits bricMap via SequenceType conformance
}

extension CollectionOfOne : BricLayer {
    public typealias BricSub = Iterator.Element // inherits bricMap via SequenceType conformance
}

extension EmptyCollection : BricLayer {
    public typealias BricSub = Iterator.Element // inherits bricMap via SequenceType conformance
}

//extension NonEmptyCollection : BricLayer {
//    public typealias BricSub = Element // inherits bricMap via SequenceType conformance
//}

extension Dictionary : BricLayer { // TODO: Swift 4: where Key == String
    public typealias BricSub = Value

    /// A Dictionary brics to a `Bric.obj` with stringifed keys
    public func bric(map f: (Value) -> Bric) -> Bric {
        var dict: [String : Bric] = [:]
        for keyValue in self {
            // we manually stringify the keys since we aren't able to enforce string-key conformance via generics
            dict[String(describing: keyValue.0)] = f(keyValue.1)
        }
        return Bric.obj(dict)
    }
}


/// RawRepresentable Bric methods that enable a String enum to automatically bric & brac
public extension RawRepresentable where Self.RawValue == String {
    /// A String `RawRepresentable` brics to a `Bric.str` with the underlying `rawValue`
    public func bric() -> Bric {
        return .str(rawValue)
    }
}


// MARK: Numeric Bric

/// A `BricableDoubleConvertible` is a type that can be converted to a Double for storage in a `Bric.num`
public protocol BricableDoubleConvertible : Bricable {
    var bricNum: Double { get }
}

extension BricableDoubleConvertible {
    /// A number conforming to `BricableDoubleConvertible` brics to a `Bric.num` as a `Double`
    public func bric() -> Bric {
        return .num(bricNum)
    }
}

/// RawRepresentable Bric methods that enable a numeric enum to automatically bric
public extension RawRepresentable where Self.RawValue : BricableDoubleConvertible {
    /// A numeric `RawRepresentabke` brics to a `Bric.num`
    public func bric() -> Bric {
        return .num(rawValue.bricNum)
    }
}

/// BricableDoubleConvertible conformance that enables a Double to automatically bric & brac
extension Double : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables a Float to automatically bric & brac
extension Float : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables an Int to automatically bric & brac
extension Int : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables an Int8 to automatically bric & brac
extension Int8 : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables an Int16 to automatically bric & brac
extension Int16 : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables an Int32 to automatically bric & brac
extension Int32 : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables an Int64 to automatically bric & brac
extension Int64 : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables a UInt to automatically bric & brac
extension UInt : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables a UInt8 to automatically bric & brac
extension UInt8 : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables a UInt16 to automatically bric & brac
extension UInt16 : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables a UInt32 to automatically bric & brac
extension UInt32 : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

/// BricableDoubleConvertible conformance that enables a UInt64 to automatically bric & brac
extension UInt64 : BricableDoubleConvertible {
    public var bricNum: Double { return Double(self) }
}

extension Mirror : Bricable {
    /// A mirror can bric using reflection on all the child structures; note that any reference cycles will cause a stack overflow
    public func bric() -> Bric {
        switch displayStyle {
        case .none:
            return Bric.nul
        case .some(.collection), .some(.set), .some(.tuple):
            var arr: [Bric] = []
            for (_, value) in self.children {
                if let bricable = value as? Bricable {
                    arr.append(bricable.bric())
                } else {
                    arr.append(Mirror(reflecting: value).bric())
                }
            }
            return Bric.arr(arr)
        case .some(.optional):
            assert(self.children.count <= 1)
            if let (_, value) = self.children.first {
                if let bricable = value as? Bricable {
                    return bricable.bric()
                } else {
                    return Mirror(reflecting: value).bric()
                }
            } else {
                return Bric.nul
            }
        case .some(.struct), .some(.class), .some(.enum), .some(.dictionary):
            var dict: [String: Bric] = [:]
            for (label, value) in self.children {
                if let label = label {
                    if let bricable = value as? Bricable {
                        dict[label] = bricable.bric()
                    } else {
                        dict[label] = Mirror(reflecting: value).bric()
                    }
                }
            }
            return .obj(dict)
        }
    }
}
