//
//  Schema.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 6/21/15.
//  Copyright © 2010-2020 io.glimpse. All rights reserved.
//

import BricBrac



//public typealias Schema = LegacySchema
//
//public extension LegacySchema {
//    init(type: LegacySchema.SimpleTypes?) {
//        var schema = Schema()
//        if let type = type {
//            schema.type = .init(type)
//        }
//        self = schema
//    }
//}

//
public typealias Schema = JSONSchemaRoot
//
//
//public typealias TypeSimple = SimpleTypes
//public extension JSONSchemaRoot {
//    /// Refactor shim
//    @available(*, deprecated)
//    typealias SimpleTypes = TypeSimple
//}



/// A representation of a JSON Schema file.
@available(*, deprecated, renamed: "JSONSchema")
public struct LegacySchema : Codable, Equatable, Hashable {
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
    public var exclusiveMinimum: Bric? = nil // #### false
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
    public var definitions: [String: Self]? = nil
    public var properties: [String: OneOf2<Self, Bool>]? = nil
    public var patternProperties: [String: Self]? = nil  // "additionalProperties": { "$ref": "#" }
    public var dependencies: [String: Dependencies]? = nil
    public var `enum`: [Bric]? = nil // "enum": { "type": "array", "minItems": 1, "uniqueItems": true }
    /// https://json-schema.org/understanding-json-schema/reference/generic.html#constant-values
    public var const: Bric? = nil // "const": "XXX" == { "enum": [ "XXX" ] }
    public var allOf: [Self]? = nil // { "$ref": "#/definitions/schemaArray" }
    public var anyOf: [Self]? = nil // { "$ref": "#/definitions/schemaArray" }
    public var oneOf: [Self]? = nil // { "$ref": "#/definitions/schemaArray" }
    public var not: Indirect<Self>? = nil // { "$ref": "#" }
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
        case `enum` = "enum"
        case const = "const"
        case allOf = "allOf"
        case anyOf = "anyOf"
        case oneOf = "oneOf"
        case not = "not"
    }

    public func validate() throws {
        if let `enum` = `enum` { // { "type": "array", "minItems": 1, "uniqueItems": true }
            if `enum`.count == 0 {
                throw SchemaError.enumIsEmpty
//            } else if Set(`enum`).count != `enum`.count {
//                throw SchemaError.enumIsNotUnique
            }
        }
    }

    public typealias AdditionalProperties = OneOf2<Self, Bool>
    public typealias _Type = OneOf2<SimpleTypes, [SimpleTypes]>
    public typealias AdditionalItems = OneOf2<Self, Bool>
    public typealias Items = OneOrMany<OneOf2<Self, Bool>>
    public typealias Dependencies = OneOf2<Self, [String]>

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
