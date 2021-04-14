//
//  SwiftCode.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 7/6/15.
//  Copyright © 2010-2021 io.glimpse. All rights reserved.
//

/// NOTE: do not import any BricBrac framework headers; curiotool needs to be compiled as one big lump of source with no external frameworks

/// SwiftCode elements for code emission

public protocol CodeEmitterType {
    func emit(_ tokens: String?...)
}

public extension CodeEmitterType {
    func emitComments(_ comments: [String]) {
        let comms = comments.flatMap({ $0.split { $0 == "\n" || $0 == "\r" } })

        for comment in comms {
            emit("///", String(comment))
        }
    }
}

/// The default ordering of types: protocols, typealiases, enums, then by name
func typeOrdering(t1: CodeNamedType, t2: CodeNamedType) -> Bool {
    let (t1proto, t2proto) = ((t1 is CodeProtocol), (t2 is CodeProtocol))
    let (t1alias, t2alias) = ((t1 is CodeTypeAlias), (t2 is CodeTypeAlias))
    let (t1enum, t2enum) = ((t1 is CodeEnumType), (t2 is CodeEnumType))

    if t1proto && !t2proto { return true }
    if !t1proto && t2proto { return false }
    if t1alias && !t2alias { return true }
    if !t1alias && t2alias { return false }
    if t1enum && !t2enum { return true }
    if !t1enum && t2enum { return false }
    return t1.name < t2.name
}

open class CodeEmitter<T: TextOutputStream> : CodeEmitterType {
    open var stream: T
    open var level: UInt = 0

    public init(stream: T) {
        self.stream = stream
    }

    open func emit(_ tokens: String?...) {
        if tokens.count == 1 && tokens.last ?? "" == "}" && (tokens.first ?? "")?.hasPrefix("//") != true {
            level -= 1
        }

        // only output non-blank, non-nil tokens
        let toks = tokens.filter({ $0 != nil && $0 != "" })

        if !toks.isEmpty {
            for _ in 0..<level { // indentation
                stream.write("    ")
            }
        }

        for (i, token) in toks.enumerated() {
            if let token = token {
                if i > 0 { stream.write(" ") }
                stream.write(token)
            }
        }

        // increase/decrease indentation based on trailing code blocks
        if tokens.last ?? "" == "{" && (tokens.first ?? "")?.hasPrefix("//") != true {
            level += 1
        }

        stream.write("\n")
    }
}

private class KeyCodeEmitter : CodeEmitterType {
    fileprivate var string = ""

    fileprivate func emit(_ tokens: String?...) {
        for token in tokens {
            if let token = token {
                string.append(token)
                string.append(" ")
            }
        }
        string.append("\n")
    }
}

public protocol CodeEmittable {
    var comments: [String] { get set }
    func emit(_ emitter: CodeEmitterType)
}

extension CodeEmittable {
    /// Returns the code value for this emittable
    public var codeValue: String {
        let emitter = KeyCodeEmitter()
        self.emit(emitter)
        return emitter.string
    }

    /// Generic equatability for an emittable is implemented by emitting the code and comparing both sides
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.codeValue == rhs.codeValue
    }

    /// Generic hashability for an emittable is implemented by emitting the code and returning the hash
    public func hash(into hasher: inout Hasher) {
        self.codeValue.hashValue.hash(into: &hasher)
    }

}

open class CodeModule : CodeImplementationType {
    open var types: [CodeNamedType] {
        get { return nestedTypes }
        set { nestedTypes = newValue }
    }

    open var nestedTypes: [CodeNamedType] = []
    open var comments: [String] = []
    open var imports: [String] = []
    /// Global functions in this module
    open var funcs: [CodeFunction.Implementation] = []
    /// No-op at the module level (needed for CodeImplementationType : CodeConformantType)
    open var conforms: [CodeProtocol] = []

    public init() {
    }

    open func emit(_ emitter: CodeEmitterType) {
        for i in Set(imports + ["BricBrac"]).sorted() {
            emitter.emit("@_exported import", i)
        }

        if !imports.isEmpty {
            emitter.emit()
        }

        for f in funcs {
            emitter.emit("")
            f.emit(emitter)
        }

        for inner in nestedTypes.sorted(by: typeOrdering) {
            emitter.emit("")
            inner.emit(emitter)
        }
    }
}


