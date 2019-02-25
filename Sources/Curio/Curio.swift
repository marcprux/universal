//
//  Curio.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 6/30/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

import BricBrac

/// A JSON Schema processor that emits Swift code using the Bric-a-Brac framework for marshalling and unmarshalling.
///
/// Current shortcomings:
/// • "anyOf" schema type values cannot prevent that all their tuple elements not be set to nil
///
/// TODO:
/// • hide Indirect in private fields and make public Optional getters/setters
public struct Curio {

    /// The swift version to generate
    public var swiftVersion = 4.2

    /// whether to generate codable implementations for each type
    public var generateCodable = true

    /// Whether to generate a compact representation with type shorthand and string enum types names reduced
    public var compact = true

    /// whether to generate structs or classes (classes are faster to compiler for large models)
    public var generateValueTypes = true

    /// whether to generate equatable functions for each type
    public var generateEquals = true

    /// whether to generate hashable functions for each type
    public var generateHashable = true

    /// Whether to output union types as a typealias to a BricBrac.OneOf<T1, T2, ...> enum
    public var useOneOfEnums = true

    /// Whether to output sum types as a typealias to a BricBrac.AllOf<T1, T2, ...> enum
    public var useAllOfEnums = true

    /// Whether to output optional sum types as a typealias to a BricBrac.AnyOf<T1, T2, ...> enum
    public var useAnyOfEnums = true

    /// Whether AnyOf elements should be treated as OneOf elements
    public var anyOfAsOneOf = false

    /// the number of properties beyond which Optional types should instead be Indirect; this is needed beause
    /// a struct that contains many other stucts can make very large compilation units and take a very long
    /// time to compile
    /// This isn't as much of an issue now that OneOfN enums are indirect; the vega-lite schema is 7M with indirectCountThreshold=9 and 13M with indirectCountThreshold=99
    /// Also, if indirectCountThreshold is to be used, we need to synthesize the CodingKeys macro again
    public var indirectCountThreshold = 99

    /// The prefix for private internal indirect implementations
    public var indirectPrefix = "_"

    /// The suffic for a OneOf choice enum
    public var oneOfSuffix = "Choice"

    /// The suffic for a AllOf choice enum
    public var allOfSuffix = "Sum"

    /// The suffic for a AnyOf choice enum
    public var anyOfSuffix = "Some"

    /// The suffix for a case operation
    public var caseSuffix = "Case"

    public var accessor: ([CodeTypeName])->(CodeAccess) = { _ in .`public` }
    public var renamer: ([CodeTypeName], String)->(CodeTypeName?) = { (parents, id) in nil }

    /// The list of type names to exclude from the generates file
    public var excludes: Set<CodeTypeName> = []

    /// The list of type aliases that will wrap around their aliased types
    public var encapsulate: [CodeTypeName: CodeExternalType] = [:]

    /// Override individual property types
    public var propertyTypeOverrides: [CodeTypeName: CodeTypeName] = [:]

    /// The case of the generated enums
    public var enumCase: EnumCase = .lower

    public enum EnumCase { case upper, lower }

    /// special prefixes to trim (adheres to the convention that top-level types go in the "defintions" level)
    public var trimPrefixes = ["#/definitions/", "#/defs/"]

    /// The suffix to append to generated types
    public var typeSuffix = ""

    /// Whether to gather identical types and promote them to a top level upon reificiation (helps with reducing the number of parochical string constants)
    public var promoteIdenticalTypes = true

    public var propOrdering: ([CodeTypeName], String)->(Array<String>?) = { (parents, id) in nil }

    /// The protocols all our types will adopt
    var standardAdoptions: [CodeProtocol] {
        var protos: [CodeProtocol] = []
        if generateEquals { protos.append(.equatable) }
        if generateHashable { protos.append(.hashable) }
        if generateCodable { protos.append(.codable) }
        return protos
    }

    public init() {
    }

    enum CodegenErrors : Error, CustomDebugStringConvertible {
        case typeArrayNotSupported
        case illegalDefaultType
        case defaultValueNotInStringEnum
        case nonStringEnumsNotSupported // TODO
        case tupleTypeingNotSupported // TODO
        case complexTypesNotAllowedInMultiType
        case illegalState(String)
        case unsupported(String)
        indirect case illegalProperty(Schema)
        case compileError(String)

        var debugDescription : String {
            switch self {
            case .typeArrayNotSupported: return "TypeArrayNotSupported"
            case .illegalDefaultType: return "IllegalDefaultType"
            case .defaultValueNotInStringEnum: return "DefaultValueNotInStringEnum"
            case .nonStringEnumsNotSupported: return "NonStringEnumsNotSupported"
            case .tupleTypeingNotSupported: return "TupleTypeingNotSupported"
            case .complexTypesNotAllowedInMultiType: return "ComplexTypesNotAllowedInMultiType"
            case .illegalState(let x): return "IllegalState(\(x))"
            case .unsupported(let x): return "Unsupported(\(x))"
            case .illegalProperty(let x): return "IllegalProperty(\(x))"
            case .compileError(let x): return "CompileError(\(x))"
            }
        }
    }


    /// Alphabetical characters
    static let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    /// “Identifiers begin with an uppercase or lowercase letter A through Z, an underscore (_), a noncombining alphanumeric Unicode character in the Basic Multilingual Plane, or a character outside the Basic Multilingual Plane that isn’t in a Private Use Area.”
    static let nameStart = Set((alphabet.uppercased() + "_" + alphabet.lowercased()))

    /// “After the first character, digits and combining Unicode characters are also allowed.”
    static let nameBody = Set(Array(nameStart) + "0123456789")


    func propName(_ parents: [CodeTypeName], _ id: String, arg: Bool = false) -> CodePropName {
        if let pname = renamer(parents, id) {
            return pname
        }

        // enums can't have a prop named "init", since it will conflict with the constructor name
        var idx = id == "init" ? "initx" : id

        while let first = idx.first , !Curio.nameStart.contains(first) {
            idx = String(idx.dropFirst())
        }

        // swift version 2.2+ allow unescaped keywords as argument names: https://github.com/apple/swift-evolution/blob/master/proposals/0001-keywords-as-argument-labels.md
        if arg {
            if idx.isSwiftReservedArg() {
                idx = "`" + idx + "`"
            }
        } else {
            if idx.isSwiftKeyword() {
                idx = "`" + idx + "`"
            }
        }

        return idx
    }

    func unescape(_ name: String) -> String {
        if name.hasPrefix("`") && name.hasSuffix("`") && name.count >= 2 {
            return String(name[name.index(after: name.startIndex)..<name.index(before: name.endIndex)])
        } else {
            return name
        }
    }

    func sanitizeString(_ fromName: String, capitalize: Bool = true) -> String {
        let nm: String
        // if the name is just a number, then try to use the spelling of the number
        if Double(fromName)?.description == fromName {
            nm = "n" + fromName
        } else {
            nm = fromName
        }

        var name = ""

        var capnext = capitalize
        for c in nm {
            let validCharacters = name.isEmpty ? Curio.nameStart : Curio.nameBody
            if c == "." {
                name.append("_")
            } else if !validCharacters.contains(c) {
                capnext = name.isEmpty ? capitalize : true
            } else if capnext {
                name.append(String(c).uppercased())
                capnext = false
            } else {
                name.append(c)
            }
        }
        return name
    }

