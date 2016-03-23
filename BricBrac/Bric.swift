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

/// A Bric is a bit of JSON encoded as an enumeration; it can represent a `Bool` (`Bric.Bol`),
/// `String` (`Bric.Str`), `Double` (`Bric.Num`), `Array` (`Bric.Arr`), `Dictionary` (`Bric.Obj`),
/// or `nil` (`Bric.Nul`)
public enum Bric {
    case Arr([Bric]) // Array
    case Obj([String: Bric]) // Dictionary
    case Str(String) // String
    case Num(Double) // Number
    case Bol(Bool) // Boolean
    case Nul // Null
}

extension Bric {
    /// Returns the underlying `String` for `Bric.Str` cases, else nil
    public var str: String? { if case .Str(let x) = self { return x } else { return nil } }
    /// Returns the underlying `Double` for `Bric.Num` cases, else nil
    public var num: Double? { if case .Num(let x) = self { return x } else { return nil } }
    /// Returns the underlying `Bool` for `Bric.Bol` cases, else nil
    public var bol: Bool? { if case .Bol(let x) = self { return x } else { return nil } }
    /// Returns the underlying `Void` for `Bric.Nul` cases, else nil
    public var nul: Void? { if case .Nul = self { return Void() } else { return nil } }
    /// Returns the underlying `Array<Bric>` for `Bric.Arr` cases, else nil
    public var arr: [Bric]? { if case .Arr(let x) = self { return x.map({ $0 as Bric }) } else { return nil } }
    /// Returns the underlying `Dictionary<String,Bric>` for `Bric.Obj` cases, else nil
    public var obj: [String : Bric]? { if case .Obj(let x) = self { return x } else { return nil } }
}

extension Bric : Equatable { }

/// Two Brics are the same when they represent the same type and have the same contents
public func ==(lhs: Bric, rhs: Bric) -> Bool {
    switch (lhs, rhs) {
    case let (.Arr(arr1), .Arr(arr2)): return arr1 == arr2
    case let (.Obj(obj1), .Obj(obj2)): return obj1 == obj2
    case let (.Str(str1), .Str(str2)): return str1 == str2
    case let (.Num(num1), .Num(num2)): return num1 == num2
    case let (.Bol(bol1), .Bol(bol2)): return bol1 == bol2
    case (.Nul, .Nul): return true
    default: return false
    }
}

extension Bric : Hashable {
    public var hashValue: Int {
        switch self {
        case .Arr(let a): return a.reduce(0, combine: { sum, bric in Int.multiplyWithOverflow(37, Int.addWithOverflow(sum, bric.hashValue).0).0 })
        case .Obj(let o): return o.reduce(0, combine: { sum, keyValue in Int.multiplyWithOverflow(37, Int.addWithOverflow(Int.addWithOverflow(sum, keyValue.0.hashValue).0, keyValue.1.hashValue).0).0 })
        case .Str(let s): return s.hashValue
        case .Num(let d): return d.hashValue
        case .Bol(let b): return b.hashValue
        case .Nul: return 0
        }
    }
}

