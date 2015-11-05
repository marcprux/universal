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

    /// the number of properties beyond which Optional types should instead be Indirect; this is needed beause
    /// a struct that contains many other stucts can make very large compilation units and take a very long
    /// time to compile
    public var indirectCountThreshold = 20

    /// The prefix for private internal indirect implementations
    public var indirectPrefix = "_"

    public var accessor: ([CodeTypeName])->(CodeAccess) = { _ in .Default }
    public var renamer: ([CodeTypeName], String)->(CodeTypeName?) = { (parents, id) in nil }

    /// special prefixes to trim (adheres to the convention that top-level types go in the "defintions" level)
    public var trimPrefixes = ["#/definitions/"]

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


        if self.dynamicType.reservedWords.contains(id) {
            id = "`" + id + "`"
        }
        return id
    }

    func typeName(parents: [CodeTypeName], _ id: String) -> CodeTypeName {
        if let tname = renamer(parents, id) {
            return tname
        }
        var name = ""
        var capnext = true

        var nm = id
        for pre in trimPrefixes {
            if nm.hasPrefix(pre) {
                nm = nm[pre.endIndex..<nm.endIndex]
            }
        }

        for c in nm.characters {
            let validCharacters = name.isEmpty ? self.dynamicType.nameStart : self.dynamicType.nameBody
            if !validCharacters.contains(c) {
                capnext = true
            } else if capnext {
                name.appendContentsOf(String(c).uppercaseString)
                capnext = false
            } else {
                name.append(c)
            }
        }

        if self.dynamicType.reservedWords.contains(name) {
            name = "`" + name + "`"
        }

        if name.isEmpty { // e.g., ">=" -> "U62U61"
            for c in id.unicodeScalars {
                name += "U\(c.value)"
            }
        }
        return CodeTypeName(name)
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


        let BricType = CodeExternalType("Bric", access: accessor(parents))
        let StringType = CodeExternalType("String", access: accessor(parents))
        let IntType = CodeExternalType("Int", access: accessor(parents))
        let DoubleType = CodeExternalType("Double", access: accessor(parents))
        let BoolType = CodeExternalType("Bool", access: accessor(parents))
        let VoidType = CodeExternalType("Void", access: accessor(parents))
        let ObjectType = dictionaryType(StringType, BricType)

        /// Calculate the fully-qualified name of the given type
        func fullName(type: CodeType) -> String {
            return (parents + [type.identifier]).joinWithSeparator(".")
        }

        let bricable = CodeProtocol(name: "Bricable", access: accessor(parents))
        let bricfun = CodeFunction.Declaration(name: "bric", access: accessor(parents), instance: true, returns: CodeTuple(elements: [(name: nil, type: BricType, value: nil, anon: false)]))

        let bracable = CodeProtocol(name: "Bracable", access: accessor(parents))
        let bracfun: (CodeType)->(CodeFunction.Declaration) = { CodeFunction.Declaration(name: "brac", access: self.accessor(parents), instance: false, exception: true, arguments: CodeTuple(elements: [(name: "bric", type: BricType, value: nil, anon: false)]), returns: CodeTuple(elements: [(name: nil, type: CodeExternalType(fullName($0), access: self.accessor(parents)), value: nil, anon: false)])) }

        let bricbrac = CodeProtocol(name: "BricBrac", access: accessor(parents))

        let comments = [schema.title, schema.description].filter({ $0 != nil }).map({ $0! })

        func createComplexEnumeration(multi: [Schema]) throws -> CodeEnum {
            let ename = typeName(parents, id)
            var code = CodeEnum(name: ename, access: accessor(parents))
            code.comments = comments

            var bricbody : [String] = []
            var bracbody : [String] = []

            bricbody.append("switch self {")
            bracbody.append("return try bric.bracOne([")

            var casenames = Set<String>()
            for sub in multi {
                let subname = sub.title.flatMap({ typeName(parents, $0) }) ?? "Type\(casenames.count+1)"

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
                    let subtype = try reify(sub, id: subname, parents: parents + [code.name])
                    // when the generated code is merely a typealias, just inline it in the enum case
                    if let alias = subtype as? CodeTypeAlias where alias.peers.isEmpty {
                        casetype = alias.type
                    } else {
                        code.nestedTypes.append(subtype)

                        if generateValueTypes && subtype.directReferences.map({ $0.name }).contains(ename) {
                            casetype = indirectType(subtype)
                        } else {
                            casetype = subtype
                        }
                    }
                }

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
                } else {
                    bricbody.append("case .\(casename)(let x): return x.bric()")
                    bracbody.append("{ try .\(casename)(\(casetype.identifier).brac(bric)) },")
                }
            }

            bricbody.append("}")
            bracbody.append("])")

            code.conforms.append(bricbrac)

            code.funcs.append(CodeFunction.Implementation(declaration: bricfun, body: bricbody, comments: []))

            if bracbody.isEmpty { bracbody.append("fatalError()") }
            code.funcs.append(CodeFunction.Implementation(declaration: bracfun(code), body: bracbody, comments: []))

            return code
        }

        func createSimpleEnumeration(typename: CodeTypeName, name: String, types: [Schema.SimpleTypes]) -> CodeNamedType {
            var assoc = CodeEnum(name: typeName(parents, name), access: accessor(parents + [typeName(parents, name)]))

            var bricbody : [String] = []
            var bracbody : [String] = []

            bricbody.append("switch self {")
            bracbody.append("return try bric.bracOne([")

            for (_, sub) in types.enumerate() {
                switch sub {
                case .String:
                    assoc.cases.append(CodeEnum.Case(name: "Text", type: StringType))
                    bricbody.append("case .Text(let x): return x.bric()")
                    bracbody.append("{ try .Text(String.brac(bric)) },")
                case .Number:
                    assoc.cases.append(CodeEnum.Case(name: "Number", type: DoubleType))
                    bricbody.append("case .Number(let x): return x.bric()")
                    bracbody.append("{ try .Number(Double.brac(bric)) },")
                case .Boolean:
                    assoc.cases.append(CodeEnum.Case(name: "Boolean", type: BoolType))
                    bricbody.append("case .Boolean(let x): return x.bric()")
                    bracbody.append("{ try .Boolean(Bool.brac(bric)) },")
                case .Integer:
                    assoc.cases.append(CodeEnum.Case(name: "Integer", type: IntType))
                    bricbody.append("case .Integer(let x): return x.bric()")
                    bracbody.append("{ try .Integer(Int.brac(bric)) },")
                case .Null:
                    assoc.cases.append(CodeEnum.Case(name: "None", type: nil))
                    bricbody.append("case .None: return .Nul")
                    bracbody.append("{ .Nul },")
                default:
                    //print("warning: making Bric for key: \(name)")
                    assoc.cases.append(CodeEnum.Case(name: "Object", type: BricType))
                    bricbody.append("case .Object(let x): return x.bric()")
                    bracbody.append("{ .Object(bric) },")
                }
            }

            bricbody.append("}")
            bracbody.append("])")

            assoc.conforms.append(bricable)
            assoc.funcs.append(CodeFunction.Implementation(declaration: bricfun, body: bricbody, comments: []))

            parents += [typename]
            if bracbody.isEmpty { bracbody.append("fatalError()") }
            assoc.conforms.append(bracable)
            assoc.funcs.append(CodeFunction.Implementation(declaration: bracfun(assoc), body: bracbody, comments: []))
            parents = Array(parents.dropLast())

            return assoc
        }

        enum StateMode { case Standard, AllOf, AnyOf }
        typealias PropInfo = (name: String?, required: Bool, schema: Schema)

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
            var props = properties.map({ (name: $0.name ?? "p\(anonPropCount++)", required: $0.required, prop: $0.schema, anon: $0.name == nil) })

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
                        let subtype = try reify(prop, id: prop.title ?? (name + "Type"), parents: parents + [code.name])
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
                                initbody.append("self.\(indirectPrefix)\(d.name) = Indirect(fromOptional: \(d.name))")
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

            if mode == .AllOf || mode == .AnyOf {
                bricbody.append("return Bric(merge: [")
                for (name, _, _, _) in props {
                    bricbody.append("\(propName(parents + [typename], name)).bric(),")
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
                bricbody.append("return Bric(object: [")
                if hasAdditionalProps == true { // empty key for additional properties; first so addprop keys don't clobber state keys
                    bricbody.append("(\(keysName).\(addPropName), \(addPropName).bric()),")
                }
                for (key, _, _, _) in props {
                    let pname = propName(parents + [typename], key)
                    bricbody.append("(\(keysName).\(pname), \(pname).bric()),")
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
                        let alias = CodeTypeAlias(name: typeName(parents, id), type: arrayType(type), access: accessor(parents), peers: [type])
                        return alias
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

            return code
        }

        func getPropInfo(properties: [String: Schema]) -> [PropInfo] {
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
            return try createObject(typename, properties: getPropInfo(properties), mode: .Standard)
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
//            let oneOf = try createComplexEnumeration(anyOf)
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
            return try createComplexEnumeration(anyOf)

        } else if let oneOf = schema.oneOf { // TODO: allows properties in addition to oneOf
            return try createComplexEnumeration(oneOf)
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
}