    func dictionaryType(_ keyType: CodeType, _ valueType: CodeType) -> CodeExternalType {
        return CodeExternalType("Dictionary", generics: [keyType, valueType], defaultValue: "[:]")
    }

    func arrayType(_ type: CodeType) -> CodeExternalType {
        return CodeExternalType("Array", generics: [type], defaultValue: "[]", shorthand: (prefix: "[", suffix: "]"))
    }

    func collectionOfOneType(_ type: CodeType) -> CodeExternalType {
        return CodeExternalType("CollectionOfOne", generics: [type], defaultValue: "[]")
    }

    func optionalType(_ type: CodeType) -> CodeExternalType {
        return CodeExternalType("Optional", generics: [type], defaultValue: ".none", shorthand: (prefix: nil, suffix: "?"))
    }

    func indirectType(_ type: CodeType) -> CodeExternalType {
        return CodeExternalType("Indirect", generics: [type], defaultValue: "nil")
    }

    func nullableType(_ type: CodeType) -> CodeExternalType {
        return CodeExternalType("ExplicitNull", generics: [type])
    }

    func notBracType(_ type: CodeType) -> CodeExternalType {
        return CodeExternalType("NotBrac", generics: [type], defaultValue: "nil")
    }

    func nonEmptyType(_ type: CodeType) -> CodeExternalType {
        return CodeExternalType("NonEmptyCollection", generics: [type, arrayType(type)])
    }

    func oneOfType(_ types: [CodeType]) -> CodeExternalType {
        return CodeExternalType("OneOf\(types.count)", generics: types)
    }

    func anyOfType(_ types: [CodeType]) -> CodeExternalType {
        return CodeExternalType("AnyOf\(types.count)", generics: types)
    }

    func allOfType(_ types: [CodeType]) -> CodeExternalType {
        return CodeExternalType("AllOf\(types.count)", generics: types)
    }


    func typeName(_ parents: [CodeTypeName], _ id: String, capitalize: Bool = true) -> CodeTypeName {
        if let tname = renamer(parents, id) {
            return tname
        }

        var nm = id
        for pre in trimPrefixes {
            if nm.hasPrefix(pre) {
                nm = String(nm[pre.endIndex..<nm.endIndex])
            }
        }

        var name = sanitizeString(nm, capitalize: capitalize)

        if name.isSwiftKeyword() {
            name = "`" + name + "`"
        }

        if name.isEmpty { // e.g., ">=" -> "U62U61"
            for c in id.unicodeScalars {
                name += (enumCase == .upper ? "U" : "u") + "\(c.value)"
            }
        }
        return CodeTypeName(name)
    }

    func aliasType(_ type: CodeNamedType) -> CodeType? {
        if let alias = type as? CodeTypeAlias , alias.peerTypes.isEmpty {
            return alias.type
        } else {
            return nil
        }
    }

    /// Returns true if the schema will be serialized as a raw Bric instance
    func isBricType(_ schema: Schema) -> Bool {
        return false
//        var sch = schema
//        // trim out extranneous values
//        sch.description = nil
//
//        let bric = sch.bric()
//        if bric == [:] { return true }
//        if bric == ["type": "object"] { return true }
//
//        return false
    }

    typealias PropInfo = (name: String?, required: Bool, schema: Schema)
    typealias PropDec = (name: String, required: Bool, prop: Schema, anon: Bool)

    func getPropInfo(_ schema: Schema, id: String, parents: [CodeTypeName]) -> [PropInfo] {
        let properties = schema.properties ?? [:]

        /// JSON Schema Draft 4 doesn't have any notion of property ordering, so we use a user-defined sorter
        /// followed by ordering them by their appearance in the (non-standard) "propertyOrder" element
        /// followed by ordering them by their appearance in the "required" element
        /// followed by alphabetical property name ordering
        var ordering: [String] = []
        ordering.append(contentsOf: propOrdering(parents, id) ?? [])
        ordering.append(contentsOf: schema.propertyOrder ?? [])
        ordering.append(contentsOf: schema.required ?? [])
        ordering.append(contentsOf: properties.keys.sorted())
        
        let ordered = properties.sorted { a, b in return ordering.index(of: a.0)! <= ordering.index(of: b.0)! }
        let req = Set(schema.required ?? [])
        let props: [PropInfo] = ordered.map({ PropInfo(name: $0, required: req.contains($0), schema: $1) })
        return props
    }

    /// Encapsulates the given typename with the specified external type
    func encapsulateType(name typename: CodeTypeName, type: CodeExternalType, access: CodeAccess)  -> CodeNamedType {
        let aliasType = type
        let propn = CodePropName("rawValue")
        let propd = CodeProperty.Declaration(name: propn, type: aliasType, access: access, mutable: false)
        var enc = CodeStruct(name: typename, access: access, props: [propd.implementation])

        enc.conforms += standardAdoptions
        enc.conforms.append(.rawRepresentable)

        let rawInit = CodeFunction.Declaration(name: "init", access: access, instance: true, exception: false, arguments: CodeTuple(elements: [(name: "rawValue", type: aliasType, value: nil, anon: false)]), returns: CodeTuple(elements: []))
        let rawInitImp = CodeFunction.Implementation(declaration: rawInit, body: ["self.rawValue = rawValue"], comments: [])

        enc.funcs.append(rawInitImp)

        return enc
    }