/// A CodeUnit is any code container, be it a type or property
public protocol CodeUnit {
}

public typealias CodeTypeName = String
public typealias CodePropName = String

//public struct CodeTypeName : RawRepresentable, Hashable, ExpressibleByStringLiteral {
//    public let rawValue: String
//    public init(rawValue: String) { self.rawValue = rawValue }
//    public init(stringLiteral: String) { self.rawValue = stringLiteral }
//}
//
//public struct CodePropName : RawRepresentable, Hashable, ExpressibleByStringLiteral {
//    public let rawValue: String
//    public init(rawValue: String) { self.rawValue = rawValue }
//    public init(stringLiteral: String) { self.rawValue = stringLiteral }
//}

public protocol CodeType : CodeUnit {
    /// Returns a reference identifier for this code unit
    var identifier : String { get }

    /// Returna a default value initializer for instances of this type
    var defaultValue : String? { get }

    var directReferences : [CodeNamedType] { get }

}

public extension CodeType {
    /// By default, types have no default value
    var defaultValue : String? {
        return nil
    }
}

/// A type reference refers to another type that may not be defined here (e.g., "String" or "Array<Int>")
public struct CodeExternalType : CodeType {
    public var name : CodeTypeName
    public var generics : [CodeType]
    public var stitchType: String? = nil
    public var access: CodeAccess
    public var comments: [String] = []
    public var defaultValue: String? = nil
    public var shorthand: (prefix: String?, suffix: String?)?

    public init(_ name: CodeTypeName, generics: [CodeType] = [], stitchType: String? = nil, access: CodeAccess = CodeAccess.public, defaultValue: String? = nil, shorthand: (prefix: String?, suffix: String?)? = nil) {
        self.name = name
        self.generics = generics
        self.stitchType = stitchType
        self.access = access
        self.defaultValue = defaultValue
        self.shorthand = shorthand
    }

    public var identifier : String {
        if generics.isEmpty {
            return name
        } else if let shorthand = shorthand {
            var str = (shorthand.prefix ?? "")
            str += (generics.map(\.identifier)).joined(separator: ", ")
            str += (shorthand.suffix ?? "")
            return str
        } else {
            let sep = stitchType.flatMap({ ">." + $0 + "<" }) ?? ", "
            return name + "<" + (generics.map(\.identifier)).joined(separator: sep) + ">"
        }
    }

//    public var defaultValue : String? {
//        if name == "Array" { return "[]" }
//        if name == "Dictionary" { return "[:]" }
//        if name == "Optional" { return "nil" }
//        if name == "Indirect" { return "nil" }
//        if name == "NotBrac" { return "nil" }
//        if name == "Bric" { return "nil" }
//
//        return nil
//    }

    public var directReferences : [CodeNamedType] {
        return [CodeTypeAlias(name: name, type: self, access: access)]
    }
}

/// A compound type is an anonymous type that it not shareable or referencable
public protocol CodeCompoundType : CodeType {
}

public enum CodeAccess : String, Hashable, CaseIterable {
    case `public` = "public", `private` = "private", `internal` = "internal", `default` = ""
}

public protocol CodeImplementation : CodeEmittable {
    var body: [String] { get set }
}

public struct CodeProperty {
    public struct Declaration: CodeUnit {
        public var name: CodePropName
        /// The type of the property, which can be nil if we want it to be inferred
        public var type: CodeType?
        public var instance: Bool
        public var access: CodeAccess
        public var mutable: Bool = true
        public var comments: [String] = []

        public var isDictionary: Bool {
            return type?.identifier.hasPrefix("Dictionary") ?? false
        }

        public var isArray: Bool {
            return type?.identifier.hasPrefix("Array") ?? false
        }

        public init(name: CodePropName, type: CodeType?, access: CodeAccess, instance: Bool = true, mutable: Bool = true) {
            self.name = name
            self.type = type
            self.access = access
            self.instance = instance
            self.mutable = mutable
        }

