//
//  SwiftCode.swift
//  BricBrac
//
//  Created by Marc Prud'hommeaux on 7/6/15.
//  Copyright © 2015 io.glimpse. All rights reserved.
//

/// SwiftCode elements for code emission

public protocol CodeEmitterType {
    func emit(tokens: String?...)
}

public extension CodeEmitterType {
    public func emitComments(comments: [String]) {
        let comms = comments.flatMap({ $0.characters.split { $0 == "\n" || $0 == "\r" } })

        for comment in comms {
            emit("///", String(comment))
        }
    }
}


public class CodeEmitter<T: OutputStreamType> : CodeEmitterType {
    public var stream: T
    public var level: UInt = 0

    public init(stream: T) {
        self.stream = stream
    }

    public func emit(tokens: String?...) {
        if tokens.count == 1 && tokens.last ?? "" == "}" {
            level -= 1
        }

        // only output non-blank, non-nil tokens
        let toks = tokens.filter({ $0 != nil && $0 != "" })

        if !toks.isEmpty {
            for _ in 0..<level { // indentation
                stream.write("    ")
            }
        }

        for (i, token) in toks.enumerate() {
            if let token = token {
                if i > 0 { stream.write(" ") }
                stream.write(token)
            }
        }

        // increase/decrease indentation based on trailing code blocks
        if tokens.last ?? "" == "{" {
            level += 1
        }

        stream.write("\n")
    }
}

private class KeyCodeEmitter : CodeEmitterType {
    private var string = ""

    private func emit(tokens: String?...) {
        for token in tokens {
            if let token = token {
                string.appendContentsOf(token)
                string.appendContentsOf(" ")
            }
        }
        string.appendContentsOf("\n")
    }
}

public protocol CodeEmittable {
    var comments: [String] { get set }
    func emit(emitter: CodeEmitterType)
}

public class CodeModule : CodeImplementationType {
    public var types: [CodeNamedType] {
        get { return nestedTypes }
        set { nestedTypes = newValue }
    }

    public var nestedTypes: [CodeNamedType] = []
    public var comments: [String] = []
    public var imports: [String] = []
    /// Global functions in this module
    public var funcs: [CodeFunction.Implementation] = []
    /// No-op at the module level (needed for CodeImplementationType : CodeConformantType)
    public var conforms: [CodeProtocol] = []

    public init() {
    }

