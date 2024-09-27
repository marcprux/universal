/**
 Copyright (c) 2015-2023 Marc Prud'hommeaux
 */
import Swift
import Either
import struct Foundation.Date
import struct Foundation.Data
import struct Foundation.URL
import struct Foundation.Decimal
import class Foundation.NSDate
import class Foundation.NSData
import class Foundation.NSURL
import class Foundation.NSDecimalNumber
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder
import class Foundation.ISO8601DateFormatter

extension JSON {
    /// Parses the given `Data` into a `JSON` structure.
    public static func parse(_ json: Data, decoder: @autoclosure () -> JSONDecoder = JSONDecoder(), allowsJSON5: Bool = true, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy? = nil, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? = nil, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = nil, userInfo: [CodingUserInfoKey : Any]? = nil) throws -> JSON {
        try JSON(fromJSON: json, decoder: decoder(), allowsJSON5: allowsJSON5, dataDecodingStrategy: dataDecodingStrategy, dateDecodingStrategy: dateDecodingStrategy, nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo)
    }

    /// Attempts to decode the given type from this JSON.
    public func decode<T: Decodable>(options: JSONDecodingOptions? = nil) throws -> T {
        try T(json: self, options: options)
    }
}


// MARK: Encoding / Decoding

private extension _JSONContainer {
    func addElement(_ element: _JSONContainer) throws {
        guard let arr = self.json.array else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Element was not an array"))
        }
        self.json = .array(arr + [element.json])
    }

    func insertElement(_ element: _JSONContainer, at index: Int) throws {
        guard var arr = self.json.array else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Element was not an array"))
        }
        arr.insert(element.json, at: index)
        self.json = .array(arr)
    }

    func setProperty(_ key: String, _ element: _JSONContainer) throws {
        guard var obj = self.json.object else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Element was not an object"))
        }
        obj[key] = element.json
        self.json = .object(obj)
    }
}

/// A set of options for decoding an entity from a `JSON` instance.
open class JSONDecodingOptions {
    /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
    open var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy

    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy

    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy

    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    open var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey : Any]

    public init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.dateDecodingStrategy = dateDecodingStrategy
        self.dataDecodingStrategy = dataDecodingStrategy
        self.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        self.keyDecodingStrategy = keyDecodingStrategy
        self.userInfo = userInfo
    }
}

/// A set of options for encoding an entity from a `JSON` instance.
open class JSONEncodingOptions {
    /// The output format to produce. Defaults to `[]`.
    open var outputFormatting: JSONEncoder.OutputFormatting

    /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
    open var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy

    /// The strategy to use in encoding binary data. Defaults to `.base64`.
    open var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy

    /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy

    /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
    open var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy

    /// Contextual user-provided information for use during encoding.
    open var userInfo: [CodingUserInfoKey : Any]

    public init(outputFormatting: JSONEncoder.OutputFormatting = .sortedKeys, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64, nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy = .throw, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.outputFormatting = outputFormatting
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
        self.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
        self.keyEncodingStrategy = keyEncodingStrategy
        self.userInfo = userInfo
    }
}

#if canImport(Combine)
import Combine
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private protocol TopLevelJEncoder : TopLevelEncoder {
}
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private protocol TopLevelJDecoder : TopLevelDecoder {
}
#else
private protocol TopLevelJEncoder {
}
private protocol TopLevelJDecoder {
}
#endif

extension Encodable {
    /// Creates an in-memory J representation of the instance's encoding.
    ///
    /// - Parameter options: the options for serializing the data
    /// - Returns: A J containing the structure of the encoded instance
    @inlinable public func json(options: JSONEncodingOptions? = nil) throws -> JSON {
        try JEncoder(options: options).encode(self)
    }
}

extension Decodable {
    /// Creates an instance from an encoded intermediate representation.
    ///
    /// A `JSON` can be created from JSON, YAML, Plists, or other similar data formats.
    /// This intermediate representation can then be used to instantiate a compatible `Decodable` instance.
    ///
    /// - Parameters:
    ///   - json: the JSON to load the instance from
    ///   - options: the options for deserializing the data such as the decoding strategies for dates and data.
    @inlinable public init(json: JSON, options: JSONDecodingOptions? = nil) throws {
        try self = JDecoder(options: options).decode(Self.self, from: json)
    }
}