        public func emit(_ emitter: CodeEmitterType) {
            emitter.emitComments(comments)
            emitter.emit(instance ? "" : "static", "var", name + (type == nil ? "" : ":"), type?.identifier, "{", "get", mutable ? "set" : "", "}")
        }

        public var implementation: Implementation {
            return Implementation(declaration: self, value: nil, body: [], comments: comments)
        }
    }

    
    public struct Implementation : CodeImplementation {
        public let declaration: Declaration
        public var value: String?
        public var body: [String] = []
        public var comments: [String] = []

        public func emit(_ emitter: CodeEmitterType) {
            emitter.emitComments(declaration.comments)
            // TODO: allow declaration bodies (e.g., dynamic get/set, willSet/didSet)
            emitter.emit(declaration.access.rawValue, declaration.instance ? "" : "static", declaration.mutable || !body.isEmpty ? "var" : "let", declaration.name + (declaration.type == nil ? "" : ":"), declaration.type?.identifier, value == nil ? "" : "=", value, body.isEmpty ? "" : "{")

            if !body.isEmpty {
                for b in body {
                    emitter.emit(b) // TODO: trailing { should indent
                }
                emitter.emit("}")
            }
        }
    }
}

public typealias CodeTupleElement = (name: CodePropName?, type: CodeType?, value: String?, anon: Bool)

public struct CodeTuple : CodeCompoundType {
    public var elements: [CodeTupleElement]
    public var arity: Int { return elements.count }
    public var comments: [String] = []

    public init(elements: [CodeTupleElement] = []) {
        self.elements = elements
    }

    public var identifier : String {
        // (foo: Bar, baz: String) or (Bar, String) or (foo: Bar? = nil, baz: String = "Foo") depending on whether they have names
        func ename(_ element: CodeTupleElement) -> String {
            // slow compile!
            // return (element.name.flatMap({ $0 + ": " }) ?? "") + element.type.identifier + (element.value.flatMap({ " = " + $0 }) ?? "")
            let anondec = element.anon ? "_ " : ""
            let namedec = element.name.flatMap({ $0 + (element.type == nil ? " " : ": ") }) ?? ""
            let typedec = element.type?.identifier ?? ""
            let valuedec = element.value.flatMap({ " = " + $0 }) ?? ""
            return anondec + namedec + typedec + valuedec
        }
        let parts = elements.map(ename)
        // un-named single-element tuples do not need to be named
        let paren = arity != 1 || elements.first?.name != nil
        return (paren ? "(" : "") + parts.joined(separator: ", ") + (paren ? ")" : "")
    }

    public var directReferences : [CodeNamedType] {
        return elements.compactMap({ $0.type?.directReferences }).flatMap({ $0 })
    }

    /// Create a type alias for this tuple type, removing the name for single-tuple elements (since they are illegal)
    public func makeTypeAlias(_ name: CodeTypeName, access: CodeAccess) -> CodeTypeAlias {
        var t = self
        // single-element tuples are not allowed to have a name
        if t.elements.count == 1 {
            t.elements[0].name = nil
        }
        for i in 0..<t.elements.count {
            t.elements[i].anon = false
            t.elements[i].value = nil
        }
        return CodeTypeAlias(name: name, type: t, access: access)

    }
}

public protocol CodeAccessible : CodeType {
    var access: CodeAccess { get set }

    func emit(_ emitter: CodeEmitterType)
}

public struct CodeFunction {
    public struct Declaration: CodeCompoundType {
        public var name: CodePropName
        public var instance: Bool
        public var exception: Bool
        public var access: CodeAccess
        public var arguments: CodeTuple
        public var returns: CodeTuple
        public var comments: [String] = []

        public init(name: CodePropName, access: CodeAccess, instance: Bool = true, exception: Bool = false, arguments: CodeTuple = CodeTuple(), returns: CodeTuple = CodeTuple()) {
            self.access = access
            self.instance = instance
            self.exception = exception
            self.name = name
            self.arguments = arguments
            self.returns = returns
        }

        public var identifier : String {
            // (foo: Bar, baz: String)->(Void)
            return arguments.identifier + (exception ? " throws" : "") + " -> " + returns.identifier
        }

