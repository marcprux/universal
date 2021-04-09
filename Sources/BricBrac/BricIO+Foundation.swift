//
//  BricIO+Cocoa.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 7/20/15.
//  Copyright © 2010-2020 io.glimpse. All rights reserved.
//

#if canImport(Foundation)

import Foundation

public extension JSONSchema {
    /// We heard you liked `JSONSchema` so we put some `JSONSchema` in your `JSONSchema`.
    static let schemaSchema = Result { try JSONSchema.parseJSON(JSONSchema.schemaSource) }
}

extension Decodable {
    /// Initializes the instance by de-serializeing the JSON from the in-memory `Bric` instance.
    @inlinable public init(bric: Bric, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) throws {
        self = try decoder.decode(Self.self, from: encoder.encode(bric))
    }

    /// Loads this `Decodable` from the JSON stored in the given URL.
    @inlinable public static func loadJSON(url: URL) throws -> Self {
        try loadFromJSON(data: Data(contentsOf: url))
    }

    /// Loads this `Decodable` from the JSON stored in the given data.
    @inlinable public static func loadFromJSON(data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }

    /// Instantiates the given type by parsing the JSON string.
    @inlinable public static func parseJSON(_ json: String, using decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        try decoder.decode(Self.self, from: json.data(using: .utf8) ?? .init())
    }
}

extension UUID : IdentifierString {
    public init?(identifierString string: String) { self.init(uuidString: string) }
    public var identifierString: String { uuidString }

    /// Returns a fixed UUID with the value of the arguments in least-signficant-first oeder.
    ///
    /// Examples:
    /// ```
    /// fixedUUID() => "00000000-0000-0000-0000-000000000000"
    /// fixedUUID(0) => "00000000-0000-0000-0000-000000000000"
    /// fixedUUID(1) => "00000000-0000-0000-0000-000000000001"
    /// fixedUUID(2) => "00000000-0000-0000-0000-000000000002"
    /// fixedUUID(255) => "00000000-0000-0000-0000-0000000000FF"
    /// fixedUUID(.max) => "00000000-0000-0000-0000-0000000000FF"
    /// fixedUUID(1, 2) => "00000000-0000-0000-0000-000000000201"
    /// fixedUUID(1, 2, 0, 3) => "00000000-0000-0000-0000-000003000201"
    /// fixedUUID(.max, .max, .max, .max, .max, .max, .max, .max, .max, .max, .max, .max, .max, .max, .max, .max) => "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    /// ```
    @inlinable public static func fixedUUID(_ ids: UInt8...) -> Self {
        UUID(uuid: (ids.count > 15 ? ids[15] : 0,
                    ids.count > 14 ? ids[14] : 0,
                    ids.count > 13 ? ids[13] : 0,
                    ids.count > 12 ? ids[12] : 0,
                    ids.count > 11 ? ids[11] : 0,
                    ids.count > 10 ? ids[10] : 0,
                    ids.count > 9 ? ids[9] : 0,
                    ids.count > 8 ? ids[8] : 0,
                    ids.count > 7 ? ids[7] : 0,
                    ids.count > 6 ? ids[6] : 0,
                    ids.count > 5 ? ids[5] : 0,
                    ids.count > 4 ? ids[4] : 0,
                    ids.count > 3 ? ids[3] : 0,
                    ids.count > 2 ? ids[2] : 0,
                    ids.count > 1 ? ids[1] : 0,
                    ids.count > 0 ? ids[0] : 0))
    }
}

extension IndexPath : Defaultable { } // inherits initializer from ExpressibleByArrayLiteral

public extension IndexPath {
    /// Symbolic constant for the root of a tree (which is simply an empty index path)
    static let root: IndexPath = []
}

private func createJSONEncoder(_ outputFormatting: JSONEncoder.OutputFormatting, sortedKeys: Bool, withoutEscapingSlashes: Bool) -> JSONEncoder {
    let encoder = JSONEncoder()
    var fmt = outputFormatting

    if sortedKeys, #available(macOS 10.13, iOS 13.0, *) {
        fmt = fmt.union(.sortedKeys)
    }

    if withoutEscapingSlashes, #available(macOS 10.15, iOS 13.0, *) {
        fmt = fmt.union(.withoutEscapingSlashes)
    }

    encoder.outputFormatting = fmt
    return encoder
}