@usableFromInline internal class JEncoder : TopLevelJEncoder {
    @usableFromInline let options: JSONEncodingOptions

    /// Initializes `self` with default strategies.
    @inlinable public init(options: JSONEncodingOptions? = nil) {
        self.options = options ?? JSONEncodingOptions()
    }

    /// Encodes the given top-level value and returns its script object representation.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    /// - Returns: A new `Data` value containing the encoded script object data.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    @inlinable public func encode<Value: Encodable>(_ value: Value) throws -> JSON {
        try encodeToTopLevelContainer(value)
    }

    /// Encodes the given top-level value and returns its script-type representation.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    /// - Returns: A new top-level array or dictionary representing the value.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    @usableFromInline internal func encodeToTopLevelContainer<Value: Encodable>(_ value: Value) throws -> JSON {
        let encoder = JSONElementEncoder(options: options)
        guard let topLevel = try encoder.box_(value) else {
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [],
                                                                   debugDescription: "Top-level \(Value.self) did not encode any values."))
        }

        return topLevel.json
    }
}


/// `JDecoder` facilitates the decoding of `J` values into `Decodable` types.
@usableFromInline internal class JDecoder : TopLevelJDecoder {
    @usableFromInline let options: JSONDecodingOptions

    /// Initializes `self` with default strategies.
    public init(options: JSONDecodingOptions? = nil) {
        self.options = options ?? JSONDecodingOptions()
    }

    /// Decodes a top-level value of the given type from the given script representation.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    /// - Returns: A value of the requested type.
    /// - Throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not a valid script object.
    /// - Throws: An error if any value throws an error during decoding.
    public func decode<T: Decodable>(_ type: T.Type, from data: JSON) throws -> T {
        try decode(type, fromTopLevel: data)
    }

    /// Decodes a top-level value of the given type from the given script object container (top-level array or dictionary).
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - container: The top-level script container.
    /// - Returns: A value of the requested type.
    /// - Throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not a valid script object.
    /// - Throws: An error if any value throws an error during decoding.
    @usableFromInline internal func decode<T: Decodable>(_ type: T.Type, fromTopLevel container: JSON) throws -> T {
        let decoder = _JSONDecoder(options: options, referencing: container)
        guard let value = try decoder.unbox(container, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }

        return value
    }
}


