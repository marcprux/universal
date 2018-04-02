////
////  Brequality.swift
////  BricBrac
////
////  Created by Marc Prud'hommeaux on 2/7/16.
////  Copyright © 2016 io.glimpse. All rights reserved.
////
//
//// Swift 4.1 TODO: Breqable is obsolete with https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#extensions-of-structural-types
//
///// Brequality allows Bricable instances to have a default equality implementation that
///// compares the serialized instances, while allowing individual instances to provide their
///// own more efficient implementation. Note that `Breqable` does not conform to `Equatable` directly;
///// it is the custom type's obligation to declare `Equatable` or `BricBrac` conformance.
//public protocol Breqable {
//    /// Equality implementation
//    func breq(_ other: Self) -> Bool
//}
//
///// Breqable equatablilty defers to the `breq` implemention in the concrete type
//public func ==<T: Breqable>(lhs: T, rhs: T) -> Bool {
//    return lhs.breq(rhs)
//}
//
//extension BricBrac {
//    /// The default equals implementation compares the serialized JSON instances; 
//    /// this should be overridden in the implementation for a more efficient comparison
//    public func breq(_ other: Self) -> Bool {
//        return bric() == other.bric()
//    }
//}
//
//extension Equatable where Self : Breqable {
//    /// All Equatable implementations have `breq` defer to direct comparison
//    public func breq(_ other: Self) -> Bool { return other == self }
//}
//
//extension Bric: Breqable { }
//extension String: Breqable { }
//extension Bool: Breqable { }
//extension Int: Breqable { }
//extension Int8: Breqable { }
//extension Int16: Breqable { }
//extension Int32: Breqable { }
//extension Int64: Breqable { }
//extension UInt: Breqable { }
//extension UInt8: Breqable { }
//extension UInt16: Breqable { }
//extension UInt32: Breqable { }
//extension UInt64: Breqable { }
//extension Float: Breqable { }
//extension Double: Breqable { }
//
///// A BreqLayer is able to evaluate equality for the BricLayer's `BricSub` instances
//public protocol BreqLayer : BricLayer {
//    func breqMap(_ other: Self, eq: (BricSub, BricSub) -> Bool) -> Bool
//}
//
//public extension BreqLayer where Self.BricSub : Breqable {
//    /// Brics through one level of `BreqLayer`
//    public func breq(_ other: Self) -> Bool {
//        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
//    }
//}
//
//public extension BreqLayer where Self.BricSub : BreqLayer, Self.BricSub.BricSub : Breqable {
//    /// Breqs through two levels of `BreqLayer`
//    public func breq(_ other: Self) -> Bool {
//        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
//    }
//}
//
//public extension BreqLayer where Self.BricSub : BreqLayer, Self.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub : Breqable {
//    /// Breqs through three levels of `BreqLayer`
//    public func breq(_ other: Self) -> Bool {
//        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
//    }
//}
//
//public extension BreqLayer where Self.BricSub : BreqLayer, Self.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub.BricSub : Breqable {
//    /// Breqs through four levels of `BreqLayer`
//    public func breq(_ other: Self) -> Bool {
//        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
//    }
//}
//
//public extension BreqLayer where Self.BricSub : BreqLayer, Self.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub.BricSub : BreqLayer, Self.BricSub.BricSub.BricSub.BricSub.BricSub : Breqable {
//    /// Breqs through five levels of `BreqLayer`
//    public func breq(_ other: Self) -> Bool {
//        return breqMap(other, eq: { lhs, rhs in lhs.breq(rhs) })
//    }
//}
//
//
//extension WrapperType {
//    /// All flat mappables breq through their unwrapped instances
//    public func breqMap(_ other: Self, eq: (Wrapped, Wrapped) -> Bool) -> Bool {
//        let lhs = self.flatMap({ $0 })
//        let rhs = other.flatMap({ $0 })
//        if let lhs = lhs, let rhs = rhs {
//            return eq(lhs, rhs)
//        } else {
//            return lhs == nil && rhs == nil
//        }
//    }
//}
//
//extension Optional : BreqLayer { }
//extension Indirect : BreqLayer { }
//
//extension Sequence {
//    /// All sequences breq sub-equality
//    public func breqSequence(_ other: Self, eq: (Iterator.Element, Iterator.Element) -> Bool) -> Bool {
//        var a = self.makeIterator(), b = other.makeIterator()
//        while let lhs = a.next(), let rhs = b.next() {
//            if eq(lhs, rhs) == false {
//                return false
//            }
//        }
//
//        // lastly ensure that the number of elements in each collection was the same
//        if a.next() != nil { return false }
//        if b.next() != nil { return false }
//        
//        return true
//    }
//
//    public func breqMap(_ other: Self, eq: (Iterator.Element, Iterator.Element) -> Bool) -> Bool {
//        return breqSequence(other, eq: eq)
//    }
//
//}
//
//extension Collection {
//    public func breqCollection(_ other: Self, eq: (Iterator.Element, Iterator.Element) -> Bool) -> Bool {
//        if self.isEmpty != other.isEmpty { return false }
//
////        // Fast check for underlying array pointer equality (performance: O(1))
////        if AnyForwardCollection(self) === AnyForwardCollection(other) {
////            return true
////        }
//
//        // after the check because count might be O(N)
//        if self.count != other.count { return false }
//
//        // fall back to the default sequence mapping
//        return self.breqSequence(other, eq: eq)
//    }
//
//    public func breqMap(_ other: Self, eq: (Iterator.Element, Iterator.Element) -> Bool) -> Bool {
//        return breqCollection(other, eq: eq)
//    }
//}
//
//extension Array : BreqLayer {
//    public func breqMap(_ other: Array, eq: (Iterator.Element, Iterator.Element) -> Bool) -> Bool {
//        // comparing the underlying equality with many elements is expensive for the common case where
//        // the elements are unchanged; performing a direct pointer comparison is much faster
//        // note that this should be redundant against CollectionType's AnyForwardCollection ===
//        // optimization, but observation has shown that this passes at times when AnyForwardCollection fails
//        let ptreq = self.withUnsafeBufferPointer { ptr1 in
//            other.withUnsafeBufferPointer { ptr2 in
//                ptr1.count == ptr2.count && ptr1.baseAddress == ptr2.baseAddress
//            }
//        }
//
//        if ptreq {
//            return true
//        } else {
//        return breqCollection(other, eq: eq)
//        }
//    }
//}
//
//extension ArraySlice : BreqLayer {
//    public func breqMap(_ other: ArraySlice, eq: (Iterator.Element, Iterator.Element) -> Bool) -> Bool {
//        let ptreq = self.withUnsafeBufferPointer { ptr1 in
//            other.withUnsafeBufferPointer { ptr2 in
//                ptr1.count == ptr2.count && ptr1.baseAddress == ptr2.baseAddress
//            }
//        }
//
//        if ptreq {
//            return true
//        } else {
//            return breqCollection(other, eq: eq)
//        }
//    }
//}
//
//extension ContiguousArray : BreqLayer {
//    public func breqMap(_ other: ContiguousArray, eq: (Iterator.Element, Iterator.Element) -> Bool) -> Bool {
//        let ptreq = self.withUnsafeBufferPointer { ptr1 in
//            other.withUnsafeBufferPointer { ptr2 in
//                ptr1.count == ptr2.count && ptr1.baseAddress == ptr2.baseAddress
//            }
//        }
//
//        if ptreq {
//            return true
//        } else {
//            return breqCollection(other, eq: eq)
//        }
//    }
//}
//
//extension CollectionOfOne : BreqLayer { } // inherits breqMap via CollectionType conformance
//extension EmptyCollection : BreqLayer { } // inherits breqMap via CollectionType conformance
////extension NonEmptyCollection : BreqLayer { } // inherits breqMap via CollectionType conformance
//
//extension Set : BreqLayer { } // inherits breqMap via SequenceType conformance
//
//extension Dictionary : BreqLayer { // TODO: Swift 3: where Key == String
//
//    public func breqMap(_ other: Dictionary, eq: (BricSub, BricSub) -> Bool) -> Bool {
//        if self.count != other.count {
//            return false
//        }
//
//        let keys = Set(self.keys)
//        if keys != Set(other.keys) { return false }
//        let selfValues = keys.map({ self[$0]! }), otherValues = keys.map({ other[$0]! })
//        return selfValues.breqMap(otherValues, eq: eq)
//    }
//}
