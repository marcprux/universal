//
//  Structures.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 11/4/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

// General data structes need for `Brac` and `Curio` schema support

public extension Bric {
    /// Returns the underlying `BricDateTime` for `Bric.str` cases that can be pased with `ISO8601FromString`, else nil
    public var dtm: BricDateTime? {
        if let str = self.str {
            return BricDateTime(str)
        } else {
            return nil
        }
    }
}

/// A WrapperType is able to map itself through a wrapped optional
public protocol WrapperType {
    associatedtype Wrapped
    init(_ some: Wrapped)
    func flatMap<U>(@noescape f: (Wrapped) throws -> U?) rethrows -> U?
}

/// Wrappable can contain zero or one instances (covers both `Optional` and `Indirect`)
public protocol Wrappable : NilLiteralConvertible {
    associatedtype Wrapped
    init(_ some: Wrapped)
}


extension Optional : WrapperType { }
extension Optional : Wrappable { }

/// Behaves exactly the same a an Optional except the .Some case is indirect, allowing for recursive value types
public enum Indirect<Wrapped> : WrapperType, Wrappable, NilLiteralConvertible {
    case None
    indirect case Some(Wrapped)

    /// Construct a `nil` instance.
    public init() {
        self = .None
    }

    /// Create an instance initialized with `nil`.
    public init(nilLiteral: ()) {
        self = .None
    }

    /// Construct a non-`nil` instance that stores `some`.
    public init(_ some: Wrapped) {
        self = .Some(some)
    }

    public init(fromOptional opt: Wrapped?) {
        switch opt {
        case .Some(let x): self = .Some(x)
        case .None: self = .None
        }
    }

    public var value: Wrapped? {
        get {
            switch self {
            case .None: return nil
            case .Some(let v): return v
            }
        }

        set {
            if let v = newValue {
                self = .Some(v)
            } else {
                self = .None
            }
        }
    }

    /// If `self == nil`, returns `nil`.  Otherwise, returns `f(self!)`.
    @warn_unused_result
    public func map<U>(@noescape f: (Wrapped) throws -> U) rethrows -> U? {
        return try value.map(f)

    }


    /// Returns `nil` if `self` is nil, `f(self!)` otherwise.
    @warn_unused_result
    public func flatMap<U>(@noescape f: (Wrapped) throws -> U?) rethrows -> U? {
        return try value.flatMap(f)
    }
}

/// An Object Bric type that cannot contain anything
public struct HollowBric : Bricable, Bracable, Breqable {
    public init() {
    }

    public func bric() -> Bric {
        return [:]
    }

    public static func brac(bric: Bric) throws -> HollowBric {
        return HollowBric()
    }

    public func breq(other: HollowBric) -> Bool {
        return true
    }
}

/// A collection that must always have at least one element; the opposite of `EmptyCollection`
public struct NonEmptyCollection<Element, Tail: RangeReplaceableCollectionType where Tail.Generator.Element == Element, Tail.Index == Int> : RangeReplaceableCollectionType {
    /// A type that represents a valid position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript.
    public typealias Index = Int

    public var head: Element
    public var tail: Tail

    /// last will always succeed, since we are guaranteed to have access to head
    public var last: Element {
        return tail.last ?? head
    }

    /// - Postcondition: `count >= 1`
    public var count: Int { return tail.count + 1 }

    /// Always returns `false`, since this collection can never be empty.
    public var isEmpty: Bool { return false }

    /// Always zero
    public let startIndex = 0

    public var endIndex: Index { return tail.endIndex + 1 }

    public init(_ head: Element, tail: Tail = Tail()) {
        self.head = head
        self.tail = tail
    }

    /// A requirement of `RangeReplaceableCollectionType`, but will always fail because a head element is required
    /// Use `init(head, tail)` instead
    public init() {
        // wrapped in a function, or else we get the compiler warning "Will never be executed"
        func makeHead() -> Element {
            preconditionFailure("NonEmptyCollection must be initialized with at least one element")
        }
        head = makeHead()
        tail = Tail()
    }

    /// Removes all elements from the tail
    public mutating func removeAll() {
        removeAll(keepCapacity: false)
    }

    /// Drops the head element, returning just the tail
    public func dropFirst() -> Tail {
        return tail // simply return the underlying tail array
    }

    /// Remove the element at `startIndex` and return it.
    ///
    /// - Complexity: O(`self.count-1`)
    /// - Requires: `self.count > 0`.
    public mutating func removeFirst() -> Element {
        let first = head
        head = tail.removeFirst()
        return first
    }