fileprivate class JSONElementEncoder: Encoder {
    fileprivate let options: JSONEncodingOptions

    /// The encoder's storage.
    fileprivate var storage: _JSONEncodingStorage

    /// The path to the current point in encoding.
    fileprivate(set) public var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }

    /// Initializes `self` with the given top-level encoder options.
    fileprivate init(options: JSONEncodingOptions, codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _JSONEncodingStorage()
        self.codingPath = codingPath
    }

    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    fileprivate var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return self.storage.count == self.codingPath.count
    }

    public func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        // If an existing keyed container was already requested, return that one.
        let topContainer: _JSONContainer
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushKeyedContainer(options)
        } else {
            guard let container = self.storage.containers.last else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        let container = _JSONKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        // If an existing unkeyed container was already requested, return that one.
        let topContainer: _JSONContainer
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            do {
                topContainer = try storage.pushUnkeyedContainer(options)
            } catch {
                fatalError("Failed to pushUnkeyedContainer: \(error)")
            }
        } else {
            guard let container = self.storage.containers.last else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        return _JSONUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

fileprivate final class _JSONContainer {
    var json: JSON
    init(json: JSON) {
        self.json = json
    }
}

// MARK: - Encoding Storage and Containers
fileprivate struct _JSONEncodingStorage {
    /// The container stack.
    /// Elements may be any one of the script types
    private(set) fileprivate var containers: [_JSONContainer] = []

    /// Initializes `self` with no containers.
    fileprivate init() {}

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate mutating func pushKeyedContainer(_ options: JSONEncodingOptions) -> _JSONContainer {
        let dictionary = _JSONContainer(json: JSON.object([:]))
        self.containers.append(dictionary)
        return dictionary
    }

    fileprivate mutating func pushUnkeyedContainer(_ options: JSONEncodingOptions) throws -> _JSONContainer {
        let array = _JSONContainer(json: JSON.array([]))
        self.containers.append(array)
        return array
    }

    fileprivate mutating func push(container: __owned _JSONContainer) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() -> _JSONContainer {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.popLast()!
    }
}

fileprivate struct _JSONUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    /// A reference to the encoder we're writing to.
    private let encoder: JSONElementEncoder

    /// A reference to the container we're writing to.
    private var container: _JSONContainer

    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]

    /// The number of elements encoded into the container.
    public var count: Int {
        container.json.count
    }

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: JSONElementEncoder, codingPath: [CodingKey], wrapping container: _JSONContainer) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    public mutating func encodeNil() throws { try container.addElement(.init(json: JSON.null)) }
    public mutating func encode(_ value: Bool) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Int) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Int8) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Int16) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Int32) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Int64) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: UInt) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: UInt8) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: UInt16) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: UInt32) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: UInt64) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Float) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Double) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: String) throws { try container.addElement(encoder.box(value)) }

    public mutating func encode<T: Encodable>(_ value: T) throws {
        self.encoder.codingPath.append(_JSONKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        try self.container.addElement(self.encoder.box(value))
    }

    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        self.codingPath.append(_JSONKey(index: self.count))
        defer { self.codingPath.removeLast() }

        let dictionary = _JSONContainer(json: JSON.object([:]))
        try? self.container.addElement(dictionary)

        let container = _JSONKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(_JSONKey(index: self.count))
        defer { self.codingPath.removeLast() }

        do {
            let array = _JSONContainer(json: JSON.array([]))
            try self.container.addElement(array)
            return _JSONUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
        } catch {
            fatalError("Failed to pushUnkeyedContainer: \(error)")
        }
    }

    public mutating func superEncoder() -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: self.container.json.count, wrapping: self.container)
    }
}

extension JSONElementEncoder: SingleValueEncodingContainer {
    private func assertCanEncodeNewValue() {
        precondition(self.canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }

    public func encodeNil() throws {
        assertCanEncodeNewValue()
        self.storage.push(container: _JSONContainer(json: JSON.null))
    }

    public func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode<T: Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try self.storage.push(container: self.box(value))
    }
}

extension JSONElementEncoder {

    /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
    fileprivate func box(_ value: Bool) -> _JSONContainer {
        .init(json: .boolean(value))
    }