extension Bric {
    /// The count of Bric is either the number of properties (for an object), number of elements (for an array), 0 for null, or 1 for string & number
    public var count: Int {
        switch self {
        case .Obj(let ob): return ob.count
        case .Arr(let arr): return arr.count
        case .Nul: return 0
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
    public mutating func appendContentsOf(bric: Bric) {
        switch (self, bric) {
        case (.Obj(var obj1), .Obj(let obj2)):
            for (k, v) in obj2 { obj1[k] = v }
            self = .Obj(obj1)
        case (.Arr(let arr1), .Arr(let arr2)):
            self = .Arr(arr1 + arr2)
        case (.Arr(let arr1), _):
            self = .Arr(arr1 + [bric])
        case (_, .Arr(let arr2)):
            self = .Arr([self] + arr2)
        default:
            self = .Arr([self, bric])
        }
    }
}

public extension Bric {
    /// Copy the values of all enumerable own properties from one or more source objects to a target object,
    /// returning the union of the objects
    ///
    /// - See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign
    @warn_unused_result
    public func assign(bric: Bric) -> Bric {
        return merge(bric, depth: 1)
    }

    /// Performs a deep merge of all the object & array elements of the given Bric
    @warn_unused_result
    public func merge(bric: Bric, depth: Int = Int.max) -> Bric {
        if depth <= 0 { return self }

        if case .Arr(var a1) = self, case .Arr(let a2) = bric {
            for (i, (e1, e2)) in zip(a1, a2).enumerate() {
                a1[i] = e1.merge(e2, depth: depth - 1)
            }
            return .Arr(a1)
        }

        guard case .Obj(var dest) = self, case .Obj(let src) = bric else { return self }
        for (srckey, srcval) in src {
            if let destval = dest[srckey] {
                dest[srckey] = destval.merge(srcval, depth: depth - 1)
            } else {
                dest[srckey] = srcval
            }
        }
        return .Obj(dest)
    }
}


/// Object keyed subscription helpers for fluent dictionary-like access to Bric
public extension Bric {

    /// Bric has a string subscript when it is an object type
    public subscript(key: String)->Bric? {
        get { return try? bracKey(key) }

        set {
            switch self {
            case .Obj(var ob): ob[key] = newValue; self = .Obj(ob)
            default: break
            }
        }
    }
}

/// Array indexed subscription helpers for fluent dictionary-like access to Bric
public extension Bric {

    /// Bric has an int subscript when it is an array type; safe indexing is used
    public subscript(index: Int)->Bric? {
        get {
            switch self {
            case .Arr(let arr):
                return index < 0 || index >= arr.count ? .None : arr[index]
            default:
                return .None
            }
        }

        set {
            switch self {
            case .Arr(var arr):
                if index < 0 || index >= arr.count {
                    return
                }
                arr[index] = newValue ?? .Nul
                self = .Arr(arr)
            default:
                break
            }
        }
    }
}

extension Bric : NilLiteralConvertible {
    /// Creates some null Bric
    public init(nilLiteral: ()) {
        self = .Nul
    }
}

extension Bric : BooleanLiteralConvertible {
    /// Creates some boolean Bric
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .Bol(value)
    }
}

extension Bric : FloatLiteralConvertible {
    /// Creates some numeric Bric
    public init(floatLiteral value: FloatLiteralType) {
        self = .Num(value)
    }
}

extension Bric : IntegerLiteralConvertible {
    /// Creates some numeric Bric
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Num(Double(value))
    }
}

extension Bric : ArrayLiteralConvertible {
    /// Creates an array of Bric
    public init(arrayLiteral elements: Bric...) {
        self = .Arr(elements)
    }
}

extension Bric : StringLiteralConvertible {
    /// Creates some String Bric
    public init(stringLiteral value: String) {
        self = .Str(value)
    }

    /// Creates some String Bric
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .Str(value)
    }

    /// Creates some String Bric
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .Str(value)
    }
}

extension Bric : DictionaryLiteralConvertible {
    /// Creates a dictonary of some Bric
    public init(dictionaryLiteral elements: (String, Bric)...) {
        var d: Dictionary<String, Bric> = [:]
        for (k, v) in elements { d[k] = v }
        self = .Obj(d)
    }


    /// Creates a Bric.Obj with the given key/value pairs
    public init<R: RawRepresentable where R.RawValue == String>(object: [(R, Bric)]) {
        var d: Dictionary<String, Bric> = [:]
        for (k, v) in object {
            if !k.rawValue.isEmpty {
                switch (k.rawValue, v) {
                case (_, .Nul):
                    break // nil doens't get saved
                case (let key, _):
                    d[key] = v
                }
            } else {
                // empty key name: merge the Bric dictionary into the given dictionary
                if case .Obj(let sub) = v {
                    for (subk, subv) in sub {
                        d[subk] = subv
                    }
                }
            }
        }
        self = .Obj(d)
    }

