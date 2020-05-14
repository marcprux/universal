//
//  BricIO+Cocoa.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 7/20/15.
//  Copyright © 2010-2020 io.glimpse. All rights reserved.
//

#if canImport(Foundation)

import Foundation
import CoreFoundation

extension Decodable {
    /// Any decodable can be brac'd from a Bric via the built-in decoding
    @inlinable public static func bracDecoded(bric: Bric, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) throws -> Self {
        return try decoder.decode(Self.self, from: encoder.encode(bric))
    }

    /// Loads this `Decodable` from the JSON stored in the given URL.
    @inlinable public static func loadJSON(url: URL) throws -> Self {
        try loadFromJSON(data: Data(contentsOf: url))
    }

    /// Loads this `Decodable` from the JSON stored in the given URL.
    @inlinable public static func loadFromJSON(data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}


private func createJSONEncoder(_ outputFormatting: JSONEncoder.OutputFormatting) -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = outputFormatting
    return encoder
}

/// Singleton JSON encoder used for encoding; must be public to permit use as default arg;
/// “On iOS 7 and later and macOS 10.9 and later JSONSerialization is thread safe.”
@available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
public let BricBracSharedSortedJSONEncoder = createJSONEncoder([.sortedKeys, .withoutEscapingSlashes]) // we want consistent key ordering

/// Singleton JSON encoder used for encoding; must be public to permit use as default arg;
/// “On iOS 7 and later and macOS 10.9 and later JSONSerialization is thread safe.”
public let BricBracSharedUnsortedJSONEncoder = createJSONEncoder([.withoutEscapingSlashes]) // we want it to be unsorted

@available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
public let BricBracSharedFormattedJSONEncoder = createJSONEncoder([.sortedKeys, .withoutEscapingSlashes, .prettyPrinted])


public extension Encodable {
    /// Returns a simple debug description of the JSON encoding of the given `Encodable`.
    var jsonDebugDescription: String { (try? encodedStringOrdered()) ?? "{}" }
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
    /// Returns an encoded string for the given encoder (defaulting to a JSON encoder)
    @available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
    @available(*, deprecated, renamed: "encodedStringOrdered")
    @inlinable func encodedString() throws -> String {
        try encodedStringOrdered()
    }

    /// Returns an encoded string for the given encoder (defaulting to a JSON encoder);
    /// this is somewhat slower than `encodedStringUnordered` because it returns unordered keys.
    ///
    /// Example: for a 2.3MB JSON, this has been seen to be almost 3x slower (269ms vs. 769ms)
    @available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
    @inlinable func encodedStringOrdered(encoder: (Self) throws -> (Data) = BricBracSharedSortedJSONEncoder.encode) rethrows -> String {
        return String(data: try encoder(self), encoding: .utf8) ?? "{}"
    }

    /// Returns an encoded string for the given encoder (defaulting to a JSON encoder);
    /// this is somewhat faster than `encodedString` because it returns unordered keys.
    ///
    /// Example: for a 2.3MB JSON, this has been seen to be almost 3x faster (269ms vs. 769ms)
    @inlinable func encodedStringUnordered() throws -> String {
        return String(data: try BricBracSharedUnsortedJSONEncoder.encode(self), encoding: .utf8) ?? "{}"
    }

    /// Returns an pretty-printed encoded string for the encodable.
    @inlinable func encodedStringFormatted() throws -> String {
        return String(data: try BricBracSharedFormattedJSONEncoder.encode(self), encoding: .utf8) ?? "{}"
    }


    /// Takes an Encodable instance and serialies it to JSON and then parses it as a Bric.
    /// This only works for top-level encodable properties (i.e., Array and Dictionary, but not String, Double, or Boolean).
    /// Full support would require a custom JSONEncoder to encode directly as a Bric.
    @inlinable func bricEncoded(outputFormatting: JSONEncoder.OutputFormatting? = nil, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil, nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil, userInfo: [CodingUserInfoKey : Any]? = nil) throws -> Bric {
        let encoder = JSONEncoder()

        if let outputFormatting = outputFormatting { encoder.outputFormatting = outputFormatting }
        if let dateEncodingStrategy = dateEncodingStrategy { encoder.dateEncodingStrategy = dateEncodingStrategy }
        if let dataEncodingStrategy = dataEncodingStrategy { encoder.dataEncodingStrategy = dataEncodingStrategy }
        if let nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy { encoder.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy }
        if let userInfo = userInfo { encoder.userInfo = userInfo }
        
        let data = try encoder.encode(self)
        guard let str = String(data: data, encoding: .utf8) else { return .nul } // unlikely
        return try Bric.parse(str)
    }
}

public extension Encodable where Self : Decodable {
    /// Attempts to merge one object with another by encoding the two objects and deep-merging their JSON representations. Note that conflicting keys will resove to that defined by this instance (or the other instance, if `reverse` is true).
    @available(*, deprecated, message: "slow and unreliable")
    func merging(withCodable other: Self, reverse: Bool = false) throws -> Self {
        let b1 = try self.bricEncoded()
        let b2 = try other.bricEncoded()
        let b3 = reverse ? b2.merge(bric: b1) : b1.merge(bric: b2)
        return try b3.decode(Self.self)
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

        return try decoder.decode(type, from: BricBracSharedUnsortedJSONEncoder.encode(self.bric()))
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


extension FoundationBricolage : Bricable, Bracable {
    public func bric() -> Bric {
        return FoundationBricolage.toBric(object)
    }

    fileprivate static let bolTypes = Set(arrayLiteral: "B", "c") // "B" on 64-bit, "c" on 32-bit
    fileprivate static func toBric(_ object: Any) -> Bric {
        if let bol = object as? BolType , bolTypes.contains(String(cString: bol.objCType)) {
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

