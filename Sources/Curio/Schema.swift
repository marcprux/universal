//
//  Schema.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 6/21/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

public extension Schema {
    public init(type: SimpleTypes?) {
        var schema = Schema()
        if let type = type {
            schema.type = .a(type)
        }
        self = schema
    }
}

public struct Schema : BricBrac {
    public var ref: String? = nil
    public var type: _Type? = nil
    public var id: String? = nil // format: uri
    public var _schema: String? = nil // format: uri
    public var title: String? = nil
    public var description: String? = nil
    public var _default: Bric? = nil // {}
    public var multipleOf: Double? = nil // minimum: 0, exclusiveMinimum: true
    public var maximum: Double? = nil
    public var exclusiveMaximum: Bool? = nil // #### false
    public var minimum: Double? = nil
    public var exclusiveMinimum: Bool? = nil // #### false
    public var maxLength: PositiveInteger? = nil
    public var minLength: PositiveIntegerDefault0? = nil
    public var pattern: String? = nil // format: regex
    public var additionalItems: AdditionalItems? = nil
    public var items: Items? = nil
    public var maxItems: PositiveInteger? = nil
    public var minItems: PositiveIntegerDefault0? = nil
    public var uniqueItems: Bool? = nil // ### false
    public var maxProperties: PositiveInteger? = nil
    public var minProperties: PositiveIntegerDefault0? = nil
    public var required: StringArray? = nil
    public var propertyOrder: [String]? = nil
    public var additionalProperties: AdditionalProperties? = nil
    public var definitions: [String: Schema]? = nil
    public var properties: [String: Schema]? = nil
    public var patternProperties: [String: Schema]? = nil  // "additionalProperties": { "$ref": "#" }
    public var dependencies: [String: Dependencies]? = nil
    public var _enum: [Bric]? = nil // "enum": { "type": "array", "minItems": 1, "uniqueItems": true }
    public var allOf: SchemaArray? = nil // { "$ref": "#/definitions/schemaArray" }
    public var anyOf: SchemaArray? = nil // { "$ref": "#/definitions/schemaArray" }
    public var oneOf: SchemaArray? = nil // { "$ref": "#/definitions/schemaArray" }
    public var not: Indirect<Schema> = nil // { "$ref": "#" }
    public var _additionalProperties: Dictionary<String, Bric> = [:]

    enum Keys: String {
        case ref = "$ref"
        case type = "type"
        case id = "id"
        case _schema = "$schema"
        case title = "title"
        case description = "description"
        case _default = "default"
        case multipleOf = "multipleOf"
        case maximum = "maximum"
        case exclusiveMaximum = "exclusiveMaximum"
        case minimum = "minimum"
        case exclusiveMinimum = "exclusiveMinimum"
        case maxLength = "maxLength"
        case minLength = "minLength"
        case pattern = "pattern"
        case additionalItems = "additionalItems"
        case items = "items"
        case maxItems = "maxItems"
        case minItems = "minItems"
        case uniqueItems = "uniqueItems"
        case maxProperties = "maxProperties"
        case minProperties = "minProperties"
        case required = "required"
        case propertyOrder = "propertyOrder"
        case additionalProperties = "additionalProperties"
        case definitions = "definitions"
        case properties = "properties"
        case patternProperties = "patternProperties"
        case dependencies = "dependencies"
        case _enum = "enum"
        case allOf = "allOf"
        case anyOf = "anyOf"
        case oneOf = "oneOf"
        case not = "not"
    }

