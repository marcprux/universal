//
//  Curio.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 6/30/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//


/// A JSON Schema processor that emits Swift code using the Bric-a-Brac framework for marshalling and unmarshalling.
///
/// Current shortcomings:
/// • "anyOf" schema type values cannot prevent that all their tuple elements not be set to nil
///
/// TODO:
/// • hide Indirect in private fields and make public Optional getters/setters
public struct Curio {

    /// whether to generate structs or classes (classes are faster to compiler for large models)
    public var generateValueTypes = true

    /// whether to generate breqable functions for each type
    /// Not yet supported due to inability to equate nested types (e.g.: binary operator '==' cannot be applied to two 'Optional<Array<ValuesItem>>' (aka 'Optional<Array<Dictionary<String, Bric>>>') operands)
    /// Unless we want to write a ton more code for equatability, we'll need to wait for Swift 3's
    /// ability to declare constrained protocol conformance
    public var generateEquals = false

    /// Whether to output simple union types as a typealias to a BricBrac.OneOf<T1, T2, ...> enum
    public var useOneOfEnums = true

    /// the number of properties beyond which Optional types should instead be Indirect; this is needed beause
    /// a struct that contains many other stucts can make very large compilation units and take a very long
    /// time to compile
    public var indirectCountThreshold = 20

    /// The prefix for private internal indirect implementations
    public var indirectPrefix = "_"

    public var accessor: ([CodeTypeName])->(CodeAccess) = { _ in .Public }
    public var renamer: ([CodeTypeName], String)->(CodeTypeName?) = { (parents, id) in nil }

    /// special prefixes to trim (adheres to the convention that top-level types go in the "defintions" level)
    public var trimPrefixes = ["#/definitions/", "#/defs/"]

    /// The suffix to append to generated types
    public var typeSuffix = ""

    public var propOrdering: ([CodeTypeName], String)->(Array<String>?) = { (parents, id) in nil }

    public init() {
    }

    enum CodegenErrors : ErrorType, CustomDebugStringConvertible {
        case TypeArrayNotSupported
        case IllegalDefaultType
        case DefaultValueNotInStringEnum
        case NonStringEnumsNotSupported // TODO
        case TupleTypeingNotSupported // TODO
        case IllegalState(String)
        case Unsupported(String)
        case IllegalProperty(Schema)
        case CompileError(String)

        var debugDescription : String {
            switch self {
            case TypeArrayNotSupported: return "TypeArrayNotSupported"
            case IllegalDefaultType: return "IllegalDefaultType"
            case DefaultValueNotInStringEnum: return "DefaultValueNotInStringEnum"
            case NonStringEnumsNotSupported: return "NonStringEnumsNotSupported"
            case TupleTypeingNotSupported: return "TupleTypeingNotSupported"
            case IllegalState(let x): return "IllegalState(\(x))"
            case Unsupported(let x): return "Unsupported(\(x))"
            case IllegalProperty(let x): return "IllegalProperty(\(x))"
            case CompileError(let x): return "CompileError(\(x))"
            }
        }
    }


    /// Alphabetical characters
    static let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    /// “Identifiers begin with an uppercase or lowercase letter A through Z, an underscore (_), a noncombining alphanumeric Unicode character in the Basic Multilingual Plane, or a character outside the Basic Multilingual Plane that isn’t in a Private Use Area.”
    static let nameStart = Set((alphabet.uppercaseString + "_" + alphabet.lowercaseString).characters)

    /// “After the first character, digits and combining Unicode characters are also allowed.”
    static let nameBody = Set(Array(nameStart) + "0123456789".characters)

    /// Reserved words as per the Swift language guide
    static let reservedWords = Set(["class", "deinit", "enum", "extension", "func", "import", "init", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "for", "if", "in", "retu", ", switch", "where", "while", "as", "dynamicType", "false", "is", "nil", "self", "Self", "super", "true", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "convenience", "dynamic", "didSet", "final", "get", "infix", "inout", "lazy", "left", "mutating", "none", "nonmutating", "optional", "override", "postfix", "precedence", "prefix", "Protocol", "required", "right", "set", "Type", "unowned", "weak", "willSet"])

    func propName(parents: [CodeTypeName], var _ id: String) -> CodePropName {
        if let pname = renamer(parents, id) {
            return pname
        }

        if id == "init" {
            id = "initx" // even escaped with `init`, it crashes the compiler
        }


        while let first = id.characters.first where !Curio.nameStart.contains(first) {
            id = String(id.characters.dropFirst())
        }


        if Curio.reservedWords.contains(id) {
            id = "`" + id + "`"
        }
        return id
    }

    func unescape(name: String) -> String {
        if name.hasPrefix("`") && name.hasSuffix("`") && name.characters.count >= 2 {
            return name[name.startIndex.successor()..<name.endIndex.predecessor()]
        } else {
            return name
        }
    }

    func capitalize(nm: String) -> String {
        var name = ""
        var capnext = true
        for c in nm.characters {
            let validCharacters = name.isEmpty ? Curio.nameStart : Curio.nameBody
            if !validCharacters.contains(c) {
                capnext = true
            } else if capnext {
                name.appendContentsOf(String(c).uppercaseString)
                capnext = false
            } else {
                name.append(c)
            }
        }
        return name
    }