    /// Reifies the given schema as a Swift data structure
    public func reify(_ schema: Schema, id: String, parents parentsx: [CodeTypeName]) throws -> CodeNamedType {
        var parents = parentsx
        let bricfun = CodeFunction.Declaration(name: "bric", access: accessor(parents), instance: true, returns: CodeTuple(elements: [(name: nil, type: CodeExternalType.bric, value: nil, anon: false)]))

        func selfType(_ type: CodeType, name: String?) -> CodeTupleElement {
            return CodeTupleElement(name: name, type: CodeExternalType(fullName(type), access: self.accessor(parents)), value: nil, anon: false)
        }

        let bracfun: (CodeType)->(CodeFunction.Declaration) = { CodeFunction.Declaration(name: "brac", access: self.accessor(parents), instance: false, exception: true, arguments: CodeTuple(elements: [(name: "bric", type: CodeExternalType.bric, value: nil, anon: false)]), returns: CodeTuple(elements: [selfType($0, name: nil)])) }

        let encodefun = CodeFunction.Declaration(name: "encode", access: accessor(parents), instance: true, exception: true, arguments: CodeTuple(elements: [(name: "to encoder", type: CodeExternalType.encoder, value: nil, anon: false)]), returns: CodeTuple(elements: []))
        let decodefun = CodeFunction.Declaration(name: "init", access: accessor(parents), instance: true, exception: true, arguments: CodeTuple(elements: [(name: "from decoder", type: CodeExternalType.decoder, value: nil, anon: false)]), returns: CodeTuple(elements: []))


        let comments = [schema.title, schema.description].compactMap { $0 }

        /// Calculate the fully-qualified name of the given type
        func fullName(_ type: CodeType) -> String {
            return (parents + [type.identifier]).joined(separator: ".")
        }

        func schemaTypeName(_ schema: Schema, types: [CodeType], suffix: String = "") -> String {
            if let titleName = schema.title.flatMap({ typeName(parents, $0) }) { return titleName }

            // before we fall-back to using a generic "Type" name, try to name a simple struct
            // from the names of all of its properties

            // a list of names to ensure that the type is unique
            let names = types.map({ ($0 as? CodeNamedType)?.name ?? "" }).filter({ !$0.isEmpty })

            let props = getPropInfo(schema, id: id, parents: parents)
            if props.count > 0 && props.count <= 5 {
                var name = ""
                for prop in props {
                    name += sanitizeString(prop.name ?? "")
                }
                name += "Type"

                // ensure the name is unique
                var uniqueName = name
                var num = 0
                while names.contains(uniqueName) {
                    num += 1
                    uniqueName = name + String(num)
                }

                return uniqueName
            }

            return "Type" + suffix
        }

        func createOneOf(_ multi: [Schema]) throws -> CodeNamedType {
            let ename = typeName(parents, id)
            var code = CodeEnum(name: ename, access: accessor(parents))
            code.comments = comments

            var encodebody : [String] = []
            var decodebody : [String] = []

            encodebody.append("switch self {")
            decodebody.append("var errors: [Error] = []")

            var casenames = Set<String>()
            var casetypes = Array<CodeType>()
            for sub in multi {
                let casetype: CodeType

                switch sub.type {
                case .some(.v1(.string)) where sub._enum == nil: casetype = CodeExternalType.string
                case .some(.v1(.number)): casetype = CodeExternalType.double
                case .some(.v1(.boolean)): casetype = CodeExternalType.bool
                case .some(.v1(.integer)): casetype = CodeExternalType.int
                case .some(.v1(.null)): casetype = CodeExternalType.null
                default:
                    if let values = sub._enum {
                        let literalEnum = try createStringEnum(values: values)
                        code.nestedTypes.append(literalEnum) // we will later try to promote any CodeSimpleEnum<String> to be a peer of an alias type
                        casetype = literalEnum
                    } else {
                        // otherwise, create an anonmount sub-type (Type1, Type2, …)
                        let subtype = try reify(sub, id: schemaTypeName(sub, types: casetypes, suffix: String(code.nestedTypes.count+1)), parents: parents + [code.name])
                        // when the generated code is merely a typealias, just inline it in the enum case
                        if let aliasType = aliasType(subtype) {
                            casetype = aliasType
                        } else {
                            code.nestedTypes.append(subtype)

                            if generateValueTypes && subtype.directReferences.map({ $0.name }).contains(ename) {
                                casetype = indirectType(subtype)
                            } else {
                                casetype = subtype
                            }
                        }
                    }
                }

                casetypes.append(casetype)
                let cname = typeName(parents, casetype.identifier, capitalize: enumCase == .upper) + caseSuffix

                var casename = cname
                if enumCase == .lower && casename.count > 2 {
                    // lower-case the case; just because it was not capitalized above does not mean it
                    // was lower-cases, because the case name may have been derived from a type name (list ArrayStringCase)
                    let initial = casename[casename.startIndex..<casename.index(after: casename.startIndex)]
                    let second = casename[casename.index(after: casename.startIndex)..<casename.index(after: casename.index(after: casename.startIndex))]
                    // only lower-case the type name if the second character is *not* upper-case; this heuristic
                    // is to prevent downcasing synonym types (e.g., we don't want "RGBCase" to be "rGBCase")
                    if second.uppercased() != second {
                        let remaining = casename[casename.index(after: casename.startIndex)..<casename.endIndex]
                        casename = initial.lowercased() + remaining
                    }
                }
                var n = 0
                // make sure case names are unique by suffixing with a number
                while casenames.contains(casename) {
                    n += 1
                    casename = cname + String(n)
                }
                casenames.insert(casename)
                code.cases.append(CodeEnum.Case(name: casename, type: casetype))

                if casetype.identifier == "Void" {
                    // Void can't be extended, so we need to special-case it to avoid calling methods on the type
                    encodebody.append("case .\(casename): try NSNull().encode(to: encoder)")
                    decodebody.append("do { try let _ = NSNull(from: decoder); self = .\(casename); return } catch { errors.append(error) }")
                } else {
                    encodebody.append("case .\(casename)(let x): try x.encode(to: encoder)")
                    decodebody.append("do { self = try .\(casename)(\(casetype.identifier)(from: decoder)); return } catch { errors.append(error) }")
                }

                // Also add a convenience init argument for the type that just accepts the associated value
                // The type should be unique, since they are OneOf types that aren't allowed to match
                let initfun = CodeFunction.Declaration(name: "init", access: accessor(parents), instance: true, arguments: CodeTuple(elements: [(name: "_ arg", type: casetype, value: nil, anon: false)]), returns: CodeTuple(elements: []))
                let initbody = [ "self = .\(casename)(arg)" ]
                let initimp = CodeFunction.Implementation(declaration: initfun, body: initbody, comments: ["Initializes with the \(casename) case"])
                code.funcs.append(initimp)
            }

            encodebody.append("}")
            decodebody.append("throw OneOfDecodingError(errors: errors)")

            code.conforms += standardAdoptions
            if generateCodable {
                code.funcs.append(CodeFunction.Implementation(declaration: encodefun, body: encodebody, comments: []))
                code.funcs.append(CodeFunction.Implementation(declaration: decodefun, body: decodebody, comments: []))
            }

            if useOneOfEnums && casetypes.count >= 2 && casetypes.count <= 10 {
                let constantEnums = code.nestedTypes.compactMap({ $0 as? CodeSimpleEnum<String> })
                if code.nestedTypes.count == constantEnums.count { // if there are no nested types, or they are all constant enums, we can simply return a typealias to the OneOfX type
                    var alias = aliasOneOf(casetypes, name: ename, optional: false, defined: parents.isEmpty)
                    alias.peerTypes = constantEnums
                    return alias
                } else { // otherwise we need to continue to use the nested inner types in a hollow enum and return the typealias
                    let choiceName = oneOfSuffix
                    let aliasName = ename + (parents.isEmpty ? "" : choiceName) // top-level aliases are fully-qualified types because they are defined in defs and refs
                    // the enum code now just contains the nested types, so copy over only the embedded types
                    let nestedAlias = CodeTypeAlias(name: choiceName, type: oneOfType(casetypes), access: accessor(parents))
                    var nestedEnum = CodeEnum(name: ename + "Types", access: accessor(parents))
                    nestedEnum.nestedTypes = [nestedAlias] + code.nestedTypes

                    // FIXME: alias to nested type doesn't seem to work
                    // let aliasRef = CodeExternalType(typeName([nestedEnum.name], choiceName), access: accessor(parents))
                    let aliasRef = CodeExternalType(nestedEnum.name + "." + choiceName, access: accessor(parents))

                    var alias = CodeTypeAlias(name: aliasName, type: aliasRef, access: accessor(parents))
                    alias.comments = comments
                    alias.peerTypes = [nestedEnum]

                    return alias
                }
            }

            return code
        }

        func createSimpleEnumeration(_ typename: CodeTypeName, name: String, types: [Schema.SimpleTypes]) -> CodeNamedType {
            var assoc = CodeEnum(name: typeName(parents, name), access: accessor(parents + [typeName(parents, name)]))

            var subTypes: [CodeType] = []
            let optional = false

            for (_, sub) in types.enumerated() {
                switch sub {
                case .string:
                    let caseName = enumCase == .upper ? "Text" : "text"
                    subTypes.append(CodeExternalType.string)
                    assoc.cases.append(CodeEnum.Case(name: caseName, type: CodeExternalType.string))
                case .number:
                    let caseName = enumCase == .upper ? "Number" : "number"
                    subTypes.append(CodeExternalType.double)
                    assoc.cases.append(CodeEnum.Case(name: caseName, type: CodeExternalType.double))
                case .boolean:
                    let caseName = enumCase == .upper ? "Boolean" : "boolean"
                    subTypes.append(CodeExternalType.bool)
                    assoc.cases.append(CodeEnum.Case(name: caseName, type: CodeExternalType.bool))
                case .integer:
                    let caseName = enumCase == .upper ? "Integer" : "integer"
                    subTypes.append(CodeExternalType.int)
                    assoc.cases.append(CodeEnum.Case(name: caseName, type: CodeExternalType.int))
                case .array:
                    let caseName = enumCase == .upper ? "List" : "list"
                    subTypes.append(CodeExternalType.array)
                    assoc.cases.append(CodeEnum.Case(name: caseName, type: CodeExternalType.array))
                case .object:
                    let caseName = enumCase == .upper ? "Object" : "object"
                    //print("warning: making Bric for key: \(name)")
                    subTypes.append(CodeExternalType.bric)
                    assoc.cases.append(CodeEnum.Case(name: caseName, type: CodeExternalType.bric))
                case .null:
                    let caseName = enumCase == .upper ? "None" : "none"
                    subTypes.append(CodeExternalType.null)
//                    optional = true
                    assoc.cases.append(CodeEnum.Case(name: caseName, type: nil))
                }
            }

            assoc.conforms += standardAdoptions
            parents += [typename]
            parents = Array(parents.dropLast())

            if subTypes.count > 0 {
                return aliasOneOf(subTypes, name: assoc.name, optional: optional, defined: parents.isEmpty)
            }

            return assoc
        }

        func aliasOneOf(_ subTypes: [CodeType], name: CodeTypeName, optional: Bool, defined: Bool) -> CodeTypeAlias {
            // There's no OneOf1; this can happen e.g. when a schema has types: ["double", "null"]
            // In these cases, simply return an alias to the types
            let aname = defined ? name : (unescape(name) + oneOfSuffix)


            let typ = subTypes.count == 1 ? subTypes[0] : oneOfType(subTypes)
            var alias = CodeTypeAlias(name: aname, type: optional ? optionalType(typ) : typ, access: accessor(parents))

            alias.comments = comments
            return alias
        }

        func aliasSimpleType(name typename: CodeTypeName, type: CodeExternalType) -> CodeNamedType {
            // When we encapsulate a typealias (e.g., Color = String), we make it into a separate type that can be extended
            if let encapsulatedType = self.encapsulate[typename] {
                return encapsulateType(name: typename, type: encapsulatedType, access: accessor(parents))
            }
            return CodeTypeAlias(name: typename, type: type, access: accessor(parents))
        }

        enum StateMode { case standard, allOf, anyOf }

        /// Creates a schema instance for an "object" type with all the listed properties
        func createObject(_ typename: CodeTypeName, properties: [PropInfo], mode modex: StateMode) throws -> CodeNamedType {
            var mode = modex
            let isUnionType = mode == .allOf || mode == .anyOf

            var code: CodeStateType
            if generateValueTypes {
                code = CodeStruct(name: typename, access: accessor(parents + [typename]))
            } else {
                code = CodeClass(name: typename, access: accessor(parents + [typename]))
            }

            code.comments = comments

            typealias PropNameType = (name: CodePropName, type: CodeType)
            var proptypes: [PropNameType] = []

            // assign some anonymous names to the properties
            var anonPropCount = 0
            func incrementAnonPropCount() -> Int {
                anonPropCount += 1
                return anonPropCount - 1
            }
            var props: [PropDec] = properties.map({ PropDec(name: $0.name ?? propName(parents, "p\(incrementAnonPropCount())"), required: $0.required, prop: $0.schema, anon: $0.name == nil) })

            for (name, required, prop, anon) in props {
                var proptype: CodeType

                if let ref = prop.ref {
                    let tname = typeName(parents, ref)
                    proptype = CodeExternalType(tname, access: accessor(parents + [typename]))
                } else if let overrideType = propertyTypeOverrides[typename + "." + name] {
                    proptype = CodeExternalType(overrideType, access: accessor(parents + [typename]))
                } else {
                    switch prop.type {
                    case .some(.v1(.string)) where prop._enum == nil: proptype = CodeExternalType.string
                    case .some(.v1(.number)): proptype = CodeExternalType.double
                    case .some(.v1(.boolean)): proptype = CodeExternalType.bool
                    case .some(.v1(.integer)): proptype = CodeExternalType.int
                    case .some(.v1(.null)): proptype = CodeExternalType.null

                    case .some(.v2(let types)):
                        let assoc = createSimpleEnumeration(typename, name: name, types: types)
                        code.nestedTypes.append(assoc)
                        proptype = assoc

                    case .some(.v1(.array)):
                        // a set of all the items, eliminating duplicates; this eliminated redundant schema declarations in the items list
                        let items: Set<Schema> = Set(prop.items?.v2 ?? prop.items?.v1.flatMap({ [$0] }) ?? [])

                        switch items.count {
                        case 0:
                            proptype = arrayType(CodeExternalType.bric)
                        case 1:
                            let item = items.first!
                            if let ref = item.ref {
                                proptype = arrayType(CodeExternalType(typeName(parents, ref), access: accessor(parents)))
                            } else {
                                let type = try reify(item, id: name + "Item", parents: parents + [code.name])
                                code.nestedTypes.append(type)
                                proptype = arrayType(type)
                            }
                        default:
                            throw CodegenErrors.typeArrayNotSupported
                        }

                    default:
                        // generate the type for the object
                        let subtype = try reify(prop, id: prop.title ?? (sanitizeString(name) + typeSuffix), parents: parents + [code.name])
                        code.nestedTypes.append(subtype)
                        proptype = subtype
                    }
                }

                var indirect: CodeType?

                if !required {
                    let structProps = props.filter({ (name, required, prop, anon) in

                        var types: [Schema.SimpleTypes] = prop.type?.values.1 ?? []
                        if let typ = prop.type?.values.0 { types.append(typ) }

                        switch types.first {
                        case .none: return true // unspecified object type: maybe a $ref
                        case .some(.object): return true // a custom object
                        default: return false // raw types never get an indirect
                        }
                    })

                    if structProps.count >= self.indirectCountThreshold {
                        indirect = indirectType(proptype)
                    }
                    proptype = optionalType(proptype)
                }

                let propn = propName(parents + [typename], name)
                var propd = CodeProperty.Declaration(name: propn, type: proptype, access: accessor(parents))
                propd.comments = [prop.title, prop.description].compactMap { $0 }

                var propi = propd.implementation

                // indirect properties are stored privately as _prop vars with cover wrappers that convert them to optionals
                if let indirect = indirect {
                    let ipropn = propName(parents + [typename], indirectPrefix + name)
                    var ipropd = CodeProperty.Declaration(name: ipropn, type: indirect, access: .`private`)
                    let ipropi = ipropd.implementation
                    code.props.append(ipropi)

                    propi.body = [
                        "get { return " + ipropn + ".value }",
                        "set { " + ipropn + " = Indirect(fromOptional: newValue) }",
                    ]
                }


                code.props.append(propi)
                let pt: PropNameType = (name: propn, type: proptype)
                proptypes.append(pt)
            }

            var addPropType: CodeType? = nil
            let hasAdditionalProps: Bool? // true=yes, false=no, nil=unspecified

            switch schema.additionalProperties {
            case .none:
                hasAdditionalProps = nil // TODO: make a global default for whether unspecified additionalProperties means yes or no
            case .some(.v1(false)):
                hasAdditionalProps = nil // FIXME: when this is false, allOf union types won't validate
            case .some(.v1(true)), .some(.v2): // TODO: generate object types for B
                hasAdditionalProps = true
                addPropType = CodeExternalType.object // additionalProperties default to [String:Bric]
            }

            let addPropName = renamer(parents, "additionalProperties") ?? "additionalProperties"

            if let addPropType = addPropType {
                let propn = propName(parents + [typename], addPropName)
                let propd = CodeProperty.Declaration(name: propn, type: addPropType, access: accessor(parents))
                let propi = propd.implementation
                code.props.append(propi)
                let pt: PropNameType = (name: propn, type: addPropType)
//                proptypes.append(pt)
            }

            /// Creates a Keys enumeration of all the valid keys for this state instance
            func makeKeys(_ keyName: String) {
                var cases: [CodeCaseSimple<String>] = []
                for (key, _, _, _) in props {
                    let pname = propName(parents + [typename], key)
                    cases.append(CodeCaseSimple(name: pname, value: key))
                }

                if addPropType != nil {
                    cases.append(CodeCaseSimple(name: addPropName, value: ""))
                }

                if !cases.isEmpty {
                    var keysType = CodeSimpleEnum(name: keyName, access: accessor(parents), cases: cases)
                    keysType.conforms.append(.codingKey)
                    keysType.conforms.append(.hashable)
                    keysType.conforms.append(.codable)
                    keysType.conforms.append(.caseIterable)
                    code.nestedTypes.insert(keysType, at: 0)
                }
            }

            /// Creates a memberwise initializer for the object type
            func makeInit(_ merged: Bool) {
                var elements: [CodeTupleElement] = []
                var initbody: [String] = []
                var wasIndirect = false
                for p1 in code.props {
                    if p1.declaration.name.hasPrefix(indirectPrefix) {
                        wasIndirect = true
                    } else {
                        // allOf merged will take any sub-states and create initializers with all of their arguments
                        let sub = merged ? p1.declaration.type as? CodeStateType : nil
                        for p in (sub?.props ?? [p1]) {
                            let d = p.declaration
                            let e = CodeTupleElement(name: d.name, type: d.type, value: d.type?.defaultValue, anon: isUnionType)

                            elements.append(e)
                            if wasIndirect {
                                // unescape is a hack because we don't preserve the original property name, so we need to
                                // do self._case = XXX instead of self._`case` = XXX
                                initbody.append("self.\(indirectPrefix)\(unescape(d.name)) = Indirect(fromOptional: \(d.name))")
                                wasIndirect = false
                            } else {
                                initbody.append("self.\(d.name) = \(d.name)")
                            }
                        }
                    }
                }


                // for the init declaration, unescape all the elements and only re-escape them if they are the few forbidden keywords
                // https://github.com/apple/swift-evolution/blob/master/proposals/0001-keywords-as-argument-labels.md
                var argElements = elements
                for i in 0..<argElements.count {
                    if var name = argElements[i].name {
                        let unescaped = unescape(name)
                        if unescaped.isSwiftReservedArg() {
                            name = "`" + unescaped + "`"
                        }
                        argElements[i].name = name
                    }
                }

                let initargs = CodeTuple(elements: argElements)
                let initfun = CodeFunction.Declaration(name: "init", access: accessor(parents), instance: true, arguments: initargs, returns: CodeTuple(elements: []))
                let initimp = CodeFunction.Implementation(declaration: initfun, body: initbody, comments: [])
                code.funcs.append(initimp)
            }

            let keysName = "CodingKeys"
            if !isUnionType {
                // create an enumeration of "Keys" for all the object's properties
                makeKeys(keysName)
            }

            makeInit(false)

            code.conforms += standardAdoptions

            let reftypes = proptypes.map({ $0.type })
            if (mode == .allOf || mode == .anyOf) && useAllOfEnums && reftypes.count >= 2 && reftypes.count <= 10 {
                let suffix = mode == .allOf ? allOfSuffix : anyOfSuffix
                let sumType = mode == .allOf ? allOfType(reftypes) : anyOfType(reftypes)

                if code.nestedTypes.isEmpty { // if there are no nested types, we can simply return a typealias to the AllOfX type
                    var alias = CodeTypeAlias(name: code.name, type: sumType, access: accessor(parents))
                    alias.comments = comments
                    return alias
                } else { // otherwise we need to continue to use the nested inner types in a hollow enum and return the typealias
                    let choiceName = suffix
                    // the enum code now just contains the nested types, so copy over only the embedded types
                    let nestedAlias = CodeTypeAlias(name: choiceName, type: sumType, access: accessor(parents))
                    var nestedEnum = CodeEnum(name: code.name + "Types", access: accessor(parents))
                    nestedEnum.nestedTypes = [nestedAlias] + code.nestedTypes

                    // FIXME: alias to nested type doesn't seem to work
                    // let aliasRef = CodeExternalType(typeName([nestedEnum.name], choiceName), access: accessor(parents))
                    let aliasRef = CodeExternalType(nestedEnum.name + "." + choiceName, access: accessor(parents))

                    var alias = CodeTypeAlias(name: code.name, type: aliasRef, access: accessor(parents))
                    alias.comments = comments
                    alias.peerTypes = [nestedEnum]

                    return alias
                }
            }

            return code
        }

        func createArray(_ typename: CodeTypeName) throws -> CodeNamedType {
            // when a top-level type is an array, we make it a typealias with a type for the individual elements
            switch schema.items {
            case .none:
                return CodeTypeAlias(name: typeName(parents, id), type: arrayType(CodeExternalType.bric), access: accessor(parents))
            case .some(.v2):
                throw CodegenErrors.typeArrayNotSupported
            case .some(.v1(let item)):
                if let ref = item.ref {
                    return CodeTypeAlias(name: typeName(parents, id), type: arrayType(CodeExternalType(typeName(parents, ref), access: accessor(parents))), access: accessor(parents))
                } else {
                    // note that we do not tack on the alias' name, because it will not be used as the external name of the type
                    let type = try reify(item, id: typename + "Item", parents: parents)

                    // rather than creating two aliases when something is an array of an alias, merge them as a single unit
                    if let sub = aliasType(type) {
                        return CodeTypeAlias(name: typeName(parents, id), type: arrayType(sub), access: accessor(parents))
                    } else {
                        let alias = CodeTypeAlias(name: typeName(parents, id), type: arrayType(type), access: accessor(parents), peerTypes: [type])
                        return alias
                    }
                }
            }
        }

        func createStringEnum(_ name: CodeTypeName? = nil, values: [Bric]) throws -> CodeSimpleEnum<String> {
            // some languages (like Typescript) commonly have union types that are like: var intOrConstant: number | "someConst"
            // when a string enum has fewer values than constantPromotionThreshold, we promote the type to the top level to global use
            let valueTypeNames = typeName(parents, "Literal" + values.map({ $0.stringify() }).joined(separator: "Or"), capitalize: true)

            var code = CodeSimpleEnum<String>(name: name ?? valueTypeNames, access: accessor(parents))
            code.comments = comments
            for e in values {
                if case .str(let evalue) = e {
                    code.cases.append(CodeCaseSimple<String>(name: typeName(parents, evalue, capitalize: enumCase == .upper), value: evalue))
                } else if case .num(let evalue) = e {
                    // FIXME: this isn't right, but we don't currently support mixed-type simple enums
                    code.cases.append(CodeCaseSimple<String>(name: typeName(parents, evalue.description, capitalize: enumCase == .upper), value: evalue.description))

                } else {
                    throw CodegenErrors.nonStringEnumsNotSupported
                }
            }

            // when there is only a single possible value, make it the default
            if let firstCase = code.cases.first , code.cases.count == 1 {
                code.defaultValue = "." + firstCase.name
            }

            code.conforms += standardAdoptions
            code.conforms.append(.caseIterable)
            return code
        }

        let type = schema.type
        let typename = typeName(parents, id)
        let explicitName = id.hasPrefix("#") // explicit named like "#/definitions/LocalMultiTimeUnit" must be used literally
        if let values = schema._enum {
            // when creating a string enum, explcit names must be used, otherwise we generate a name like "LiteralXOrYOrZ"
            return try createStringEnum(explicitName ? typename : nil, values: values)
        } else if case .some(.v2(let multiType)) = type {
            // "type": ["string", "number"]
            var subTypes: [CodeType] = []
            for type in multiType {
                switch type {
                case .array: subTypes.append(arrayType(CodeExternalType.bric))
                case .boolean: subTypes.append(CodeExternalType.bool)
                case .integer: subTypes.append(CodeExternalType.int)
                case .null: subTypes.append(CodeExternalType.null)
                case .number: subTypes.append(CodeExternalType.double)
                case .object: subTypes.append(CodeExternalType.bric)
                case .string: subTypes.append(CodeExternalType.string)
                }
            }
            return aliasOneOf(subTypes, name: typename, optional: false, defined: parents.isEmpty)
        } else if case .some(.v1(.string)) = type {
            return aliasSimpleType(name: typename, type: CodeExternalType.string)
        } else if case .some(.v1(.integer)) = type {
            return aliasSimpleType(name: typename, type: CodeExternalType.int)
        } else if case .some(.v1(.number)) = type {
            return aliasSimpleType(name: typename, type: CodeExternalType.double)
        } else if case .some(.v1(.boolean)) = type {
            return aliasSimpleType(name: typename, type: CodeExternalType.bool)
        } else if case .some(.v1(.null)) = type {
            return aliasSimpleType(name: typename, type: CodeExternalType.null)
        } else if case .some(.v1(.array)) = type {
            return try createArray(typename)
        } else if let properties = schema.properties , !properties.isEmpty {
            return try createObject(typename, properties: getPropInfo(schema, id: id, parents: parents), mode: .standard)
        } else if let allOf = schema.allOf {
            // represent allOf as a struct with non-optional properties
            var props: [PropInfo] = []
            for propSchema in allOf {
                // an internal nested state type can be safely collapsed into the owning object
                // not working for a few reasons, one of which is bric merge info
//                if let subProps = propSchema.properties where !subProps.isEmpty {
//                    props.appendContentsOf(getPropInfo(subProps))
//                    // TODO: sub-schema "required" array
//                } else {
                    props.append(PropInfo(name: nil, required: true, schema: propSchema))
//                }
            }
            return try createObject(typename, properties: props, mode: .allOf)
        } else if let anyOf = schema.anyOf {
            if anyOfAsOneOf {
                // some schemas mis-interpret anyOf to mean oneOf, so redirect them to oneOfs
                return try createOneOf(anyOf)
            }
            var props: [PropInfo] = []
            for propSchema in anyOf {
                // if !isBricType(propSchema) { continue } // anyOfs disallow misc Bric types // disabled because this is sometimes used in an allOf to validate peer properties
                props.append(PropInfo(name: nil, required: false, schema: propSchema))
            }
            if props.count == 1 { props[0].required = true }

            // AnyOfs with only 1 property are AllOf
            return try createObject(typename, properties: props, mode: props.count > 1 ? .anyOf : .allOf)
        } else if let oneOf = schema.oneOf { // TODO: allows properties in addition to oneOf
            return try createOneOf(oneOf)
        } else if let ref = schema.ref { // create a typealias to the reference
            let tname = typeName(parents, ref)
            let extern = CodeExternalType(tname)
            return CodeTypeAlias(name: typename == tname ? typename + "Type" : typename, type: extern, access: accessor(parents))
        } else if let not = schema.not?.value { // a "not" generates a validator against an inverse schema
            let inverseId = "Not" + typename
            let inverseSchema = try reify(not, id: inverseId, parents: parents)
            return CodeTypeAlias(name: typename, type: notBracType(inverseSchema), access: accessor(parents), peerTypes: [inverseSchema])
            // TODO
//        } else if let req = schema.required where !req.isEmpty { // a sub-bric with only required properties just validates
//            let reqId = "Req" + typename
//            let reqSchema = try reify(not, id: reqId, parents: parents)
//            return CodeTypeAlias(name: typename, type: notBracType(reqSchema), access: accessor(parents), peerTypes: [reqSchema])
        } else if isBricType(schema) { // an empty schema just generates pure Bric
            return CodeTypeAlias(name: typename, type: CodeExternalType.bric, access: accessor(parents))
        } else if case .some(.v1(.object)) = type, case let .some(.v2(adp)) = schema.additionalProperties {
            // an empty schema with additionalProperties makes it a [String:Type]
            let adpType = try reify(adp, id: typename + "Value", parents: parents)
            return CodeTypeAlias(name: typename, type: dictionaryType(CodeExternalType.string, adpType), access: accessor(parents), peerTypes: [adpType])
        } else if case .some(.v1(.object)) = type, case .some(.v1(true)) = schema.additionalProperties {
            // an empty schema with additionalProperties makes it a [String:Bric]
            //print("warning: making Brictionary for code: \(schema.bric().stringify())")
            return CodeTypeAlias(name: typename, type: CodeExternalType.object, access: self.accessor(parents))
        } else {
            // throw CodegenErrors.illegalState("No code to generate for: \(schema.bric().stringify())")
//            print("warning: making HollowBric for code: \(schema.bric().stringify())")
            return CodeTypeAlias(name: typename, type: CodeExternalType.bric, access: self.accessor(parents))
        }
    }