    fileprivate func box(_ value: Int) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: Int8) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: Int16) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: Int32) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: Int64) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: UInt) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: UInt8) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: UInt16) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: UInt32) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: UInt64) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: Float) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: Double) -> _JSONContainer {
        .init(json: .number(.init(value)))
    }
    fileprivate func box(_ value: String) -> _JSONContainer {
        .init(json: .string(value))
    }
    fileprivate func box(_ date: Date) throws -> _JSONContainer {
        switch self.options.dateEncodingStrategy {
        case .deferredToDate:
            // Must be called with a surrounding with(pushedKey:) call.
            // Dates encode as single-value objects; this can't both throw and push a container, so no need to catch the error.
            try date.encode(to: self)
            return .init(json: self.storage.popContainer().json)

        case .secondsSince1970:
            return .init(json: .number(date.timeIntervalSince1970))

        case .millisecondsSince1970:
            return .init(json: .number(1000.0 * date.timeIntervalSince1970))

        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return .init(json: .string(_iso8601Formatter.string(from: date)))
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

        case .custom(let closure):
            let depth = self.storage.count
            do {
                try closure(date, self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                if self.storage.count > depth {
                    let _ = self.storage.popContainer()
                }

                throw error
            }

            guard self.storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return .init(json: .object([:]))
            }

            // We can pop because the closure encoded something.
            return self.storage.popContainer()

        #if !os(Linux) && swift(>=6.0) && swift(<6.1)
        // bug with Swift 6.0 on Linux: error: pattern variable binding cannot appear in an expression
        case let JSONEncoder.DateEncodingStrategy.formatted(formatter):
        //case .formatted(let formatter):
            return .init(json: .string(formatter.string(from: date)))
        #endif

        @unknown default:
            return .init(json: .string(_iso8601Formatter.string(from: date)))
        }
    }

    func box(_ data: Data) throws -> _JSONContainer {
        switch self.options.dataEncodingStrategy {
        case .deferredToData:
            // Must be called with a surrounding with(pushedKey:) call.
            let depth = self.storage.count
            do {
                try data.encode(to: self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                // This shouldn't be possible for Data (which encodes as an array of bytes), but it can't hurt to catch a failure.
                if self.storage.count > depth {
                    let _ = self.storage.popContainer()
                }

                throw error
            }

            return self.storage.popContainer()

        case .base64:
            return .init(json: .string(data.base64EncodedString()))

        case .custom(let closure):
            let depth = self.storage.count
            do {
                try closure(data, self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                if self.storage.count > depth {
                    let _ = self.storage.popContainer()
                }

                throw error
            }

            guard self.storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return .init(json: .object([:]))
            }

            // We can pop because the closure encoded something.
            return self.storage.popContainer()
        @unknown default:
            return .init(json: .string(data.base64EncodedString()))
        }
    }

    fileprivate func box<T: Encodable>(_ value: T) throws -> _JSONContainer {
        return try self.box_(value) ?? .init(json: JSON.object([:]))
    }

    fileprivate func box_<T: Encodable>(_ value: T) throws -> _JSONContainer? {
        let type = Swift.type(of: value)
        if type == Date.self || type == NSDate.self {
            return try self.box((value as! Date))
        } else if type == Data.self || type == NSData.self {
            return try self.box((value as! Data))
        } else if type == URL.self || type == NSURL.self {
            return .init(json: .string((value as! URL).absoluteString))
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            return .init(json: .number((value as! NSDecimalNumber).doubleValue))
        }

        // The value should request a container from the JSONElementEncoder.
        let depth = self.storage.count
        do {
            try value.encode(to: self)
        } catch let error {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if self.storage.count > depth {
                let _ = self.storage.popContainer()
            }

            throw error
        }

        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }

        return self.storage.popContainer()
    }
}

fileprivate struct _JSONKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K

    /// A reference to the encoder we're writing to.
    private let encoder: JSONElementEncoder

    /// A reference to the container we're writing to.
    private var container: _JSONContainer

    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: JSONElementEncoder, codingPath: [CodingKey], wrapping container: _JSONContainer) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    public mutating func encodeNil(forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .null))
    }

    public mutating func encode(_ value: Bool, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .boolean(value)))
    }

    public mutating func encode(_ value: Int, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: Int8, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: Int16, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: Int32, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: Int64, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: UInt, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: String, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .string(value)))
    }

    public mutating func encode(_ value: Float, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(.init(value))))
    }

    public mutating func encode(_ value: Double, forKey key: Key) throws {
        try container.setProperty(key.stringValue, .init(json: .number(value)))
    }

    public mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        try container.setProperty(key.stringValue, self.encoder.box(value))
    }

    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = _JSONContainer(json: JSON.object([:]))
        _ = try? self.container.setProperty(key.stringValue, dictionary)

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = _JSONKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        do {
            let array = _JSONContainer(json: JSON.array([]))
            try container.setProperty(key.stringValue, array)

            self.codingPath.append(key)
            defer { self.codingPath.removeLast() }
            return _JSONUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
        } catch {
            fatalError("Failed to nestedUnkeyedContainer: \(error)")
        }
    }

    public mutating func superEncoder() -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: _JSONKey.super, wrapping: self.container)
    }

    public mutating func superEncoder(forKey key: Key) -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: key, wrapping: self.container)
    }
}


