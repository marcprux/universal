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

/// Breqable equatablilty defers to the `brequal` implemention in the concrete type
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



extension Optional : BreqLayer {
    public func breqMap(other: Optional, eq: (Wrapped, Wrapped) -> Bool) -> Bool {
        if let lhs = self, rhs = other {
            return eq(lhs, rhs)
        } else {
            return false
        }
    }
}

extension Indirect : BreqLayer {
    public func breqMap(other: Indirect, eq: (Wrapped, Wrapped) -> Bool) -> Bool {
        if let lhs = self, rhs = other {
            return eq(lhs, rhs)
        } else {
            return false
        }
    }
}

extension SequenceType {
    /// All sequences breq sub-equality
    public func breqMap(other: Self, eq: (Generator.Element, Generator.Element) -> Bool) -> Bool {
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
}

extension Array : BreqLayer { } // inherits breqMap via SequenceType conformance
extension ArraySlice : BreqLayer { } // inherits breqMap via SequenceType conformance
extension ContiguousArray : BreqLayer { } // inherits breqMap via SequenceType conformance
extension Set : BreqLayer { } // inherits breqMap via SequenceType conformance
extension CollectionOfOne : BreqLayer { } // inherits breqMap via SequenceType conformance
extension EmptyCollection : BreqLayer { } // inherits breqMap via SequenceType conformance
extension NonEmptyCollection : BreqLayer { } // inherits breqMap via SequenceType conformance