    /// Parses the given schema source into a module; if the rootSchema is non-nil, then all the schemas
    /// will be generated beneath the given root
    public func assemble(_ schemas: [(String, Schema)], rootName: String? = nil) throws -> CodeModule {

        var types: [CodeNamedType] = []
        for (key, schema) in schemas {
            if key == rootName { continue }
            types.append(try reify(schema, id: key, parents: []))
        }

        let rootSchema = schemas.filter({ $0.0 == rootName }).first?.1
        let module = CodeModule()

        // next, promote all of the types for promoteIdenticalTypes
        if promoteIdenticalTypes {
            func flattenedTypes(_ types: [CodeNamedType]) -> [CodeNamedType] {
                let nestedTypes = types.compactMap({ $0 as? CodeStateType }).flatMap({ $0.nestedTypes  })
                let peerTypes = types.compactMap({ $0 as? CodeTypeAlias }).flatMap({ $0.peerTypes  })
                if nestedTypes.isEmpty && peerTypes.isEmpty { return types }
                return types + flattenedTypes(nestedTypes) + flattenedTypes(peerTypes)
            }

            let deepTypes = flattenedTypes(types)

            func duplicatedTypes<T : CodeNamedType & Hashable>(_ typeList: [T], from: [CodeNamedType]) -> Set<T> {
                var enumCounts: [T: Int] = [:]
                for enumType in typeList {
                    enumCounts[enumType] = (enumCounts[enumType] ?? 0) + 1
                }

                var dupes: Set<T> = []
                for (type, count) in enumCounts {
                    // any types that have more than one count and are not a "CodingKeys" type can be promoted to the top-level
                    if count > 1 && type.identifier != "CodingKeys" {
                        dupes.insert(type)
                    }
                }

                return dupes
            }

            // we currently just promote string enums, since those are the most common shared code we've observed
            let promotedTypes = duplicatedTypes(deepTypes.compactMap({ $0 as? CodeSimpleEnum<String> }), from: types)

            types = types.map({ $0.purgeTypes(promotedTypes) }) + Array(promotedTypes)

            // next add in any encapsulated types we have specified that might not actually
            // have been defined in the schema; this allows us to encapsulate things
            // into wrappers without them being treated specially by the schema
            for (name, type) in self.encapsulate {
                if !deepTypes.contains(where: { $0.name == name }) {
                    let encap = encapsulateType(name: name, type: type, access: accessor([]))
                    types.append(encap)
                }
            }

            // this doesn't quite work because we have some conflicting types for common cases (e.g., "Value")
        // types = promoteTypes(deepTypes.compactMap({ $0 as? CodeTypeAlias }), from: types)


        }

        // lastly we filter out all the excluded types we want to skip
        types = types.filter({ !excludes.contains($0.name) })

        if let rootSchema = rootSchema {
            let code = try reify(rootSchema, id: rootName ?? "Schema", parents: [])
            if var root = code as? CodeStateType {
                root.nestedTypes.append(contentsOf: types)
                module.types = [root]
            } else {
                module.types = [code]
                module.types.append(contentsOf: types)
            }
        } else {
            module.types = types
        }

        return module
    }

}