    /// Creates a Bric.Obj with the given dictionary where the key is a String RawRepresentable
    public init<R: RawRepresentable where R.RawValue == String>(obj: [R: Bric]) {
        self.init(object: Array(obj))
    }

    /// Creates a Bric.Obj by merging any sub-objects into a single Bric Object
    public init(merge: [Bric]) {
        var d: Dictionary<String, Bric> = [:]
        for b in merge { // .reverse() { // reverse because initial elements take precedence
            if case .Obj(let dict) = b {
                for (key, value) in dict {
                    if let oldValue = d[key] where oldValue != value {
                        print("warning: overwriting dictionary key «\(key)» value «\(oldValue)» with «\(value)»")
                    }
                    d[key] = value
                }
            }
        }
        self = .Obj(d)
    }

    /// Returns a Bric Obj with the specified keys removed
    public func disjoint(keys: [String]) -> Bric {
        if case .Obj(var dict) = self {
            for key in keys {
                dict.removeValueForKey(key)
            }
            return .Obj(dict)
        } else {
            return self
        }
    }
}

extension Bric {
    public init<R: RawRepresentable where R.RawValue == String>(_ elements: [R: Bric]) {
        var d: Dictionary<String, Bric> = [:]
        for (k, v) in elements { d[k.rawValue] = v }
        self = .Obj(d)
    }
}

extension Bric {
    /// Construct a `Bric.Num` from any supported numeric type
    public init(_ num: BricableDoubleConvertible) {
        self = .Num(num.bricNum)
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
    /// A String brics to a `Bric.Str`
    public func bric() -> Bric { return .Str(self) }
}

extension Bool: Bricable {
    /// A Bool brics to a `Bric.Bol`
    public func bric() -> Bric { return .Bol(self) }
}


// MARK: BricLayer wrapper Bric

/// A `BricLayer` acts as a wrapper around some eventually bricable instance by using the `bricMap` function.
/// `BricLayer`s are composable, meaning that a `BricLayer` can be nested up to five layers deep the the underlying
/// data will be wrapped accordingly.
public protocol BricLayer {
    /// The type that is being wrapped by this layer
    associatedtype BricSub

