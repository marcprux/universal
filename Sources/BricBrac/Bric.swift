import JSum
import Bricolage
import JSON

public typealias Bricable = Encodable

extension Bricolage {
    /// Validates the given JSON string and throws an error if there was a problem
    public static func validate(_ string: String, options: JSONParser.Options) throws {
        try JSONParser(options: options).parse(Array(string.unicodeScalars), complete: true)
    }

    /// Validates the given array of JSON unicode scalars and throws an error if there was a problem
    public static func validate(_ scalars: [UnicodeScalar], options: JSONParser.Options) throws {
        try JSONParser(options: options).parse(scalars, complete: true)
    }
}

/// A Bricable is a type that is able to serialize itself to Bric
public extension Bricable {
    /// Returns the Bric'd form of this instance
//    @available(*, deprecated, renamed: "jsum")
    func bric() -> JSum {
        try! self.jsum()
    }
}

extension Bricolagable {
    public func bric() -> JSum { return bricolage() }
}

/// Storage for JSON that is tailored for Swift-fluent access
extension JSum: Bricolage {
    public typealias Storage = JSum

    public typealias NulType = Void
    public typealias BolType = Bool
    public typealias StrType = String
    public typealias NumType = Double
    public typealias ArrType = Array<JSum>
    public typealias ObjType = Dictionary<StrType, JSum>

    public init(nul: NulType) { self = .nul }
    public init(bol: BolType) { self = .bol(bol) }
    public init(str: StrType) { self = .str(str) }
    public init(num: NumType) { self = .num(num) }
    public init(arr: ArrType) { self = .arr(arr) }
    public init(obj: ObjType) { self = .obj(obj) }
    public init(encodable: BricolageEncodable) {
        switch encodable {
        case .null: self = .nul
        case .bool(let x): self = .bol(x)
        case .int(let x): self = .num(Double(x))
        case .int8(let x): self = .num(Double(x))
        case .int16(let x): self = .num(Double(x))
        case .int32(let x): self = .num(Double(x))
        case .int64(let x): self = .num(Double(x))
        case .uint(let x): self = .num(Double(x))
        case .uint8(let x): self = .num(Double(x))
        case .uint16(let x): self = .num(Double(x))
        case .uint32(let x): self = .num(Double(x))
        case .uint64(let x): self = .num(Double(x))
        case .string(let x): self = .str(x)
        case .float(let x): self = .num(Double(x))
        case .double(let x): self = .num(x)
        }
    }

    public static func createNull() -> NulType { }
    public static func createTrue() -> BolType { return true }
    public static func createFalse() -> BolType { return false }
    public static func createObject() -> ObjType { return ObjType() }
    public static func createArray() -> ArrType { return ArrType() }
    public static func createString(_ scalars: [UnicodeScalar]) -> StrType? { return String(scalars: scalars) }
    public static func createNumber(_ scalars: [UnicodeScalar]) -> NumType? { return Double(String(scalars: scalars)) }
    public static func putElement(_ arr: ArrType, element: JSum) -> ArrType { return arr + [element] }
    public static func putKeyValue(_ object: ObjType, key: StrType, value: JSum) -> ObjType {
        var obj = object
        obj[key] = value
        return obj
    }
}


extension String {
    /// Convenience for creating a string from an array of UnicodeScalars
    init(scalars: [UnicodeScalar]) {
        self = String(String.UnicodeScalarView() + scalars) // seems a tiny bit faster
    }
}


/// An Object Bric type that cannot contain anything
@frozen public struct HollowBric : Bricable, Bracable {
    public init() {
    }

    public func bric() -> JSum {
        return [:]
    }

    public static func brac(bric: JSum) throws -> HollowBric {
        return HollowBric()
    }
}

public func ==(lhs: HollowBric, rhs: HollowBric) -> Bool {
    return true
}


//extension OneOf2 : Bricable where T1: Bricable, T2: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric)]()
//    }
//}