/// `_JSONReferencingEncoder` is a special subclass of JSONElementEncoder which has its own storage, but references the contents of a different encoder.
/// It's used in `superEncoder()`, which returns a new encoder for encoding a superclass -- the lifetime of the encoder should not escape the scope it's created in, but it doesn't necessarily know when it's done being used (to write to the original container).
fileprivate class _JSONReferencingEncoder: JSONElementEncoder {
    /// The type of container we're referencing.
    private enum Reference {
        /// Referencing a specific index in an array container.
        case array(_JSONContainer, Int)

        /// Referencing a specific key in a dictionary container.
        case dictionary(_JSONContainer, String)
    }

    /// The encoder we're referencing.
    private let encoder: JSONElementEncoder

    /// The container reference itself.
    private let reference: Reference

    /// Initializes `self` by referencing the given array container in the given encoder.
    fileprivate init(referencing encoder: JSONElementEncoder, at index: Int, wrapping array: _JSONContainer) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(options: encoder.options, codingPath: encoder.codingPath)

        self.codingPath.append(_JSONKey(index: index))
    }

    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    fileprivate init(referencing encoder: JSONElementEncoder, at key: CodingKey, wrapping dictionary: _JSONContainer) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)
        super.init(options: encoder.options, codingPath: encoder.codingPath)

        self.codingPath.append(key)
    }

    fileprivate override var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return self.storage.count == self.codingPath.count - self.encoder.codingPath.count - 1
    }

    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let value: _JSONContainer
        switch self.storage.count {
        case 0: value = _JSONContainer(json: JSON.object([:]))
        case 1: value = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }

        switch self.reference {
        case .array(let array, let index):
            try? array.insertElement(value, at: index)

        case .dictionary(let dictionary, let key):
            try? dictionary.setProperty(key, value)
        }
    }
}


fileprivate class _JSONDecoder: Decoder {
    let options: JSONDecodingOptions

    /// The decoder's storage.
    fileprivate var storage: _JSONDecodingStorage

    /// The path to the current point in encoding.
    fileprivate(set) public var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }

    /// Initializes `self` with the given top-level container and options.
    fileprivate init(options: JSONDecodingOptions, referencing container: JSON, at codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _JSONDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
    }

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !(self.storage.topContainer == .null) else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let obj = self.storage.topContainer.object else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String: Any].self, reality: self.storage.topContainer)
        }

        let container = _JSONKeyedDecodingContainer<Key>(referencing: self, wrapping: obj)
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !(self.storage.topContainer == .null) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }

        guard let arr = self.storage.topContainer.array else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: self.storage.topContainer)
        }

        return _JSONUnkeyedDecodingContainer(referencing: self, wrapping: arr)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

fileprivate struct _JSONDecodingStorage {
    /// The container stack.
    /// Elements may be any one of the script types
    private(set) fileprivate var containers: [JSON] = []

    /// Initializes `self` with no containers.
    fileprivate init() {}

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate var topContainer: JSON {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.last!
    }

    fileprivate mutating func push(container: __owned JSON) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        self.containers.removeLast()
    }
}

fileprivate struct _JSONKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    /// A reference to the decoder we're reading from.
    private let decoder: _JSONDecoder

    /// A reference to the container we're reading from.
    private let container: [String: JSON]

    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]

    /// Initializes `self` by referencing the given decoder and container.
    fileprivate init(referencing decoder: _JSONDecoder, wrapping container: [String: JSON]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }

    public var allKeys: [Key] {
        return self.container.keys.compactMap { Key(stringValue: $0) }
    }

    public func contains(_ key: Key) -> Bool {
        return self.container[key.stringValue] != nil
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        (self.container[key.stringValue] == .null) != false
    }

    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Bool.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        guard let value = try self.decoder.unbox(entry, as: Float.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Double.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- no value found for key \"\(key.stringValue)\""))
        }

        guard let obj = value.object else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String: Any].self, reality: value)
        }

        let container = _JSONKeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: obj)
        return KeyedDecodingContainer(container)
    }

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested unkeyed container -- no value found for key \"\(key.stringValue)\""))
        }

        guard let array = value.array else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: value)
        }

        return _JSONUnkeyedDecodingContainer(referencing: self.decoder, wrapping: array)
    }

    private func _superDecoder(forKey key: __owned CodingKey) throws -> Decoder {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value: JSON = self.container[key.stringValue] ?? .null
        return _JSONDecoder(options: self.decoder.options, referencing: value, at: self.decoder.codingPath)
    }

    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _JSONKey.super)
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

