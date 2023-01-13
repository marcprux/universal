//
//  Defaultables.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 7/12/19.
//

/// A defaultable type is a type that can be initialized with no arguments and a default value.
/// The `defaultValue` instance should generally be considered an "empty instance".
/// For example, and `Collections`'s `defaultValue` is an empty version of itself.
/// - Note: some type should not be defaultable, such as `String` and `Int`, since their defaultablily may introduce confusion.
public protocol Defaultable {
    /// An instance of the default value for this type.
    static var defaultValue: Self { get }
}

extension ExplicitNull : Defaultable {
    /// The default (and only value) for `ExplicitNull` is `null`
    public static var defaultValue = ExplicitNull.null
}

/// A WrapperType wraps something; is able to map itself through a wrapped optional.
/// This protocol is mostly an artifact of the inability for a protocol extension to be constrained
/// to a concrete generic type, so when we want to constrain a protocol to Optional types,
/// we rely on its implementation of `flatMap`.
///
/// It needs to be public in order for external protocols to conform.
///
/// - See Also: `Optional.flatMap`
public protocol _WrapperType {
    associatedtype Wrapped
    init(_ some: Wrapped)

    /// If `self == nil`, returns `nil`.  Otherwise, returns `f(self!)`.
    /// - See Also: `Optional.map`
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?

    /// Returns `nil` if `self` is `nil`, `f(self!)` otherwise.
    /// - See Also: `Optional.flatMap`
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?

    /// Returns the wrapped instance as an optional value.
    var asOptional: Wrapped? { get }
}

public protocol _OptionalType : _WrapperType, ExpressibleByNilLiteral {
}

extension Optional : _OptionalType {
    @inlinable public var asOptional: Wrapped? { self }
}

extension _WrapperType {
    /// Convert this type to an optional; shorthand for `flatMap({ $0 })`
    @usableFromInline func toOptional() -> Wrapped? {
        return self.flatMap({ $0 })
    }
}

public extension _WrapperType {
    /// Returns the wrapped value or the defaulting value if the wrapped value if nil
    @inlinable subscript(faulting defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        get { asOptional ?? defaultValue() }
        set { self = Self(newValue) }
        // Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
//        _modify {
//            var x = asOptional ?? defaultValue()
//            yield &x
//            self = Self(x)
//        }
    }

    /// Returns the wrapped value or the defaulting value if the wrapped value if nil. This is a variant of the @autoclosure subscript,
    /// except it can be used in a key path when `Wrapped` is `Hashable`.
    /// The `@autoclosure` form of `subscript(faulting:)` should be used when possible as it can be faster.
    @inlinable subscript(faultingValue defaultValue: Wrapped) -> Wrapped {
        get { asOptional ?? defaultValue }
        set { self = Self(newValue) }

        // Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
//        _modify {
//            var x = asOptional ?? defaultValue
//            yield &x
//            self = Self(x)
//        }
    }

}

public extension _WrapperType where Wrapped : Defaultable {
    /// Returns the current value of the wrapped instance or, if unset, uses the type's `defaultValue`.
    /// Unlike `defaulted`, setting the value to the default value doesn't clear it.
    ///
    /// See also: `faulted`
    @inlinable var faulted: Wrapped {
        get { return self[faulting: .defaultValue] }
        set { self = Self(newValue) }
        // Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
//        _modify {
//            var x = self[faulting: .defaultValue]
//            yield &x
//            self = Self(x)
//        }
    }
}

public extension Optional where Wrapped : Equatable {
    /// Transforms the empty wrapped instance into the given non-optional instance.
    /// This is similar to the `defaulting` subscript, with the important difference that when
    /// the value is set to the default value, the underlying optional is cleared to `.none`.
    @inlinable subscript(defaulting defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        get { self ?? defaultValue() }
        set { self = newValue == defaultValue() ? .none : newValue }
    }

    /// Returns the wrapped value or the defaulting value if the wrapped value if nil. This is a variant of the @autoclosure subscript,
    /// except it can be used in a key path when `Wrapped` is `Hashable`.
    /// The `@autoclosure` form of `subscript(defaulting:)` should be used when possible as it can be faster.
    @inlinable subscript(defaultingValue defaultValue: Wrapped) -> Wrapped {
        get { self ?? defaultValue }
        set { self = Self(newValue) }
        // Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
//        _modify {
//            var x = self ?? defaultValue
//            yield &x
//            self = x == defaultValue ? .none : x
//        }
    }

}

public extension Optional where Wrapped : Defaultable & Equatable {
    /// Faults in the default value, but when assigned a new value that is the same as the default value, clear the value instead (unlike `faulted`)
    ///
    /// See also: `defaulted`
    @inlinable var defaulted: Wrapped {
        get { self ?? Wrapped.defaultValue }
        set { self[defaulting: .defaultValue] = newValue }
        // Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
//        _modify {
//            var x = self ?? Wrapped.defaultValue
//            yield &x
//            self = x == Wrapped.defaultValue ? .none : x
//        }
    }
}