    public func bric() -> Bric {
        return Bric(object: Array<(key: String, value: Bric)>(_additionalProperties) + ([
            (Keys.ref.rawValue, ref.bric()) as (String, Bric),
            (Keys.type.rawValue, type.bric()) as (String, Bric),
            (Keys.id.rawValue, id.bric()) as (String, Bric),
            (Keys.type.rawValue, type.bric()) as (String, Bric),
            (Keys.id.rawValue, id.bric()) as (String, Bric),
            (Keys._schema.rawValue, _schema.bric()) as (String, Bric),
            (Keys.title.rawValue, title.bric()) as (String, Bric),
            (Keys.description.rawValue, description.bric()) as (String, Bric),
            (Keys._default.rawValue, _default.bric()) as (String, Bric),
            (Keys.multipleOf.rawValue, multipleOf.bric()) as (String, Bric),
            (Keys.maximum.rawValue, maximum.bric()) as (String, Bric),
            (Keys.exclusiveMinimum.rawValue, exclusiveMinimum.bric()) as (String, Bric),
            (Keys.maxLength.rawValue, maxLength.bric()) as (String, Bric),
            (Keys.minLength.rawValue, minLength.bric()) as (String, Bric),
            (Keys.pattern.rawValue, pattern.bric()) as (String, Bric),
            (Keys.additionalItems.rawValue, additionalItems.bric()) as (String, Bric),
            (Keys.items.rawValue, items.bric()) as (String, Bric),
            (Keys.maxItems.rawValue, maxItems.bric()) as (String, Bric),
            (Keys.minItems.rawValue, minItems.bric()) as (String, Bric),
            (Keys.uniqueItems.rawValue, uniqueItems.bric()) as (String, Bric),
            (Keys.maxProperties.rawValue, maxProperties.bric()) as (String, Bric),
            (Keys.minProperties.rawValue, minProperties.bric()) as (String, Bric),
            (Keys.required.rawValue, required.bric()) as (String, Bric),
            (Keys.propertyOrder.rawValue, propertyOrder.bric()) as (String, Bric),
            (Keys.additionalProperties.rawValue, additionalProperties.bric()) as (String, Bric),
            (Keys.definitions.rawValue, definitions.bric()) as (String, Bric),
            (Keys.properties.rawValue, properties.bric()) as (String, Bric),
            (Keys.patternProperties.rawValue, patternProperties.bric()) as (String, Bric),
            (Keys.dependencies.rawValue, dependencies.bric()) as (String, Bric),
            (Keys._enum.rawValue, _enum.bric()) as (String, Bric),
            (Keys.allOf.rawValue, allOf.bric()) as (String, Bric),
            (Keys.anyOf.rawValue, anyOf.bric()) as (String, Bric),
            (Keys.oneOf.rawValue, oneOf.bric()) as (String, Bric),
            (Keys.not.rawValue, not.bric()) as (String, Bric)
            ] as [(key: String, value: Bric)])
        )
    }

    public static func brac(bric: Bric) throws -> Schema {
//        fatalError()
        return try Schema(
            ref: bric.brac(key: Keys.ref),
            type: bric.brac(key: Keys.type),
            id: bric.brac(key: Keys.id),
            _schema: bric.brac(key: Keys._schema),
            title: bric.brac(key: Keys.title),
            description: bric.brac(key: Keys.description),
            _default: bric.brac(key: Keys._default),
            multipleOf: bric.brac(key: Keys.multipleOf),
            maximum: bric.brac(key: Keys.maximum),
            exclusiveMaximum: bric.brac(key: Keys.exclusiveMaximum),
            minimum: bric.brac(key: Keys.minimum),
            exclusiveMinimum: bric.brac(key: Keys.exclusiveMinimum),
            maxLength: bric.brac(key: Keys.maxLength),
            minLength: bric.brac(key: Keys.minLength),
            pattern: bric.brac(key: Keys.pattern),
            additionalItems: bric.brac(key: Keys.additionalItems),
            items: bric.brac(key: Keys.items),
            maxItems: bric.brac(key: Keys.maxItems),
            minItems: bric.brac(key: Keys.minItems),
            uniqueItems: bric.brac(key: Keys.uniqueItems),
            maxProperties: bric.brac(key: Keys.maxProperties),
            minProperties: bric.brac(key: Keys.minProperties),
            required: bric.brac(key: Keys.required),
            propertyOrder: bric.brac(key: Keys.propertyOrder),
            additionalProperties: bric.brac(key: Keys.additionalProperties),
            definitions: bric.brac(key: Keys.definitions),
            properties: bric.brac(key: Keys.properties),
            patternProperties: bric.brac(key: Keys.patternProperties),
            dependencies: bric.brac(key: Keys.dependencies),
            _enum: bric.brac(key: Keys._enum),
            allOf: bric.brac(key: Keys.allOf),
            anyOf: bric.brac(key: Keys.anyOf),
            oneOf: bric.brac(key: Keys.oneOf),
            not: bric.brac(key: Keys.not),
            _additionalProperties: bric.brac(disjoint: Keys.self) // everything else
        )
    }