        public func emit(_ emitter: CodeEmitterType) {
            emitter.emitComments(comments)
            emitter.emit(access.rawValue, instance ? "" : "static", "func", name, identifier)
        }

        public var directReferences : [CodeNamedType] {
            // a function is a reference type
            return []
        }

        public var implementation: Implementation {
            return Implementation(declaration: self, body: [], comments: comments)
        }

    }

    public struct Implementation : CodeImplementation {
        public let declaration: Declaration
        public var body: [String] = []
        public var comments: [String] = []

        public func emit(_ emitter: CodeEmitterType) {
            emitter.emitComments(declaration.comments)

            // TODO: if emitted by a class, "static" should be called "class"
            if declaration.name == "init" {
                emitter.emit(declaration.access.rawValue, declaration.name + declaration.arguments.identifier, declaration.exception ? "throws" : "", "{")
            } else {
                emitter.emit(declaration.access.rawValue, declaration.instance ? "" : "static", "func", declaration.name + declaration.identifier, "{")
            }
            for b in body {
                emitter.emit(b + " ") // FIXME: trailing space is a hack to prevent lone "{" function from undenting
            }
            emitter.emit("}")
        }
    }
}


/// A named type is a type that is referencable by name (struct, class, enum)
public protocol CodeNamedType : CodeAccessible, CodeEmittable {
    var name: CodeTypeName { get set }
}

public extension CodeNamedType {
    /// The identifier for a named type is the name itself
    var identifier : String { return name }
}

/// A type alias can take an unnamed type (like a tuple) and assign it a name
public struct CodeTypeAlias : CodeNamedType, Hashable {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var type: CodeType
    /// A typeaias cannot have a nested types, so the nest best thing it to keey a list of peers that will
    /// be emitted when the typealias is emitted
    public var peerTypes: [CodeNamedType]
    public var comments: [String] = []

    public init(name: CodeTypeName, type: CodeType, access: CodeAccess, peerTypes: [CodeNamedType] = []) {
        self.access = access
        self.name = name
        self.type = type
        self.peerTypes = peerTypes
    }

    public func emit(_ emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, "typealias", name, "=", type.identifier)

        // type aliases can refer to an external type (like "String", but they can also carry their own peer types)
        for peer in peerTypes {
            peer.emit(emitter)
        }
    }

    public var directReferences : [CodeNamedType] {
        return type.directReferences
    }
}


/// A conformant type can conform to protocol (struct, class, enum, protocol)
public protocol CodeConformantType : CodeUnit {
    var conforms: [CodeProtocol] { get set }
}

/// An implementation type can contain function implementations (struct, class, enum)
public protocol CodeImplementationType : CodeConformantType, CodeEmittable {
    var nestedTypes: [CodeNamedType] { get set }
    var funcs: [CodeFunction.Implementation] { get set }
}

/// Reserved words as per the Swift language guide
private let reservedWords = Set(["class", "deinit", "enum", "extension", "func", "import", "init", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "for", "if", "in", "retu", ", switch", "where", "while", "as", "dynamicType", "false", "is", "nil", "self", "Self", "super", "true", "#column", "#file", "#function", "#line", "associativity", "convenience", "dynamic", "didSet", "final", "get", "infix", "inout", "lazy", "mutating", "nonmutating", "optional", "override", "postfix", "precedence", "prefix", "Protocol", "repeat", "required", "set", "Type", "unowned", "weak", "willSet"])

// Swift version 2.2+ allow unescaped keywords as argument names: https://github.com/apple/swift-evolution/blob/master/proposals/0001-keywords-as-argument-labels.md
private let reservedArgs = Set(["inout", "var", "let"])

extension String {
    func afterLast(_ sep: Character) -> String {
        let lastPart: String = (self.split { $0 == "." }).last.flatMap({ String($0) }) ?? self
        return lastPart
    }

    func isSwiftKeyword() -> Bool {
        return reservedWords.contains(self)
    }

    func isSwiftReservedArg() -> Bool {
        return reservedArgs.contains(self)
    }
}

public protocol CodeEnumType : CodeNamedType, CodeImplementationType {
    var associatedTypeName: String { get }
}