    /// Construct an instance of self by invoking the function on the given bric
    func bricMap(f: BricSub -> Bric) -> Bric
}

public extension BricLayer where Self.BricSub : Bricable {
    /// Brics through one level of `BricLayer`
    public func bric() -> Bric {
        return bricMap { $0.bric() }
    }
}

public extension BricLayer where Self.BricSub : BricLayer, Self.BricSub.BricSub : Bricable {
    /// Brics through two levels of `BricLayer`
    public func bric() -> Bric {
        return bricMap { $0.bricMap { $0.bric() } }
    }
}

public extension BricLayer where Self.BricSub : BricLayer, Self.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub : Bricable {
    /// Brics through three levels of `BricLayer`
    public func bric() -> Bric {
        return bricMap { $0.bricMap { $0.bricMap { $0.bric() } } }
    }
}

public extension BricLayer where Self.BricSub : BricLayer, Self.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub.BricSub : Bricable {
    /// Brics through four levels of `BricLayer`
    public func bric() -> Bric {
        return bricMap { $0.bricMap { $0.bricMap { $0.bricMap { $0.bric() } } } }
    }
}

public extension BricLayer where Self.BricSub : BricLayer, Self.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub.BricSub : BricLayer, Self.BricSub.BricSub.BricSub.BricSub.BricSub : Bricable {
    /// Brics through five levels of `BricLayer`
    public func bric() -> Bric {
        return bricMap { $0.bricMap { $0.bricMap { $0.bricMap { $0.bricMap { $0.bric() } } } } }
    }
}


extension WrapperType {
    /// Maps the underlying layer, or `Bric.Nul` if it is nil
    public func bricMap(f: Wrapped -> Bric) -> Bric {
        if let x = flatMap({$0}) {
            return f(x)
        } else {
            return Bric.Nul
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
    public func bricMap(f: RawValue -> Bric) -> Bric {
        return f(rawValue)
    }
}

extension SequenceType {
    /// All sequences bric to a `Bric.Arr` array
    public func bricMap(f: Generator.Element -> Bric) -> Bric {
        return Bric.Arr(map(f))
    }
}

extension Array : BricLayer {
    public typealias BricSub = Generator.Element // inherits bricMap via SequenceType conformance
}

extension ArraySlice : BricLayer {
    public typealias BricSub = Generator.Element // inherits bricMap via SequenceType conformance
}

extension ContiguousArray : BricLayer {
    public typealias BricSub = Generator.Element // inherits bricMap via SequenceType conformance
}

extension Set : BricLayer {
    public typealias BricSub = Generator.Element // inherits bricMap via SequenceType conformance
}

extension CollectionOfOne : BricLayer {
    public typealias BricSub = Generator.Element // inherits bricMap via SequenceType conformance
}

extension EmptyCollection : BricLayer {
    public typealias BricSub = Generator.Element // inherits bricMap via SequenceType conformance
}

extension NonEmptyCollection : BricLayer {
    public typealias BricSub = Element // inherits bricMap via SequenceType conformance
}

extension Dictionary : BricLayer { // TODO: Swift 3: where Key == String
    public typealias BricSub = Value

    /// A Dictionary brics to a `Bric.Obj` with stringifed keys
    public func bricMap(f: Value -> Bric) -> Bric {
        var dict: [String : Bric] = [:]
        for keyValue in self {
            // we manually stringify the keys since we aren't able to enforce string-key conformance via generics
            dict[String(keyValue.0)] = f(keyValue.1)
        }
        return Bric.Obj(dict)
    }
}


/// RawRepresentable Bric methods that enable a String enum to automatically bric & brac
public extension RawRepresentable where Self.RawValue == String {
    /// A String `RawRepresentable` brics to a `Bric.Str` with the underlying `rawValue`
    public func bric() -> Bric {
        return .Str(rawValue)
    }
}


// MARK: Numeric Bric

/// A `BricableDoubleConvertible` is a type that can be converted to a Double for storage in a `Bric.Num`
public protocol BricableDoubleConvertible : Bricable {
    var bricNum: Double { get }
}

extension BricableDoubleConvertible {
    /// A number conforming to `BricableDoubleConvertible` brics to a `Bric.Num` as a `Double`
    public func bric() -> Bric {
        return .Num(bricNum)
    }
}

/// RawRepresentable Bric methods that enable a numeric enum to automatically bric
public extension RawRepresentable where Self.RawValue : BricableDoubleConvertible {
    /// A numeric `RawRepresentabke` brics to a `Bric.Num`
    public func bric() -> Bric {
        return .Num(rawValue.bricNum)
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
        case .None:
            return Bric.Nul
        case .Some(.Collection), .Some(.Set), .Some(.Tuple):
            var arr: [Bric] = []
            for (_, value) in self.children {
                if let bricable = value as? Bricable {
                    arr.append(bricable.bric())
                } else {
                    arr.append(Mirror(reflecting: value).bric())
                }
            }
            return Bric.Arr(arr)
        case .Some(.Optional):
            assert(self.children.count <= 1)
            if let (_, value) = self.children.first {
                if let bricable = value as? Bricable {
                    return bricable.bric()
                } else {
                    return Mirror(reflecting: value).bric()
                }
            } else {
                return Bric.Nul
            }
        case .Some(.Struct), .Some(.Class), .Some(.Enum), .Some(.Dictionary):
            var bric: Bric = [:]
            for (label, value) in self.children {
                if let label = label {
                    if let bricable = value as? Bricable {
                        bric[label] = bricable.bric()
                    } else {
                        bric[label] = Mirror(reflecting: value).bric()
                    }
                }
            }
            return bric
        }
    }
}
