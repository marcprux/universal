//
//  Schema.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 6/21/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

public struct Schema : Codable, Equatable, Hashable {
    public var ref: String? = nil
    public var type: _Type? = nil
    public var id: String? = nil // format: uri
    public var _schema: String? = nil // format: uri
    public var title: String? = nil
    public var description: String? = nil
//    public var _default: Bric? = nil // {}
    public var multipleOf: Double? = nil // minimum: 0, exclusiveMinimum: true
    public var maximum: Double? = nil
    public var exclusiveMaximum: Bool? = nil // #### false
    public var minimum: Double? = nil
    public var exclusiveMinimum: Bool? = nil // #### false
    public var maxLength: Int? = nil
    public var minLength: Int? = nil
    public var pattern: String? = nil // format: regex
    public var additionalItems: AdditionalItems? = nil
    public var items: Items? = nil
    public var maxItems: Int? = nil
    public var minItems: Int? = nil
    public var uniqueItems: Bool? = nil // ### false
    public var maxProperties: Int? = nil
    public var minProperties: Int? = nil
    public var required: [String]? = nil
    public var propertyOrder: [String]? = nil
    public var additionalProperties: AdditionalProperties? = nil
    public var definitions: [String: Schema]? = nil
    public var properties: [String: Schema]? = nil
    public var patternProperties: [String: Schema]? = nil  // "additionalProperties": { "$ref": "#" }
    public var dependencies: [String: Dependencies]? = nil
    public var _enum: [Bric]? = nil // "enum": { "type": "array", "minItems": 1, "uniqueItems": true }
    public var allOf: [Schema]? = nil // { "$ref": "#/definitions/schemaArray" }
    public var anyOf: [Schema]? = nil // { "$ref": "#/definitions/schemaArray" }
    public var oneOf: [Schema]? = nil // { "$ref": "#/definitions/schemaArray" }
    public var not: Indirect<Schema>? = nil // { "$ref": "#" }
    public var _additionalProperties: Dictionary<String, Bric> = [:]

    public enum CodingKeys: String, CodingKey {
        case ref = "$ref"
        case type = "type"
        case id = "id"
        case _schema = "$schema"
        case title = "title"
        case description = "description"
//        case _default = "default"
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

    public func validate() throws {
        if let _enum = _enum { // { "type": "array", "minItems": 1, "uniqueItems": true }
            if _enum.count == 0 {
                throw SchemaError.enumIsEmpty
//            } else if Set(_enum).count != _enum.count {
//                throw SchemaError.enumIsNotUnique
            }
        }
    }

    public typealias AdditionalProperties = OneOf2<Bool, Schema>
    public typealias _Type = OneOf2<SimpleTypes, [SimpleTypes]>
    public typealias AdditionalItems = OneOf2<Bool, Schema>
    public typealias Items = OneOf2<Schema, [Schema]>
    public typealias Dependencies = OneOf2<Schema, [String]>

    public enum SimpleTypes: String, Codable { // "enum": [ "array", "boolean", "integer", "null", "number", "object", "string" ]
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

public extension Schema {
    init(type: SimpleTypes?) {
        var schema = Schema()
        if let type = type {
            schema.type = .v1(type)
        }
        self = schema
    }
}