extension OneOf2 : Bracable where T1: Bracable, T2: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            ])
    }
}

//extension OneOf3 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric, T3.bric)]()
//    }
//}

extension OneOf3 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            ])
    }
}
//extension OneOf4 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric, T3.bric, T4.bric)]()
//    }
//}

extension OneOf4 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            ])
    }
}

//extension OneOf5 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric, T3.bric, T4.bric, T5.bric)]()
//    }
//}

extension OneOf5 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            ])
    }
}

//extension OneOf6 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric, T3.bric, T4.bric, T5.bric, T6.bric)]()
//    }
//}

extension OneOf6 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            ])
    }
}

//extension OneOf7 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric, T3.bric, T4.bric, T5.bric, T6.bric, T7.bric)]()
//    }
//}

extension OneOf7 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable, T7: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            { try .v7(T7.brac(bric: bric)) },
            ])
    }
}

//extension OneOf8 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric, T3.bric, T4.bric, T5.bric, T6.bric, T7.bric, T8.bric)]()
//    }
//}

extension OneOf8 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable, T7: Bracable, T8: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            { try .v7(T7.brac(bric: bric)) },
            { try .v8(T8.brac(bric: bric)) },
            ])
    }
}

//extension OneOf9 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable, T9: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric, T3.bric, T4.bric, T5.bric, T6.bric, T7.bric, T8.bric, T9.bric)]()
//    }
//}

extension OneOf9 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable, T7: Bracable, T8: Bracable, T9: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            { try .v7(T7.brac(bric: bric)) },
            { try .v8(T8.brac(bric: bric)) },
            { try .v9(T9.brac(bric: bric)) },
            ])
    }
}

//extension OneOf10 : Bricable where T1: Bricable, T2: Bricable, T3: Bricable, T4: Bricable, T5: Bricable, T6: Bricable, T7: Bricable, T8: Bricable, T9: Bricable, T10: Bricable {
//    @inlinable public func bric() -> JSum {
//        self[routing: (T1.bric, T2.bric, T3.bric, T4.bric, T5.bric, T6.bric, T7.bric, T8.bric, T9.bric, T10.bric)]()
//    }
//}

extension OneOf10 : Bracable where T1: Bracable, T2: Bracable, T3: Bracable, T4: Bracable, T5: Bracable, T6: Bracable, T7: Bracable, T8: Bracable, T9: Bracable, T10: Bracable {
    @inlinable public static func brac(bric: JSum) throws -> Self {
        return try bric.brac(oneOf: [
            { try .v1(T1.brac(bric: bric)) },
            { try .v2(T2.brac(bric: bric)) },
            { try .v3(T3.brac(bric: bric)) },
            { try .v4(T4.brac(bric: bric)) },
            { try .v5(T5.brac(bric: bric)) },
            { try .v6(T6.brac(bric: bric)) },
            { try .v7(T7.brac(bric: bric)) },
            { try .v8(T8.brac(bric: bric)) },
            { try .v9(T9.brac(bric: bric)) },
            { try .v10(T10.brac(bric: bric)) },
            ])
    }
}

/// An ISO-8601 date-time structure, the common JSON format for dates and times
/// - See: https://en.wikipedia.org/wiki/ISO_8601
public protocol ISO8601DateTime {
    var year: Int { get set }
    var month: Int { get set }
    var day: Int { get set }
    var hour: Int { get set }
    var minute: Int { get set }
    var second: Double { get set }
    var zone: BricZone { get set }
}


public extension JSum {
    /// Returns the underlying `BricDateTime` for `JSum.str` cases that can be pased with `ISO8601FromString`, else nil
    var dtm: BricDateTime? {
        if let str = self.str {
            return BricDateTime(str)
        } else {
            return nil
        }
    }
}

public struct BricZone : Equatable, Codable, Hashable {
    public let hours: Int
    public let minutes: Int
}