public extension Bric {
    /// Singleton JSON encoder used for encoding; must be public to permit use as default arg;
    /// “On iOS 7 and later and macOS 10.9 and later JSONSerialization is thread safe.”
    static let JSONEncoderUnsorted = createJSONEncoder([], sortedKeys: false, withoutEscapingSlashes: true) // we want it to be unsorted

    /// Singleton JSON encoder used for encoding; must be public to permit use as default arg;
    /// “On iOS 7 and later and macOS 10.9 and later JSONSerialization is thread safe.”
    static let JSONEncoderSorted = createJSONEncoder([], sortedKeys: true, withoutEscapingSlashes: true) // we want consistent key ordering

    static let JSONEncoderFormatted = createJSONEncoder([.prettyPrinted], sortedKeys: true, withoutEscapingSlashes: true)
}

public extension Encodable {
    /// Returns a simple debug description of the JSON encoding of the given `Encodable`.
    var jsonDebugDescription: String { (try? encodedStringSorted()) ?? "{}" }
}

public extension JSONEncoder {
    /// Merely calls `encode` with the given value, but permits fragmentary elements to be encoded.
    /// This is similar to `JSONSerialization.ReadingOptions.allowFragments`, but for writing.
    func encodeFragment<T: Encodable>(_ value: T) throws -> Data {
        do {
            return try self.encode(value) // attempt to just encode the value
        } catch {
            let data = try self.encode([value]) // wrap it in an array…
            let whitespace = Set(" \n\r\t".utf8)
            return Data(data.dropFirst().drop(while: whitespace.contains).reversed().dropFirst().drop(while: whitespace.contains).reversed()) // …and trim the enclosing array boundry and and whitespace
        }
    }
}

public extension JSONDecoder {
    private static let openBrace: Data = "[".data(using: .utf8)!
    private static let closeBrace: Data = "]".data(using: .utf8)!

    /// Merely calls `decode` with the given value, but permits fragmentary elements to be encoded.
    /// This is similar to `JSONSerialization.ReadingOptions.allowFragments`.
    func decodeFragment<T: Decodable>(_ valueType: T.Type, from data: Data) throws -> T? {
        let values = try self.decode(Array<T>.self, from: Self.openBrace + data + Self.closeBrace)

        if values.count != 1 {
            return nil // we don't throw an error because we want to be able to indicate that the value was empty (e.g, just whitespace)
        }
        return values[0]
    }
}

public extension Encodable {
    /// Returns an encoded string for the given encoder (defaulting to a JSON encoder);
    /// this is somewhat faster than `encodedStringSorted` because it returns unordered keys.
    ///
    /// Example: for a 2.3MB JSON, this has been seen to be almost 3x faster (269ms vs. 769ms)
    @inlinable func encodedString() throws -> String {
        return String(data: try Bric.JSONEncoderUnsorted.encode(self), encoding: .utf8) ?? "{}"
    }

    /// Returns an encoded string for the given encoder (defaulting to a JSON encoder);
    /// this is somewhat slower than `encodedString` because it returns unordered keys.
    ///
    /// Example: for a 2.3MB JSON, this has been seen to be almost 3x slower (269ms vs. 769ms)
    @inlinable func encodedStringSorted(encoder: (Self) throws -> (Data) = Bric.JSONEncoderSorted.encode) rethrows -> String {
        return String(data: try encoder(self), encoding: .utf8) ?? "{}"
    }

    /// Returns an pretty-printed encoded string for the encodable.
    @inlinable func encodedStringFormatted() throws -> String {
        return String(data: try Bric.JSONEncoderFormatted.encode(self), encoding: .utf8) ?? "{}"
    }

    /// The result of a call with the default parameters to `bricEncoded()`.
    /// `memoz`-able.
    @inlinable var bricResult: Result<Bric, Error> {
        Result { try bricEncoded() }
    }

    /// Takes an Encodable instance and serialies it to JSON and then parses it as a Bric.
    /// This only works for top-level encodable properties (i.e., Array and Dictionary, but not String, Double, or Boolean).
    /// Full support would require a custom JSONEncoder to encode directly as a Bric.
    @inlinable func bricEncoded(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil, nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil, userInfo: [CodingUserInfoKey : Any]? = nil) throws -> Bric {
        let encoder = JSONEncoder()

        if let dateEncodingStrategy = dateEncodingStrategy { encoder.dateEncodingStrategy = dateEncodingStrategy }
        if let dataEncodingStrategy = dataEncodingStrategy { encoder.dataEncodingStrategy = dataEncodingStrategy }
        if let nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy { encoder.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy }
        if let userInfo = userInfo { encoder.userInfo = userInfo }
        
        let data = try encoder.encode(self)
        guard let str = String(data: data, encoding: .utf8) else { return .nul } // unlikely
        return try Bric.parse(str)
    }
}

