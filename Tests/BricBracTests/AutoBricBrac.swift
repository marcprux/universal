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
    static var autobricbrac: (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) { get }
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
private func abric<T>(_ value: T) -> Bric where T: Bricable {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
private func abric<T>(_ value: T) -> Bric where T: BricLayer, T.BricSub : Bricable {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
private func abric<T>(_ value: T) -> Bric where T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : Bricable {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
private func abric<T>(_ value: T) -> Bric where T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : Bricable {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
private func abric<T>(_ value: T) -> Bric where T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub : Bricable {
    return value.bric()
}

/// Overloaded free-function for converting a Bricable or BricLayer into Bric
private func abric<T>(_ value: T) -> Bric where T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub.BricSub : Bricable {
    return value.bric()
}



/// Overloaded free-function for converting a Bracable or BracLayer into the type
private func abrac<T>(_ bric: Bric) throws -> T where T: Bracable {
    return try T.brac(bric: bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
private func abrac<T>(_ bric: Bric) throws -> T where T: BracLayer, T.BracSub : Bracable {
    return try T.brac(bric: bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
private func abrac<T>(_ bric: Bric) throws -> T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : Bracable {
    return try T.brac(bric: bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
private func abrac<T>(_ bric: Bric) throws -> T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : Bracable {
    return try T.brac(bric: bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
private func abrac<T>(_ bric: Bric) throws -> T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : Bracable {
    return try T.brac(bric: bric)
}

/// Overloaded free-function for converting a Bracable or BracLayer into the type
private func abrac<T>(_ bric: Bric) throws -> T where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub.BracSub : Bracable {
    return try T.brac(bric: bric)
}



extension AutoBricBrac {

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, R: RawRepresentable>(_ factory: @escaping (F1, F2) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, F4, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3, F4) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3), _ key4: (key: R, getter: (Self) -> F4, writer: (F4) -> Bric, reader: (Bric) throws -> F4)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, F4, F5, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3, F4, F5) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3), _ key4: (key: R, getter: (Self) -> F4, writer: (F4) -> Bric, reader: (Bric) throws -> F4), _ key5: (key: R, getter: (Self) -> F5, writer: (F5) -> Bric, reader: (Bric) throws -> F5)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, F4, F5, F6, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3, F4, F5, F6) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3), _ key4: (key: R, getter: (Self) -> F4, writer: (F4) -> Bric, reader: (Bric) throws -> F4), _ key5: (key: R, getter: (Self) -> F5, writer: (F5) -> Bric, reader: (Bric) throws -> F5), _ key6: (key: R, getter: (Self) -> F6, writer: (F6) -> Bric, reader: (Bric) throws -> F6)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3, F4, F5, F6, F7) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3), _ key4: (key: R, getter: (Self) -> F4, writer: (F4) -> Bric, reader: (Bric) throws -> F4), _ key5: (key: R, getter: (Self) -> F5, writer: (F5) -> Bric, reader: (Bric) throws -> F5), _ key6: (key: R, getter: (Self) -> F6, writer: (F6) -> Bric, reader: (Bric) throws -> F6), _ key7: (key: R, getter: (Self) -> F7, writer: (F7) -> Bric, reader: (Bric) throws -> F7)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3, F4, F5, F6, F7, F8) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3), _ key4: (key: R, getter: (Self) -> F4, writer: (F4) -> Bric, reader: (Bric) throws -> F4), _ key5: (key: R, getter: (Self) -> F5, writer: (F5) -> Bric, reader: (Bric) throws -> F5), _ key6: (key: R, getter: (Self) -> F6, writer: (F6) -> Bric, reader: (Bric) throws -> F6), _ key7: (key: R, getter: (Self) -> F7, writer: (F7) -> Bric, reader: (Bric) throws -> F7), _ key8: (key: R, getter: (Self) -> F8, writer: (F8) -> Bric, reader: (Bric) throws -> F8)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3, F4, F5, F6, F7, F8, F9) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3), _ key4: (key: R, getter: (Self) -> F4, writer: (F4) -> Bric, reader: (Bric) throws -> F4), _ key5: (key: R, getter: (Self) -> F5, writer: (F5) -> Bric, reader: (Bric) throws -> F5), _ key6: (key: R, getter: (Self) -> F6, writer: (F6) -> Bric, reader: (Bric) throws -> F6), _ key7: (key: R, getter: (Self) -> F7, writer: (F7) -> Bric, reader: (Bric) throws -> F7), _ key8: (key: R, getter: (Self) -> F8, writer: (F8) -> Bric, reader: (Bric) throws -> F8), _ key9: (key: R, getter: (Self) -> F9, writer: (F9) -> Bric, reader: (Bric) throws -> F9)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3), _ key4: (key: R, getter: (Self) -> F4, writer: (F4) -> Bric, reader: (Bric) throws -> F4), _ key5: (key: R, getter: (Self) -> F5, writer: (F5) -> Bric, reader: (Bric) throws -> F5), _ key6: (key: R, getter: (Self) -> F6, writer: (F6) -> Bric, reader: (Bric) throws -> F6), _ key7: (key: R, getter: (Self) -> F7, writer: (F7) -> Bric, reader: (Bric) throws -> F7), _ key8: (key: R, getter: (Self) -> F8, writer: (F8) -> Bric, reader: (Bric) throws -> F8), _ key9: (key: R, getter: (Self) -> F9, writer: (F9) -> Bric, reader: (Bric) throws -> F9), _ key10: (key: R, getter: (Self) -> F10, writer: (F10) -> Bric, reader: (Bric) throws -> F10)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)) )
        }

        return (bricer, bracer)
    }

    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, R: RawRepresentable>(_ factory: @escaping (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11) -> Self, _ key1: (key: R, getter: (Self) -> F1, writer: (F1) -> Bric, reader: (Bric) throws -> F1), _ key2: (key: R, getter: (Self) -> F2, writer: (F2) -> Bric, reader: (Bric) throws -> F2), _ key3: (key: R, getter: (Self) -> F3, writer: (F3) -> Bric, reader: (Bric) throws -> F3), _ key4: (key: R, getter: (Self) -> F4, writer: (F4) -> Bric, reader: (Bric) throws -> F4), _ key5: (key: R, getter: (Self) -> F5, writer: (F5) -> Bric, reader: (Bric) throws -> F5), _ key6: (key: R, getter: (Self) -> F6, writer: (F6) -> Bric, reader: (Bric) throws -> F6), _ key7: (key: R, getter: (Self) -> F7, writer: (F7) -> Bric, reader: (Bric) throws -> F7), _ key8: (key: R, getter: (Self) -> F8, writer: (F8) -> Bric, reader: (Bric) throws -> F8), _ key9: (key: R, getter: (Self) -> F9, writer: (F9) -> Bric, reader: (Bric) throws -> F9), _ key10: (key: R, getter: (Self) -> F10, writer: (F10) -> Bric, reader: (Bric) throws -> F10), _ key11: (key: R, getter: (Self) -> F11, writer: (F11) -> Bric, reader: (Bric) throws -> F11)) -> (bricer: ((Self) -> Bric), bracer: ((Bric) throws -> Self)) where R.RawValue == String {

        let bricer: ((Self) -> Bric) = { value in
            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))) ])
        }

        let bracer: ((Bric) throws -> Self) = { bric in
            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)) )
        }

        return (bricer, bracer)
    }