public struct BricDateTime: ISO8601DateTime, Hashable, Equatable, Codable, CustomStringConvertible, Bracable {
    public typealias BricDate = (year: Int, month: Int, day: Int)
    public typealias BricTime = (hour: Int, minute: Int, second: Double)

    public var year, month, day, hour, minute: Int
    public var second: Double
    public var zone: BricZone

    public init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Double, zone: (Int, Int)) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.zone = BricZone(hours: zone.0, minutes: zone.1)
    }

    /// Attempt to parse the given String as an ISO-8601 date-time structure
    public init?(_ str: String) {
        if let dtm = BricDateTime(year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, zone: (0, 0)).parseISO8601String(str) {
            self = dtm
        } else {
            return nil
        }
    }

    public var description: String { return toISO8601String() }

    /// BricDateTime instances are serialized to ISO-8601 strings
    public func bric() -> JSum {
        return JSum.str(toISO8601String())
    }

    /// BricDateTime instances are serialized to ISO-8601 strings
    public static func brac(bric: JSum) throws -> BricDateTime {
        guard case .str(let str) = bric else { return try bric.invalidType() }
        guard let dtm = BricDateTime(str) else { return try bric.invalidRawValue(str) }
        return dtm
    }

}

public extension ISO8601DateTime {

    /// Converts this datetime to a formatted string with the given time separator and designator for UTC (Zulu) time
    func toFormattedString(timesep: String = "T", utctz: String? = "Z", padsec: Int = 3) -> String {
        func pad(_ num: Int, _ len: Int) -> String {
            var str = String(num)
            while str.count < len {
                str = "0" + str
            }
            return str
        }

        /// Secs need to be padded to 2 at the beginning and 3 at the end, e.g.: 00.000
        func sec(_ secs: Double) -> String {
            var str = String(secs)
            let chars = str
            if padsec > 0 {
                if chars.count >= 2 && chars.dropFirst().first == "." { str = "0" + str }
                while str.count < (padsec + 3) { str += "0" }
            }
            return str
        }

        return pad(year, 4) + "-" + pad(month, 2) + "-" + pad(day, 2) + timesep + pad(hour, 2) + ":" + pad(minute, 2) + ":" + sec(second) + ((utctz != nil && zone.hours == 0 && zone.minutes == 0) ? utctz! : ((zone.hours >= 0 ? "+" : "") + pad(zone.hours, 2) + ":" + pad(zone.minutes, 2)))
    }

    /// Returns a string representation in accordance with ISO-8601
    func toISO8601String() -> String {
        return toFormattedString()
    }