extension CodeNamedType {
    func purgeTypes<T : CodeNamedType & Hashable>(_ purge: Set<T>) -> CodeNamedType {
        let purgeCodeSet = purge.map({ $0.codeValue }) // ### ugly, but generics prevent us from checking for equatable
        if var impl = self as? CodeStateType {
            impl.nestedTypes = impl.nestedTypes.filter({ !purgeCodeSet.contains($0.codeValue) }).map({ $0.purgeTypes(purge) })
            return impl
        } else if var alias = self as? CodeTypeAlias {
            alias.peerTypes = alias.peerTypes.filter({ !purgeCodeSet.contains($0.codeValue) }).map({ $0.purgeTypes(purge) })
            return alias
        } else {
            return self
        }
    }
}

public extension Schema {

    enum BracReferenceError : Error, CustomDebugStringConvertible {
        case referenceRequiredRoot(String)
        case referenceMustBeRelativeToCurrentDocument(String)
        case referenceMustBeRelativeToDocumentRoot(String)
        case refWithoutAdditionalProperties(String)
        case referenceNotFound(String)

        public var debugDescription : String {
            switch self {
            case .referenceRequiredRoot(let str): return "ReferenceRequiredRoot: \(str)"
            case .referenceMustBeRelativeToCurrentDocument(let str): return "ReferenceMustBeRelativeToCurrentDocument: \(str)"
            case .referenceMustBeRelativeToDocumentRoot(let str): return "ReferenceMustBeRelativeToDocumentRoot: \(str)"
            case .refWithoutAdditionalProperties(let str): return "RefWithoutAdditionalProperties: \(str)"
            case .referenceNotFound(let str): return "ReferenceNotFound: \(str)"
            }
        }
    }

