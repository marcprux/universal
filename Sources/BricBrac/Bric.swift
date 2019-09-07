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
    @inlinable public var str: String? {
        get { if case .str(let x) = self { return x } else { return nil } }
        set { self = newValue.flatMap(Bric.str) ?? .nul }
    }

    /// Returns the underlying `Double` for `Bric.num` cases, else nil
    @inlinable public var num: Double? {
        get { if case .num(let x) = self { return x } else { return nil } }
        set { self = newValue.flatMap(Bric.num) ?? .nul }
    }

    /// Returns the underlying `Bool` for `Bric.bol` cases, else nil
    @inlinable public var bol: Bool? {
        get { if case .bol(let x) = self { return x } else { return nil } }
        set { self = newValue.flatMap(Bric.bol) ?? .nul }
    }

    /// Returns the underlying `Void` for `Bric.nul` cases, else nil
    @inlinable public var nul: Void? {
        get { if case .nul = self { return Void() } else { return nil } }
        set { self = .nul }
    }

    /// Returns the underlying `Array<Bric>` for `Bric.arr` cases, else nil
    @inlinable public var arr: [Bric]? {
        get { if case .arr(let x) = self { return x.map({ $0 as Bric }) } else { return nil } }
        set { self = newValue.flatMap(Bric.arr) ?? .nul }
    }

    /// Returns the underlying `Dictionary<String,Bric>` for `Bric.obj` cases, else nil
    @inlinable public var obj: [String : Bric]? {
        get { if case .obj(let x) = self { return x } else { return nil } }
        set { self = newValue.flatMap(Bric.obj) ?? .nul }
    }

}

extension Bric : Equatable { }
extension Bric : Hashable { }