    /// Attempt to parse the given String as an ISO-8601 date-time structure
    func parseISO8601String(_ str: String) -> Self? {
        var gen = str.makeIterator()

        func scan(_ skip: Int = 0, _ until: Character...) -> (String, Character?)? {
            var num = 0
            var buf = ""
            while let c = gen.next() {
                if until.contains(c) && num >= skip {
                    if buf.isEmpty { return nil }
                    return (buf, c)
                }
                num += 1
                buf.append(c)
            }
            if buf.isEmpty { return nil }
            return (buf, nil)
        }

        func str2int(_ str: String, _ stop: Character?) -> Int? { return Int(str) }

        guard let year = scan(1, "-").flatMap(str2int) else { return nil }
        guard let month = scan(0, "-").flatMap(str2int) , month >= 1 && month <= 12 else { return nil }
        guard let day = scan(0, "T").flatMap(str2int) , day >= 1 && day <= 31 else { return nil }

        if day == 31 && (month == 4 || month == 6 || month == 9 || month == 11) { return nil }

        // Feb leap year check
        if day > 28 && month == 2 && !((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) { return nil }

        guard let hour = scan(0, ":").flatMap(str2int) , hour >= 0 && hour <= 24 else { return nil }
        guard let minute = scan(0, ":").flatMap(str2int) , minute >= 0 && minute <= 59 else { return nil }

        // “ISO 8601 permits the hyphen (-) to be used as the minus (−) character when the character set is limited.”
        guard let secstop = scan(0, "Z", "+", "-", "−") else { return nil }

        guard let second = Double(secstop.0) , second >= 0.0 && second < 60.0 else { return nil }

        if hour == 24 && (minute > 0 || second > 0.0) { return nil } // 24 is only valid as 24:00:00.0

        let tzc = secstop.1
        var tzh = 0, tzm = 0
        if tzc != "Z" { // non-Zulu time
            guard let h = scan(0, ":").flatMap(str2int) , h >= 0 && h <= 23 else { return nil }
            tzh = h * (tzc == "-" || tzc == "−" ? -1 : +1)

            guard let m = scan(0).flatMap(str2int) , m >= 0 && m <= 59 else { return nil }
            tzm = m
        }

        if gen.next() != nil { return nil } // trailing characters

        // fill in the fields
        var dtm = self
        dtm.year = year
        dtm.month = month
        dtm.day = day
        dtm.hour = hour
        dtm.minute = minute
        dtm.second = second
        dtm.zone = BricZone(hours: tzh, minutes: tzm)
        return dtm
    }
}


//public enum Choose<A, B> : OneOf2Type, Either2Type, OneOfShapable {
//    public typealias T1 = A
//    public typealias T2 = B
//    public typealias TN = B
//    public typealias Swapped = Choose<B, A>
//
//    public typealias OneOfNext = Self // Or<Never>
//
//    case a(A)
//    case b(B)
//
//    public init(t1: A) { self = .a(t1) }
//    public init(_ t1: A) { self = .a(t1) }
//    public init(t2: B) { self = .b(t2) }
//    public init(_ t2: B) { self = .b(t2) }
//
//    public func infer() -> A? {
//        if case .a(let x) = self { return x } else { return nil }
//    }
//
//    public func infer() -> B? {
//        if case .b(let x) = self { return x } else { return nil }
//    }
//
//    public var swapped: Choose<B, A> {
//        fatalError()
//    }
//
//    public func map2<U1, U2>(_ f1: (A) throws -> (U1), _ f2: (B) throws -> (U2)) rethrows -> This<U1>.Or<U2> {
//        switch self {
//        case .a(let a): return .init(try f1(a))
//        case .b(let b): return .init(try f2(b))
//        }
//    }
//
//
////    public enum Or<C> : OneOf2Type, Either2Type, OneOfShapable {
////
////    }
//}

/// An `Identifiable` that is represented by a wrapped identity type that can be generated on-demand.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol Actualizable : Identifiable where ID : WrapperType, ID.Wrapped : RawCodable & Hashable {
    /// The mutable identity
    var id: ID { get set }

    /// Returns this instance with a guaranteed assigned identity
    var actual: (id: ID.Wrapped, instance: Self) { get set }

    /// Returns this instance with an absent identity
    var ideal: Self { get }
}


/// Compare two Actualizables to equivalence without their identifies
infix operator ~==~ : ComparisonPrecedence

/// Compare two Actualizables to equivalence without their identifies
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
@inlinable public func ~==~<T: Actualizable & Equatable>(lhs: T, rhs: T) -> Bool {
    lhs.ideal == rhs.ideal
}


/// A type that can generate a new globally unique instance of itself
public protocol GloballyUnique {
    /// A new unique instance of this type
    static func uiqueValue() -> Self
}

/// A generalization of a unique identifier.
///
/// Implemented in `Foundation.UUID`
public protocol IdentifierString where Self : Hashable {
    /// Returns nil for invalid strings.
    init?(identifierString string: String)