    /// Support for JSON $ref <http://tools.ietf.org/html/draft-pbryan-zyp-json-ref-03>
    func resolve(_ path: String) throws -> Schema {
        var parts = path.split(whereSeparator: { $0 == "/" }).map { String($0) }
//        print("parts: \(parts)")
        if parts.isEmpty { throw BracReferenceError.referenceRequiredRoot(path) }
        let first = parts.remove(at: 0)
        if first != "#" {  throw BracReferenceError.referenceMustBeRelativeToCurrentDocument(path) }
        if parts.isEmpty { throw BracReferenceError.referenceRequiredRoot(path) }
        let root = parts.remove(at: 0)
        if _additionalProperties.isEmpty { throw BracReferenceError.refWithoutAdditionalProperties(path) }
        guard var json = _additionalProperties[root] else { throw BracReferenceError.referenceNotFound(path) }
        for part in parts {
            guard let next: Bric = json[part] else { throw BracReferenceError.referenceNotFound(path) }
            json = next
        }

        return try Schema.bracDecoded(bric: json)
    }

    /// Parse the given JSON info an array of resolved schema references, maintaining property order from the source JSON
    public static func parse(_ source: String, rootName: String?) throws -> [(String, Schema)] {
        return try generate(impute(source), rootName: rootName)
    }