fileprivate struct _JSONUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    /// A reference to the decoder we're reading from.
    private let decoder: _JSONDecoder

    /// A reference to the container we're reading from.
    private let container: [JSON]

    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]

    /// The index of the element we're about to decode.
    private(set) public var currentIndex: Int

    /// Initializes `self` by referencing the given decoder and container.
    fileprivate init(referencing decoder: _JSONDecoder, wrapping container: [JSON]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }

    public var count: Int? {
        return self.container.count
    }

    public var isAtEnd: Bool {
        return self.currentIndex >= self.count!
    }

    public mutating func decodeNil() throws -> Bool {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        if self.container[self.currentIndex] == .null {
            self.currentIndex += 1
            return true
        } else {
            return false
        }
    }

    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Bool.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int.Type) throws -> Int {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Float.Type) throws -> Float {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Float.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Double.Type) throws -> Double {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Double.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: String.Type) throws -> String {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        guard value != .null else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let obj = value.object else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String: JSON].self, reality: value)
        }

        self.currentIndex += 1
        let container = _JSONKeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: obj)
        return KeyedDecodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested unkeyed container -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        guard !(value == .null) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let arr = value.array else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: value)
        }

        self.currentIndex += 1
        return _JSONUnkeyedDecodingContainer(referencing: self.decoder, wrapping: arr)
    }

    public mutating func superDecoder() throws -> Decoder {
        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self, DecodingError.Context(codingPath: self.codingPath,
                                                                                  debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        self.currentIndex += 1
        return _JSONDecoder(options: self.decoder.options, referencing: value, at: self.decoder.codingPath)
    }
}