//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13), _ key14: (key: R, getter: Self -> F14, writer: F14 -> Bric, reader: Bric throws -> F14)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))), (key14.key, key14.writer(key14.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)), key14.reader(bric.brac(key: key14.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13), _ key14: (key: R, getter: Self -> F14, writer: F14 -> Bric, reader: Bric throws -> F14), _ key15: (key: R, getter: Self -> F15, writer: F15 -> Bric, reader: Bric throws -> F15)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))), (key14.key, key14.writer(key14.getter(value))), (key15.key, key15.writer(key15.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)), key14.reader(bric.brac(key: key14.key)), key15.reader(bric.brac(key: key15.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13), _ key14: (key: R, getter: Self -> F14, writer: F14 -> Bric, reader: Bric throws -> F14), _ key15: (key: R, getter: Self -> F15, writer: F15 -> Bric, reader: Bric throws -> F15), _ key16: (key: R, getter: Self -> F16, writer: F16 -> Bric, reader: Bric throws -> F16)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))), (key14.key, key14.writer(key14.getter(value))), (key15.key, key15.writer(key15.getter(value))), (key16.key, key16.writer(key16.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)), key14.reader(bric.brac(key: key14.key)), key15.reader(bric.brac(key: key15.key)), key16.reader(bric.brac(key: key16.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13), _ key14: (key: R, getter: Self -> F14, writer: F14 -> Bric, reader: Bric throws -> F14), _ key15: (key: R, getter: Self -> F15, writer: F15 -> Bric, reader: Bric throws -> F15), _ key16: (key: R, getter: Self -> F16, writer: F16 -> Bric, reader: Bric throws -> F16), _ key17: (key: R, getter: Self -> F17, writer: F17 -> Bric, reader: Bric throws -> F17)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))), (key14.key, key14.writer(key14.getter(value))), (key15.key, key15.writer(key15.getter(value))), (key16.key, key16.writer(key16.getter(value))), (key17.key, key17.writer(key17.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)), key14.reader(bric.brac(key: key14.key)), key15.reader(bric.brac(key: key15.key)), key16.reader(bric.brac(key: key16.key)), key17.reader(bric.brac(key: key17.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13), _ key14: (key: R, getter: Self -> F14, writer: F14 -> Bric, reader: Bric throws -> F14), _ key15: (key: R, getter: Self -> F15, writer: F15 -> Bric, reader: Bric throws -> F15), _ key16: (key: R, getter: Self -> F16, writer: F16 -> Bric, reader: Bric throws -> F16), _ key17: (key: R, getter: Self -> F17, writer: F17 -> Bric, reader: Bric throws -> F17), _ key18: (key: R, getter: Self -> F18, writer: F18 -> Bric, reader: Bric throws -> F18)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))), (key14.key, key14.writer(key14.getter(value))), (key15.key, key15.writer(key15.getter(value))), (key16.key, key16.writer(key16.getter(value))), (key17.key, key17.writer(key17.getter(value))), (key18.key, key18.writer(key18.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)), key14.reader(bric.brac(key: key14.key)), key15.reader(bric.brac(key: key15.key)), key16.reader(bric.brac(key: key16.key)), key17.reader(bric.brac(key: key17.key)), key18.reader(bric.brac(key: key18.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13), _ key14: (key: R, getter: Self -> F14, writer: F14 -> Bric, reader: Bric throws -> F14), _ key15: (key: R, getter: Self -> F15, writer: F15 -> Bric, reader: Bric throws -> F15), _ key16: (key: R, getter: Self -> F16, writer: F16 -> Bric, reader: Bric throws -> F16), _ key17: (key: R, getter: Self -> F17, writer: F17 -> Bric, reader: Bric throws -> F17), _ key18: (key: R, getter: Self -> F18, writer: F18 -> Bric, reader: Bric throws -> F18), _ key19: (key: R, getter: Self -> F19, writer: F19 -> Bric, reader: Bric throws -> F19)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))), (key14.key, key14.writer(key14.getter(value))), (key15.key, key15.writer(key15.getter(value))), (key16.key, key16.writer(key16.getter(value))), (key17.key, key17.writer(key17.getter(value))), (key18.key, key18.writer(key18.getter(value))), (key19.key, key19.writer(key19.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)), key14.reader(bric.brac(key: key14.key)), key15.reader(bric.brac(key: key15.key)), key16.reader(bric.brac(key: key16.key)), key17.reader(bric.brac(key: key17.key)), key18.reader(bric.brac(key: key18.key)), key19.reader(bric.brac(key: key19.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13), _ key14: (key: R, getter: Self -> F14, writer: F14 -> Bric, reader: Bric throws -> F14), _ key15: (key: R, getter: Self -> F15, writer: F15 -> Bric, reader: Bric throws -> F15), _ key16: (key: R, getter: Self -> F16, writer: F16 -> Bric, reader: Bric throws -> F16), _ key17: (key: R, getter: Self -> F17, writer: F17 -> Bric, reader: Bric throws -> F17), _ key18: (key: R, getter: Self -> F18, writer: F18 -> Bric, reader: Bric throws -> F18), _ key19: (key: R, getter: Self -> F19, writer: F19 -> Bric, reader: Bric throws -> F19), _ key20: (key: R, getter: Self -> F20, writer: F20 -> Bric, reader: Bric throws -> F20)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))), (key14.key, key14.writer(key14.getter(value))), (key15.key, key15.writer(key15.getter(value))), (key16.key, key16.writer(key16.getter(value))), (key17.key, key17.writer(key17.getter(value))), (key18.key, key18.writer(key18.getter(value))), (key19.key, key19.writer(key19.getter(value))), (key20.key, key20.writer(key20.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)), key14.reader(bric.brac(key: key14.key)), key15.reader(bric.brac(key: key15.key)), key16.reader(bric.brac(key: key16.key)), key17.reader(bric.brac(key: key17.key)), key18.reader(bric.brac(key: key18.key)), key19.reader(bric.brac(key: key19.key)), key20.reader(bric.brac(key: key20.key)) )
//        }
//
//        return (bricer, bracer)
//    }
//
//    /// Returns a pair of functions that will bric and brac this type based on the passed in factory, keys, accessors, and field mediators
//    public static func abricbrac<F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21, R: RawRepresentable where R.RawValue == String>(factory: (F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21) -> Self, _ key1: (key: R, getter: Self -> F1, writer: F1 -> Bric, reader: Bric throws -> F1), _ key2: (key: R, getter: Self -> F2, writer: F2 -> Bric, reader: Bric throws -> F2), _ key3: (key: R, getter: Self -> F3, writer: F3 -> Bric, reader: Bric throws -> F3), _ key4: (key: R, getter: Self -> F4, writer: F4 -> Bric, reader: Bric throws -> F4), _ key5: (key: R, getter: Self -> F5, writer: F5 -> Bric, reader: Bric throws -> F5), _ key6: (key: R, getter: Self -> F6, writer: F6 -> Bric, reader: Bric throws -> F6), _ key7: (key: R, getter: Self -> F7, writer: F7 -> Bric, reader: Bric throws -> F7), _ key8: (key: R, getter: Self -> F8, writer: F8 -> Bric, reader: Bric throws -> F8), _ key9: (key: R, getter: Self -> F9, writer: F9 -> Bric, reader: Bric throws -> F9), _ key10: (key: R, getter: Self -> F10, writer: F10 -> Bric, reader: Bric throws -> F10), _ key11: (key: R, getter: Self -> F11, writer: F11 -> Bric, reader: Bric throws -> F11), _ key12: (key: R, getter: Self -> F12, writer: F12 -> Bric, reader: Bric throws -> F12), _ key13: (key: R, getter: Self -> F13, writer: F13 -> Bric, reader: Bric throws -> F13), _ key14: (key: R, getter: Self -> F14, writer: F14 -> Bric, reader: Bric throws -> F14), _ key15: (key: R, getter: Self -> F15, writer: F15 -> Bric, reader: Bric throws -> F15), _ key16: (key: R, getter: Self -> F16, writer: F16 -> Bric, reader: Bric throws -> F16), _ key17: (key: R, getter: Self -> F17, writer: F17 -> Bric, reader: Bric throws -> F17), _ key18: (key: R, getter: Self -> F18, writer: F18 -> Bric, reader: Bric throws -> F18), _ key19: (key: R, getter: Self -> F19, writer: F19 -> Bric, reader: Bric throws -> F19), _ key20: (key: R, getter: Self -> F20, writer: F20 -> Bric, reader: Bric throws -> F20), _ key21: (key: R, getter: Self -> F21, writer: F21 -> Bric, reader: Bric throws -> F21)) -> (bricer: (Self -> Bric), bracer: (Bric throws -> Self)) {
//
//        let bricer: (Self -> Bric) = { value in
//            return Bric(object: [ (key1.key, key1.writer(key1.getter(value))), (key2.key, key2.writer(key2.getter(value))), (key3.key, key3.writer(key3.getter(value))), (key4.key, key4.writer(key4.getter(value))), (key5.key, key5.writer(key5.getter(value))), (key6.key, key6.writer(key6.getter(value))), (key7.key, key7.writer(key7.getter(value))), (key8.key, key8.writer(key8.getter(value))), (key9.key, key9.writer(key9.getter(value))), (key10.key, key10.writer(key10.getter(value))), (key11.key, key11.writer(key11.getter(value))), (key12.key, key12.writer(key12.getter(value))), (key13.key, key13.writer(key13.getter(value))), (key14.key, key14.writer(key14.getter(value))), (key15.key, key15.writer(key15.getter(value))), (key16.key, key16.writer(key16.getter(value))), (key17.key, key17.writer(key17.getter(value))), (key18.key, key18.writer(key18.getter(value))), (key19.key, key19.writer(key19.getter(value))), (key20.key, key20.writer(key20.getter(value))), (key21.key, key21.writer(key21.getter(value))) ])
//        }
//
//        let bracer: (Bric throws -> Self) = { bric in
//            try factory(key1.reader(bric.brac(key: key1.key)), key2.reader(bric.brac(key: key2.key)), key3.reader(bric.brac(key: key3.key)), key4.reader(bric.brac(key: key4.key)), key5.reader(bric.brac(key: key5.key)), key6.reader(bric.brac(key: key6.key)), key7.reader(bric.brac(key: key7.key)), key8.reader(bric.brac(key: key8.key)), key9.reader(bric.brac(key: key9.key)), key10.reader(bric.brac(key: key10.key)), key11.reader(bric.brac(key: key11.key)), key12.reader(bric.brac(key: key12.key)), key13.reader(bric.brac(key: key13.key)), key14.reader(bric.brac(key: key14.key)), key15.reader(bric.brac(key: key15.key)), key16.reader(bric.brac(key: key16.key)), key17.reader(bric.brac(key: key17.key)), key18.reader(bric.brac(key: key18.key)), key19.reader(bric.brac(key: key19.key)), key20.reader(bric.brac(key: key20.key)), key21.reader(bric.brac(key: key21.key)) )
//        }
//        
//        return (bricer, bracer)
//    }


    /// An autobricbrac key argument
    
    public static func bbkey<T: Bricable>(_ key: String, _ getter: @escaping (Self)->(T)) -> (String, (Self)->(T), ((T) -> Bric), ((Bric) throws -> T)) where T: Bracable {
        return (key, getter, abric, abrac)
    }

    /// An autobricbrac key argument
    
    public static func bbkey<T>(_ key: String, _ getter: @escaping (Self)->(T)) -> (String, (Self)->(T), ((T) -> Bric), ((Bric) throws -> T)) where T: BracLayer, T.BracSub : Bracable, T: BricLayer, T.BricSub : Bricable {
        return (key, getter, abric, abrac)
    }

    /// An autobricbrac key argument
    
    public static func bbkey<T>(_ key: String, _ getter: @escaping (Self)->(T)) -> (String, (Self)->(T), ((T) -> Bric), ((Bric) throws -> T)) where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : Bracable, T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : Bricable {
        return (key, getter, abric, abrac)
    }

    /// An autobricbrac key argument
    
    public static func bbkey<T>(_ key: String, _ getter: @escaping (Self)->(T)) -> (String, (Self)->(T), ((T) -> Bric), ((Bric) throws -> T)) where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : Bracable, T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : Bricable {
        return (key, getter, abric, abrac)
    }

    /// An autobricbrac key argument
    
    public static func bbkey<T>(_ key: String, _ getter: @escaping (Self)->(T)) -> (String, (Self)->(T), ((T) -> Bric), ((Bric) throws -> T)) where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : Bracable, T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub : Bricable {
        return (key, getter, abric, abrac)
    }

    /// An autobricbrac key argument
    
    public static func bbkey<T>(_ key: String, _ getter: @escaping (Self)->(T)) -> (String, (Self)->(T), ((T) -> Bric), ((Bric) throws -> T)) where T: BracLayer, T.BracSub : BracLayer, T.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub : BracLayer, T.BracSub.BracSub.BracSub.BracSub.BracSub : Bracable, T: BricLayer, T.BricSub : BricLayer, T.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub : BricLayer, T.BricSub.BricSub.BricSub.BricSub.BricSub : Bricable {
        return (key, getter, abric, abrac)
    }
}