extension Bric {
    /// The count of Bric is either the number of properties (for an object), number of elements (for an array), 0 for null, or 1 for string & number
    @inlinable public var count: Int {
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
    
    func assign(bric: Bric) -> Bric {
        return merge(bric: bric, depth: 1)
    }

    /// Performs a deep merge of all the object & array elements of the given Bric
    
    func merge(bric: Bric, depth: Int = Int.max) -> Bric {
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
    subscript(index: Int)->Bric? {
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
}

extension Bric : ExpressibleByDictionaryLiteral {
    /// Creates a dictonary of some Bric
    public init(dictionaryLiteral elements: (String, Bric)...) {
        var d: Dictionary<String, Bric> = [:]
        for (k, v) in elements { d[k] = v }
        self = .obj(d)
    }


    /// Creates a Bric.obj with the given key/value pairs
    public init(object: [(String, Bric)]) {
        var d: Dictionary<String, Bric> = [:]
        for (k, v) in object {
            if !k.rawValue.isEmpty {
                switch (k, v) {
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

extension WrapperType where Wrapped : Bricable {
    /// Maps the underlying layer, or `Bric.nul` if it is nil
    public func bric() -> Bric {
        if let x = flatMap({$0}) {
            return x.bric()
        } else {
            return Bric.nul
        }
    }
}

// this works, but it introduces a lot of ambiguous conflicts with WrapperType where Wrapped : Bricable
//extension WrapperType where Wrapped : RawRepresentable, Wrapped.RawValue : Bricable {
//    /// Maps the underlying layer, or `Bric.nul` if it is nil
//    public func bric() -> Bric {
//        if let x = flatMap({$0}) {
//            return x.bric()
//        } else {
//            return Bric.nul
//        }
//    }
//}

extension Optional : Bricable where Wrapped : Bricable {
}

extension RawRepresentable where RawValue : Bricable {
    public func bric() -> Bric {
        return rawValue.bric()
    }
}

extension Sequence where Element : Bricable {
    /// All sequences bric to a `Bric.arr` array
    public func bric() -> Bric {
        return Bric.arr(map({ $0.bric() }))
    }
}

extension Array : Bricable where Element : Bricable {
}

extension ArraySlice : Bricable where Element : Bricable {
}

extension ContiguousArray : Bricable where Element : Bricable {
}

extension Set : Bricable where Element : Bricable {
}

extension CollectionOfOne : Bricable where Element : Bricable {
}

extension EmptyCollection : Bricable where Element : Bricable {
}

extension Dictionary : Bricable where Key == String, Value : Bricable { // TODO: Swift 4: where Key == String
    /// A Dictionary brics to a `Bric.obj` with stringifed keys
    public func bric() -> Bric {
        var dict: [String : Bric] = [:]
        for keyValue in self {
            // we manually stringify the keys since we aren't able to enforce string-key conformance via generics
            dict[String(describing: keyValue.0)] = keyValue.1.bric()
        }
        return Bric.obj(dict)
    }
}


/// RawRepresentable Bric methods that enable a String enum to automatically bric & brac
public extension RawRepresentable where Self.RawValue == String {
    /// A String `RawRepresentable` brics to a `Bric.str` with the underlying `rawValue`
    func bric() -> Bric {
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
    func bric() -> Bric {
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
        @unknown default:
            return Bric.nul
        }
    }
}


#if swift(>=5.1)

/// A vaguely-defined type that can hold some concrete properties as well as
/// an underlying `Bric` that is used to store `@dynamicMemberLookup` properties.
@dynamicMemberLookup public protocol Vague : Hashable, Codable {
    /// The container for the underlying unstructured items.
    var bric: Bric { get set }
    /// The property type for unstructured items
    associatedtype Property : VagueProperty = Stuff
    subscript(dynamicMember member: String) -> Property { get set }
}

public protocol VagueProperty : Vague {
    init(initialValue value: Bric)
}

public extension Vague {
    /// Dyanmic lookup for members, which will be resolved to an empty object if not found.
    subscript(dynamicMember member: String) -> Property {
        get { return Property(initialValue: bric[member] ?? .obj([:])) }
        set { bric[member] = newValue.bric }
    }
}

/// Vaguely wraps a concrete value and merges its properties with a vague `Stuff`,
/// enabling semi-structured properties.
@propertyWrapper public struct Vaguely<T: Codable> : Codable {
    public var wrappedValue: T
    public var vague: Stuff = nil

    public init(wrappedValue value: T) {
        self.wrappedValue = value
    }

    /// Decodability passed through to the underlying `Bric.init(from:)`
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try T(from: decoder)
        self.vague = try Stuff(from: decoder) // TODO: eliminate keys from value
    }

    /// Encodability passed through to the underlying `Bric.encode(to:)`
    public func encode(to encoder: Encoder) throws {
        try vague.encode(to: encoder)
        try wrappedValue.encode(to: encoder)
    }
}

extension Vaguely : Equatable where T : Equatable {
}

extension Vaguely : Hashable where T : Hashable {
}


/// A wrapper for a piece of `Bric` that dynamically looks up its value. Members default to an
/// empty `.obj`, which enables the dynamic creation of nested `Bric` objects like so:
///
/// ```
/// var ob: Stuff = nil // Bric.nul
/// ob.x.y.z = 1.234 // ["x": ["y": ["z": 1.2234]]]
/// ```
public struct Stuff : VagueProperty, ExpressibleByNilLiteral, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    public typealias Property = Stuff
    public var bric: Bric

    /// Array accessor; unlike `dynamicMember`, accessing specific indices is not a guarded operation,
    /// and so accessing out of bounds values will crash.
    public subscript(index: Int) -> Stuff {
        get { return Stuff(initialValue: bric.arr?[index] ?? .obj([:])) }
        set { bric.arr?[index] = newValue.bric }
    }

    public init(initialValue value: Bric) {
        self.bric = value
    }

    public init(nilLiteral: ()) {
        self.bric = .nul
    }

    public init(floatLiteral value: Double) {
        self.bric = .init(floatLiteral: value)
    }

    public init(stringLiteral value: String) {
        self.bric = .init(stringLiteral: value)
    }

    public init(booleanLiteral value: Bool) {
        self.bric = .init(booleanLiteral: value)
    }

    public init(integerLiteral value: Int) {
        self.bric = .init(integerLiteral: value)
    }

    public init(arrayLiteral elements: Bric...) {
        self.bric = .arr(elements)
    }

    public init(dictionaryLiteral elements: (String, Bric)...) {
        self.bric = .init(object: elements)
    }

    public subscript(coercing to: String) -> String {
        get { fatalError() }
        set { fatalError() }
    }

}

extension Stuff : Codable {
    /// Decodability passed through to the underlying `Bric.init(from:)`
    public init(from decoder: Decoder) throws {
        self.bric = try Bric(from: decoder)
    }

    /// Encodability passed through to the underlying `Bric.encode(to:)`
    public func encode(to encoder: Encoder) throws {
        if bric != nil {
            try bric.encode(to: encoder)
        }
    }
}

/// A type that is codable using its contained `CodingKeys` type.
public protocol KeyedCodable : Codable {
    associatedtype CodingKeyPaths

    /// Tuple containing all the `WritableKeyPath`s for the type.
    static var codingKeyPaths: CodingKeyPaths { get }

    /// The keys that will be associated with this type
    associatedtype CodingKeys : CodingKey & Hashable
}

public extension KeyedCodable where CodingKeys : RawRepresentable, CodingKeys.RawValue == String {
    /// Swaps the values of two separate coding keys. This can be used, for example, to re-assign two different types that are serialization-compatible but not type-compatible.
    /// - Parameter keys: the two keys to swap
    mutating func swapBricValues(keys: (CodingKeys, CodingKeys)) throws {
        var bric = try self.bricEncoded()
        let v0 = bric[keys.0.rawValue]
        let v1 = bric[keys.1.rawValue]
        bric[keys.0.rawValue] = v1
        bric[keys.1.rawValue] = v0
        self = try bric.decode(Self.self)
    }
}

public protocol FixedCodingKeys : CaseIterable, CodingKey {

}

public extension FixedCodingKeys where Self : RawRepresentable, Self.RawValue == String {
    func decode<T: Codable>(_ decoder: KeyedDecodingContainer<Self>) throws -> T {
        return try decoder.decode(T.self, forKey: self)
    }

    func decode<T: Codable>(_ decoder: KeyedDecodingContainer<Self>, defaultValue: T) throws -> T {
        return try decoder.decodeIfPresent(T.self, forKey: self) ?? defaultValue
    }

    /// Clear out all fixed properties from the given dynamic `Bric`
    static func purgeKeys(from rawBric: Bric) -> Bric {
        var bric = rawBric
        for key in Self.allCases { bric[key.rawValue] = nil }
        return bric
    }
}



#endif