public extension Encodable where Self : Hashable {
    /// A `memoz`-compatible key for the encoded string
    var formattedJSON: Result<String, Error> {
        Result { try self.encodedStringFormatted() }
    }

    /// A `memoz`-compatible key for the encoded string
    var unformattedJSON: Result<String, Error> {
        Result { try self.encodedString() }
    }
}

public extension JSONEncoder {
    /// Encodes the given `Encodable` using custom key ordering.
    /// This function will return any `OrderedCodingKey` instances in the order they are declared (at the cost of some expensive post-processing on the data)
    ///
    /// - See Also: `OrderedCodingKey`
    /// - Note: Unlike `JSONEncoder.encode`, this function is not thread-safe due to needing to modify internal properties of the `JSONEncoder`.
    /// - Note: The underlying impementation is a *total* hack – it swaps out key names with a prefix that can be lexically sorted by the built in `sortedKeys` key, and then post-processes the underlying raw data to get rid of the key prefixes (thus restoring the original key names)
    @available(macOS 10.13, iOS 13.0, *)
    func encodeOrdered<T: Encodable>(_ value: T) throws -> Data {
        // we need to sort the keys in order for our replacement scheme to work
        let hadSorted = self.outputFormatting.contains(.sortedKeys)
        if !hadSorted { self.outputFormatting.insert(.sortedKeys) } // add the `sortedKeys` formatting…
        defer { if !hadSorted { self.outputFormatting.remove(.sortedKeys) } } // …then remove it afterwards

        // we use a custom keyEncodingStrategy to enable sorting by custom keys
        let prevEncodingStrategy = self.keyEncodingStrategy
        defer { self.keyEncodingStrategy = prevEncodingStrategy }

        // while JSONEncoder doesn't let us specify a custom sort order for keys, but can use a `KeyEncodingStrategy.custom`
        // to replace any keys that have specified an ordering with a prefix that contains the desired ordering,
        // so that when it is later sorted (due to `OutputFormatting.sortedKeys`), it will show up in the correct order.
        let orderPrefix = "@#_KEYORDER___"
        let indexDigits = 5 // a max of 99,999 keys should be sufficient
        let keylen = orderPrefix.count + indexDigits
        func keyPrefix(index: Int) -> String {
            let key = index.description
            let padzeros = indexDigits - key.count
            if padzeros <= 0 {
                return orderPrefix + key
            } else { // convert "keyName" to "@__KEYORDER___00009keyName"
                return orderPrefix + String(repeating: "0", count: padzeros) + key
            }
        }

        self.keyEncodingStrategy = .custom({ (keys) -> CodingKey in
            let lastKey = keys.last ?? AnyCodingKey(stringValue: "key")

            guard let orderedKey = lastKey as? OrderedCodingKey else {
                return lastKey
            }

            if orderedKey.intValue != nil {
                return lastKey // we don't support custom ordering for int key
            }

            guard let index = orderedKey.keyOrder else {
                return lastKey
            }

            // convert the key "key" to "@#_KEYORDER___00009key"
            return AnyCodingKey(stringValue: keyPrefix(index: index) + lastKey.stringValue)
        })

        var data = try self.encode(value)

        // now post-process the encoded data to excise out any "@#_KEYORDER___12345" substrings, thus restoring the original keys
        if let orderPrefixData = orderPrefix.data(using: .utf8) { // JSON encoding is always UTF8
            for i in data.indices.reversed() { // go from back to front so we can remove data chunks with impunity
                if data[i...].starts(with: orderPrefixData) { // Data slice subscript is complexity: O(1)
                    data.removeSubrange(i..<i+keylen) // remove the prefix, along with the key number; the prefix is a fixed length, so we can simply cut out the raw bytes without needing to look at the contents
                }
            }
        }

        return data
    }
}

public extension Encodable {
    /// Returns an encoded string for the encodable with a custom key ordering for types whose `CodingKey` conforms to `OrderedCodingKey`
    /// This function will return any `OrderedCodingKey` instances in the order they are declared (at the cost of some expensive post-processing on the data)
    @available(macOS 10.15, iOS 13.0, *)
    func encodedStringOrdered(format: JSONEncoder.OutputFormatting = [.prettyPrinted, .withoutEscapingSlashes]) throws -> String {
        let encoder = JSONEncoder()
        return String(data: try encoder.encodeOrdered(self), encoding: .utf8) ?? "{}"
    }
}

