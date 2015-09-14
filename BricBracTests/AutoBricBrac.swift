//
//  AutoBricBrac.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 9/13/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

import BricBrac

// MARK: Experimental AutoBricBrac support


/// AutoBricBrac allows automatic implementations of `Bricable` and `Bracable` based on the type
public protocol AutoBricBrac : BricBrac {
    static var autobricbrac: (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) { get }
}

public extension AutoBricBrac {
    public func bric() -> Bric {
        return Self.autobricbrac.bricer(self)
    }

    public static func brac(bric: Bric) throws -> Self {
        return try Self.autobricbrac.bracer(bric)
    }
}


/// Overloaded free-function for converting a Bricable or BricLayer into Bric
public func abric<T where T: Bricable>(value: T) -> Bric {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
public func abric<T where T: BricLayer, T.BricSub : Bricable>(value: T) -> Bric {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
public func abric<T where T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : Bricable>(value: T) -> Bric {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
public func abric<T where T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : Bricable>(value: T) -> Bric {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
public func abric<T where T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub : Bricable>(value: T) -> Bric {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
public func abric<T where T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub.BricSub : Bricable>(value: T) -> Bric {
    return value.bric()
}



/// Overloaded free-function for converting a Bracable or BracLayer into the type
public func abrac<T where T: Bracable>(bric: Bric) throws -> T {
    return try T.brac(bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
public func abrac<T where T: BracLayer, T.BracSub : Bracable>(bric: Bric) throws -> T {
    return try T.brac(bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
public func abrac<T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : Bracable>(bric: Bric) throws -> T {
    return try T.brac(bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
public func abrac<T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : Bracable>(bric: Bric) throws -> T {
    return try T.brac(bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
public func abrac<T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : Bracable>(bric: Bric) throws -> T {
    return try T.brac(bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
public func abrac<T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub.BracSub : Bracable>(bric: Bric) throws -> T {
    return try T.brac(bric)
}



/// Overloaded free-function for converting a Bricable/Bracable or BricLayer/BracLayer into bric/brac
public func abricbrac<T where T: Bracable, T: Bricable>() -> (() -> (T -> Bric), () -> (Bric throws -> T)) {
    return ({abric}, {abrac})
}

/// Overloaded free-function for converting a Bricable/Bracable or BricLayer/BracLayer into bric/brac
public func abricbrac<T where T: BracLayer, T.BracSub : Bracable, T: BricLayer, T.BricSub : Bricable>() -> (() -> (T -> Bric), () -> (Bric throws -> T)) {
    return ({abric}, {abrac})
}

/// Overloaded free-function for converting a Bricable/Bracable or BricLayer/BracLayer into bric/brac
public func abricbrac<T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : Bracable, T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : Bricable>() -> (() -> (T -> Bric), () -> (Bric throws -> T)) {
    return ({abric}, {abrac})
}

/// Overloaded free-function for converting a Bricable/Bracable or BricLayer/BracLayer into bric/brac
public func abricbrac<T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : Bracable, T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : Bricable>() -> (() -> (T -> Bric), () -> (Bric throws -> T)) {
    return ({abric}, {abrac})
}

/// Overloaded free-function for converting a Bricable/Bracable or BricLayer/BracLayer into bric/brac
public func abricbrac<T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : Bracable, T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub : Bricable>() -> (() -> (T -> Bric), () -> (Bric throws -> T)) {
    return ({abric}, {abrac})
}

/// Overloaded free-function for converting a Bricable/Bracable or BricLayer/BracLayer into bric/brac
public func abricbrac<T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub.BracSub : Bracable, T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub.BricSub : Bricable>() -> (() -> (T -> Bric), () -> (Bric throws -> T)) {
    return ({abric}, {abrac})
}



/// Support for AutoBricBrac types with 2 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2) -> Self)(_ keys: (R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2))))(_ accessors: Self -> (T1, T2)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 3 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3) -> Self)(_ keys: (R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3))))(_ accessors: Self -> (T1, T2, T3)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 4 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, T4, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3, T4) -> Self)(_ keys: (R, R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3)), (bricer: (T4 -> Bric), bracer: (Bric throws -> T4))))(_ accessors: Self -> (T1, T2, T3, T4)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)), (keys.3, mediators.3.bricer(vals.3)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)), mediators.3.bracer(bric.bracKey(keys.3)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 5 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, T4, T5, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3, T4, T5) -> Self)(_ keys: (R, R, R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3)), (bricer: (T4 -> Bric), bracer: (Bric throws -> T4)), (bricer: (T5 -> Bric), bracer: (Bric throws -> T5))))(_ accessors: Self -> (T1, T2, T3, T4, T5)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)), (keys.3, mediators.3.bricer(vals.3)), (keys.4, mediators.4.bricer(vals.4)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)), mediators.3.bracer(bric.bracKey(keys.3)), mediators.4.bracer(bric.bracKey(keys.4)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 6 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, T4, T5, T6, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3, T4, T5, T6) -> Self)(_ keys: (R, R, R, R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3)), (bricer: (T4 -> Bric), bracer: (Bric throws -> T4)), (bricer: (T5 -> Bric), bracer: (Bric throws -> T5)), (bricer: (T6 -> Bric), bracer: (Bric throws -> T6))))(_ accessors: Self -> (T1, T2, T3, T4, T5, T6)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)), (keys.3, mediators.3.bricer(vals.3)), (keys.4, mediators.4.bricer(vals.4)), (keys.5, mediators.5.bricer(vals.5)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)), mediators.3.bracer(bric.bracKey(keys.3)), mediators.4.bracer(bric.bracKey(keys.4)), mediators.5.bracer(bric.bracKey(keys.5)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 7 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, T4, T5, T6, T7, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3, T4, T5, T6, T7) -> Self)(_ keys: (R, R, R, R, R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3)), (bricer: (T4 -> Bric), bracer: (Bric throws -> T4)), (bricer: (T5 -> Bric), bracer: (Bric throws -> T5)), (bricer: (T6 -> Bric), bracer: (Bric throws -> T6)), (bricer: (T7 -> Bric), bracer: (Bric throws -> T7))))(_ accessors: Self -> (T1, T2, T3, T4, T5, T6, T7)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)), (keys.3, mediators.3.bricer(vals.3)), (keys.4, mediators.4.bricer(vals.4)), (keys.5, mediators.5.bricer(vals.5)), (keys.6, mediators.6.bricer(vals.6)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)), mediators.3.bracer(bric.bracKey(keys.3)), mediators.4.bracer(bric.bracKey(keys.4)), mediators.5.bracer(bric.bracKey(keys.5)), mediators.6.bracer(bric.bracKey(keys.6)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 8 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, T4, T5, T6, T7, T8, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3, T4, T5, T6, T7, T8) -> Self)(_ keys: (R, R, R, R, R, R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3)), (bricer: (T4 -> Bric), bracer: (Bric throws -> T4)), (bricer: (T5 -> Bric), bracer: (Bric throws -> T5)), (bricer: (T6 -> Bric), bracer: (Bric throws -> T6)), (bricer: (T7 -> Bric), bracer: (Bric throws -> T7)), (bricer: (T8 -> Bric), bracer: (Bric throws -> T8))))(_ accessors: Self -> (T1, T2, T3, T4, T5, T6, T7, T8)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)), (keys.3, mediators.3.bricer(vals.3)), (keys.4, mediators.4.bricer(vals.4)), (keys.5, mediators.5.bricer(vals.5)), (keys.6, mediators.6.bricer(vals.6)), (keys.7, mediators.7.bricer(vals.7)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)), mediators.3.bracer(bric.bracKey(keys.3)), mediators.4.bracer(bric.bracKey(keys.4)), mediators.5.bracer(bric.bracKey(keys.5)), mediators.6.bracer(bric.bracKey(keys.6)), mediators.7.bracer(bric.bracKey(keys.7)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 9 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, T4, T5, T6, T7, T8, T9, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3, T4, T5, T6, T7, T8, T9) -> Self)(_ keys: (R, R, R, R, R, R, R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3)), (bricer: (T4 -> Bric), bracer: (Bric throws -> T4)), (bricer: (T5 -> Bric), bracer: (Bric throws -> T5)), (bricer: (T6 -> Bric), bracer: (Bric throws -> T6)), (bricer: (T7 -> Bric), bracer: (Bric throws -> T7)), (bricer: (T8 -> Bric), bracer: (Bric throws -> T8)), (bricer: (T9 -> Bric), bracer: (Bric throws -> T9))))(_ accessors: Self -> (T1, T2, T3, T4, T5, T6, T7, T8, T9)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)), (keys.3, mediators.3.bricer(vals.3)), (keys.4, mediators.4.bricer(vals.4)), (keys.5, mediators.5.bricer(vals.5)), (keys.6, mediators.6.bricer(vals.6)), (keys.7, mediators.7.bricer(vals.7)), (keys.8, mediators.8.bricer(vals.8)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)), mediators.3.bracer(bric.bracKey(keys.3)), mediators.4.bracer(bric.bracKey(keys.4)), mediators.5.bracer(bric.bracKey(keys.5)), mediators.6.bracer(bric.bracKey(keys.6)), mediators.7.bracer(bric.bracKey(keys.7)), mediators.8.bracer(bric.bracKey(keys.8)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 10 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) -> Self)(_ keys: (R, R, R, R, R, R, R, R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3)), (bricer: (T4 -> Bric), bracer: (Bric throws -> T4)), (bricer: (T5 -> Bric), bracer: (Bric throws -> T5)), (bricer: (T6 -> Bric), bracer: (Bric throws -> T6)), (bricer: (T7 -> Bric), bracer: (Bric throws -> T7)), (bricer: (T8 -> Bric), bracer: (Bric throws -> T8)), (bricer: (T9 -> Bric), bracer: (Bric throws -> T9)), (bricer: (T10 -> Bric), bracer: (Bric throws -> T10))))(_ accessors: Self -> (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)), (keys.3, mediators.3.bricer(vals.3)), (keys.4, mediators.4.bricer(vals.4)), (keys.5, mediators.5.bricer(vals.5)), (keys.6, mediators.6.bricer(vals.6)), (keys.7, mediators.7.bricer(vals.7)), (keys.8, mediators.8.bricer(vals.8)), (keys.9, mediators.9.bricer(vals.9)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)), mediators.3.bracer(bric.bracKey(keys.3)), mediators.4.bracer(bric.bracKey(keys.4)), mediators.5.bracer(bric.bracKey(keys.5)), mediators.6.bracer(bric.bracKey(keys.6)), mediators.7.bracer(bric.bracKey(keys.7)), mediators.8.bracer(bric.bracKey(keys.8)), mediators.9.bracer(bric.bracKey(keys.9)) )
        }

        return (bricer, bracer)
    }
}

/// Support for AutoBricBrac types with 11 properties
public extension AutoBricBrac {
    /// Returns a pair of functions that will bric and brac this type based on the passes in factory, keys, accessors, and mediators
    public static func abricbrac<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, R: RawRepresentable where R.RawValue == String>(factory: (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) -> Self)(_ keys: (R, R, R, R, R, R, R, R, R, R, R))(_ mediators: ((bricer: (T1 -> Bric), bracer: (Bric throws -> T1)), (bricer: (T2 -> Bric), bracer: (Bric throws -> T2)), (bricer: (T3 -> Bric), bracer: (Bric throws -> T3)), (bricer: (T4 -> Bric), bracer: (Bric throws -> T4)), (bricer: (T5 -> Bric), bracer: (Bric throws -> T5)), (bricer: (T6 -> Bric), bracer: (Bric throws -> T6)), (bricer: (T7 -> Bric), bracer: (Bric throws -> T7)), (bricer: (T8 -> Bric), bracer: (Bric throws -> T8)), (bricer: (T9 -> Bric), bracer: (Bric throws -> T9)), (bricer: (T10 -> Bric), bracer: (Bric throws -> T10)), (bricer: (T11 -> Bric), bracer: (Bric throws -> T11))))(_ accessors: Self -> (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {

        let bricer: (Self -> Bric) = { value in
            let vals = accessors(value)
            return Bric(object: [ (keys.0, mediators.0.bricer(vals.0)), (keys.1, mediators.1.bricer(vals.1)), (keys.2, mediators.2.bricer(vals.2)), (keys.3, mediators.3.bricer(vals.3)), (keys.4, mediators.4.bricer(vals.4)), (keys.5, mediators.5.bricer(vals.5)), (keys.6, mediators.6.bricer(vals.6)), (keys.7, mediators.7.bricer(vals.7)), (keys.8, mediators.8.bricer(vals.8)), (keys.9, mediators.9.bricer(vals.9)), (keys.10, mediators.10.bricer(vals.10)) ])
        }

        let bracer: (Bric throws -> Self) = { bric in
            try factory(mediators.0.bracer(bric.bracKey(keys.0)), mediators.1.bracer(bric.bracKey(keys.1)), mediators.2.bracer(bric.bracKey(keys.2)), mediators.3.bracer(bric.bracKey(keys.3)), mediators.4.bracer(bric.bracKey(keys.4)), mediators.5.bracer(bric.bracKey(keys.5)), mediators.6.bracer(bric.bracKey(keys.6)), mediators.7.bracer(bric.bracKey(keys.7)), mediators.8.bracer(bric.bracKey(keys.8)), mediators.9.bracer(bric.bracKey(keys.9)), mediators.10.bracer(bric.bracKey(keys.10)) )
        }

        return (bricer, bracer)
    }
}