    public func emit(emitter: CodeEmitterType) {
        for i in imports {
            emitter.emit("import", i)
        }

        if !imports.isEmpty {
            emitter.emit()
        }

        for f in funcs {
            emitter.emit("")
            f.emit(emitter)
        }

        for inner in nestedTypes {
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

public protocol CodeType : CodeUnit {
    /// Returns a reference identifier for this code unit
    var identifier : String { get }

    /// Returna a default value initializer for instances of this type
    var defaultValue : String? { get }

    var directReferences : [CodeNamedType] { get }

}

public extension CodeType {
    /// By default, types have no default value
    public var defaultValue : String? {
        return nil
    }
}

/// A type reference refers to another type that may not be defined here (e.g., "String" or "Array<Int>")
public struct CodeExternalType : CodeType {
    public var name : CodeTypeName
    public var generics : [CodeType]
    public var access: CodeAccess
    public var comments: [String] = []

    public init(_ name: CodeTypeName, generics: [CodeType] = [], access: CodeAccess) {
        self.name = name
        self.generics = generics
        self.access = access
    }

    public var identifier : String {
        if generics.isEmpty {
            return name
        } else {
            return name + "<" + (generics.map({ $0.identifier })).joinWithSeparator(", ") + ">"
        }
    }

    public var defaultValue : String? {
        if name == "Array" { return "[]" }
        if name == "Dictionary" { return "[:]" }
        if name == "Optional" { return "nil" }
        if name == "Indirect" { return "nil" }
        if name == "NotBrac" { return "nil" }
        if name == "Bric" { return "nil" }

        return nil
    }

    public var directReferences : [CodeNamedType] {
        return [CodeTypeAlias(name: name, type: self, access: access)]
    }
}

/// A compound type is an anonymous type that it not shareable or referencable
public protocol CodeCompoundType : CodeType {
}

public enum CodeAccess : String {
    case Public = "public", Private = "private", Internal = "internal", Default = ""
}

public protocol CodeImplementation : CodeEmittable {
    var body: [String] { get set }
}

public struct CodeProperty {
    public class Declaration: CodeUnit {
        public var name: CodePropName
        public var type: CodeType
        public var access: CodeAccess
        public var mutable: Bool = true
        public var comments: [String] = []

        public var isDictionary: Bool {
            return type.identifier.hasPrefix("Dictionary")
        }

        public var isArray: Bool {
            return type.identifier.hasPrefix("Array")
        }

        public init(name: CodePropName, type: CodeType, access: CodeAccess, mutable: Bool = true) {
            self.name = name
            self.type = type
            self.access = access
            self.mutable = mutable
        }

        public func emit(emitter: CodeEmitterType) {
            emitter.emitComments(comments)
            emitter.emit("var", name + ":", type.identifier, "{", "get", mutable ? "set" : "", "}")
        }

        public var implementation: Implementation {
            return Implementation(declaration: self, body: [], comments: comments)
        }
    }

    public struct Implementation : CodeImplementation {
        public let declaration: Declaration
        public var body: [String] = []
        public var comments: [String] = []

        public func emit(emitter: CodeEmitterType) {
            emitter.emitComments(declaration.comments)
            // TODO: allow declaration bodies (e.g., dynamic get/set, willSet/didSet)
            emitter.emit(declaration.access.rawValue, declaration.mutable || !body.isEmpty ? "var" : "let", declaration.name + ":", declaration.type.identifier, body.isEmpty ? "" : "{")
            if !body.isEmpty {
                for b in body {
                    emitter.emit(b) // TODO: trailing { should indent
                }
                emitter.emit("}")
            }
        }
    }
}

public typealias CodeTupleElement = (name: CodePropName?, type: CodeType, value: String?, anon: Bool)

public struct CodeTuple : CodeCompoundType {
    public var elements: [CodeTupleElement]
    public var arity: Int { return elements.count }
    public var comments: [String] = []

    public init(elements: [CodeTupleElement] = []) {
        self.elements = elements
    }

    public var identifier : String {
        // (foo: Bar, baz: String) or (Bar, String) or (foo: Bar? = nil, baz: String = "Foo") depending on whether they have names
        func ename(element: CodeTupleElement) -> String {
            // slow compile!
            // return (element.name.flatMap({ $0 + ": " }) ?? "") + element.type.identifier + (element.value.flatMap({ " = " + $0 }) ?? "")
            let n0: String = element.anon ? "_ " : ""
            let n1: String = (element.name.flatMap({ $0 + ": " }) ?? "")
            let n2: String = (element.value.flatMap({ " = " + $0 }) ?? "")
            return n0 + n1 + element.type.identifier + n2
        }
        let parts = elements.map(ename)
        // un-named single-element tuples do not need to be named
        let paren = arity != 1 || elements.first?.name != nil
        return (paren ? "(" : "") + parts.joinWithSeparator(", ") + (paren ? ")" : "")
    }

    public var directReferences : [CodeNamedType] {
        return elements.flatMap({ $0.type.directReferences })
    }
}

public protocol CodeAccessible : CodeType {
    var access: CodeAccess { get set }

    func emit(emitter: CodeEmitterType)
}

public struct CodeFunction {
    public class Declaration: CodeCompoundType {
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

        public func emit(emitter: CodeEmitterType) {
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

        public func emit(emitter: CodeEmitterType) {
            emitter.emitComments(declaration.comments)

            // TODO: if emitted by a class, "static" should be called "class"
            if declaration.name == "init" {
                emitter.emit(declaration.access.rawValue, declaration.name + declaration.arguments.identifier, "{")
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
    public var identifier : String { return name }
}

/// A type alias can take an unnamed type (like a tuple) and assign it a name
public struct CodeTypeAlias : CodeNamedType {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var type: CodeType
    /// A typeaias cannot have a nested types, so the nest best thing it to keey a list of peers that will
    /// be emitted when the typealias is emitted
    public var peers: [CodeNamedType]
    public var comments: [String] = []

    public init(name: CodeTypeName, type: CodeType, access: CodeAccess, peers: [CodeNamedType] = []) {
        self.access = access
        self.name = name
        self.type = type
        self.peers = peers
    }

    public func emit(emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, "typealias", name, "=", type.identifier)

        // type aliases can refer to an external type (like "String", but they can also carry their own peer types)
        for peer in peers {
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
private let reservedWords = Set(["class", "deinit", "enum", "extension", "func", "import", "init", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "for", "if", "in", "retu", ", switch", "where", "while", "as", "dynamicType", "false", "is", "nil", "self", "Self", "super", "true", "#column", "#file", "#function", "#line", "associativity", "convenience", "dynamic", "didSet", "final", "get", "infix", "inout", "lazy", "left", "mutating", "none", "nonmutating", "optional", "override", "postfix", "precedence", "prefix", "Protocol", "required", "right", "set", "Type", "unowned", "weak", "willSet"])

// Wwift version 2.2+ allow unescaped keywords as argument names: https://github.com/apple/swift-evolution/blob/master/proposals/0001-keywords-as-argument-labels.md
private let reservedArgs = Set(["inout", "var", "let"])

extension String {
    func afterLast(sep: Character) -> String {
        let lastPart: String = (self.characters.split { $0 == "." }).last.flatMap({ String($0) }) ?? self
        return lastPart
    }

    func isSwiftKeyword() -> Bool {
        return reservedWords.contains(self)
    }

    func isSwiftReservedArg() -> Bool {
        return reservedArgs.contains(self)
    }
}

public struct CodeSimpleEnum<T> : CodeNamedType, CodeImplementationType {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var cases: [CodeCaseSimple<T>] = []
    public var conforms: [CodeProtocol] = []
    public var funcs: [CodeFunction.Implementation] = []
    public var comments: [String] = []
    public var defaultValue: String?
    public var nestedTypes: [CodeNamedType] = []

    public init(name: CodeTypeName, access: CodeAccess, cases: [CodeCaseSimple<T>] = []) {
        self.access = access
        self.name = name
        self.cases = cases
    }

    func quotedString(value: T) -> String {
        if value is String {
            return "\"\(value)\""
        } else {
            return "\(value)"
        }
    }

    var adoptions: String {
        let typeName = String(T.self)
        // get the last part of "Swift.String", "Swift.Int", etc.
        let lastPart: String = typeName.afterLast(".")
        var exts = ([lastPart] + conforms.map({ $0.identifier })).joinWithSeparator(", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public func emit(emitter: CodeEmitterType) {
        emitter.emitComments(comments)

        emitter.emit(access.rawValue, "enum", name, adoptions, "{")
        for c in cases {
            emitter.emit("case", c.name, c.value.flatMap({ "= " + quotedString($0) }))
        }

        for inner in nestedTypes {
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

public struct CodeEnum : CodeNamedType, CodeImplementationType {
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

    public var directReferences : [CodeNamedType] {
        return [self] + cases.flatMap({ $0.directReferences })
    }

    public struct Case {
        public var name: CodeTypeName
        public var type: CodeType?

        public var directReferences : [CodeNamedType] {
            return type.flatMap({ $0.directReferences }) ?? []
        }

    }

    public var adoptions: String {
        var exts = conforms.map({ $0.identifier }).joinWithSeparator(", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public func emit(emitter: CodeEmitterType) {
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

        for inner in nestedTypes {
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

public struct CodeProtocol : CodeNamedType, CodeConformantType {
    public var name: CodeTypeName
    public var access: CodeAccess
    public var conforms: [CodeProtocol] = []
    public var props: [CodeProperty.Declaration]
    public var funcs: [CodeFunction.Declaration] = []
    public var comments: [String] = []

    public init(name: CodeTypeName, access: CodeAccess, props: [CodeProperty.Declaration] = []) {
        self.access = access
        self.name = name
        self.props = props
    }

    public var allprops : [CodeProperty.Declaration] {
        return conforms.flatMap({ $0.allprops }) + props
    }

    var adoptions: String {
        var exts = conforms.map({ $0.identifier }).joinWithSeparator(", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public var directReferences : [CodeNamedType] {
        return []
    }

    public func emit(emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, "protocol", name, adoptions, "{")
        for p in props { p.emit(emitter) }
        emitter.emit("}")
    }
}

/// An implementation type is a named type that can hold state and functions
public protocol CodePropertyImplementationType : CodeNamedType, CodeConformantType, CodeImplementationType {
    var props: [CodeProperty.Implementation] { get set }
}

public protocol CodeStateType : CodePropertyImplementationType, CodeImplementationType {
    var conforms: [CodeProtocol] { get set }
    var props: [CodeProperty.Implementation] { get set }
    var funcs: [CodeFunction.Implementation] { get set }
}

public struct CodeStruct : CodeStateType {
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
        var exts = conforms.map({ $0.identifier }).joinWithSeparator(", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public var directReferences : [CodeNamedType] {
        return [self] + props.flatMap({ $0.declaration.type.directReferences })
    }

    public func emit(emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, "struct", name, adoptions, "{")
        for p in props {
            p.emit(emitter)
        }
        for p in conforms.flatMap({ $0.allprops }) {
            // provide default implementations for all protocol properties
            // TODO: only is we have not explicitly provided implementations
            p.implementation.emit(emitter)
        }

        for f in funcs {
            emitter.emit("")
            f.emit(emitter)
        }

        for inner in nestedTypes {
            emitter.emit("")
            inner.emit(emitter)
        }

        emitter.emit("}")
    }
}

public struct CodeClass : CodeStateType {
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
        var refs = conforms.map({ $0.identifier })
        if let ext = extends.first { refs.insert(ext.identifier, atIndex: 0) }

        var exts = refs.joinWithSeparator(", ")
        if !exts.isEmpty {
            exts = ": " + exts
        }
        return exts
    }

    public var directReferences : [CodeNamedType] {
        // a class does not have any "direct" references since it is a reference type
        return []
        // return [self] + props.flatMap({ $0.declaration.type })
    }

    public func emit(emitter: CodeEmitterType) {
        emitter.emitComments(comments)
        emitter.emit(access.rawValue, final ? "final" : "", "class", name, adoptions, "{")

        for p in props {
            p.emit(emitter)
        }
        for p in conforms.flatMap({ $0.allprops }) {
            // provide default implementations for all protocol properties
            // TODO: only is we have not explicitly provided implementations
            // TODO: only if the superclass has not already provided an implementation
            p.implementation.emit(emitter)
        }


        for f in funcs {
            emitter.emit("")
            f.emit(emitter)
        }
        
        for inner in nestedTypes {
            emitter.emit("")
            inner.emit(emitter)
        }
        
        emitter.emit("}")
    }
}