/// A key that specifies a sort order for encoding.
/// - See Also: `Encodable.encodedStringOrdered`
public protocol OrderedCodingKey : CodingKey {
    /// The sort order of the key, if any.
    /// - See Also: `Encodable.encodedStringOrdered`
    var keyOrder: Int? { get }
}

public extension OrderedCodingKey where Self : CaseIterable & Equatable {
    /// The default key ordering for an `OrderedCodingKey` is the position of this key in its `allCases` list.
    /// - See Also: `Encodable.encodedStringOrdered`
    /// - Complexity: O(N) on the number of keys
    var keyOrder: Self.AllCases.Index? {
        // this could be optimized by caching a [Self: Index] in the type, but we'd need to manually cache it separately in each type since protocol extension cannot have stored static properties
        Self.allCases.firstIndex(of: self)
    }
}

extension Bric : Encodable {
    @inlinable public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .nul: try container.encodeNil()
        case .bol(let x): try container.encode(x)
        case .num(let x): try container.encode(x)
        case .str(let x): try container.encode(x)
        case .obj(let x): try container.encode(x)
        case .arr(let x): try container.encode(x)
        }
    }
}

extension Bric : Decodable {
    @inlinable public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        func decode<T: Decodable>() throws -> T { try container.decode(T.self) }
        if container.decodeNil() {
            self = .nul
        }  else {
            do {
                self = try .bol(decode())
            } catch DecodingError.typeMismatch {
                do {
                    self = try .num(decode())
                } catch DecodingError.typeMismatch {
                    do {
                        self = try .str(decode())
                    } catch DecodingError.typeMismatch {
                        do {
                            self = try .obj(decode())
                        } catch DecodingError.typeMismatch {
                            do {
                                self = try .arr(decode())
                            } catch DecodingError.typeMismatch {
                                throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
                            }
                        }
                    }
                }
            }
        }
    }
}

public extension Bricable {
    /// Decode this bric into a decodable instance
    @inlinable func decode<T: Decodable>(_ type: T.Type, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy? = nil, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? = nil, userInfo: [CodingUserInfoKey : Any]? = nil) throws -> T {
        let decoder = JSONDecoder()
        
        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }
        
        if let dataDecodingStrategy = dataDecodingStrategy {
            decoder.dataDecodingStrategy = dataDecodingStrategy
        }
        
        if let nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy {
            decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        }
        
        if let userInfo = userInfo {
            decoder.userInfo = userInfo
        }

        return try decoder.decode(type, from: Bric.JSONEncoderUnsorted.encode(self.bric()))
    }
}

public extension Bric {

    /// Validates the given JSON string and throws an error if there was a problem
    static func parseCocoa(_ string: String, options: JSONParser.Options = .CocoaCompat) throws -> NSObject {
        return try FoundationBricolage.parseJSON(Array(string.unicodeScalars), options: options).object
    }

    /// Validates the given array of unicode scalars and throws an error if there was a problem
    static func parseCocoa(_ scalars: [UnicodeScalar], options: JSONParser.Options = .CocoaCompat) throws -> NSObject {
        return try FoundationBricolage.parseJSON(scalars, options: options).object
    }
}


/// Bricolage that represents the elements as Cocoa NSObject types with reference semantics
public final class FoundationBricolage: NSObject, Bricolage {
    public typealias NulType = NSNull
    public typealias BolType = NSNumber
    public typealias StrType = NSString
    public typealias NumType = NSNumber
    public typealias ArrType = NSMutableArray
    public typealias ObjType = NSMutableDictionary

    public let object: NSObject

