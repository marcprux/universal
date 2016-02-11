//
//  Structures.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 11/4/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

// General data structes need for `Brac` and `Curio` schema support

/// A WrapperType is able to map itself through a wrapped optional
public protocol WrapperType {
    typealias Wrapped
    init(_ some: Wrapped)
    func flatMap<U>(@noescape f: (Wrapped) throws -> U?) rethrows -> U?
}

/// Wrappable can contain zero or one instances (covers both `Optional` and `Indirect`)
public protocol Wrappable : NilLiteralConvertible {
    typealias Wrapped
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

public protocol OneOf: BricBrac {
    typealias T

    /// Returns a tuple of the possible value types for this OneOf
    var values: T { get }
}


/// A simple union type that can be one of either T1 or T2
public indirect enum OneOf2<T1, T2 where T1: Bricable, T1: Bracable, T1: Breqable, T2: Bricable, T2: Bracable, T2: Breqable> : OneOf {
    case V1(T1), V2(T2)

    public init(t1: T1) { self = .V1(t1) }
    public init(_ t1: T1) { self = .V1(t1) }

    public init(t2: T2) { self = .V2(t2) }
    public init(_ t2: T2) { self = .V2(t2) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?) { return (extract(), extract()) }

    public func extract() -> T1? {
        if case .V1(let v1) = self {
            return v1
        } else {
            return nil
        }
    }

    public func extract() -> T2? {
        if case .V2(let v2) = self {
            return v2
        } else {
            return nil
        }
    }

    public func bric() -> Bric {
        switch self {
        case .V1(let t1): return t1.bric()
        case .V2(let t2): return t2.bric()
        }
    }

    public static func brac(bric: Bric) throws -> OneOf2 {
        return try bric.bracOne([
            { try .V1(T1.brac(bric)) },
            { try .V2(T2.brac(bric)) }
            ])
    }

    public func breq(other: OneOf2) -> Bool {
        switch (self, other) {
        case (.V1(let v1l), .V1(let v1r)): return v1l.breq(v1r)
        case (.V2(let v2l), .V2(let v2r)): return v2l.breq(v2r)
        case (.V1, .V2), (.V2, .V1): return false
        }
    }
}



/// A simple union type that can be one of either T1 or T2 or T3
public indirect enum OneOf3<T1, T2, T3 where T1: Bricable, T1: Bracable, T1: Breqable, T2: Bricable, T2: Bracable, T2: Breqable, T3: Bricable, T3: Bracable, T3: Breqable> : OneOf {
    case V1(T1), V2(T2), V3(T3)

    public init(t1: T1) { self = .V1(t1) }
    public init(_ t1: T1) { self = .V1(t1) }

    public init(t2: T2) { self = .V2(t2) }
    public init(_ t2: T2) { self = .V2(t2) }

    public init(t3: T3) { self = .V3(t3) }
    public init(_ t3: T3) { self = .V3(t3) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?) { return (extract(), extract(), extract()) }

    public func extract() -> T1? {
        if case .V1(let v1) = self {
            return v1
        } else {
            return nil
        }
    }

    public func extract() -> T2? {
        if case .V2(let v2) = self {
            return v2
        } else {
            return nil
        }
    }

    public func extract() -> T3? {
        if case .V3(let v3) = self {
            return v3
        } else {
            return nil
        }
    }

    public func bric() -> Bric {
        switch self {
        case .V1(let t1): return t1.bric()
        case .V2(let t2): return t2.bric()
        case .V3(let t3): return t3.bric()
        }
    }

    public static func brac(bric: Bric) throws -> OneOf3 {
        return try bric.bracOne([
            { try .V1(T1.brac(bric)) },
            { try .V2(T2.brac(bric)) },
            { try .V3(T3.brac(bric)) },
            ])
    }

    public func breq(other: OneOf3) -> Bool {
        switch (self, other) {
        case (.V1(let v1l), .V1(let v1r)): return v1l.breq(v1r)
        case (.V2(let v2l), .V2(let v2r)): return v2l.breq(v2r)
        case (.V3(let v3l), .V3(let v3r)): return v3l.breq(v3r)
        default: return false
        }
    }
}



/// A simple union type that can be one of either T1 or T2 or T3
public indirect enum OneOf4<T1, T2, T3, T4 where T1: Bricable, T1: Bracable, T1: Breqable, T2: Bricable, T2: Bracable, T2: Breqable, T3: Bricable, T3: Bracable, T3: Breqable, T4: Bricable, T4: Bracable, T4: Breqable> : OneOf {
    case V1(T1), V2(T2), V3(T3), V4(T4)

    public init(t1: T1) { self = .V1(t1) }
    public init(_ t1: T1) { self = .V1(t1) }

    public init(t2: T2) { self = .V2(t2) }
    public init(_ t2: T2) { self = .V2(t2) }

    public init(t3: T3) { self = .V3(t3) }
    public init(_ t3: T3) { self = .V3(t3) }

    public init(t4: T4) { self = .V4(t4) }
    public init(_ t4: T4) { self = .V4(t4) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?) { return (extract(), extract(), extract(), extract()) }

    public func extract() -> T1? {
        if case .V1(let v1) = self {
            return v1
        } else {
            return nil
        }
    }

    public func extract() -> T2? {
        if case .V2(let v2) = self {
            return v2
        } else {
            return nil
        }
    }

    public func extract() -> T3? {
        if case .V3(let v3) = self {
            return v3
        } else {
            return nil
        }
    }

    public func extract() -> T4? {
        if case .V4(let v4) = self {
            return v4
        } else {
            return nil
        }
    }

    public func bric() -> Bric {
        switch self {
        case .V1(let t1): return t1.bric()
        case .V2(let t2): return t2.bric()
        case .V3(let t3): return t3.bric()
        case .V4(let t4): return t4.bric()
        }
    }

    public static func brac(bric: Bric) throws -> OneOf4 {
        return try bric.bracOne([
            { try .V1(T1.brac(bric)) },
            { try .V2(T2.brac(bric)) },
            { try .V3(T3.brac(bric)) },
            { try .V4(T4.brac(bric)) },
            ])
    }

    public func breq(other: OneOf4) -> Bool {
        switch (self, other) {
        case (.V1(let v1l), .V1(let v1r)): return v1l.breq(v1r)
        case (.V2(let v2l), .V2(let v2r)): return v2l.breq(v2r)
        case (.V3(let v3l), .V3(let v3r)): return v3l.breq(v3r)
        case (.V4(let v4l), .V4(let v4r)): return v4l.breq(v4r)
        default: return false
        }
    }
}



/// A simple union type that can be one of either T1 or T2 or T3
public indirect enum OneOf5<T1, T2, T3, T4, T5 where T1: Bricable, T1: Bracable, T1: Breqable, T2: Bricable, T2: Bracable, T2: Breqable, T3: Bricable, T3: Bracable, T3: Breqable, T4: Bricable, T4: Bracable, T4: Breqable, T5: Bricable, T5: Bracable, T5: Breqable> : OneOf {
    case V1(T1), V2(T2), V3(T3), V4(T4), V5(T5)

    public init(t1: T1) { self = .V1(t1) }
    public init(_ t1: T1) { self = .V1(t1) }

    public init(t2: T2) { self = .V2(t2) }
    public init(_ t2: T2) { self = .V2(t2) }

    public init(t3: T3) { self = .V3(t3) }
    public init(_ t3: T3) { self = .V3(t3) }

    public init(t4: T4) { self = .V4(t4) }
    public init(_ t4: T4) { self = .V4(t4) }

    public init(t5: T5) { self = .V5(t5) }
    public init(_ t5: T5) { self = .V5(t5) }

    /// Returns a tuple of optionals, exactly one of which will be non-nil
    public var values: (T1?, T2?, T3?, T4?, T5?) { return (extract(), extract(), extract(), extract(), extract()) }

    public func extract() -> T1? {
        if case .V1(let v1) = self {
            return v1
        } else {
            return nil
        }
    }

    public func extract() -> T2? {
        if case .V2(let v2) = self {
            return v2
        } else {
            return nil
        }
    }

    public func extract() -> T3? {
        if case .V3(let v3) = self {
            return v3
        } else {
            return nil
        }
    }

    public func extract() -> T4? {
        if case .V4(let v4) = self {
            return v4
        } else {
            return nil
        }
    }

    public func extract() -> T5? {
        if case .V5(let v5) = self {
            return v5
        } else {
            return nil
        }
    }

    public func bric() -> Bric {
        switch self {
        case .V1(let t1): return t1.bric()
        case .V2(let t2): return t2.bric()
        case .V3(let t3): return t3.bric()
        case .V4(let t4): return t4.bric()
        case .V5(let t5): return t5.bric()
        }
    }

    public static func brac(bric: Bric) throws -> OneOf5 {
        return try bric.bracOne([
            { try .V1(T1.brac(bric)) },
            { try .V2(T2.brac(bric)) },
            { try .V3(T3.brac(bric)) },
            { try .V4(T4.brac(bric)) },
            { try .V5(T5.brac(bric)) },
            ])
    }

    public func breq(other: OneOf5) -> Bool {
        switch (self, other) {
        case (.V1(let v1l), .V1(let v1r)): return v1l.breq(v1r)
        case (.V2(let v2l), .V2(let v2r)): return v2l.breq(v2r)
        case (.V3(let v3l), .V3(let v3r)): return v3l.breq(v3r)
        case (.V4(let v4l), .V4(let v4r)): return v4l.breq(v4r)
        case (.V5(let v5l), .V5(let v5r)): return v5l.breq(v5r)
        default: return false
        }
    }
}