    public static func generate(_ json: Bric, rootName: String?) throws -> [(String, Schema)] {
        let refmap = try json.resolve()

        var refschema : [String : Schema] = [:]

        var schemas: [(String, Schema)] = []
        for (key, value) in refmap {
            let subschema = try Schema.bracDecoded(bric: value)
            refschema[key] = subschema
            schemas.append((key, subschema))
        }

        let schema = try Schema.bracDecoded(bric: json)
        if let rootName = rootName {
            schemas.append((rootName, schema))
        }
        return schemas
    }

    /// Parses the given JSON and injects the property ordering attribute based on the underlying source
    public static func impute(_ source: String) throws -> Bric {
        var fidelity = try FidelityBricolage.parse(source)
        fidelity = imputePropertyOrdering(fidelity)
        return fidelity.bric()
    }


    /// Walk through the raw bricolage and add in the "propertyOrder" prop so that the schema generator
    /// can use the same ordering that appears in the raw JSON schema
    fileprivate static func imputePropertyOrdering(_ bc: FidelityBricolage) -> FidelityBricolage {
        switch bc {
        case .arr(let arr):
            return .arr(arr.map(imputePropertyOrdering))
        case .obj(let obj):
            var sub = FidelityBricolage.createObject()

            for (key, value) in obj {
                sub.append((key, imputePropertyOrdering(value)))
                // if the key is "properties" then also add a "propertyOrder" property with the order that the props appear in the raw JSON
                if case .obj(let dict) = value , !dict.isEmpty && String(String.UnicodeScalarView() + key) == "properties" {
                    // ### FIXME: we hack in a check for "type" to determine if we are in a schema element and not,
                    //  e.g., another properties list, but this will fail if there is an actual property named "type"
                    if bc.bric()["type"] == "object" {
                        let ordering = dict.map({ $0.0 })
                        sub.append((FidelityBricolage.StrType("propertyOrder".unicodeScalars), FidelityBricolage.arr(ordering.map(FidelityBricolage.str))))
                    }
                }
            }
            return .obj(sub)
        default:
            return bc
        }
    }

}