public struct CodeSimpleEnum<T> : CodeEnumType, CodeStateType, Hashable {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var cases: [CodeCaseSimple<T>] = []
    public var conforms: [CodeProtocol] = []
    public var props: [CodeProperty.Implementation]
    public var funcs: [CodeFunction.Implementation] = []
    public var comments: [String] = []
    public var defaultValue: String?
    public var nestedTypes: [CodeNamedType] = []

    public init(name: CodeTypeName, access: CodeAccess, cases: [CodeCaseSimple<T>] = [], props: [CodeProperty.Implementation] = []) {
        self.access = access
        self.name = name
        self.cases = cases
        self.props = props
    }

    public var associatedTypeName: String {
        return String(describing: T.self)
    }

    func quotedString(_ value: T) -> String {
        if value is String {
            return "\"\(value)\""
        } else {
            return "\(value)"
        }
    }

    var adoptions: String {
        let typeName = String(describing: T.self)
        // get the last part of "Swift.String", "Swift.Int", etc.
        let lastPart: String = typeName.afterLast(".")
        var exts = ([lastPart] + conforms.map(\.identifier)).joined(separator: ", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public func emit(_ emitter: CodeEmitterType) {
        emitter.emitComments(comments)

        emitter.emit(access.rawValue, "enum", name, adoptions, "{")
        for c in cases {
            if let v = c.value, (c.name == "\(v)" || c.name == "`\(v)`") {
                emitter.emit("case", c.name) // don't emit string cases when they are the same as the enum name
            } else {
                emitter.emit("case", c.name, c.value.flatMap({ "= " + quotedString($0) }))
            }
        }

        for p in props {
            p.emit(emitter)
        }

        for f in funcs {
            emitter.emit("")
            f.emit(emitter)
        }

        // sort typealiases & enums before structs & classes
        for inner in nestedTypes.sorted(by: typeOrdering) {
            emitter.emit("")
            inner.emit(emitter)
        }

        emitter.emit("}")
    }

    public var directReferences : [CodeNamedType] {
        return [self]
    }

}

public struct CodeCaseSimple<T> {
    public var name: CodeTypeName
    public var value: T?

    public init(name: CodeTypeName, value: T?) {
        self.name = name
        self.value = value
    }
}

public struct CodeEnum : CodeEnumType, Hashable {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var cases: [Case] = []
    public var conforms: [CodeProtocol] = []
    public var funcs: [CodeFunction.Implementation] = []
    public var comments: [String] = []
    public var nestedTypes: [CodeNamedType] = []

    public init(name: CodeTypeName, access: CodeAccess) {
        self.access = access
        self.name = name
    }

    public var associatedTypeName: String {
        return String(describing: CodeEnum.self)
    }

    public var directReferences : [CodeNamedType] {
        return [self] + cases.flatMap(\.directReferences)
    }

    public struct Case {
        public var name: CodeTypeName
        public var type: CodeType?

        public var directReferences : [CodeNamedType] {
            return type.flatMap({ $0.directReferences }) ?? []
        }

    }