    /// Returns a string created from the identifier
    var identifierString: String { get }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Actualizable {
    /// Clears the ID and re-assigns it to a new globally-uniqued value
    @inlinable public var reactualized: Self {
        ideal.actual.instance
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Actualizable where ID.Wrapped : RawInitializable, ID : ExpressibleByNilLiteral {

    /// Accesses the ideal, identity-less instance; can be used on any `Identifiable` type whose `ID` can be initialized from `nil`
    @inlinable public var ideal: Self {
        get {
            var this = self
            this.id = nil
            return this
        }
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Actualizable where ID.Wrapped : RawInitializable, ID.Wrapped.RawValue : GloballyUnique {
    /// Assigns an ID to the element if one was not already assigned, returning any newly assigned ID.
    @discardableResult @inlinable public mutating func actualize(with id: () -> ID.Wrapped.RawValue = ID.Wrapped.RawValue.uiqueValue) -> ID.Wrapped {
        if let existingID = self.id.flatMap({ a in a }) { // already has an ID
            return existingID
        } else {
            let newID = ID.Wrapped(rawValue: id())
            self.id = ID(newID)
            return newID
        }
    }

    /// Accesses the guaranteed actualized (i.e., assigned id) instance
    @inlinable public var actual: (id: ID.Wrapped, instance: Self) {
        get {
            var this = self
            let id = this.actualize()
            return (id, this)
        }

        set {
            var (id, instance) = newValue
            instance.id = .init(id)
            self = instance
        }
    }
}

/// An `IdMap` enables dictionaries keyed by non-String/Int values to be encoded & decoded via JSON Objects (rather than the default behavior of encoding to an array of alternating keys & values)
///
/// - SeeAlso: `KeyMap`
@propertyWrapper public struct IdMap<Key: RawRepresentable & Codable & Hashable, Value: Codable> : Codable where Key.RawValue : IdentifierString & Codable {
    public var wrappedValue: [Key: Value]

    public init() {
        wrappedValue = [:]
    }

    public init(wrappedValue: [Key: Value]) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawKeyedDictionary = try container.decode([String: Value].self)

        var map: [Key: Value] = [:]
        for (rawKey, value) in rawKeyedDictionary {
            guard let uuid = Key.RawValue(identifierString: rawKey),
                  let key = Key(rawValue: uuid) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "cannot create key '\(Key.self)' from invalid '\(Key.RawValue.self)' value '\(rawKey)'")
            }
            map[key] = value
        }

        self.wrappedValue = map
    }

    public func encode(to encoder: Encoder) throws {
        let rawKeyedDictionary: [String: Value] = Dictionary(uniqueKeysWithValues: wrappedValue.map { ($0.rawValue.identifierString, $1) })
        var container = encoder.singleValueContainer()
        try container.encode(rawKeyedDictionary)
    }
}

extension IdMap : Equatable where Value : Equatable { }
extension IdMap : Hashable where Value : Hashable { }

/// A `KeyMap` enables dictionaries keyed by non-String/Int values to be encoded & decoded via JSON Objects (rather than the default behavior of encoding to an array of alternating keys & values)
///
/// Inspired by the sample from: https://fivestars.blog/swift/codable-swift-dictionaries.html
///
/// - SeeAlso: `IdMap`
@propertyWrapper public struct KeyMap<Key: Hashable & RawRepresentable, Value: Codable>: Codable where Key.RawValue == String {
    public var wrappedValue: [Key: Value]

    public init() {
        wrappedValue = [:]
    }

    public init(wrappedValue: [Key: Value]) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawKeyedDictionary = try container.decode([String: Value].self)

        var map: [Key: Value] = [:]
        for (rawKey, value) in rawKeyedDictionary {
            guard let key = Key(rawValue: rawKey) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "cannot create key '\(Key.self)' from invalid '\(Key.RawValue.self)' value '\(rawKey)'")
            }
            map[key] = value
        }

        self.wrappedValue = map
    }

    public func encode(to encoder: Encoder) throws {
        let rawKeyedDictionary = Dictionary(uniqueKeysWithValues: wrappedValue.map { ($0.rawValue, $1) })
        var container = encoder.singleValueContainer()
        try container.encode(rawKeyedDictionary)
    }
}

extension KeyMap : Equatable where Value : Equatable { }
extension KeyMap : Hashable where Value : Hashable { }