extension _JSONDecoder: SingleValueDecodingContainer {
    private func expectNonNull<T>(_ type: T.Type) throws {
        if storage.topContainer == .null {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }

    public func decodeNil() -> Bool {
        storage.topContainer == .null
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(Bool.self)
        return try self.unbox(self.storage.topContainer, as: Bool.self)!
    }

    public func decode(_ type: Int.Type) throws -> Int {
        try expectNonNull(Int.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNonNull(Int8.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNonNull(Int16.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNonNull(Int32.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNonNull(Int64.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: UInt.Type) throws -> UInt {
        try expectNonNull(UInt.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNonNull(UInt8.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNonNull(UInt16.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNonNull(UInt32.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNonNull(UInt64.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Float.Type) throws -> Float {
        try expectNonNull(Float.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Double.Type) throws -> Double {
        try expectNonNull(Double.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: String.Type) throws -> String {
        try expectNonNull(String.self)
        return try self.unbox(self.storage.topContainer, as: String.self)!
    }

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(type)
        return try self.unbox(self.storage.topContainer, as: type)!
    }
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
internal var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()


extension _JSONDecoder {
    /// Returns the given value unboxed from a container.
    fileprivate func unbox(_ value: JSON, as type: Bool.Type) throws -> Bool? {
        guard let bol = value.boolean else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        return bol
    }

    fileprivate func unboxNumber(_ value: JSON) throws -> Double {
        guard let num = value.number else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: Double.self, reality: value)
        }
        return num
    }

    fileprivate func unbox(_ value: JSON, as type: Double.Type) throws -> Double? {
        try unboxNumber(value)
    }

    fileprivate func unbox(_ value: JSON, as type: String.Type) throws -> String? {
        guard let str = value.string else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        return str
    }

    fileprivate func unbox(_ value: JSON, as type: Date.Type) throws -> Date? {
        switch options.dateDecodingStrategy {
        case .deferredToDate:
            return try Date(from: self)

        case .secondsSince1970:
            guard let number = value.number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date secondsSince1970."))
            }

            return Date(timeIntervalSince1970: number)

        case .millisecondsSince1970:
            guard let number = value.number else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date millisecondsSince1970."))
            }

            return Date(timeIntervalSince1970: number / 1000.0)

        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                guard let string = value.string,
                      let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }

                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

        case .custom(let closure):
            return try closure(self)

        #if !os(Linux) && swift(>=6.0) && swift(<6.1)
        // bug with Swift 6.0 on Linux: error: pattern variable binding cannot appear in an expression
        case let JSONDecoder.DateDecodingStrategy.formatted(formatter):
        //case .formatted(let formatter):
            guard let string = value.string else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
            }
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            return date
        #endif

        @unknown default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unhandled date decoding strategy."))
        }
    }

    fileprivate func unbox(_ value: JSON, as type: Data.Type) throws -> Data? {
        switch options.dataDecodingStrategy {
        case .deferredToData:
            return try Data(from: self)

        case .base64:
            guard let string = value.string else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected data to be Base64."))
            }

            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }

            return data

        case .custom(let closure):
            return try closure(self)

        @unknown default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unhandled data decoding strategy."))
        }
    }

    fileprivate func unbox(_ value: JSON, as type: URL.Type) throws -> URL? {
        guard let string = value.string else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected URL string."))
        }

        return URL(string: string)
    }

    fileprivate func unbox<T: Decodable>(_ value: JSON, as type: T.Type) throws -> T? {
        if type == Date.self || type == NSDate.self {
            return try self.unbox(value, as: Date.self) as? T
        } else if type == Data.self || type == NSData.self {
            return try self.unbox(value, as: Data.self) as? T
        } else if type == URL.self || type == NSURL.self {
            return try self.unbox(value, as: URL.self) as? T
        } else {
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try type.init(from: self)
        }
    }
}

extension DecodingError {
    /// Returns a `.typeMismatch` error describing the expected type.
    ///
    /// - Parameters:
    ///   - path: The path of `CodingKey`s taken to decode a value of this type.
    ///   - expectation: The type expected to be encountered.
    ///   - reality: The value that was encountered instead of the expected type.
    /// - Returns: A `DecodingError` with the appropriate path and debug description.
    internal static func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: Any) -> DecodingError {
        let description = "Expected to decode \(expectation) but found \(type(of: reality)) instead."
        return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
    }
}

fileprivate struct _JSONKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    fileprivate init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    fileprivate static let `super` = _JSONKey(stringValue: "super")!
}

public extension Decodable {
    /// Initialized this instance from a JSON string
    init(fromJSON json: Data, decoder: @autoclosure () -> JSONDecoder = JSONDecoder(), allowsJSON5: Bool = true, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy? = nil, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? = nil, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = nil, userInfo: [CodingUserInfoKey : Any]? = nil) throws {
        let decoder = decoder()
        #if XXX && !os(Linux) && !os(Android) && !os(Windows)
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            decoder.allowsJSON5 = allowsJSON5
        }
        #endif

        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }

        if let dataDecodingStrategy = dataDecodingStrategy {
            decoder.dataDecodingStrategy = dataDecodingStrategy
        }

        if let nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy {
            decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        }

        if let keyDecodingStrategy = keyDecodingStrategy {
            decoder.keyDecodingStrategy = keyDecodingStrategy
        }

        if let userInfo = userInfo {
            decoder.userInfo = userInfo
        }

        self = try decoder.decode(Self.self, from: json)
    }
}

extension Encodable {
    /// Encode this instance as JSON data
    /// - Parameters:
    ///   - encoder: the encoder to use, defaulting to a stock `JSONEncoder`
    ///   - outputFormatting: formatting options, defaulting to `.sortedKeys` and `.withoutEscapingSlashes`
    ///   - dateEncodingStrategy: the strategy for decoding `Date` instances
    ///   - dataEncodingStrategy: the strategy for decoding `Data` instances
    ///   - nonConformingFloatEncodingStrategy: the strategy for handling non-conforming floats
    ///   - keyEncodingStrategy: the strategy for encoding keys
    ///   - userInfo: additional user info to pass to the encoder
    /// - Returns: the JSON-encoded `Data`
    @inlinable public func toJSON(encoder: @autoclosure () -> JSONEncoder = JSONEncoder(), outputFormatting: JSONEncoder.OutputFormatting? = nil, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil, nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil, userInfo: [CodingUserInfoKey : Any]? = nil) throws -> Data {
        let formatting: JSONEncoder.OutputFormatting
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            formatting = outputFormatting ?? [.sortedKeys, .withoutEscapingSlashes]
        } else {
            formatting = outputFormatting ?? [.sortedKeys]
        }