private let CurioUsage = [
    "Usage: cat <schema.json> | curio <arguments> | xcrun -sdk macosx swiftc -parse -",
    "Parameters:",
    "  -name: The name of the top-level type to be generated",
    "  -defs: The internal path to definitions (default: #/definitions/)",
    "  -maxdirect: The maximum number of properties before making them Indirect",
    "  -useOneOfEnums: Whether to collapse oneOfs into OneOf enum types",
    "  -useAllOfEnums: Whether to collapse allOfs into AllOf sum types",
    "  -useAnyOfEnums: Whether to collapse anyOfs into AnyOf sum types",
    "  -anyOfAsOneOf: Whether to treat AnyOf elements as OneOf elements",
    "  -rename: A renaming mapping",
    "  -import: Additional imports at the top of the generated source",
    "  -access: Default access (public, private, internal, or default)",
    "  -typetype: Generated type (struct or class)"
    ].joined(separator: "\n")

extension Curio {
    public static func runWithArguments(_ arguments: [String]) throws {
        var args = arguments.makeIterator()
        _ = args.next() ?? "curio" // cmdname


        struct UsageError : Error {
            let msg: String

            init(_ msg: String) {
                self.msg = msg + "\n" + CurioUsage
            }
        }

        var modelName: String? = nil
        var accessType: String? = "public"
        var renames: [String : String] = [:]
        var imports: [String] = ["BricBrac"]
        var maxdirect: Int?
        var typeType: String?
        var useOneOfEnums: Bool?
        var useAllOfEnums: Bool?
        var useAnyOfEnums: Bool?
        var anyOfAsOneOf: Bool?
        var generateEquals: Bool?
        var generateHashable: Bool?
        var generateCodable: Bool?
        var promoteIdenticalTypes: Bool?

        while let arg = args.next() {
            switch arg {
            case "-help":
                print(CurioUsage)
                return
            case "-name":
                modelName = args.next()
            case "-maxdirect":
                maxdirect = Int(args.next() ?? "")
            case "-rename":
                renames[args.next() ?? ""] = args.next()
            case "-import":
                imports.append(args.next() ?? "")
            case "-access":
                accessType = args.next()
            case "-typetype":
                typeType = String(args.next() ?? "")
            case "-useOneOfEnums":
                useOneOfEnums = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            case "-useAllOfEnums":
                useAllOfEnums = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            case "-useAnyOfEnums":
                useAnyOfEnums = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            case "-anyOfAsOneOf":
                anyOfAsOneOf = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            case "-generateEquals":
                generateEquals = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            case "-generateHashable":
                generateHashable = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            case "-generateCodable":
                generateCodable = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            case "-promoteIdenticalTypes":
                promoteIdenticalTypes = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            default:
                throw UsageError("Unrecognized argument: \(arg)")
            }
        }

        do {
            guard let modelName = modelName else {
                throw UsageError("Missing model name")
            }

            guard let accessType = accessType else {
                throw UsageError("Missing access type")
            }

            var access: CodeAccess
            switch accessType {
            case "public": access = .`public`
            case "private": access = .`private`
            case "internal": access = .`internal`
            case "default": access = .`default`
            default: throw UsageError("Unknown access type: \(accessType) (must be 'public', 'private', 'internal', or 'default')")
            }

            var curio = Curio()
            if let maxdirect = maxdirect { curio.indirectCountThreshold = maxdirect }
            if let useOneOfEnums = useOneOfEnums { curio.useOneOfEnums = useOneOfEnums }
            if let useAllOfEnums = useAllOfEnums { curio.useAllOfEnums = useAllOfEnums }
            if let useAnyOfEnums = useAnyOfEnums { curio.useAnyOfEnums = useAnyOfEnums }
            if let anyOfAsOneOf = anyOfAsOneOf { curio.anyOfAsOneOf = anyOfAsOneOf }
            if let generateEquals = generateEquals { curio.generateEquals = generateEquals }
            if let generateHashable = generateHashable { curio.generateHashable = generateHashable }
            if let generateCodable = generateCodable { curio.generateCodable = generateCodable }
            if let promoteIdenticalTypes = promoteIdenticalTypes { curio.promoteIdenticalTypes = promoteIdenticalTypes }

            if let typeType = typeType {
                switch typeType {
                case "struct": curio.generateValueTypes = true
                case "class": curio.generateValueTypes = false
                default: throw UsageError("Unknown type type: \(typeType) (must be 'struct' or 'class')")
                }
            }
            
            curio.accessor = { _ in access }
            curio.renamer = { (parents, id) in
                let key = (parents + [id]).joined(separator: ".")
                return renames[id] ?? renames[key]
            }
            
            
            //debugPrint("Reading schema file from standard input")
            var src: String = ""
            while let line = readLine(strippingNewline: false) {
                src += line
            }
            
            let schemas = try Schema.parse(src, rootName: modelName)
            let module = try curio.assemble(schemas)

            module.imports = imports

            let emitter = CodeEmitter(stream: "")
            module.emit(emitter)
            
            let code = emitter.stream
            print(code)
        }
    }
}

/// Standard types
extension CodeExternalType {
    static let string = CodeExternalType("String")
    static let int = CodeExternalType("Int")
    static let double = CodeExternalType("Double")
    static let bool = CodeExternalType("Bool")
    static let void = CodeExternalType("Void")
    static let encoder = CodeExternalType("Encoder")
    static let decoder = CodeExternalType("Decoder")
}

/// BricBrac types
extension CodeExternalType {
    static let null = CodeExternalType("ExplicitNull")
    static let hollow = CodeExternalType("HollowBric")
    static let bric = CodeExternalType("Bric", defaultValue: "nil")
    static let array = CodeExternalType("Array", generics: [CodeExternalType.bric], defaultValue: "[]")
    static let object = CodeExternalType("Dictionary", generics: [CodeExternalType.string, CodeExternalType.bric], defaultValue: "[:]")
}

/// Standard protocols
extension CodeProtocol {
    static let codable = CodeProtocol(name: "Codable")
    static let codingKey = CodeProtocol(name: "CodingKey")
    static let caseIterable = CodeProtocol(name: "CaseIterable")
    static let equatable = CodeProtocol(name: "Equatable")
    static let hashable = CodeProtocol(name: "Hashable")
    static let rawRepresentable = CodeProtocol(name: "RawRepresentable")
}

/// BricBrac protocols
extension CodeProtocol {
    static let bracable = CodeProtocol(name: "Bracable")
    static let bricable = CodeProtocol(name: "Bricable")
}