extension ExpressibleByNilLiteral {
    /// An `ExpressibleByNilLiteral` conforms to `Defaultable` by nil initialization
    @inlinable public static var defaultValue: Self { Self(nilLiteral: ()) }
}

extension ExpressibleByArrayLiteral {
    /// An `ExpressibleByArrayLiteral` conforms to `Defaultable` by empty array initialization
    @inlinable public static var defaultValue: Self { Self() }
}

extension ExpressibleByDictionaryLiteral {
    /// An `ExpressibleByDictionaryLiteral` conforms to `Defaultable` by empty dictionary initialization
    @inlinable public static var defaultValue: Self { Self() }
}

//extension Optional : Defaultable { } // conflicts with conditional `Wrapped : Defaultable` below
extension Set : Defaultable { } // inherits initializer from ExpressibleByArrayLiteral
extension Array : Defaultable { } // inherits initializer from ExpressibleByArrayLiteral
extension ArraySlice : Defaultable { } // inherits initializer from ExpressibleByArrayLiteral
extension ContiguousArray : Defaultable { } // inherits initializer from ExpressibleByArrayLiteral
extension Dictionary : Defaultable { } // inherit initializer from ExpressibleByDictionaryLiteral

extension EmptyCollection : Defaultable {
    @inlinable public static var defaultValue: Self { Self() }
}

/// An optional is defaultable when its wrapped instance is defaultable
extension Optional : Defaultable where Wrapped : Defaultable {
    @inlinable public static var defaultValue: Self { .some(.defaultValue) }
}

public extension Defaultable where Self : Equatable {
    /// Returns true if this instance is the same as the defaulted value
    @inlinable var isDefaultedValue: Bool {
        return self == .defaultValue
    }

    /// Assign this to the specified value unless it is already set, in which
    /// case it is defaulted to the default value. For example:
    /// ob.optionalString.toggleDefault("foo") will set the optionalString?
    /// variable to "foo", or, if it was already "foo", will clear it.
    @inlinable mutating func toggleDefault(_ value: Self) {
        self = self == value ? .defaultValue : value
    }

}

/// Optional extension to get around the inability for optional chains to be writable
///
/// Introduces three new key paths to Optional:
///
///   some: T? -> T??
///   flatMap: T? -> T?
///   map: T -> T?
public extension Optional {
    /// Wraps the child instance in Optional; this enables `\.some` to be
    /// used as a `WritableKeyPath` when otherwise optional traversal would be
    /// treated as read-only for keyPath setters.
    ///
    /// For example, this optionally-chained keypath is read-only:
    ///
    ///   `a[keyPath: \A.b?.c?.cx]`
    ///
    /// But the following equivalent nested keyPath is readable & writable:
    ///
    ///   `a[keyPath: \A.b[some: \.c[some: \.cx]]]`
    ///
    /// The `flatMap` subcript and `some` subscript are identical implementations,
    /// but the `flatMap` version coalesces multiple nulls.
    ///
    ///   https://github.com/apple/swift-evolution/blob/master/proposals/0227-identity-keypath.md
    @inlinable subscript<T>(some optionalKeyPath: WritableKeyPath<Wrapped, T?>) -> T?? {
        get {
            switch self {
            case .none:
                return .none
            case .some(let value):
                return value[keyPath: optionalKeyPath]
            }
        }

        set {
            switch self {
            case .none:
            return // cannot over-assign to a .none path
            case .some(var value):
                value[keyPath: optionalKeyPath] = newValue ?? .none
                self = .some(value)
            }
        }
    }

    /// Wraps the child instance in Optional; this enables `\.[flatMap: path]` to be
    /// used as a `WritableKeyPath` when otherwise optional traversal using the
    /// built-on `optionalChain` handling would be treated as read-only for keyPath setters.
    ///
    /// For example, this optionally-chained keypath is read-only:
    ///
    ///   `a[keyPath: \A.b?.c?.cx]`
    ///
    /// But the following equivalent nested keyPath is readable & writable:
    ///
    ///   `a[keyPath: \A.b[some: \.c[some: \.cx]]]`
    ///
    /// The `flatMap` subcript and `some` subscript are identical implementations,
    /// but the `flatMap` version coalesces multiple nulls.
    ///
    ///   https://github.com/apple/swift-evolution/blob/master/proposals/0227-identity-keypath.md
    @inlinable subscript<T>(flatMap optionalKeyPath: WritableKeyPath<Wrapped, T?>) -> T? {
        get { return self[some: optionalKeyPath] ?? .none }
        set { self[some: optionalKeyPath] = newValue }
    }

    @inlinable subscript<T>(map throughKeyPath: WritableKeyPath<Wrapped, T>) -> T? {
        get {
            return self?[keyPath: throughKeyPath] ?? .none
        }

        set {
            if let newValue = newValue {
                switch self {
                case .none:
                    break // cannot assign to none since we don't know how to construct a new instance; use `.faulting`
                case .some(var value):
                    value[keyPath: throughKeyPath] = newValue
                    self = .some(value)
                }
            } else {
                self = .none
            }
        }
    }
}