    public init(str: StrType) { self.object = str }
    public init(num: NumType) { self.object = num }
    public init(bol: BolType) { self.object = bol }
    public init(arr: ArrType) { self.object = arr }
    public init(obj: ObjType) { self.object = obj }
    public init(nul: NulType) { self.object = nul }
    public convenience init(encodable: BricolageEncodable) {
        switch encodable {
        case .null: self.init(nul: NulType())
        case .bool(let x): self.init(bol: x as BolType)
        case .int(let x): self.init(num: x as NumType)
        case .int8(let x): self.init(num: x as NumType)
        case .int16(let x): self.init(num: x as NumType)
        case .int32(let x): self.init(num: x as NumType)
        case .int64(let x): self.init(num: x as NumType)
        case .uint(let x): self.init(num: x as NumType)
        case .uint8(let x): self.init(num: x as NumType)
        case .uint16(let x): self.init(num: x as NumType)
        case .uint32(let x): self.init(num: x as NumType)
        case .uint64(let x): self.init(num: x as NumType)
        case .string(let x): self.init(str: x as StrType)
        case .float(let x): self.init(num: x as NumType)
        case .double(let x): self.init(num: x as NumType)
        }
    }

    public static func createNull() -> NulType { return NSNull() }
    public static func createTrue() -> BolType { return true }
    public static func createFalse() -> BolType { return false }
    public static func createObject() -> ObjType { return ObjType() }
    public static func createArray() -> ArrType { return ArrType() }

    public static func createString(_ scalars: [UnicodeScalar]) -> StrType? {
        return String(String.UnicodeScalarView() + scalars) as NSString
    }

    public static func createNumber(_ scalars: [UnicodeScalar]) -> NumType? {
        if let str: NSString = createString(Array(scalars)) {
            return NSDecimalNumber(string: str as String) // needed for 0.123456789e-12
        } else {
            return nil
        }
    }

    public static func putKeyValue(_ obj: ObjType, key: StrType, value: FoundationBricolage) -> ObjType {
        obj.setObject(value.object, forKey: key)
        return obj
    }

    public static func putElement(_ arr: ArrType, element: FoundationBricolage) -> ArrType {
        arr.add(element.object)
        return arr
    }
}

public extension FoundationBricolage {
    /// Try to create from a the given primitive object, returning `nil` if the object is not one of the Bricolage types.
    /// Arrays and Objects are not supported, and will return `nil`.
    @inlinable convenience init?(primitive object: NSObject) {
        if let str = object as? NSString {
            self.init(str: str)
        } else if let num = object as? NSNumber {
            if Self.bolTypes.contains(String(cString: num.objCType)) {
                self.init(bol: num)
            } else {
                self.init(num: num)
            }
        } else if let null = object as? NSNull {
            self.init(nul: null)
        } else {
            return nil
        }
    }

    /// Returns the Cocoa wrapper from the given bric.
    @inlinable static func primitiveValue(for bric: Bric) -> NSObject? {
        switch bric {
        case .arr: return nil // not primitive
        case .obj: return nil // not primitive
        case .str(let str): return str as NSString
        case .num(let num): return num as NSNumber
        case .bol(let bol): return bol as NSNumber
        case .nul: return NSNull()
        }
    }

    /// Returns the Cocoa wrapper from the given bric.
    @inlinable static func cocoaValue(for bric: Bric) -> NSObject {
        switch bric {
        case .arr(let arr): return arr as NSArray
        case .obj(let obj): return obj as NSDictionary
        case .str(let str): return str as NSString
        case .num(let num): return num as NSNumber
        case .bol(let bol): return bol as NSNumber
        case .nul: return NSNull()
        }
    }

}

extension FoundationBricolage : Bricable, Bracable {
    @inlinable public func bric() -> Bric {
        return FoundationBricolage.toBric(object)
    }

    @usableFromInline static let bolTypes = Set(arrayLiteral: "B", "c") // "B" on 64-bit, "c" on 32-bit
    @usableFromInline static func toBric(_ object: Any) -> Bric {
        if let bol = object as? BolType, bolTypes.contains(String(cString: bol.objCType)) {
            if let b = bol as? Bool {
                return Bric.bol(b)
            } else {
                return Bric.bol(false)
            }
        }
        if let str = object as? StrType {
            return Bric.str(str as String)
        }
        if let num = object as? NumType {
            if let d = num as? Double {
                return Bric.num(d)
            } else {
                return Bric.num(0.0)
            }
        }
        if let arr = object as? ArrType {
            return Bric.arr(arr.map(toBric))
        }
        if let obj = object as? ObjType {
            var dict: [String: Bric] = [:]
            for (key, value) in obj {
                dict[String(describing: key)] = toBric(value as AnyObject)
            }
            return Bric.obj(dict)
        }

        return Bric.nul
    }