    public func validate() throws {
        if let _enum = _enum { // { "type": "array", "minItems": 1, "uniqueItems": true }
            if _enum.count == 0 {
                throw SchemaError.enumIsEmpty
            } else if Set(_enum).count != _enum.count {
                throw SchemaError.enumIsNotUnique
            }
        }
    }

    public typealias StringArray = Array<String> // { "type": "array", "items": { "type": "string" }, "minItems": 1, "uniqueItems": true }
    public enum AdditionalProperties : BricBrac {
        case a(Bool) // { "type": "boolean" }
        case b(Indirect<Schema>) // { "$ref": "#" } // TODO: make "indirect" in Swift 2

        public func bric() -> Bric {
            switch self {
            case let .a(x): return x.bric()
            case let .b(x): return x.bric()
            }
        }

        public static func brac(bric: Bric) throws -> Schema.AdditionalProperties {
            switch bric {
            case .bol(let x): return .a(x)
            case .obj: return try .b(Indirect(Schema.brac(bric: bric)))
            default: return try bric.invalidType()
            }
        }
    }

    public enum _Type : BricBrac {
        case a(SimpleTypes) // { "$ref": "#/definitions/simpleTypes" }
        case b([SimpleTypes]) // { "type": "array", "items": { "$ref": "#/definitions/simpleTypes" }, "minItems": 1, "uniqueItems": true }

        public var types: [SimpleTypes] {
            switch self {
            case .a(let a): return [a]
            case .b(let b): return b
            }
        }
        
        public func bric() -> Bric {
            switch self {
            case let .a(x): return x.bric()
            case let .b(x): return x.bric()
            }
        }

        public static func brac(bric: Bric) throws -> Schema._Type {
            switch bric {
            case .str: return try .a(Schema.SimpleTypes.brac(bric: bric))
            case .arr(let x): return try .b(x.map(Schema.SimpleTypes.brac))
            default: return try bric.invalidType()
            }
        }
    }

    public typealias SchemaArray = Array<Schema> // { "type": "array", "minItems": 1, "items": { "$ref": "#" } }

    public typealias PositiveInteger = Int
    public typealias PositiveIntegerDefault0 = PositiveInteger // { "allOf": [ { "$ref": "#/definitions/positiveInteger" }, { "default": 0 } ] }

    public enum AdditionalItems : BricBrac {
        case a(Bool) // { "type": "boolean" }
        case b(Indirect<Schema>) // { "$ref": "#" } // TODO: make "indirect" in Swift 2

        public func bric() -> Bric {
            switch self {
            case let .a(x): return x.bric()
            case let .b(x): return x.bric()
            }
        }

        public static func brac(bric: Bric) throws -> Schema.AdditionalItems {
            switch bric {
            case .bol(let x): return .a(x)
            case .obj: return try .b(Indirect(Schema.brac(bric: bric)))
            default: return try bric.invalidType()
            }
        }
    }

    public enum Items : BricBrac {
        case a(Indirect<Schema>) // { "$ref": "#" }
        case b(SchemaArray) // { "$ref": "#/definitions/schemaArray" }

        public func bric() -> Bric {
            switch self {
            case let .a(x): return x.bric()
            case let .b(x): return x.bric()
            }
        }

        public static func brac(bric: Bric) throws -> Schema.Items {
            switch bric {
            case .obj: return try .a(Indirect(Schema.brac(bric: bric)))
            case .arr(let x): return try .b(x.map(Schema.brac))
            default: return try bric.invalidType()
            }
        }
    }

    public enum Dependencies : BricBrac {
        case a(Indirect<Schema>) // { "$ref": "#" }
        case b(StringArray) // { "$ref": "#/definitions/stringArray" }

        public func bric() -> Bric {
            switch self {
            case let .a(x): return x.bric()
            case let .b(x): return x.bric()
            }
        }

        public static func brac(bric: Bric) throws -> Schema.Dependencies {
            switch bric {
            case .obj: return try .a(Indirect(Schema.brac(bric: bric)))
            case .arr(let x): return try .b(x.map(String.brac))
            default: return try bric.invalidType()
            }
        }
    }

    public enum SimpleTypes: String, BricBrac { // "enum": [ "array", "boolean", "integer", "null", "number", "object", "string" ]
        case array = "array"
        case boolean = "boolean"
        case integer = "integer"
        case null = "null"
        case number = "number"
        case object = "object"
        case string = "string"
    }

    public enum SchemaError : Error {
        case enumIsEmpty
        case enumIsNotUnique
    }
}