        let encoder = encoder()
        //if let formatting = formatting {
            encoder.outputFormatting = formatting
        //}

        if let dateEncodingStrategy = dateEncodingStrategy {
            encoder.dateEncodingStrategy = dateEncodingStrategy
        }

        if let dataEncodingStrategy = dataEncodingStrategy {
            encoder.dataEncodingStrategy = dataEncodingStrategy
        }

        if let nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy {
            encoder.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
        }

        if let keyEncodingStrategy = keyEncodingStrategy {
            encoder.keyEncodingStrategy = keyEncodingStrategy
        }

        if let userInfo = userInfo {
            encoder.userInfo = userInfo
        }

        let data = try encoder.encode(self)
        return data
    }

    /// Returns the pretty-printed form of the JSON
    public var prettyJSON: String {
        get throws {
            try toJSON(encoder: prettyJSONEncoder).utf8String ?? "{}"
        }
    }

    /// Returns the canonical form of the JSON.
    ///
    /// The encoder replicates JSON Canonical form [JSON Canonicalization Scheme (JCS)](https://tools.ietf.org/id/draft-rundgren-json-canonicalization-scheme-05.html)
    public var canonicalJSON: String {
        get throws {
            try toJSON(encoder: canonicalJSONEncoder).utf8String ?? "{}"
        }
    }

    /// Returns the debug form of the JSON
    public var debugJSON: String {
        get throws {
            try toJSON(encoder: debugJSONEncoder).utf8String ?? "{}"
        }
    }
}

private let debugJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    } else {
        encoder.outputFormatting = [.sortedKeys]
    }
    encoder.dateEncodingStrategy = .iso8601
    encoder.dataEncodingStrategy = .base64
    return encoder
}()

private let debugJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.dataDecodingStrategy = .base64
    return decoder
}()

private let prettyJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    } else {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    encoder.dateEncodingStrategy = .iso8601
    encoder.dataEncodingStrategy = .base64
    return encoder
}()

/// An encoder that replicates JSON Canonical form [JSON Canonicalization Scheme (JCS)](https://tools.ietf.org/id/draft-rundgren-json-canonicalization-scheme-05.html)
let canonicalJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys] // must not use .withoutEscapingSlashes
    encoder.dateEncodingStrategy = .iso8601
    encoder.dataEncodingStrategy = .base64
    return encoder
}()




extension Decodable where Self : Encodable {

    /// Parses this codable into the given data structure, along with a raw `JSON`
    /// that will be used to verify that the codable instance contains all the expected properties.
    ///
    /// - Parameters:
    ///   - data: the data to parse by the Codable and the JSON
    ///   - encoder: the custom encoder to use, or `nil` to use the system default
    ///   - decoder: the custom decoder to use, or `nil` to use the system default
    /// - Returns: a tuple with both the parsed codable instance, as well as an optional `difference` JSON that will be nil if the codability was an exact match
    public static func codableComplete(data: Data, encoder: JSONEncoder? = nil, decoder: JSONDecoder? = nil) throws -> (instance: Self, difference: JSON?) {
        let item = try (decoder ?? debugJSONDecoder).decode(Self.self, from: data)
        let itemJSON = try item.toJSON(encoder: encoder ?? canonicalJSONEncoder).utf8String

        // parse into a generic JSON and ensure that both the items are serialized the same
        let raw = try (decoder ?? debugJSONDecoder).decode(JSON.self, from: data)
        let rawJSON = try raw.toJSON(encoder: encoder ?? canonicalJSONEncoder).utf8String

        return (instance: item, difference: itemJSON == rawJSON ? JSON?.none : raw)
    }
}

extension Data {
    /// The UTF8-encoded String for this data
    @inlinable public var utf8String: String? {
        String(data: self, encoding: .utf8)
    }
}

extension StringProtocol {
    /// The UTF8-encoded data for this string
    @inlinable public var utf8Data: Data {
        data(using: .utf8) ?? Data(utf8) // should never fail, but if so, fall back to wrapping the utf8 data bytes
    }
}

