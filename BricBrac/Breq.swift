//
//  Brequality.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 2/7/16.
//  Copyright © 2016 io.glimpse. All rights reserved.
//

/// Brequality allows Bricable instances to have a default equality implementation that
/// compares the serialized instances, while allowing individual instances to provide their
/// own more efficient implementation
public protocol Breqable : Equatable {
    /// Equality implementation
    func breq(other: Self) -> Bool
}

extension BricBrac {
    /// The default equals implementation compares the serialized JSON instances; 
    /// this should be overridden in the implementation for a more efficient comparison
    public func breq(other: Self) -> Bool {
        return bric() == other.bric()
    }
}

extension Equatable {
    /// All Equatable implementations have `breq` defer to direct comparison
    public func breq(other: Self) -> Bool { return other == self }
}

extension Bric: Breqable { }
extension String: Breqable { }
extension Bool: Breqable { }
extension Int: Breqable { }
extension Int8: Breqable { }
extension Int16: Breqable { }
extension Int32: Breqable { }
extension Int64: Breqable { }
extension UInt: Breqable { }
extension UInt8: Breqable { }
extension UInt16: Breqable { }
extension UInt32: Breqable { }
extension UInt64: Breqable { }
extension Float: Breqable { }
extension Double: Breqable { }

/// Breqable equatablilty defers to the `breq` implemention in the concrete type
public func ==<T: Breqable>(lhs: T, rhs: T) -> Bool {
    return lhs.breq(rhs)
}

/// A BreqLayer is able to evaluate equality for the BricLayer's `BricSub` instances
public protocol BreqLayer : BricLayer {
    func breqMap(other: Self, eq: (BricSub, BricSub) -> Bool) -> Bool
}

public extension BreqLayer where Self.BricSub : Breqable {
    /// Brics through one level of `BreqLayer`
    public func breq(other: Self) -> Bool {
        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
    }
}

public extension BreqLayer where Self.BricSub : BreqLayer, Self.BricSub.BricSub : Breqable {
    /// Breqs through two levels of `BreqLayer`
    public func breq(other: Self) -> Bool {
        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
    }
}

public extension BreqLayer where Self.BricSub : BreqLayer, Self.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub : Breqable {
    /// Breqs through three levels of `BreqLayer`
    public func breq(other: Self) -> Bool {
        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
    }
}

public extension BreqLayer where Self.BricSub : BreqLayer, Self.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub.BricSub : Breqable {
    /// Breqs through four levels of `BreqLayer`
    public func breq(other: Self) -> Bool {
        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
    }
}

public extension BreqLayer where Self.BricSub : BreqLayer, Self.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub.BricSub.BricSub : Breqable {
    /// Breqs through five levels of `BreqLayer`
    public func breq(other: Self) -> Bool {
        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
    }
}


extension WrapperType {
    /// All flat mappables breq through their unwrapped instances
    public func breqMap(other: Self, eq: (Wrapped, Wrapped) -> Bool) -> Bool {
        let lhs = self.flatMap({ $0 })
        let rhs = other.flatMap({ $0 })
        if let lhs = lhs, rhs = rhs {
            return eq(lhs, rhs)
        } else {
            return lhs == nil && rhs == nil
        }
    }
}

extension Optional : BreqLayer { }
extension Indirect : BreqLayer { }

extension SequenceType {
    /// All sequences breq sub-equality
    public func breqSequence(other: Self, eq: (Generator.Element, Generator.Element) -> Bool) -> Bool {
        var a = self.generate(), b = other.generate()
        while let lhs = a.next(), rhs = b.next() {
            if eq(lhs, rhs) == false {
                return false
            }
        }

        // lastly ensure that the number of elements in each collection was the same
        if a.next() != nil { return false }
        if b.next() != nil { return false }
        
        return true
    }

    public func breqMap(other: Self, eq: (Generator.Element, Generator.Element) -> Bool) -> Bool {
        return breqSequence(other, eq: eq)
    }

}

extension CollectionType {
    public func breqCollection(other: Self, eq: (Generator.Element, Generator.Element) -> Bool) -> Bool {
        if self.isEmpty != other.isEmpty { return false }

        // Fast check for underlying array pointer equality (performance: O(1))
        let af1 = AnyForwardCollection(self)
        let af2 = AnyForwardCollection(other)
        if af1 === af2 {
            return true
        }

        // after the check because count might be O(N)
        if self.count != other.count { return false }

        // fall back to the default sequence mapping
        return self.breqSequence(other, eq: eq)
    }

    public func breqMap(other: Self, eq: (Generator.Element, Generator.Element) -> Bool) -> Bool {
        return breqCollection(other, eq: eq)
    }
}

extension Array : BreqLayer { } // inherits breqMap via CollectionType conformance
extension ArraySlice : BreqLayer { } // inherits breqMap via CollectionType conformance
extension ContiguousArray : BreqLayer { } // inherits breqMap via CollectionType conformance
extension CollectionOfOne : BreqLayer { } // inherits breqMap via CollectionType conformance
extension EmptyCollection : BreqLayer { } // inherits breqMap via CollectionType conformance
extension NonEmptyCollection : BreqLayer { } // inherits breqMap via CollectionType conformance

extension Set : BreqLayer { } // inherits breqMap via SequenceType conformance

extension Dictionary : BreqLayer { // TODO: Swift 3: where Key == String

    public func breqMap(other: Dictionary, eq: (BricSub, BricSub) -> Bool) -> Bool {
        if self.count != other.count {
            return false
        }

        if AnyForwardCollection(self) === AnyForwardCollection(other) {
            return true // optimized collection pointer comparison
        }

        let keys = Set(self.keys)
        if keys != Set(other.keys) { return false }
        let selfValues = keys.map({ self[$0]! }), otherValues = keys.map({ other[$0]! })
        return selfValues.breqMap(otherValues, eq: eq)
    }
}