    public static func brac(bric: Bric) -> FoundationBricolage {
        switch bric {
        case .nul:
            return FoundationBricolage(nul: FoundationBricolage.createNull())
        case .bol(let bol):
            return FoundationBricolage(bol: bol ? FoundationBricolage.createTrue() : FoundationBricolage.createFalse())
        case .str(let str):
            return FoundationBricolage(str: FoundationBricolage.StrType(string: str))
        case .num(let num):
            return FoundationBricolage(num: FoundationBricolage.NumType(value: num))
        case .arr(let arr):
            let nsarr = FoundationBricolage.createArray()
            for a in arr {
                _ = FoundationBricolage.putElement(nsarr, element: FoundationBricolage.brac(bric: a))
            }
            return FoundationBricolage(arr: nsarr)
        case .obj(let obj):
            let nsobj = FoundationBricolage.createObject()
            for (k, v) in obj {
                _ = FoundationBricolage.putKeyValue(nsobj, key: k as NSString, value: FoundationBricolage.brac(bric: v))
            }
            return FoundationBricolage(obj: nsobj)
        }
    }
}

#if canImport(CoreFoundation) // not Windows
#if !os(Linux) // Linux's CoreFoundation doesn't expose `CFNull`, etc.
/// Bricolage that represents the elements as Core Foundation types with reference semantics
public final class CoreFoundationBricolage: Bricolage {
    public typealias NulType = CFNull
    public typealias BolType = CFBoolean
    public typealias StrType = CFString
    public typealias NumType = CFNumber
    public typealias ArrType = CFMutableArray
    public typealias ObjType = CFMutableDictionary

    public let ptr: UnsafeMutableRawPointer

    public init(str: StrType) { self.ptr = Unmanaged.passRetained(str).toOpaque() }
    public init(num: NumType) { self.ptr = Unmanaged.passRetained(num).toOpaque() }
    public init(bol: BolType) { self.ptr = Unmanaged.passRetained(bol).toOpaque() }
    public init(arr: ArrType) { self.ptr = Unmanaged.passRetained(arr).toOpaque() }
    public init(obj: ObjType) { self.ptr = Unmanaged.passRetained(obj).toOpaque() }
    public init(nul: NulType) { self.ptr = Unmanaged.passRetained(nul).toOpaque() }
    public convenience init(encodable: BricolageEncodable) {
        switch encodable {
        case .null: self.init(nul: kCFNull)
        case .bool(let x): self.init(bol: x as BolType)
        case .int(let x): self.init(num: x as NumType)
        case .int8(let x): self.init(num: x as NumType)
        case .int16(let x): self.init(num: x as NumType)
        case .int32(let x): self.init(num: x as NumType)
        case .int64(let x): self.init(num: x as NumType)
        case .uint(let x): self.init(num: x as NumType)
        case .uint8(let x): self.init(num: x as NumType)
        case .uint16(let x): self.init(num: x as NumType)
        case .uint32(let x): self.init(num: x as NumType)
        case .uint64(let x): self.init(num: x as NumType)
        case .string(let x): self.init(str: x as StrType)
        case .float(let x): self.init(num: x as NumType)
        case .double(let x): self.init(num: x as NumType)
        }
    }

    deinit {
        Unmanaged<AnyObject>.fromOpaque(ptr).release()
    }

    public static func createNull() -> NulType { return kCFNull }
    public static func createTrue() -> BolType { return kCFBooleanTrue }
    public static func createFalse() -> BolType { return kCFBooleanFalse }
    public static func createObject() -> ObjType { return CFDictionaryCreateMutable(nil, 0, nil, nil) }
    public static func createArray() -> ArrType { return CFArrayCreateMutable(nil, 0, nil) }

    public static func createString(_ scalars: [UnicodeScalar]) -> StrType? {
        return String(String.UnicodeScalarView() + scalars) as CoreFoundationBricolage.StrType?
    }

    public static func createNumber(_ scalars: [UnicodeScalar]) -> NumType? {
        if let str = createString(Array(scalars)) {
            return NSDecimalNumber(string: str as String) // needed for 0.123456789e-12
        } else {
            return nil
        }
    }

    public static func putKeyValue(_ obj: ObjType, key: StrType, value: CoreFoundationBricolage) -> ObjType {
        CFDictionarySetValue(obj, UnsafeRawPointer(Unmanaged<CFString>.passRetained(key).toOpaque()), value.ptr)
        return obj
    }

    public static func putElement(_ arr: ArrType, element: CoreFoundationBricolage) -> ArrType {
        CFArrayAppendValue(arr, element.ptr)
        return arr
    }
}
#endif
#endif

#endif
