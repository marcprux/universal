//
//  Structures.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 11/4/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

// General data structes need for `Brac` and `Curio` schema support

/// A FlatMappable is able to map itself through an optional
public protocol FlatMappable {
    typealias Wrapped
    init(_ some: Wrapped)
    func flatMap<U>(@noescape f: (Wrapped) throws -> U?) rethrows -> U?
}

/// Wrappable can contain zero or one instances (covers both `Optional` and `Indirect`)
public protocol Wrappable : NilLiteralConvertible {
    typealias Wrapped
    init(_ some: Wrapped)
}


extension Optional : FlatMappable { }
extension Optional : Wrappable { }

/// Behaves exactly the same a an Optional except the .Some case is indirect, allowing for recursive value types
public enum Indirect<Wrapped> : FlatMappable, Wrappable, NilLiteralConvertible {
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