    func typeName(parents: [CodeTypeName], _ id: String) -> CodeTypeName {
        if let tname = renamer(parents, id) {
            return tname
        }

        var nm = id
        for pre in trimPrefixes {
            if nm.hasPrefix(pre) {
                nm = nm[pre.endIndex..<nm.endIndex]
            }
        }

        var name = capitalize(nm)

        if Curio.reservedWords.contains(name) {
            name = "`" + name + "`"
        }

        if name.isEmpty { // e.g., ">=" -> "U62U61"
            for c in id.unicodeScalars {
                name += "U\(c.value)"
            }
        }
        return CodeTypeName(name)
    }

    func aliasType(type: CodeNamedType) -> CodeType? {
        if let alias = type as? CodeTypeAlias where alias.peers.isEmpty {
            return alias.type
        } else {
            return nil
        }
    }

    typealias PropInfo = (name: String?, required: Bool, schema: Schema)

    func getPropInfo(schema: Schema, id: String, parents: [CodeTypeName]) -> [PropInfo] {
        let properties = schema.properties ?? [:]

        /// JSON Schema Draft 4 doesn't have any notion of property ordering, so we use a user-defined sorter
        /// followed by ordering them by their appearance in the (non-standard) "propertyOrder" element
        /// followed by ordering them by their appearance in the "required" element
        /// followed by alphabetical property name ordering
        let ordering = (propOrdering(parents, id) ?? []) + (schema.propertyOrder ?? []) + (schema.required ?? []) + Array(properties.keys).sort()
        let ordered = properties.sort { a, b in return ordering.indexOf(a.0) <= ordering.indexOf(b.0) }
        let req = Set(schema.required ?? [])
        let props = ordered.map({ PropInfo(name: $0, required: req.contains($0), schema: $1) })
        return props
    }