public extension Equatable {
    /// Provides for the lazy creation of an optional keypath that leads to a defaultable;
    /// this should be a keyPath to `Any`, but since subscripts can't be added to `Any`,
    /// we use `Equatable` instead as an arbitrary (and common) holder of the key path.
    @inlinable subscript<T: Defaultable>(faulting optionalKeyPath: WritableKeyPath<Self, T?>) -> T {
        get {
            return self[keyPath: optionalKeyPath] ?? T.defaultValue
        }

        set {
            self[keyPath: optionalKeyPath] = .some(newValue)
        }
    }
}

public extension Optional where Wrapped : RawRepresentable {
    /// Convert through to the underlying `RawValue`.
    @inlinable var rawOptional: Optional<Wrapped.RawValue> {
        get { self?.rawValue }
        set { self = newValue.flatMap(Wrapped.init(rawValue:)) }
    }
}

public extension Optional {
    /// Morphs the given type via a keyPath;
    /// defaultValue can be nil (e.g., so you can pass FontSize?.none), and existly
    /// mostly to allow for type declaration while maintaining the requirement that
    /// keyPath elements be hashable.
    subscript<T: RawRepresentable>(rawDefaulted defaultValue: T?) -> T? where T.RawValue == Wrapped {
        get { return self.flatMap(T.init(rawValue:)) ?? defaultValue }
        set { self = newValue?.rawValue }
    }
}

public extension Optional where Wrapped : Defaultable {
    /// This should work, and help in cases where we want to fallback to a default value for an optional.
    /// But we get the compile error:
    ///    Type of expression is ambiguous without more context
    /// Possibly because this keypath is included in a constrained extension?
    /// Appending via path.appending(path: \.[someMap: \.XXX] seems to work better…
    @inlinable subscript<T>(someDef optionalKeyPath: WritableKeyPath<Wrapped, T?>) -> T? {
        get {
            return (self ?? Wrapped.defaultValue)[keyPath: optionalKeyPath]
        }

        set {
            var val = self ?? Wrapped.defaultValue
            val[keyPath: optionalKeyPath] = newValue
            self = .some(val)
        }
    }


    /// Similar to `map`, except it will instantiate a default intermediate value
    /// if one isn't already present.
    @inlinable subscript<T>(defaultMap throughKeyPath: WritableKeyPath<Wrapped, T>) -> T? {
        get {
            return (self ?? Wrapped.defaultValue)[keyPath: throughKeyPath]
        }

        set {
            if let newValue = newValue {
                var value = self ?? Wrapped.defaultValue
                value[keyPath: throughKeyPath] = newValue
                self = .some(value)
            } else {
                self = .none // .some(Wrapped.defaultValue)
            }
        }
    }
}

public extension OneOf2Type {
    /// Returns the default value for `.v2`
    @inlinable subscript(faulting withValue: T1) -> T1 {
        get { self.infer() ?? withValue }
        set { self = Self(newValue) }
    }
}

public extension OneOf2Type where T1 : Defaultable {
    /// Returns the default value for `.v1`
    @inlinable var v1faulted: T1 {
        get { self[faulting: .defaultValue] }
        set { self[faulting: .defaultValue] = newValue }
    }
}

public extension OneOf2Type {
    /// Returns the default value for `.v2`
    @inlinable subscript(faulting withValue: T2) -> T2 {
        get { self.infer() ?? withValue }
        set { self = Self(newValue) }
    }
}

public extension OneOf2Type where T2 : Defaultable {
    /// Returns the default value for `.v2`
    @inlinable var v2faulted: T2 {
        get { self[faulting: .defaultValue] }
        set { self[faulting: .defaultValue] = newValue }
    }
}

public extension OneOf3Type {
    /// Returns the default value for `.v3`
    @inlinable subscript(faulting withValue: T3) -> T3 {
        get { self.infer() ?? withValue }
        set { self = Self(newValue) }
    }
}

public extension OneOf3Type where T3 : Defaultable {
    /// Returns the default value for `.v3`
    @inlinable var v3faulted: T3 {
        get { self[faulting: .defaultValue] }
        set { self[faulting: .defaultValue] = newValue }
    }
}

public extension OneOf4Type {
    /// Returns the default value for `.v4`
    @inlinable subscript(faulting withValue: T4) -> T4 {
        get { self.infer() ?? withValue }
        set { self = Self(newValue) }
    }
}


public extension OneOf4Type where T4 : Defaultable {
    /// Returns the default value for `.v4`
    @inlinable var v4faulted: T4 {
        get { self[faulting: .defaultValue] }
        set { self[faulting: .defaultValue] = newValue }
    }
}

public extension OneOf5Type {
    /// Returns the default value for `.v5`
    @inlinable subscript(faulting withValue: T5) -> T5 {
        get { self.infer() ?? withValue }
        set { self = Self(newValue) }
    }
}


public extension OneOf5Type where T5 : Defaultable {
    /// Returns the default value for `.v5`
    @inlinable var v5faulted: T5 {
        get { self[faulting: .defaultValue] }
        set { self[faulting: .defaultValue] = newValue }
    }
}