    /// Removes all elements from the tail
    ///
    /// - Postcondition: `capacity == 0` iff `keepCapacity` is `false`.
    ///
    /// - Complexity: O(`self.count-1`).
    public mutating func removeAll(keepCapacity keepCapacity: Bool) {
        tail.removeAll(keepCapacity: keepCapacity)
    }

    public mutating func reserveCapacity(minimumCapacity: Int) {
        tail.reserveCapacity(minimumCapacity)
    }

    public subscript(position: Int) -> Element {
        get {
            return position == 0 ? head : tail[position-1]
        }

        set {
            if position == 0 {
                head = newValue
            } else {
                tail.replaceRange(position-1..<position, with: CollectionOfOne(newValue))
            }
        }
    }

    public mutating func replaceRange<C : CollectionType where C.Generator.Element == Element>(subRange: Range<Int>, with newElements: C) {
        if subRange.startIndex > 0 {
            tail.replaceRange(subRange.startIndex-1..<subRange.endIndex-1, with: newElements)
        } else {
            // the range includes the head: temporarily move the head into the tail, perform replacement, then move back
            tail.insert(head, atIndex: 0)
            tail.replaceRange(subRange, with: newElements)
            head = tail.removeFirst()
        }
    }
}

// Swift 3 TODO: Variadic Generics: https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#variadic-generics

public protocol OneOf: BricBrac {
    associatedtype T

    /// Returns a tuple of the possible value types for this OneOf
    var values: T { get }
}


/// A simple union type that can be one of either T1 or T2
public enum OneOf2<T1, T2 where T1: Bricable, T1: Bracable, T1: Breqable, T2: Bricable, T2: Bracable, T2: Breqable> : OneOf {
    case v1(T1), v2(T2)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?) { return (extract(), extract()) }

    public func extract() -> T1? {
        if case .v1(let v1) = self {
            return v1
        } else {
            return nil
        }
    }

    public func extract() -> T2? {
        if case .v2(let v2) = self {
            return v2
        } else {
            return nil
        }
    }

    public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        }
    }

    public static func brac(bric: Bric) throws -> OneOf2 {
        return try bric.bracOne([
            { try .v1(T1.brac(bric)) },
            { try .v2(T2.brac(bric)) }
            ])
    }

    public func breq(other: OneOf2) -> Bool {
        switch (self, other) {
        case (.v1(let v1l), .v1(let v1r)): return v1l.breq(v1r)
        case (.v2(let v2l), .v2(let v2r)): return v2l.breq(v2r)
        case (.v1, .v2), (.v2, .v1): return false
        }
    }
}



/// A simple union type that can be one of either T1 or T2 or T3
public enum OneOf3<T1, T2, T3 where T1: Bricable, T1: Bracable, T1: Breqable, T2: Bricable, T2: Bracable, T2: Breqable, T3: Bricable, T3: Bracable, T3: Breqable> : OneOf {
    case v1(T1), v2(T2), v3(T3)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?) { return (extract(), extract(), extract()) }

    public func extract() -> T1? {
        if case .v1(let v1) = self {
            return v1
        } else {
            return nil
        }
    }

    public func extract() -> T2? {
        if case .v2(let v2) = self {
            return v2
        } else {
            return nil
        }
    }

    public func extract() -> T3? {
        if case .v3(let v3) = self {
            return v3
        } else {
            return nil
        }
    }

    public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        }
    }

    public static func brac(bric: Bric) throws -> OneOf3 {
        return try bric.bracOne([
            { try .v1(T1.brac(bric)) },
            { try .v2(T2.brac(bric)) },
            { try .v3(T3.brac(bric)) },
            ])
    }

    public func breq(other: OneOf3) -> Bool {
        switch (self, other) {
        case (.v1(let v1l), .v1(let v1r)): return v1l.breq(v1r)
        case (.v2(let v2l), .v2(let v2r)): return v2l.breq(v2r)
        case (.v3(let v3l), .v3(let v3r)): return v3l.breq(v3r)
        default: return false
        }
    }
}