    /// Reifies the given schema as a Swift data structure
    public func reify(schema: Schema, id: String, var parents: [CodeTypeName]) throws -> CodeNamedType {
        func dictionaryType(keyType: CodeType, _ valueType: CodeType) -> CodeExternalType {
            return CodeExternalType("Dictionary", generics: [keyType, valueType], access: accessor(parents))
        }

        func arrayType(type: CodeType) -> CodeExternalType {
            return CodeExternalType("Array", generics: [type], access: accessor(parents))
        }

        func collectionOfOneType(type: CodeType) -> CodeExternalType {
            return CodeExternalType("CollectionOfOne", generics: [type], access: accessor(parents))
        }

        func optionalType(type: CodeType) -> CodeExternalType {
            return CodeExternalType("Optional", generics: [type], access: accessor(parents))
        }

        func indirectType(type: CodeType) -> CodeExternalType {
            return CodeExternalType("Indirect", generics: [type], access: accessor(parents))
        }

        func notBracType(type: CodeType) -> CodeExternalType {
            return CodeExternalType("NotBrac", generics: [type], access: accessor(parents))
        }

        func nonEmptyType(type: CodeType) -> CodeExternalType {
            return CodeExternalType("NonEmptyCollection", generics: [type, arrayType(type)], access: accessor(parents))
        }

        func oneOfType(types: [CodeType]) -> CodeExternalType {
            return CodeExternalType("OneOf\(types.count)", generics: types, access: accessor(parents))
        }


        let BricType = CodeExternalType("Bric", access: accessor(parents))
        let StringType = CodeExternalType("String", access: accessor(parents))
        let IntType = CodeExternalType("Int", access: accessor(parents))
        let DoubleType = CodeExternalType("Double", access: accessor(parents))
        let BoolType = CodeExternalType("Bool", access: accessor(parents))
        let VoidType = CodeExternalType("Void", access: accessor(parents))
        let ArrayType = CodeExternalType("Array", generics: [BricType], access: accessor(parents))
        let ObjectType = dictionaryType(StringType, BricType)

        /// Calculate the fully-qualified name of the given type
        func fullName(type: CodeType) -> String {
            return (parents + [type.identifier]).joinWithSeparator(".")
        }

        let bricable = CodeProtocol(name: "Bricable", access: accessor(parents))
        let bricfun = CodeFunction.Declaration(name: "bric", access: accessor(parents), instance: true, returns: CodeTuple(elements: [(name: nil, type: BricType, value: nil, anon: false)]))

        func selfType(type: CodeType, name: String?) -> CodeTupleElement {
            return CodeTupleElement(name: name, type: CodeExternalType(fullName(type), access: self.accessor(parents)), value: nil, anon: false)

        }

        let bracable = CodeProtocol(name: "Bracable", access: accessor(parents))
        let bracfun: (CodeType)->(CodeFunction.Declaration) = { CodeFunction.Declaration(name: "brac", access: self.accessor(parents), instance: false, exception: true, arguments: CodeTuple(elements: [(name: "bric", type: BricType, value: nil, anon: false)]), returns: CodeTuple(elements: [selfType($0, name: nil)])) }

        let breqable = CodeProtocol(name: "Breqable", access: accessor(parents))
        let breqfun: (CodeType)->(CodeFunction.Declaration) = { CodeFunction.Declaration(name: "breq", access: self.accessor(parents), instance: true, exception: false, arguments: CodeTuple(elements: [selfType($0, name: "other")]), returns: CodeTuple(elements: [(name: nil, type: BoolType, value: nil, anon: false)])) }


        let bricbrac = CodeProtocol(name: "BricBrac", access: accessor(parents))


        let comments = [schema.title, schema.description].filter({ $0 != nil }).map({ $0! })


        func schemaTypeName(schema: Schema, types: [CodeType], suffix: String = "") -> String {
            if let titleName = schema.title.flatMap({ typeName(parents, $0) }) { return titleName }

            // before we fall-back to using a generic "Type" name, try to name a simple struct
            // from the names of all of its properties

            // a list of names to ensure that the type is unique
            let names = types.map({ ($0 as? CodeNamedType)?.name ?? "" }).filter({ !$0.isEmpty })

            let props = getPropInfo(schema, id: id, parents: parents)
            if props.count > 0 && props.count <= 5 {
                var name = ""
                for prop in props {
                    name += capitalize(prop.name ?? "")
                }
                name += "Type"

                // ensure the name is unique
                var uniqueName = name
                var num = 0
                while names.contains(uniqueName) {
                    num++
                    uniqueName = name + String(num)
                }

                return uniqueName
            }

            return "Type" + suffix
        }

        func createOneOf(multi: [Schema]) throws -> CodeNamedType {
            let ename = typeName(parents, id)
            var code = CodeEnum(name: ename, access: accessor(parents))
            code.comments = comments

            var bricbody : [String] = []
            var bracbody : [String] = []
            var breqbody : [String] = []

            bricbody.append("switch self {")
            bracbody.append("return try bric.bracOne([")
            breqbody.append("switch (self, other) {")

            var casenames = Set<String>()
            var casetypes = Array<CodeType>()
            for sub in multi {
                let casetype: CodeType

                switch sub.type {
                case .Some(.A(.String)) where sub._enum == nil:
                    casetype = StringType
                case .Some(.A(.Number)):
                    casetype = DoubleType
                case .Some(.A(.Boolean)):
                    casetype = BoolType
                case .Some(.A(.Integer)):
                    casetype = IntType
                case .Some(.A(.Null)):
                    casetype = VoidType
                default:
                    let subtype = try reify(sub, id: schemaTypeName(sub, types: casetypes, suffix: String(casenames.count+1)), parents: parents + [code.name])
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

                casetypes.append(casetype)
                let cname = typeName(parents, casetype.identifier) + "Case"

                var casename = cname
                var n = 0
                // make sure case names are unique by suffixing with a number
                while casenames.contains(casename) { casename = cname + String(++n) }
                casenames.insert(casename)

                code.cases.append(CodeEnum.Case(name: casename, type: casetype))

                if casetype.identifier == "Void" {
                    // Void can't be extended, so we need to special-case it to avoid calling methods on the type
                    bricbody.append("case .\(casename): return .Nul")
//                    bracbody.append("{ Void() },") // just skip it
                    bracbody.append("{ try .\(casename)(bric.bracNul()) },")
                    breqbody.append("case (.\(casename), .\(casename)): return true")
                } else {
                    bricbody.append("case .\(casename)(let x): return x.bric()")
                    bracbody.append("{ try .\(casename)(\(casetype.identifier).brac(bric)) },")
                    breqbody.append("case let (.\(casename)(lhs), .\(casename)(rhs)): return lhs.breq(rhs)")
                }

                // Also add a convenience init argument for the type that just accepts the associated value
                // The type should be unique, since they are OneOf types that aren't allowed to match
                let initfun = CodeFunction.Declaration(name: "init", access: accessor(parents), instance: true, arguments: CodeTuple(elements: [(name: "_ arg", type: casetype, value: nil, anon: false)]), returns: CodeTuple(elements: []))
                let initbody = [ "self = .\(casename)(arg)" ]
                let initimp = CodeFunction.Implementation(declaration: initfun, body: initbody, comments: ["Initializes with the \(casename) case"])
                code.funcs.append(initimp)
            }

            breqbody.append("default: return false")

            bricbody.append("}")
            bracbody.append("])")
            breqbody.append("}")

            code.funcs.append(CodeFunction.Implementation(declaration: bricfun, body: bricbody, comments: []))

            if bracbody.isEmpty { bracbody.append("fatalError()") }
            code.funcs.append(CodeFunction.Implementation(declaration: bracfun(code), body: bracbody, comments: []))

            code.conforms.append(bricbrac)
            if generateEquals {
                code.funcs.append(CodeFunction.Implementation(declaration: breqfun(code), body: breqbody, comments: []))
            }

            // lastly, analyze the generated code; if it contains no nested type and none of the cases are Void or Array,
            // and we opt to enable useOneOfEnums, then just typealias it to a shared OneOf type
            if useOneOfEnums
                && code.nestedTypes.isEmpty
                && casetypes.count >= 2
                && casetypes.count <= 5
                && !casetypes.contains({ ($0 as? CodeExternalType)?.name == VoidType.name })
                && !casetypes.contains({ ($0 as? CodeExternalType)?.name == ArrayType.name }) {
                var alias = CodeTypeAlias(name: ename, type: oneOfType(casetypes), access: accessor(parents))
                alias.comments = comments
                return alias
            }

            return code
        }

        func createSimpleEnumeration(typename: CodeTypeName, name: String, types: [Schema.SimpleTypes]) -> CodeNamedType {
            var assoc = CodeEnum(name: typeName(parents, name), access: accessor(parents + [typeName(parents, name)]))

            var bricbody : [String] = []
            var bracbody : [String] = []
            var breqbody : [String] = []

            bricbody.append("switch self {")
            bracbody.append("return try bric.bracOne([")
            breqbody.append("switch (self, other) {")

            for (_, sub) in types.enumerate() {
                switch sub {
                case .String:
                    assoc.cases.append(CodeEnum.Case(name: "Text", type: StringType))
                    bricbody.append("case .Text(let x): return x.bric()")
                    bracbody.append("{ try .Text(String.brac(bric)) },")
                    breqbody.append("case let (.Text(lhs), .Text(rhs)): return lhs == rhs")
                case .Number:
                    assoc.cases.append(CodeEnum.Case(name: "Number", type: DoubleType))
                    bricbody.append("case .Number(let x): return x.bric()")
                    bracbody.append("{ try .Number(Double.brac(bric)) },")
                    breqbody.append("case let (.Number(lhs), .Number(rhs)): return lhs == rhs")
                case .Boolean:
                    assoc.cases.append(CodeEnum.Case(name: "Boolean", type: BoolType))
                    bricbody.append("case .Boolean(let x): return x.bric()")
                    bracbody.append("{ try .Boolean(Bool.brac(bric)) },")
                    breqbody.append("case let (.Boolean(lhs), .Boolean(rhs)): return lhs == rhs")
                case .Integer:
                    assoc.cases.append(CodeEnum.Case(name: "Integer", type: IntType))
                    bricbody.append("case .Integer(let x): return x.bric()")
                    bracbody.append("{ try .Integer(Int.brac(bric)) },")
                    breqbody.append("case let (.Integer(lhs), .Integer(rhs)): return lhs == rhs")
                case .Array:
                    assoc.cases.append(CodeEnum.Case(name: "List", type: ArrayType))
                    bricbody.append("case .List(let x): return x.bric()")
                    bracbody.append("{ try .List(Array<Bric>.brac(bric)) },")
                    breqbody.append("case let (.List(lhs), .List(rhs)): return lhs == rhs")
                case .Object:
                    //print("warning: making Bric for key: \(name)")
                    assoc.cases.append(CodeEnum.Case(name: "Object", type: BricType))
                    bricbody.append("case .Object(let x): return x.bric()")
                    bracbody.append("{ .Object(bric) },")
                    breqbody.append("case let (.Object(lhs), .Object(rhs)): return lhs == rhs")
                case .Null:
                    assoc.cases.append(CodeEnum.Case(name: "None", type: nil))
                    bricbody.append("case .None: return .Nul")
                    bracbody.append("{ .Nul },")
                    breqbody.append("case (.None, .None): return true")
                }
            }

            breqbody.append("default: return false")

            bricbody.append("}")
            bracbody.append("])")
            breqbody.append("}")

            assoc.conforms.append(bricable)
            assoc.funcs.append(CodeFunction.Implementation(declaration: bricfun, body: bricbody, comments: []))

            parents += [typename]
            if bracbody.isEmpty { bracbody.append("fatalError()") }
            assoc.conforms.append(bracable)
            assoc.funcs.append(CodeFunction.Implementation(declaration: bracfun(assoc), body: bracbody, comments: []))

            if generateEquals {
                assoc.funcs.append(CodeFunction.Implementation(declaration: breqfun(assoc), body: breqbody, comments: []))
            }

            parents = Array(parents.dropLast())
            return assoc
        }

        enum StateMode { case Standard, AllOf, AnyOf }

        /// Creates a schema instance for an "object" type with all the listed properties
        func createObject(typename: CodeTypeName, properties: [PropInfo], mode: StateMode) throws -> CodeStateType {

            let merge = mode == .AllOf || mode == .AnyOf

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
            var props = properties.map({ (name: $0.name ?? propName(parents, "p\(anonPropCount++)"), required: $0.required, prop: $0.schema, anon: $0.name == nil) })

            for (name, required, prop, anon) in props {
                var proptype: CodeType

                if let ref = prop.ref {
                    let tname = typeName(parents, ref)
                    proptype = CodeExternalType(tname, access: accessor(parents + [typename]))
                } else {
                    switch prop.type {
                    case .Some(.A(.String)) where prop._enum == nil: proptype = StringType
                    case .Some(.A(.Number)): proptype = DoubleType
                    case .Some(.A(.Boolean)): proptype = BoolType
                    case .Some(.A(.Integer)): proptype = IntType
                    case .Some(.A(.Null)): proptype = VoidType

                    case .Some(.B(let types)):
                        let assoc = createSimpleEnumeration(typename, name: name, types: types)
                        code.nestedTypes.append(assoc)
                        proptype = assoc

                    case .Some(.A(.Array)):
                        switch prop.items {
                        case .None:
                            proptype = arrayType(BricType)
                        case .Some(.B):
                            throw CodegenErrors.TypeArrayNotSupported
                        case .Some(.A(let itemz)):
                            if let item = itemz.value { // FIXME: indirect
                                if let ref = item.ref {
                                    proptype = arrayType(CodeExternalType(typeName(parents, ref), access: accessor(parents)))
                                } else {
                                    let type = try reify(item, id: name + "Item", parents: parents + [code.name])
                                    code.nestedTypes.append(type)
                                    proptype = arrayType(type)
                                }
                            } else {
                                throw CodegenErrors.Unsupported("Empty indirect")
                            }
                        }

                    default:
                        // generate the type for the object
                        let subtype = try reify(prop, id: prop.title ?? (capitalize(name) + typeSuffix), parents: parents + [code.name])
                        code.nestedTypes.append(subtype)
                        proptype = subtype
                    }
                }

                var indirect: CodeType?

                if !required {
                    let structProps = props.filter({ (name, required, prop, anon) in
                        switch prop.type?.types.first {
                        case .None: return true // unspecified object type: maybe a $ref
                        case .Some(.Object): return true // a custom object
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
                var propi = propd.implementation

                // indirect properties are stored privately as _prop vars with cover wrappers that convert them to optionals
                if let indirect = indirect {
                    let ipropn = propName(parents + [typename], indirectPrefix + name)
                    var ipropd = CodeProperty.Declaration(name: ipropn, type: indirect, access: .Private)
                    let ipropi = ipropd.implementation
                    code.props.append(ipropi)

                    propi.body = [
                        "get { return " + ipropn + ".value }",
                        "set { " + ipropn + " = Indirect(fromOptional: newValue) }",
                    ]
                }

                propd.comments = [prop.title, prop.description].filter({ $0 != nil }).map({ $0! })
                
                code.props.append(propi)
                let pt: PropNameType = (name: propn, type: proptype)
                proptypes.append(pt)
            }

            var addPropType: CodeType? = nil
            let hasAdditionalProps: Bool? // true=yes, false=no, nil=unspecified

            switch schema.additionalProperties {
            case .None:
                hasAdditionalProps = nil // TODO: make a global default for whether unspecified additionalProperties means yes or no
            case .Some(.A(false)):
                hasAdditionalProps = nil // FIXME: when this is false, allOf union types won't validate
            case .Some(.A(true)), .Some(.B): // TODO: generate object types for B
                hasAdditionalProps = true
                addPropType = ObjectType // additionalProperties default to [String:Bric]
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
            func makeKeys(keyName: String) {
                var cases: [CodeCaseSimple<String>] = []
                for (key, _, _, _) in props {
                    let pname = propName(parents + [typename], key)
                    cases.append(CodeCaseSimple(name: pname, value: key))
                }

                if let _ = addPropType {
                    cases.append(CodeCaseSimple(name: addPropName, value: ""))
                }

                if !cases.isEmpty {
                    code.nestedTypes.insert(CodeSimpleEnum(name: keyName, access: accessor(parents), cases: cases), atIndex: 0)
                }
            }

            /// Creates a memberwise initializer for the object type
            func makeInit(merged: Bool) {
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
                            let e = CodeTupleElement(name: d.name, type: d.type, value: d.type.defaultValue, anon: merge)
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

                let initargs = CodeTuple(elements: elements)

                let initfun = CodeFunction.Declaration(name: "init", access: accessor(parents), instance: true, arguments: initargs, returns: CodeTuple(elements: []))
                let initimp = CodeFunction.Implementation(declaration: initfun, body: initbody, comments: [])
                code.funcs.append(initimp)
            }

            let keysName = "Keys"
            if !merge {
                // create an enumeration of "Keys" for all the object's properties
                makeKeys(keysName)
            }

            makeInit(false)
//            if merge { makeInit(true) } // TODO: make convenience initializers for merged (i.e., allOf) nested properties

            var bricbody : [String] = []
            var bracbody : [String] = []
            var breqbody : [String] = []

            if mode == .AllOf || mode == .AnyOf {
                bricbody.append("return Bric(merge: [")
                for (i, pt) in props.enumerate() {
                    let pname = propName(parents + [typename], pt.name)

                    let sep = (i == props.count-1 ? "" : ",")
                    bricbody.append(pname + ".bric()" + sep)

                    let ret = (i == 0 ? "return " : "")
                    let and = (i == props.count-1 ? "" : " &&")
                    breqbody.append(ret + pname + ".breq(other." + pname + ")" + and)
                }
                bricbody.append("])")

                if mode == .AllOf {
                    bracbody.append("return try \(fullName(code))(")
                } else if mode == .AnyOf {
                    bracbody.append("return try \(fullName(code))(")
                }

                for (i, pt) in proptypes.enumerate() {
                    let sep = (i == props.count-1 ? "" : ",")
                    let ti: String = pt.type.identifier
                    bracbody.append("\(ti).brac(bric)" + sep)
                }
                bracbody.append(")")
            } else {
                bricbody.append("return Bric(obj: [")
                if hasAdditionalProps == true { // empty key for additional properties; first so addprop keys don't clobber state keys
                    bricbody.append("\(keysName).\(addPropName): \(addPropName).bric(),")
                }

                for (i, pt) in props.enumerate() {
                    let pname = propName(parents + [typename], pt.name)

                    bricbody.append("\(keysName).\(pname): \(pname).bric(),")

                    let ret = (i == 0 ? "return " : "    && ")
                    breqbody.append(ret + pname + ".breq(other." + pname + ")")
                }

                if hasAdditionalProps == true {
                    breqbody.append((props.isEmpty ? "return " : "    && ") + addPropName + ".breq(other." + addPropName + ")")
                }

                bricbody.append("])")

                if hasAdditionalProps == false {
                    bracbody.append("try bric.prohibitExtraKeys(\(keysName))")
                }

                bracbody.append("return try \(fullName(code))(")
                for (i, t) in props.enumerate() {
                    let sep = (i == props.count - (addPropType == nil ? 1 : 0) ? "" : ",")
                    let pname = propName(parents + [typename], t.name)
                    bracbody.append("\(pname): bric.bracKey(\(keysName).\(pname))" + sep)
                }
                if hasAdditionalProps == true { // empty key for additional properties; first so addprop keys don't clobber state keys
                    bracbody.append("\(addPropName): bric.bracDisjoint(\(keysName).self)")
                }
                bracbody.append(")")
            }

            if bricbody.isEmpty { bricbody.append("fatalError()") }
            code.funcs.append(CodeFunction.Implementation(declaration: bricfun, body: bricbody, comments: []))
            if bracbody.isEmpty { bracbody.append("fatalError()") }
            code.funcs.append(CodeFunction.Implementation(declaration: bracfun(code), body: bracbody, comments: []))

            code.conforms.append(bricbrac)
            if generateEquals {
                code.funcs.append(CodeFunction.Implementation(declaration: breqfun(code), body: breqbody, comments: []))
            }

            return code
        }

        func createArray(typename: CodeTypeName) throws -> CodeNamedType {
            // when a top-level type is an array, we make it a typealias with a type for the individual elements
            switch schema.items {
            case .None:
                return CodeTypeAlias(name: typeName(parents, id), type: arrayType(BricType), access: accessor(parents))
            case .Some(.B):
                throw CodegenErrors.TypeArrayNotSupported
            case .Some(.A(let itemz)):
                if let item = itemz.value { // FIXME: make indirect to avoid circular references
                    if let ref = item.ref {
                        return CodeTypeAlias(name: typeName(parents, id), type: arrayType(CodeExternalType(typeName(parents, ref), access: accessor(parents))), access: accessor(parents))
                    } else {
                        // note that we do not tack on the alias' name, because it will not be used as the external name of the type
                        let type = try reify(item, id: typename + "Item", parents: parents)

                        // rather than creating two aliases when something is an array of an alias, merge them as a single unit
                        if let sub = aliasType(type) {
                            return CodeTypeAlias(name: typeName(parents, id), type: arrayType(sub), access: accessor(parents))
                        } else {
                            let alias = CodeTypeAlias(name: typeName(parents, id), type: arrayType(type), access: accessor(parents), peers: [type])
                            return alias
                        }
                    }
                } else {
                    throw CodegenErrors.Unsupported("Empty indirect")
                }
            }
        }

        func createStringEnum(typename: CodeTypeName, values: [Bric]) throws -> CodeSimpleEnum<String> {
            var code = CodeSimpleEnum<String>(name: typeName(parents, id), access: accessor(parents))
            code.comments = comments
            for e in values {
                if case .Str(let evalue) = e {
                    code.cases.append(CodeCaseSimple<String>(name: typeName(parents, evalue), value: evalue))
                } else {
                    throw CodegenErrors.NonStringEnumsNotSupported
                }
            }
            var bricbody : [String] = []
            var bracbody : [String] = []
            let breqbody : [String] = []

            // when there is only a single possible value, make it the default
            if let firstCase = code.cases.first where code.cases.count == 1 {
                code.defaultValue = "." + firstCase.name
            }

            bricbody.append("return .Nul")
//            bricbody.append("return Bric(object: [")
//            for (name, _, _) in props {
//                bricbody.append("\"\(name)\" : \(propName(parents, name)).bric(),")
//            }
//            bricbody.append("])")

            code.conforms.append(bricbrac)

            code.funcs.append(CodeFunction.Implementation(declaration: bricfun, body: bricbody, comments: []))

            if bracbody.isEmpty { bracbody.append("fatalError()") }
            code.funcs.append(CodeFunction.Implementation(declaration: bracfun(code), body: bracbody, comments: []))

            if generateEquals {
                code.funcs.append(CodeFunction.Implementation(declaration: breqfun(code), body: breqbody, comments: []))
            }

            return code
        }

        let type = schema.type
        let typename = typeName(parents, id)

        if let values = schema._enum {
            return try createStringEnum(typename, values: values)
        } else if case .Some(.A(.String)) = type {
            return CodeTypeAlias(name: typename, type: StringType, access: accessor(parents))
        } else if case .Some(.A(.Integer)) = type {
            return CodeTypeAlias(name: typename, type: IntType, access: accessor(parents))
        } else if case .Some(.A(.Number)) = type {
            return CodeTypeAlias(name: typename, type: DoubleType, access: accessor(parents))
        } else if case .Some(.A(.Boolean)) = type {
            return CodeTypeAlias(name: typename, type: BoolType, access: accessor(parents))
        } else if case .Some(.A(.Null)) = type {
            return CodeTypeAlias(name: typename, type: VoidType, access: accessor(parents))
        } else if case .Some(.A(.Array)) = type {
            return try createArray(typename)
        } else if let properties = schema.properties where !properties.isEmpty {
            return try createObject(typename, properties: getPropInfo(schema, id: id, parents: parents), mode: .Standard)
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
            return try createObject(typename, properties: props, mode: .AllOf)
        } else if let anyOf = schema.anyOf {
            // anyOf is one or more Xs, so make it a tuple of (CollectionOfOne<X>, Array<X>)
            // FIXME: compiler hang, maybe because the tuple can't be de-brac'd
//            let oneOf = try createOneOf(anyOf)
////            let tuple = CodeTuple(elements: [(name: nil, type: collectionOfOneType(oneOf), value: nil, anon: false), (name: nil, type: arrayType(oneOf), value: nil, anon: false)])
//            let anyOfId = typename + "Array"
//            let anyOfType = nonEmptyType(oneOf)
//            return CodeTypeAlias(name: anyOfId, type: anyOfType, access: accessor(parents), peers: [oneOf])

            // represent anyOf as a struct with optional properties
//            let props: [PropInfo] = anyOf.map({ (name: nil, required: false, schema: $0 ) })
//            return try createObject(typename, properties: props, mode: .AnyOf)

            // FIXME anyOf requires that at least one element be valid; there are a few ways to
            // represent this:
            // 1. as a oneOf (which is what we do here), and just ignore further successful validations
            // 2. as a tuple of optionals, but then the runtime model can be invalid (since you could set all the optionals to nil)
            // 3. as a collection of oneOf cases, but that has the same drawback as #2
            return try createOneOf(anyOf)

        } else if let oneOf = schema.oneOf { // TODO: allows properties in addition to oneOf
            return try createOneOf(oneOf)
        } else if let ref = schema.ref { // create a typealias to the reference
            return CodeTypeAlias(name: typename, type: CodeExternalType(typeName(parents, ref), access: accessor(parents)), access: accessor(parents))
        } else if let not = schema.not.value { // a "not" generates a validator against an inverse schema
            let inverseId = "Not" + typename
            let inverseSchema = try reify(not, id: inverseId, parents: parents)
            return CodeTypeAlias(name: typename, type: notBracType(inverseSchema), access: accessor(parents), peers: [inverseSchema])
        } else if schema.bric() == [:] { // an empty schema just generates pure Bric
            return CodeTypeAlias(name: typename, type: BricType, access: accessor(parents))
        } else if case .Some(.A(.Object)) = type, .Some(.B(.Some(let adp))) = schema.additionalProperties {
            // an empty schema with additionalProperties makes it a [String:Type]
            let adpType = try reify(adp, id: typename + "Value", parents: parents)
            return CodeTypeAlias(name: typename, type: dictionaryType(StringType, adpType), access: accessor(parents), peers: [adpType])
        } else if case .Some(.A(.Object)) = type, .Some(.A(let adp)) = schema.additionalProperties where adp == true {
            // an empty schema with additionalProperties makes it a [String:Bric]
            //print("warning: making Brictionary for code: \(schema.bric().stringify())")
            return CodeTypeAlias(name: typename, type: ObjectType, access: accessor(parents))
        } else {
            // throw CodegenErrors.IllegalState("No code to generate for: \(schema.bric().stringify())")
            //print("warning: making Bric for code: \(schema.bric().stringify())")
            return CodeTypeAlias(name: typename, type: BricType, access: accessor(parents))
        }
    }

    /// Parses the given schema source into a module; if the rootSchema is non-nil, then all the schemas
    /// will be generated beneath the given root
    public func assemble(schemas: [(String, Schema)], rootName: String? = nil) throws -> CodeModule {

        var types: [CodeNamedType] = []
        for (key, schema) in schemas {
            if key == rootName { continue }
            types.append(try reify(schema, id: key, parents: []))
        }

        let rootSchema = schemas.filter({ $0.0 == rootName }).first?.1
        let module = CodeModule()

        if let rootSchema = rootSchema {
            let code = try reify(rootSchema, id: rootName ?? "Schema", parents: [])
            if var root = code as? CodeStateType {
                root.nestedTypes.appendContentsOf(types)
                module.types = [root]
            } else {
                module.types = [code]
                module.types.appendContentsOf(types)
            }
        } else {
            module.types = types
        }

        return module
    }

}

public extension Schema {

    enum BracReferenceError : ErrorType, CustomDebugStringConvertible {
        case ReferenceRequiredRoot(String)
        case ReferenceMustBeRelativeToCurrentDocument(String)
        case ReferenceMustBeRelativeToDocumentRoot(String)
        case RefWithoutAdditionalProperties(String)
        case ReferenceNotFound(String)

        public var debugDescription : String {
            switch self {
            case ReferenceRequiredRoot(let str): return "ReferenceRequiredRoot: \(str)"
            case ReferenceMustBeRelativeToCurrentDocument(let str): return "ReferenceMustBeRelativeToCurrentDocument: \(str)"
            case ReferenceMustBeRelativeToDocumentRoot(let str): return "ReferenceMustBeRelativeToDocumentRoot: \(str)"
            case RefWithoutAdditionalProperties(let str): return "RefWithoutAdditionalProperties: \(str)"
            case ReferenceNotFound(let str): return "ReferenceNotFound: \(str)"
            }
        }
    }

    /// Support for JSON $ref <http://tools.ietf.org/html/draft-pbryan-zyp-json-ref-03>
    func resolve(path: String) throws -> Schema {
        var parts = path.characters.split(isSeparator: { $0 == "/" }).map { String($0) }
//        print("parts: \(parts)")
        if parts.isEmpty { throw BracReferenceError.ReferenceRequiredRoot(path) }
        let first = parts.removeAtIndex(0)
        if first != "#" {  throw BracReferenceError.ReferenceMustBeRelativeToCurrentDocument(path) }
        if parts.isEmpty { throw BracReferenceError.ReferenceRequiredRoot(path) }
        let root = parts.removeAtIndex(0)
        if _additionalProperties.isEmpty { throw BracReferenceError.RefWithoutAdditionalProperties(path) }
        guard var json = _additionalProperties[root] else { throw BracReferenceError.ReferenceNotFound(path) }
        for part in parts {
            guard let next: Bric = json[part] else { throw BracReferenceError.ReferenceNotFound(path) }
            json = next
        }

        return try Schema.brac(json)
    }

    /// Parse the given JSON info an array of resolved schema references, maintaining property order from the source JSON
    public static func parse(source: String, rootName: String) throws -> [(String, Schema)] {
        return try generate(impute(source), rootName: rootName)
    }

    public static func generate(json: Bric, rootName: String) throws -> [(String, Schema)] {
        let refmap = try json.resolve()

        var refschema : [String : Schema] = [:]

        var schemas: [(String, Schema)] = []
        for (key, value) in refmap {
            let subschema = try Schema.brac(value)
            refschema[key] = subschema
            schemas.append(key, subschema)
        }

        let schema = try Schema.brac(json)
        schemas.append(rootName, schema)
        return schemas
    }

    /// Parses the given JSON and injects the property ordering attribute based on the underlying source
    public static func impute(source: String) throws -> Bric {
        var fidelity = try FidelityBricolage.parse(source)
        fidelity = imputePropertyOrdering(fidelity)
        return fidelity.bric()
    }


    /// Walk through the raw bricolage and add in the "propertyOrder" prop so that the schema generator
    /// can use the same ordering that appears in the raw JSON schema
    private static func imputePropertyOrdering(bc: FidelityBricolage) -> FidelityBricolage {
        switch bc {
        case .Arr(let arr):
            return .Arr(arr.map(imputePropertyOrdering))
        case .Obj(let obj):
            var sub = FidelityBricolage.createObject()

            for (key, value) in obj {
                sub.append(key, imputePropertyOrdering(value))
                // if the key is "properties" then also add a "propertyOrder" property with the order that the props appear in the raw JSON
                if case .Obj(let dict) = value where !dict.isEmpty && String(String.UnicodeScalarView() + key) == "properties" {
                    // ### FIXME: we hack in a check for "type" to determine if we are in a schema element and not,
                    //  e.g., another properties list, but this will fail if there is an actual property named "type"
                    if bc.bric()["type"] == "object" {
                        let ordering = dict.map({ $0.0 })
                        sub.append((FidelityBricolage.StrType("propertyOrder".unicodeScalars), FidelityBricolage.Arr(ordering.map(FidelityBricolage.Str))))
                    }
                }
            }
            return .Obj(sub)
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
    "  -useOneOfEnums: Whether to collapse simple enums into OneOf enum types",
    "  -rename: A renaming mapping",
    "  -import: Additional imports at the top of the generated source",
    "  -access: Default access (public, private, internal, or default)",
    "  -typetype: Generated type (struct or class)"
    ].joinWithSeparator("\n")

extension Curio {
    public static func runWithArguments(arguments: [String]) throws {
        var args = arguments.generate()
        let _ = args.next() ?? "curio" // cmdname


        struct UsageError : ErrorType {
            let msg: String

            init(_ msg: String) {
                self.msg = msg + "\n" + CurioUsage
            }
        }

        var modelName: String? = nil
        var defsPath: String? = "#/definitions/"
        var accessType: String? = "public"
        var renames: [String : String] = [:]
        var imports: [String] = ["BricBrac"]
        var maxdirect: Int?
        var typeType: String?
        var useOneOfEnums: Bool?
        var generateEquals: Bool?

        while let arg = args.next() {
            switch arg {
            case "-help":
                print(CurioUsage)
                return
            case "-name":
                modelName = args.next()
            case "-defs":
                defsPath = args.next()
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
            case "-generateEquals":
                generateEquals = (args.next() ?? "true").hasPrefix("t") == true ? true : false
            default:
                throw UsageError("Unrecognized argument: \(arg)")
            }
        }

        do {
            guard let modelName = modelName else {
                throw UsageError("Missing model name")
            }

            guard let _ = defsPath else {
                throw UsageError("Missing definitions path")
            }

            guard let accessType = accessType else {
                throw UsageError("Missing access type")
            }

            var access: CodeAccess
            switch accessType {
            case "public": access = .Public
            case "private": access = .Private
            case "internal": access = .Internal
            case "default": access = .Default
            default: throw UsageError("Unknown access type: \(accessType) (must be 'public', 'private', 'internal', or 'default')")
            }

            var curio = Curio()
            if let maxdirect = maxdirect { curio.indirectCountThreshold = maxdirect }
            if let useOneOfEnums = useOneOfEnums  { curio.useOneOfEnums = useOneOfEnums }
            if let generateEquals = generateEquals { curio.generateEquals = generateEquals }

            if let typeType = typeType {
                switch typeType {
                case "struct": curio.generateValueTypes = true
                case "class": curio.generateValueTypes = false
                default: throw UsageError("Unknown type type: \(typeType) (must be 'struct' or 'class')")
                }
            }
            
            curio.accessor = { _ in access }
            curio.renamer = { (parents, id) in
                let key = (parents + [id]).joinWithSeparator(".")
                return renames[id] ?? renames[key]
            }
            
            
            //debugPrint("Reading schema file from standard input")
            var src: String = ""
            while let line = readLine(stripNewline: false) {
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
