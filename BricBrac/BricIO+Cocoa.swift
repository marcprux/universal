//
//  BricIO+Cocoa.swift
//  Bric-à-brac
//
//  Created by Marc Prud'hommeaux on 7/20/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

import Foundation
import CoreFoundation

public extension Bric {

    /// Validates the given JSON string and throws an error if there was a problem
    public static func parseCocoa(string: String, options: JSONParser.Options = .CocoaCompat) throws -> NSObject {
        return try CocoaBricolage.parseJSON(Array(string.unicodeScalars), options: options).object as! NSObject
    }

    /// Validates the given array of unicode scalars and throws an error if there was a problem
    public static func parseCocoa(scalars: [UnicodeScalar], options: JSONParser.Options = .CocoaCompat) throws -> NSObject {
        return try CocoaBricolage.parseJSON(scalars, options: options).object as! NSObject
    }
}



public extension Bric {
    public static let ISO8601DateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()

    /// Convenience variable to obtain the current date in JSON-standard ISO-8601
    public static var currentDateISO8601: String {
        return ISO8601DateFormatter.stringFromDate(NSDate())
    }
}

/// Bricolage that represents the elements as Cocoa NSObject types with reference semantics
public final class CocoaBricolage: NSObject, Bricolage {
    public typealias NulType = NSNull
    public typealias BolType = NSNumber
    public typealias StrType = NSString
    public typealias NumType = NSNumber
    public typealias ArrType = NSMutableArray
    public typealias ObjType = NSMutableDictionary

    let object: NSCopying

    static let copyElements = false

    public init(str: StrType) { self.object = str }
    public init(num: NumType) { self.object = num }
    public init(bol: BolType) { self.object = bol }
    public init(arr: ArrType) { self.object = arr }
    public init(obj: ObjType) { self.object = obj }
    public init(nul: NulType) { self.object = nul }

    public static func createNull() -> NulType { return NSNull() }
    public static func createTrue() -> BolType { return true }
    public static func createFalse() -> BolType { return false }
    public static func createObject() -> ObjType { return ObjType() }
    public static func createArray() -> ArrType { return ArrType() }

    public static func createString(scalars: [UnicodeScalar]) -> StrType? {
        return String(String.UnicodeScalarView() + scalars) as NSString
    }

    public static func createNumber(scalars: [UnicodeScalar]) -> NumType? {
        if let str: NSString = createString(Array(scalars)) {
            return NSDecimalNumber(string: str as String) // needed for 0.123456789e-12
        } else {
            return nil
        }
    }

    public static func putKeyValue(obj: ObjType, key: StrType, value: CocoaBricolage) -> ObjType {
        if let copy = (value.object as? NSCopying)?.copyWithZone(NSZone()) where copyElements {
            obj.setObject(copy, forKey: key)
        } else {
            obj.setObject(value.object, forKey: key)
        }
        return obj
    }

    public static func putElement(arr: ArrType, element: CocoaBricolage) -> ArrType {
        if let copy = (element.object as? NSCopying)?.copyWithZone(NSZone()) where copyElements {
            arr.addObject(copy)
        } else {
            arr.addObject(element.object)
        }
        return arr
    }
}

/// Bricolage that represents the elements as Core Foundation types with reference semantics
public final class FoundationBricolage: Bricolage {
    public typealias NulType = CFNull
    public typealias BolType = CFBoolean
    public typealias StrType = CFString
    public typealias NumType = CFNumber
    public typealias ArrType = CFMutableArray
    public typealias ObjType = CFMutableDictionary

    public let ptr: UnsafePointer<AnyObject>

    public init(str: StrType) { self.ptr = UnsafePointer(Unmanaged.passRetained(str).toOpaque()) }
    public init(num: NumType) { self.ptr = UnsafePointer(Unmanaged.passRetained(num).toOpaque()) }
    public init(bol: BolType) { self.ptr = UnsafePointer(Unmanaged.passRetained(bol).toOpaque()) }
    public init(arr: ArrType) { self.ptr = UnsafePointer(Unmanaged.passRetained(arr).toOpaque()) }
    public init(obj: ObjType) { self.ptr = UnsafePointer(Unmanaged.passRetained(obj).toOpaque()) }
    public init(nul: NulType) { self.ptr = UnsafePointer(Unmanaged.passRetained(nul).toOpaque()) }

    deinit {
        Unmanaged<AnyObject>.fromOpaque(COpaquePointer(ptr)).release()
    }

    public static func createNull() -> NulType { return kCFNull }
    public static func createTrue() -> BolType { return kCFBooleanTrue }
    public static func createFalse() -> BolType { return kCFBooleanFalse }
    public static func createObject() -> ObjType { return CFDictionaryCreateMutable(nil, 0, nil, nil) }
    public static func createArray() -> ArrType { return CFArrayCreateMutable(nil, 0, nil) }

    public static func createString(scalars: [UnicodeScalar]) -> StrType? {
        return String(String.UnicodeScalarView() + scalars)
    }

    public static func createNumber(scalars: [UnicodeScalar]) -> NumType? {
        if let str = createString(Array(scalars)) {
            return NSDecimalNumber(string: str as String) // needed for 0.123456789e-12
        } else {
            return nil
        }
    }

    public static func putKeyValue(obj: ObjType, key: StrType, value: FoundationBricolage) -> ObjType {
        CFDictionarySetValue(obj, UnsafePointer<Void>(Unmanaged<CFString>.passRetained(key).toOpaque()), value.ptr)
        return obj
    }

    public static func putElement(arr: ArrType, element: FoundationBricolage) -> ArrType {
        CFArrayAppendValue(arr, element.ptr)
        return arr
    }
}