/// A simple union type that can be one of either T1 or T2 or T3
public enum OneOf4<T1, T2, T3, T4 where T1: Bricable, T1: Bracable, T1: Breqable, T2: Bricable, T2: Bracable, T2: Breqable, T3: Bricable, T3: Bracable, T3: Breqable, T4: Bricable, T4: Bracable, T4: Breqable> : OneOf {
    case v1(T1), v2(T2), v3(T3), v4(T4)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?) { return (extract(), extract(), extract(), extract()) }

    public func extract() -> T1? {
        if case .v1(let v1) = self {
            return v1
        } else {
            return nil
        }
    }

    public func extract() -> T2? {
        if case .v2(let v2) = self {
            return v2
        } else {
            return nil
        }
    }

    public func extract() -> T3? {
        if case .v3(let v3) = self {
            return v3
        } else {
            return nil
        }
    }

    public func extract() -> T4? {
        if case .v4(let v4) = self {
            return v4
        } else {
            return nil
        }
    }

    public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        }
    }

    public static func brac(bric: Bric) throws -> OneOf4 {
        return try bric.bracOne([
            { try .v1(T1.brac(bric)) },
            { try .v2(T2.brac(bric)) },
            { try .v3(T3.brac(bric)) },
            { try .v4(T4.brac(bric)) },
            ])
    }

    public func breq(other: OneOf4) -> Bool {
        switch (self, other) {
        case (.v1(let v1l), .v1(let v1r)): return v1l.breq(v1r)
        case (.v2(let v2l), .v2(let v2r)): return v2l.breq(v2r)
        case (.v3(let v3l), .v3(let v3r)): return v3l.breq(v3r)
        case (.v4(let v4l), .v4(let v4r)): return v4l.breq(v4r)
        default: return false
        }
    }
}



/// A simple union type that can be one of either T1 or T2 or T3
public enum OneOf5<T1, T2, T3, T4, T5 where T1: Bricable, T1: Bracable, T1: Breqable, T2: Bricable, T2: Bracable, T2: Breqable, T3: Bricable, T3: Bracable, T3: Breqable, T4: Bricable, T4: Bracable, T4: Breqable, T5: Bricable, T5: Bracable, T5: Breqable> : OneOf {
    case v1(T1), v2(T2), v3(T3), v4(T4), v5(T5)

    public init(t1: T1) { self = .v1(t1) }
    public init(_ t1: T1) { self = .v1(t1) }

    public init(t2: T2) { self = .v2(t2) }
    public init(_ t2: T2) { self = .v2(t2) }

    public init(t3: T3) { self = .v3(t3) }
    public init(_ t3: T3) { self = .v3(t3) }

    public init(t4: T4) { self = .v4(t4) }
    public init(_ t4: T4) { self = .v4(t4) }

    public init(t5: T5) { self = .v5(t5) }
    public init(_ t5: T5) { self = .v5(t5) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?, T5?) { return (extract(), extract(), extract(), extract(), extract()) }

    public func extract() -> T1? {
        if case .v1(let v1) = self {
            return v1
        } else {
            return nil
        }
    }

    public func extract() -> T2? {
        if case .v2(let v2) = self {
            return v2
        } else {
            return nil
        }
    }

    public func extract() -> T3? {
        if case .v3(let v3) = self {
            return v3
        } else {
            return nil
        }
    }

    public func extract() -> T4? {
        if case .v4(let v4) = self {
            return v4
        } else {
            return nil
        }
    }

    public func extract() -> T5? {
        if case .v5(let v5) = self {
            return v5
        } else {
            return nil
        }
    }

    public func bric() -> Bric {
        switch self {
        case .v1(let t1): return t1.bric()
        case .v2(let t2): return t2.bric()
        case .v3(let t3): return t3.bric()
        case .v4(let t4): return t4.bric()
        case .v5(let t5): return t5.bric()
        }
    }

    public static func brac(bric: Bric) throws -> OneOf5 {
        return try bric.bracOne([
            { try .v1(T1.brac(bric)) },
            { try .v2(T2.brac(bric)) },
            { try .v3(T3.brac(bric)) },
            { try .v4(T4.brac(bric)) },
            { try .v5(T5.brac(bric)) },
            ])
    }

    public func breq(other: OneOf5) -> Bool {
        switch (self, other) {
        case (.v1(let v1l), .v1(let v1r)): return v1l.breq(v1r)
        case (.v2(let v2l), .v2(let v2r)): return v2l.breq(v2r)
        case (.v3(let v3l), .v3(let v3r)): return v3l.breq(v3r)
        case (.v4(let v4l), .v4(let v4r)): return v4l.breq(v4r)
        case (.v5(let v5l), .v5(let v5r)): return v5l.breq(v5r)
        default: return false
        }
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
    var zone: (hours: Int, minutes: Int) { get set }
}


public struct BricDateTime: ISO8601DateTime, Hashable, Equatable, CustomStringConvertible, Bricable, Bracable, Breqable {
    public typealias BricDate = (year: Int, month: Int, day: Int)
    public typealias BricTime = (hour: Int, minute: Int, second: Double)
    public typealias BricZone = (hours: Int, minutes: Int)