    public var adoptions: String {
        var exts = conforms.map(\.identifier).joined(separator: ", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public func emit(_ emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, "enum", name, adoptions, "{")
        for c in cases {
            if let type = c.type {
                emitter.emit("case", c.name + "(" + type.identifier + ")")
            } else {
                emitter.emit("case", c.name)
            }
        }

        for f in funcs {
            emitter.emit("")
            f.emit(emitter)
        }

        for inner in nestedTypes.sorted(by: typeOrdering) {
            emitter.emit("")
            inner.emit(emitter)
        }

        emitter.emit("}")
    }

}

// currently unused
//public struct CodeExtension : CodeImplementationType {
//    public let extends: CodeNamedType
//    public var conforms: [CodeProtocol] = []
//    public var funcs: [CodeFunction.Implementation] = []
//    public var comments: [String] = []
//    public var nestedTypes: [CodeNamedType] = []
//
//    public init(extends: CodeNamedType) {
//        self.extends = extends
//    }
//}

public struct CodeProtocol : CodeNamedType, CodeConformantType, Hashable {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var conforms: [CodeProtocol] = []
    public var props: [CodeProperty.Declaration]
    public var funcs: [CodeFunction.Declaration] = []
    public var comments: [String] = []

    public init(name: CodeTypeName, access: CodeAccess = CodeAccess.public, props: [CodeProperty.Declaration] = []) {
        self.access = access
        self.name = name
        self.props = props
    }

    public var allprops : [CodeProperty.Declaration] {
        return conforms.flatMap(\.allprops) + props
    }

    var adoptions: String {
        var exts = conforms.map(\.identifier).joined(separator: ", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public var directReferences : [CodeNamedType] {
        return []
    }

    public func emit(_ emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, "protocol", name, adoptions, "{")
        for p in props { p.emit(emitter) }
        emitter.emit("}")
    }
}

/// An implementation type is a named type that can hold state and functions
public protocol CodePropertyImplementationType : CodeNamedType, CodeImplementationType {
    var props: [CodeProperty.Implementation] { get set }
}

public protocol CodeStateType : CodePropertyImplementationType {
    var conforms: [CodeProtocol] { get set }
    var props: [CodeProperty.Implementation] { get set }
    var funcs: [CodeFunction.Implementation] { get set }
}

public struct CodeStruct : CodeStateType, Hashable {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var conforms: [CodeProtocol] = []
    public var props: [CodeProperty.Implementation]
    public var funcs: [CodeFunction.Implementation] = []
    public var nestedTypes: [CodeNamedType] = []
    public var comments: [String] = []

    public init(name: CodeTypeName, access: CodeAccess, props: [CodeProperty.Implementation] = []) {
        self.access = access
        self.name = name
        self.props = props
    }

    /// A struct's adoptions is the list of protocols it adopts
    var adoptions: String {
        var exts = conforms.map(\.identifier).joined(separator: ", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public var directReferences : [CodeNamedType] {
        return [self] + props.compactMap(\.declaration.type).flatMap(\.directReferences)
    }

    public func emit(_ emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, "struct", name, adoptions, "{")
        for p in props {
            p.emit(emitter)
        }
        for p in conforms.flatMap(\.allprops) {
            // provide default implementations for all protocol properties
            // TODO: only is we have not explicitly provided implementations
            p.implementation.emit(emitter)
        }

        for f in funcs {
            emitter.emit("")
            f.emit(emitter)
        }

        for inner in nestedTypes.sorted(by: typeOrdering) {
            emitter.emit("")
            inner.emit(emitter)
        }

        emitter.emit("}")
    }
}

public struct CodeClass : CodeStateType, Hashable {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var conforms: [CodeProtocol] = []
    public var extends: [CodeClass] = [] // array instead of optional to work around recursive reference
    public var final: Bool = false
    public var props: [CodeProperty.Implementation]
    public var funcs: [CodeFunction.Implementation] = []
    public var nestedTypes: [CodeNamedType] = []
    public var comments: [String] = []

    public init(name: CodeTypeName, access: CodeAccess, props: [CodeProperty.Implementation] = []) {
        self.access = access
        self.name = name
        self.props = props
    }

    /// A class' adoptions is the list of protocols it adopts as well as its superclass
    var adoptions: String {
        var refs = conforms.map(\.identifier)
        if let ext = extends.first { refs.insert(ext.identifier, at: 0) }

        var exts = refs.joined(separator: ", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public var directReferences : [CodeNamedType] {
        // a class does not have any "direct" references since it is a reference type
        return []
        // return [self] + props.flatMap(\.declaration.type)
    }

    public func emit(_ emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, final ? "final" : "", "class", name, adoptions, "{")

        for p in props {
            p.emit(emitter)
        }
        for p in conforms.flatMap(\.allprops) {
            // provide default implementations for all protocol properties
            // TODO: only is we have not explicitly provided implementations
            // TODO: only if the superclass has not already provided an implementation
            p.implementation.emit(emitter)
        }


        for f in funcs {
            emitter.emit("")
            f.emit(emitter)
        }
        
        for inner in nestedTypes.sorted(by: typeOrdering) {
            emitter.emit("")
            inner.emit(emitter)
        }
        
        emitter.emit("}")
    }
}