    public var year, month, day, hour, minute: Int
    public var second: Double
    public var zone: BricZone

    public init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Double, zone: BricZone) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.zone = zone
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

    public var hashValue: Int { return year }

    public func breq(other: BricDateTime) -> Bool {
        return self.year == other.year
            && self.month == other.month
            && self.day == other.day
            && self.hour == other.hour
            && self.minute == other.minute
            && self.second == other.second
            && self.zone.hours == other.zone.hours
            && self.zone.minutes == other.zone.minutes
    }

    /// BricDateTime instances are serialized to ISO-8601 strings
    public func bric() -> Bric {
        return Bric.str(toISO8601String())
    }

    /// BricDateTime instances are serialized to ISO-8601 strings
    public static func brac(bric: Bric) throws -> BricDateTime {
        guard case .str(let str) = bric else { return try bric.invalidType() }
        guard let dtm = BricDateTime(str) else { return try bric.invalidRawValue(str) }
        return dtm
    }

}

public extension ISO8601DateTime {

    /// Converts this datetime to a formatted string with the given time separator and designator for UTC (Zulu) time
    public func toFormattedString(timesep timesep: String = "T", utctz: String? = "Z", padsec: Int = 3) -> String {
        func pad(num: Int, _ len: Int) -> String {
            var str = String(num)
            while str.characters.count < len {
                str = "0" + str
            }
            return str
        }

        /// Secs need to be padded to 2 at the beginning and 3 at the end, e.g.: 00.000
        func sec(secs: Double) -> String {
            var str = String(secs)
            let chars = str.characters
            if padsec > 0 {
                if chars.count >= 2 && chars.dropFirst().first == "." { str = "0" + str }
                while str.characters.count < (padsec + 3) { str += "0" }
            }
            return str
        }

        return pad(year, 4) + "-" + pad(month, 2) + "-" + pad(day, 2) + timesep + pad(hour, 2) + ":" + pad(minute, 2) + ":" + sec(second) + ((utctz != nil && zone.hours == 0 && zone.minutes == 0) ? utctz! : ((zone.hours >= 0 ? "+" : "") + pad(zone.hours, 2) + ":" + pad(zone.minutes, 2)))
    }

    /// Returns a string representation in accordance with ISO-8601
    public func toISO8601String() -> String {
        return toFormattedString()
    }

    /// Attempt to parse the given String as an ISO-8601 date-time structure
    public func parseISO8601String(str: String) -> Self? {
        var gen = str.characters.generate()

        func scan(skip: Int = 0, _ until: Character...) -> (String, Character?)? {
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

        func str2int(str: String, _ stop: Character?) -> Int? { return Int(str) }

        guard let year = scan(1, "-").flatMap(str2int) else { return nil }
        guard let month = scan(0, "-").flatMap(str2int) where month >= 1 && month <= 12 else { return nil }
        guard let day = scan(0, "T").flatMap(str2int) where day >= 1 && day <= 31 else { return nil }

        if day == 31 && (month == 4 || month == 6 || month == 9 || month == 11) { return nil }

        // Feb leap year check
        if day > 28 && month == 2 && !((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) { return nil }

        guard let hour = scan(0, ":").flatMap(str2int) where hour >= 0 && hour <= 24 else { return nil }
        guard let minute = scan(0, ":").flatMap(str2int) where minute >= 0 && minute <= 59 else { return nil }

        // “ISO 8601 permits the hyphen (-) to be used as the minus (−) character when the character set is limited.”
        guard let secstop = scan(0, "Z", "+", "-", "−") else { return nil }

        guard let second = Double(secstop.0) where second >= 0.0 && second < 60.0 else { return nil }

        if hour == 24 && (minute > 0 || second > 0.0) { return nil } // 24 is only valid as 24:00:00.0

        let tzc = secstop.1
        var tzh = 0, tzm = 0
        if tzc != "Z" { // non-Zulu time
            guard let h = scan(0, ":").flatMap(str2int) where h >= 0 && h <= 23 else { return nil }
            tzh = h * (tzc == "-" || tzc == "−" ? -1 : +1)

            guard let m = scan(0).flatMap(str2int) where m >= 0 && m <= 59 else { return nil }
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
        dtm.zone = (tzh, tzm)
        return dtm
    }
}

/// Two BricDateTime instances are equal iff all their components are equal; actual temporal equality is not considered
public func ==(lhs: BricDateTime, rhs: BricDateTime) -> Bool {
    return lhs.breq(rhs)
}


