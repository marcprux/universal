import Swift
import Foundation
import Either
import Quanta


/// A YAML tree node, which can contain a `Scalar` (`String`, `Int`, `Double`, `Bool`, or `Null`), `[YAML]`, or `[Scalar: YAML]`
public struct YAML : Isomorph, Sendable, Hashable {
    public typealias NumberType = Either<IntegerLiteralType>.Or<FloatLiteralType>
    public typealias Scalar = ScalarOf<StringLiteralType, NumberType>
    public typealias Object = [Scalar: YAML]
    public typealias RawValue = Quantum<Scalar, Object.Key, Object.Value>

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension YAML.Scalar {
    public static let null = YAML.Scalar(Never?.none)
    public static let `true` = YAML.Scalar(true)
    public static let `false` = YAML.Scalar(false)
}

/// Convenience accessors for the payloads of the various `YAML` types
public extension YAML {
    static let null = YAML(Either.Or(YAML.Scalar.null))
    static let `true` = YAML(Either.Or(YAML.Scalar.true))
    static let `false` = YAML(Either.Or(YAML.Scalar.false))

    static func string(_ str: String) -> Self { YAML(Either.Or(Scalar(str))) }
    static func double(_ dbl: Double) -> Self { YAML(Either.Or(Scalar(dbl))) }
    static func integer(_ int: Int) -> Self { YAML(Either.Or(Scalar(int))) }
    static func boolean(_ bol: Bool) -> Self { YAML(Either.Or(Scalar(bol))) }
    static func array(_ arr: [YAML]) -> Self { YAML(Either.Or(Quanta(rawValue: .init(arr)))) }
    static func object(_ obj: [Scalar: YAML]) -> Self { YAML(Either.Or(Quanta(rawValue: .init(obj)))) }

    /// Returns the underlying String payload if this is a `YAML.str`, otherwise `.none`
    @inlinable var string: String? {
        rawValue.infer()?.infer()
    }

    /// Returns the underlying Boolean payload if this is a `YAML.bol`, otherwise `.none`
    @inlinable var boolean: Bool? {
        rawValue.infer()?.infer()
    }

    /// Returns the underlying Double payload if this is a `YAML.dbl`, otherwise `.none`
    @inlinable var double: Double? {
        rawValue.infer()?.infer()
    }

    /// Returns the underlying Double payload if this is a `YAML.int`, otherwise `.none`
    @inlinable var integer: Int? {
        rawValue.infer()?.infer()
    }

    /// Returns the underlying Double for either `int` or `dbl` types.
    @inlinable var number: Double? {
        double ?? integer.map(Double.init)
    }

    /// Returns the underlying JObj payload if this is a `YAML.obj`, otherwise `.none`
    @inlinable var object: Object? {
        rawValue.infer()?.rawValue.infer()
    }

    /// Returns the underlying Array payload if this is a `YAML.arr`, otherwise `.none`
    @inlinable var array: [YAML]? {
        rawValue.infer()?.rawValue.infer()
    }

    /// YAML has a string subscript when it is an object type; setting a value on a non-obj type has no effect
    @inlinable subscript(key: Scalar) -> YAML? {
        object?[key]
    }

    /// YAML has a save indexed subscript when it is an array type; setting a value on a non-array type has no effect
    @inlinable subscript(index: Int) -> YAML? {
        array?[index]
    }

    /// Returns true if this represents the JSON literal `null`.
    var isNull: Bool {
        self == YAML.null
    }

    /// The number of elements this contains: either the count of the underyling array or dictiionary, or 0 if `null`, or else 1 for a scalar.
    @inlinable var count: Int {
        switch rawValue {
        case .a:
            return isNull ? 0 : 1
        case .b(let collection):
            switch collection.rawValue {
            case .a(let x): return x.count
            case .b(let x): return x.count
            }
        }
    }
}

extension YAML : Encodable {
    /// Encodes to a JSON-compatible encoder.
    @inlinable public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self.rawValue {
        case .a(let scalar):
            switch scalar {
            case .a(let string): try container.encode(string as String)
            case .b(let scalar):
                switch scalar {
                case .a(let number):
                    switch number {
                    case .a(let integer): try container.encode(integer as Int)
                    case .b(let double): try container.encode(double as Double)
                    }
                case .b(let scalar):
                    switch scalar {
                    case .a(let boolean): try container.encode(boolean as Bool)
                    case .b(let null): assert(null as Never? == .none); try container.encodeNil()
                    }
                }
            }

        case .b(let quanta):
            switch quanta.rawValue {
            case .a(let array): try container.encode(array)
            case .b(let dictionary): try container.encode(dictionary)
            }
        }
    }
}

//extension YAML : Decodable {
//    @inlinable public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        func decode<T: Decodable>() throws -> T { try container.decode(T.self) }
//        if container.decodeNil() {
//            self = YAML.null
//        } else {
//            do {
//                self = try YAML(booleanLiteral: container.decode(Bool.self))
//            } catch DecodingError.typeMismatch {
//                do {
//                    self = try YAML(floatLiteral: container.decode(Double.self))
//                } catch DecodingError.typeMismatch {
//                    do {
//                        self = try YAML(stringLiteral: container.decode(String.self))
//                    } catch DecodingError.typeMismatch {
//                        do {
//                            self = try YAML(.init(decode() as Quanta<Key, Value>))
//                        } catch DecodingError.typeMismatch {
//                            throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
//                        }
//                    }
//                }
//            }
//        }
//    }
//}





// The YAML parsing code borrows heavily from the https://github.com/behrang/YamlSwift which is released under the following license:
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Behrang Noruzi Niya
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

extension YAML {
    /// Parses the given YAML data.
    public static func parse(_ yamlData: Data) throws -> YAML {
        try parse(yaml: String(data: yamlData, encoding: .utf8) ?? String())
    }

    /// Parses the given YAML string into a ``YAML``.
    /// - Parameter yaml: the YAML string to parse
    public static func parse(yaml: String) throws -> YAML {
        let result = YAMLParser.tokenize(yaml) >>=- Context.parseDoc
        if let value = result.value { return value } else { throw ResultError.message(result.error) }
    }

    /// Parses the given YAML string into multuple ``YAML``s.
    /// - Parameter yaml: the YAML string to parse
    public static func parse(yamls: String) throws -> [YAML] {
        let result = YAMLParser.tokenize(yamls) >>=- Context.parseDocs
        if let value = result.value { return value } else { throw ResultError.message(result.error) }
    }
}

private extension YAML {
    enum ResultError: LocalizedError {
        case message(String?)

        var errorDescription: String? {
            switch self {
            case .message(let x): return x
            }
        }
    }
}


private enum YAMLParser {

    struct Context {
        let tokens: [YAMLParser.TokenMatch]
        let aliases: [String.SubSequence: YAML]

        init(_ tokens: [YAMLParser.TokenMatch], _ aliases: [String.SubSequence: YAML] = [:]) {
            self.tokens = tokens
            self.aliases = aliases
        }

        static func parseDoc(_ tokens: [YAMLParser.TokenMatch]) -> YAMLResult<YAML> {
            let c = YAMLParser.lift(Context(tokens))
            let cv = c >>=- parseHeader >>=- parseValue
            let v = cv >>- getValue
            return cv
            >>- getContext
            >>- ignoreDocEnd
            >>=- expect(.end, message: "expected end")
            >>| v
        }

        static func parseDocs(_ tokens: [YAMLParser.TokenMatch]) -> YAMLResult<[YAML]> {
            return parseDocs([])(Context(tokens))
        }

        static func parseDocs(_ acc: [YAML]) -> (Context) -> YAMLResult<[YAML]> {
            return { context in
                if peekType(context) == .end {
                    return YAMLParser.lift(acc)
                }
                let cv = YAMLParser.lift(context)
                >>=- parseHeader
                >>=- parseValue
                let v = cv
                >>- getValue
                let c = cv
                >>- getContext
                >>- ignoreDocEnd
                let a = appendToArray(acc) <^> v
                return parseDocs <^> a <*> c |> YAMLParser.join
            }
        }

        static func error(_ message: String) -> (Context) -> String {
            return { context in
                let text = recreateText("", context: context) |> YAMLParser.escapeErrorContext
                return "\(message), \(text)"
            }
        }
    }
}

private typealias Context = YAMLParser.Context

private var error = YAMLParser.Context.error

private typealias ContextValue = (context: Context, value: YAML)
private typealias ContextKey = (context: Context, key: YAML.Object.Key)

private func createContextValue(_ context: Context) -> (YAML) -> ContextValue { { value in (context, value) } }
private func getContext(_ cv: ContextValue) -> Context { cv.context }
private func getValue(_ cv: ContextValue) -> YAML { cv.value }
private func peekType(_ context: Context) -> YAML.TokenType { context.tokens[0].type }
private func peekMatch(_ context: Context) -> String { context.tokens[0].match }


private func advance(_ context: Context) -> Context {
    var tokens = context.tokens
    tokens.remove(at: 0)
    return Context(tokens, context.aliases)
}

private func ignoreSpace(_ context: Context) -> Context {
    if ![.comment, .space, .newLine].contains(peekType(context)) {
        return context
    }
    return ignoreSpace(advance(context))
}

private func ignoreDocEnd(_ context: Context) -> Context {
    if ![.comment, .space, .newLine, .docend].contains(peekType(context)) {
        return context
    }
    return ignoreDocEnd(advance(context))
}

private func expect(_ type: YAML.TokenType, message: String) -> (Context) -> YAMLResult<Context> {
    return { context in
        let check = peekType(context) == type
        return YAMLParser.`guard`(error(message)(context), check: check)
        >>| YAMLParser.lift(advance(context))
    }
}

private func expectVersion(_ context: Context) -> YAMLResult<Context> {
    let version = peekMatch(context)
    let check = ["1.1", "1.2"].contains(version)
    return YAMLParser.`guard`(error("invalid yaml version")(context), check: check)
    >>| YAMLParser.lift(advance(context))
}


private func recreateText(_ string: String, context: Context) -> String {
    if string.count >= 50 || peekType(context) == .end {
        return string
    }
    return recreateText(string + peekMatch(context), context: advance(context))
}

private func parseHeader(_ context: Context) -> YAMLResult<Context> {
    return parseHeader(true)(Context(context.tokens, [:]))
}

private func parseHeader(_ yamlAllowed: Bool) -> (Context) -> YAMLResult<Context> {
    return { context in
        switch peekType(context) {

        case .comment, .space, .newLine:
            return YAMLParser.lift(context)
            >>- advance
            >>=- parseHeader(yamlAllowed)

        case .yamlDirective:
            let err = "duplicate yaml directive"
            return YAMLParser.`guard`(error(err)(context), check: yamlAllowed)
            >>| YAMLParser.lift(context)
            >>- advance
            >>=- expect(.space, message: "expected space")
            >>=- expectVersion
            >>=- parseHeader(false)

        case .docStart:
            return YAMLParser.lift(advance(context))

        default:
            return YAMLParser.`guard`(error("expected ---")(context), check: yamlAllowed)
            >>| YAMLParser.lift(context)
        }
    }
}

private func parseValue(_ context: Context) -> YAMLResult<ContextValue> {
    switch peekType(context) {

    case .comment, .space, .newLine:
        return parseValue(ignoreSpace(context))

    case .null:
        return YAMLParser.lift((advance(context), .null))

    case ._true:
        return YAMLParser.lift((advance(context), .true))

    case ._false:
        return YAMLParser.lift((advance(context), .false))

    case .int:
        let m = peekMatch(context)
        // will throw runtime error if overflows
        let v = YAML.integer(parseInt(m, radix: 10))
        return YAMLParser.lift((advance(context), v))

    case .intOct:
        let m = peekMatch(context) |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("0o"), template: "")
        // will throw runtime error if overflows
        let v = YAML.integer(parseInt(m, radix: 8))
        return YAMLParser.lift((advance(context), v))

    case .intHex:
        let m = peekMatch(context) |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("0x"), template: "")
        // will throw runtime error if overflows
        let v = YAML.integer(parseInt(m, radix: 16))
        return YAMLParser.lift((advance(context), v))

    case .intSex:
        let m = peekMatch(context)
        let v = YAML.integer(parseInt(m, radix: 60))
        return YAMLParser.lift((advance(context), v))

    case .infinityP:
        return YAMLParser.lift((advance(context), .double(Double.infinity)))

    case .infinityN:
        return YAMLParser.lift((advance(context), .double(-Double.infinity)))

    case .nan:
        return YAMLParser.lift((advance(context), .double(Double.nan)))

    case .double:
        let m = NSString(string: peekMatch(context))
        return YAMLParser.lift((advance(context), .double(m.doubleValue)))

    case .dash:
        return parseBlockSeq(context)

    case .openSB:
        return parseFlowSeq(context)

    case .openCB:
        return parseFlowMap(context)

    case .questionMark:
        return parseBlockMap(context)

    case .stringDQ, .stringSQ, .string:
        return parseBlockMapOrString(context)

    case .literal:
        return parseliteral(context)

    case .folded:
        let cv = parseliteral(context)
        let c = cv >>- getContext
        let v = cv
        >>- getValue
        >>- { value in YAML.string(foldBlock(value.string ?? "")) }
        return createContextValue <^> c <*> v

    case .indent:
        let cv = parseValue(advance(context))
        let v = cv >>- getValue
        let c = cv
        >>- getContext
        >>- ignoreSpace
        >>=- expect(.dedent, message: "expected dedent")
        return createContextValue <^> c <*> v

    case .anchor:
        let m = peekMatch(context)
        let name = m[m.index(after: m.startIndex)...]
        let cv = parseValue(advance(context))
        let v = cv >>- getValue
        let c = addAlias(name) <^> v <*> (cv >>- getContext)
        return createContextValue <^> c <*> v

    case .alias:
        let m = peekMatch(context)
        let name = m[m.index(after: m.startIndex)...]
        let value = context.aliases[name]
        let err = "unknown alias \(name)"
        return YAMLParser.`guard`(error(err)(context), check: value != nil)
        >>| YAMLParser.lift((advance(context), value ?? YAML.null))

    case .end, .dedent:
        return YAMLParser.lift((context, YAML.null))

    default:
        return YAMLParser.fail(error("unexpected type \(peekType(context))")(context))

    }
}

private func addAlias(_ name: String.SubSequence) -> (YAML) -> (Context) -> Context {
    return { value in
        return { context in
            var aliases = context.aliases
            aliases[name] = value
            return Context(context.tokens, aliases)
        }
    }
}

private func appendToArray(_ array: [YAML]) -> (YAML) -> [YAML] {
    { array + [$0] }
}

private func putToMap(_ map: [YAML.Scalar: YAML]) -> (YAML) -> (YAML) -> [YAML.Scalar: YAML] {
    { key in
        { value in
            var map = map
            if let yamlKey = key.yamlKey {
                map[yamlKey] = value
            }
            return map
        }
    }
}

private func checkKeyValueUniqueness(_ acc: [YAML.Scalar: YAML]) ->(_ context: Context, _ key: YAML.Scalar) -> YAMLResult<ContextKey> {
    { (context, key) in
        let err = "duplicate key \(key)"
        return YAMLParser.`guard`(error(err)(context), check: !acc.keys.contains(key))
        >>| YAMLParser.lift((context, key))
    }
}

private extension YAML {
    /// This YAML as a key in a dictionary.
    var yamlKey: Object.Key? {
        rawValue.infer()
    }
}

private func checkKeyUniqueness(_ acc: [YAML.Scalar: YAML]) ->(_ context: Context, _ key: YAML) -> YAMLResult<ContextValue> {
    { (context, key) in
        let err = "duplicate key"
        return YAMLParser.`guard`(error(err)(context), check: key.rawValue.a == nil || !acc.keys.contains(key.rawValue.a!))
        >>| YAMLParser.lift((context, key))
    }
}

private func parseFlowSeq(_ context: Context) -> YAMLResult<ContextValue> {
    YAMLParser.lift(context)
    >>=- expect(.openSB, message: "expected [")
    >>=- parseFlowSeq([])
}

private func parseFlowSeq(_ acc: [YAML]) -> (Context) -> YAMLResult<ContextValue> {
    { context in
        if peekType(context) == .closeSB {
            return YAMLParser.lift((advance(context), .array(acc)))
        }
        let cv = YAMLParser.lift(context)
        >>- ignoreSpace
        >>=- (acc.count == 0 ? YAMLParser.lift : expect(.comma, message: "expected comma"))
        >>- ignoreSpace
        >>=- parseValue
        let v = cv >>- getValue
        let c = cv
        >>- getContext
        >>- ignoreSpace
        let a = appendToArray(acc) <^> v
        return parseFlowSeq <^> a <*> c |> YAMLParser.join
    }
}

private func parseFlowMap(_ context: Context) -> YAMLResult<ContextValue> {
    YAMLParser.lift(context)
    >>=- expect(.openCB, message: "expected {")
    >>=- parseFlowMap([:])
}

private func parseFlowMap(_ acc: [YAML.Scalar: YAML]) -> (Context) -> YAMLResult<ContextValue> {
    { context in
        if peekType(context) == .closeCB {
            return YAMLParser.lift((advance(context), .object(acc)))
        }
        let ck = YAMLParser.lift(context)
        >>- ignoreSpace
        >>=- (acc.count == 0 ? YAMLParser.lift : expect(.comma, message: "expected comma"))
        >>- ignoreSpace
        >>=- parseString
        >>=- checkKeyUniqueness(acc)
        let k = ck >>- getValue
        let cv = ck
        >>- getContext
        >>=- expect(.colon, message: "expected colon")
        >>=- parseValue
        let v = cv >>- getValue
        let c = cv
        >>- getContext
        >>- ignoreSpace
        let a = putToMap(acc) <^> k <*> v
        return parseFlowMap <^> a <*> c |> YAMLParser.join
    }
}

private func parseBlockSeq(_ context: Context) -> YAMLResult<ContextValue> {
    parseBlockSeq([])(context)
}

private func parseBlockSeq(_ acc: [YAML]) -> (Context) -> YAMLResult<ContextValue> {
    { context in
        if peekType(context) != .dash {
            return YAMLParser.lift((context, .array(acc)))
        }
        let cv = YAMLParser.lift(context)
        >>- advance
        >>=- expect(.indent, message: "expected indent after dash")
        >>- ignoreSpace
        >>=- parseValue
        let v = cv >>- getValue
        let c = cv
        >>- getContext
        >>- ignoreSpace
        >>=- expect(.dedent, message: "expected dedent after dash indent")
        >>- ignoreSpace
        let a = appendToArray(acc) <^> v
        return parseBlockSeq <^> a <*> c |> YAMLParser.join
    }
}

private func parseBlockMap(_ context: Context) -> YAMLResult<ContextValue> {
    parseBlockMap([:])(context)
}

private func parseBlockMap(_ acc: [YAML.Scalar: YAML]) -> (Context) -> YAMLResult<ContextValue> {
    { context in
        switch peekType(context) {

        case .questionMark:
            return parseQuestionMarkkeyValue(acc)(context)

        case .string, .stringDQ, .stringSQ:
            return parseStringKeyValue(acc)(context)

        default:
            return YAMLParser.lift((context, .object(acc)))
        }
    }
}

private func parseQuestionMarkkeyValue(_ acc: [YAML.Scalar: YAML]) -> (Context) -> YAMLResult<ContextValue> {
    { context in
        let ck = YAMLParser.lift(context)
        >>=- expect(.questionMark, message: "expected ?")
        >>=- parseValue
        >>=- checkKeyUniqueness(acc)
        let k = ck >>- getValue
        let cv = ck
        >>- getContext
        >>- ignoreSpace
        >>=- parseColonValueOrNil
        let v = cv >>- getValue
        let c = cv
        >>- getContext
        >>- ignoreSpace
        let a = putToMap(acc) <^> k <*> v
        return parseBlockMap <^> a <*> c |> YAMLParser.join
    }
}

private func parseColonValueOrNil(_ context: Context) -> YAMLResult<ContextValue> {
    if peekType(context) != .colon {
        return YAMLParser.lift((context, YAML.null))
    }
    return parseColonValue(context)
}

private func parseColonValue(_ context: Context) -> YAMLResult<ContextValue> {
    YAMLParser.lift(context)
    >>=- expect(.colon, message: "expected colon")
    >>- ignoreSpace
    >>=- parseValue
}

private func parseStringKeyValue(_ acc: [YAML.Scalar: YAML]) -> (Context) -> YAMLResult<ContextValue> {
    { context in
        let ck = YAMLParser.lift(context)
        >>=- parseString
        >>=- checkKeyUniqueness(acc)
        let k = ck >>- getValue
        let cv = ck
        >>- getContext
        >>- ignoreSpace
        >>=- parseColonValue
        let v = cv >>- getValue
        let c = cv
        >>- getContext
        >>- ignoreSpace
        let a = putToMap(acc) <^> k <*> v
        return parseBlockMap <^> a <*> c |> YAMLParser.join
    }
}

private func parseString(_ context: Context) -> YAMLResult<ContextValue> {
    switch peekType(context) {

    case .string:
        let m = normalizeBreaks(peekMatch(context))
        let folded = m |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^[ \\t\\n]+|[ \\t\\n]+$"), template: "") |> foldFlow
        return YAMLParser.lift((advance(context), .string(folded)))

    case .stringDQ:
        let m = unwrapQuotedString(normalizeBreaks(peekMatch(context)))
        return YAMLParser.lift((advance(context), .string(unescapeDoubleQuotes(foldFlow(m)))))

    case .stringSQ:
        let m = unwrapQuotedString(normalizeBreaks(peekMatch(context)))
        return YAMLParser.lift((advance(context), .string(unescapeSingleQuotes(foldFlow(m)))))

    default:
        return YAMLParser.fail(error("expected string")(context))
    }
}

private func parseBlockMapOrString(_ context: Context) -> YAMLResult<ContextValue> {
    let match = peekMatch(context)
    // should spaces before colon be ignored?
    return context.tokens[1].type != .colon || YAMLParser.YAMLExp.matches(match, regex: YAMLParser.YAMLExp.regex("\n"))
    ? parseString(context)
    : parseBlockMap(context)
}

private func foldBlock(_ block: String) -> String {
    let (body, trail) = block |> YAMLParser.YAMLExp.splitTrail(YAMLParser.YAMLExp.regex("\\n*$"))
    return (body
            |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^([^ \\t\\n].*)\\n(?=[^ \\t\\n])", options: "m"), template: "$1 ")
            |> YAMLParser.YAMLExp.replace(
                YAMLParser.YAMLExp.regex("^([^ \\t\\n].*)\\n(\\n+)(?![ \\t])", options: "m"), template: "$1$2")
    ) + trail
}

private func foldFlow(_ flow: String) -> String {
    let (lead, rest) = flow |> YAMLParser.YAMLExp.splitLead(YAMLParser.YAMLExp.regex("^[ \\t]+"))
    let (body, trail) = rest |> YAMLParser.YAMLExp.splitTrail(YAMLParser.YAMLExp.regex("[ \\t]+$"))
    let folded = body
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^[ \\t]+|[ \\t]+$|\\\\\\n", options: "m"), template: "")
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("(^|.)\\n(?=.|$)"), template: "$1 ")
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("(.)\\n(\\n+)"), template: "$1$2")
    return lead + folded + trail
}

private func count(string: String) -> Int {
    string.count
}

private func parseliteral(_ context: Context) -> YAMLResult<ContextValue> {
    let literal = peekMatch(context)
    let blockContext = advance(context)
    let chomps = ["-": -1, "+": 1]
    let chomp = chomps[literal |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("[^-+]"), template: "")] ?? 0
    let indent = parseInt(literal |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("[^1-9]"), template: ""), radix: 10)
    let headerPattern = YAMLParser.YAMLExp.regex("^(\\||>)([1-9][-+]|[-+]?[1-9]?)( |$)")
    let error0 = "invalid chomp or indent header"
    let c = YAMLParser.`guard`(error(error0)(context),
                             check: YAMLParser.YAMLExp.matches(literal, regex: headerPattern!))
    >>| YAMLParser.lift(blockContext)
    >>=- expect(.string, message: "expected scalar block")
    let block = peekMatch(blockContext)
    |> normalizeBreaks
    let (lead, _) = block
    |> YAMLParser.YAMLExp.splitLead(YAMLParser.YAMLExp.regex("^( *\\n)* {1,}(?! |\\n|$)"))
    let foundindent = lead
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^( *\\n)*"), template: "")
    |> count
    let effectiveindent = indent > 0 ? indent : foundindent
    let invalidPattern =
    YAMLParser.YAMLExp.regex("^( {0,\(effectiveindent)}\\n)* {\(effectiveindent + 1),}\\n")
    let check1 = YAMLParser.YAMLExp.matches(block, regex: invalidPattern!)
    let check2 = indent > 0 && foundindent < indent
    let trimmed = block
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^ {0,\(effectiveindent)}"), template: "")
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\\n {0,\(effectiveindent)}"), template: "\n")
    |> (chomp == -1
        ? YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("(\\n *)*$"), template: "")
        : chomp == 0
        ? YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("(?=[^ ])(\\n *)*$"), template: "\n")
        : { s in s }
    )
    let error1 = "leading all-space line must not have too many spaces"
    let error2 = "less indented block scalar than the indicated level"
    return c
    >>| YAMLParser.`guard`(error(error1)(blockContext), check: !check1)
    >>| YAMLParser.`guard`(error(error2)(blockContext), check: !check2)
    >>| c
    >>- { context in (context, .string(trimmed))}
}


private func parseInt(_ string: String, radix: Int) -> Int {
    let (sign, str) = YAMLParser.YAMLExp.splitLead(YAMLParser.YAMLExp.regex("^[-+]"))(string)
    let multiplier = (sign == "-" ? -1 : 1)
    let ints = radix == 60
    ? toSexints(str)
    : toints(str)
    return multiplier * ints.reduce(0, { acc, i in acc * radix + i })
}

private func toSexints(_ string: String) -> [Int] {
    string.components(separatedBy: ":").map {
        c in Int(c) ?? 0
    }
}

private func toints(_ string: String) -> [Int] {
    string.unicodeScalars.map {
        c in
        switch c {
        case "0"..."9": return Int(c.value) - Int(("0" as UnicodeScalar).value)
        case "a"..."z": return Int(c.value) - Int(("a" as UnicodeScalar).value) + 10
        case "A"..."Z": return Int(c.value) - Int(("A" as UnicodeScalar).value) + 10
        default: fatalError("invalid digit \(c)")
        }
    }
}

private func normalizeBreaks(_ s: String) -> String {
    YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\\r\\n|\\r"), template: "\n")(s)
}

private func unwrapQuotedString(_ s: String) -> String {
    String(s[s.index(after: s.startIndex)..<s.index(before: s.endIndex)])
}

private func unescapeSingleQuotes(_ s: String) -> String {
    YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("''"), template: "'")(s)
}

private func unescapeDoubleQuotes(_ input: String) -> String {
    input
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\\\\([0abtnvfre \"\\/N_LP])"))
    { escapeCharacters[$0[1]] ?? "" }
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\\\\x([0-9A-Fa-f]{2})"))
    { String(describing: UnicodeScalar(parseInt($0[1], radix: 16))) }
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\\\\u([0-9A-Fa-f]{4})"))
    { String(describing: UnicodeScalar(parseInt($0[1], radix: 16))) }
    |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\\\\U([0-9A-Fa-f]{8})"))
    { String(describing: UnicodeScalar(parseInt($0[1], radix: 16))) }
}

private let escapeCharacters = [
    "0": "\0",
    "a": "\u{7}",
    "b": "\u{8}",
    "t": "\t",
    "n": "\n",
    "v": "\u{B}",
    "f": "\u{C}",
    "r": "\r",
    "e": "\u{1B}",
    " ": " ",
    "\"": "\"",
    "\\": "\\",
    "/": "/",
    "N": "\u{85}",
    "_": "\u{A0}",
    "L": "\u{2028}",
    "P": "\u{2029}"
]


private let invalidOptionsPattern = try! NSRegularExpression(pattern: "[^ixsm]", options: [])

private let regexOptions: [Character: NSRegularExpression.Options] = [
    "i": .caseInsensitive,
    "x": .allowCommentsAndWhitespace,
    "s": .dotMatchesLineSeparators,
    "m": .anchorsMatchLines
]

private extension YAMLParser {
    struct YAMLExp {
        static func matchRange(_ string: String, regex: NSRegularExpression) -> NSRange {
            let sr = NSMakeRange(0, string.utf16.count)
            return regex.rangeOfFirstMatch(in: string, options: [], range: sr)
        }

        static func matches(_ string: String, regex: NSRegularExpression) -> Bool {
            return matchRange(string, regex: regex).location != NSNotFound
        }

        static func regex(_ pattern: String, options: String = "") -> NSRegularExpression! {
            if matches(options, regex: invalidOptionsPattern) {
                return nil
            }

            let opts = options.reduce(NSRegularExpression.Options()) { (acc, opt) -> NSRegularExpression.Options in
                return NSRegularExpression.Options(rawValue:acc.rawValue | (regexOptions[opt] ?? NSRegularExpression.Options()).rawValue)
            }
            return try? NSRegularExpression(pattern: pattern, options: opts)
        }

        static func replace(_ regex: NSRegularExpression, template: String) -> (String) -> String {
            { string in
                let s = NSMutableString(string: string)
                let range = NSMakeRange(0, string.utf16.count)
                _ = regex.replaceMatches(in: s, options: [], range: range,
                                         withTemplate: template)
#if os(Linux) || os(Android)
                return s._bridgeToSwift()
#else
                return s as String
#endif
            }
        }

        static func replace(_ regex: NSRegularExpression, block: @escaping ([String]) -> String) -> (String) -> String {
            { string in
                let s = NSMutableString(string: string)
                let range = NSMakeRange(0, string.utf16.count)
                var offset = 0
                regex.enumerateMatches(in: string, options: [], range: range) {
                    result, _, _ in
                    if let result = result {
                        var captures = [String](repeating: "", count: result.numberOfRanges)
                        for i in 0..<result.numberOfRanges {
                            let rangeAt = result.range(at: i)
                            if let r = Range(rangeAt) {
                                captures[i] = NSString(string: string).substring(with: NSRange(r))
                            }
                        }
                        let replacement = block(captures)
                        let offR = NSMakeRange(result.range.location + offset, result.range.length)
                        offset += replacement.count - result.range.length
                        s.replaceCharacters(in: offR, with: replacement)
                    }
                }
#if os(Linux) || os(Android)
                return s._bridgeToSwift()
#else
                return s as String
#endif
            }
        }

        static func splitLead(_ regex: NSRegularExpression) -> (String) -> (String, String) {
            return { string in
                let r = matchRange(string, regex: regex)
                if r.location == NSNotFound {
                    return ("", string)
                } else {
                    let s = NSString(string: string)
                    let i = r.location + r.length
                    return (s.substring(to: i), s.substring(from: i))
                }
            }
        }

        static func splitTrail(_ regex: NSRegularExpression) -> (String) -> (String, String) {
            return { string in
                let r = matchRange(string, regex: regex)
                if r.location == NSNotFound {
                    return (string, "")
                } else {
                    let s = NSString(string: string)
                    let i = r.location
                    return (s.substring(to: i), s.substring(from: i))
                }
            }
        }

        static func substring(_ range: NSRange, _ string : String ) -> String {
            return NSString(string: string).substring(with: range)
        }

        static func substring(_ index: Int, _ string: String ) -> String {
            return NSString(string: string).substring(from: index)
        }
    }

}

private enum YAMLResult<T> {
    case error(String)
    case value(T)

    var error: String? {
        switch self {
        case .error(let e): return e
        case .value: return nil
        }
    }

    var value: T? {
        switch self {
        case .error: return nil
        case .value(let v): return v
        }
    }

    func map <U> (f: (T) -> U) -> YAMLResult<U> {
        switch self {
        case .error(let e): return .error(e)
        case .value(let v): return .value(f(v))
        }
    }

    func flatMap <U> (f: (T) -> YAMLResult<U>) -> YAMLResult<U> {
        switch self {
        case .error(let e): return .error(e)
        case .value(let v): return f(v)
        }
    }
}

private extension YAMLParser  {
    static func lift <V>(_ v: V) -> YAMLResult<V> { .value(v) }
    static func fail <T>(_ e: String) -> YAMLResult<T> { .error(e) }
    static func join <T>(_ x: YAMLResult<YAMLResult<T>>) -> YAMLResult<T> { x >>=- { i in i } }
    static func `guard`(_ error: @autoclosure() -> String, check: Bool) -> YAMLResult<()> { check ? lift(()) : .error(error()) }
}

private extension YAML {
    enum TokenType: String {
        case yamlDirective = "%YAML"
        case docStart = "doc-start"
        case docend = "doc-end"
        case comment = "comment"
        case space = "space"
        case newLine = "newline"
        case indent = "indent"
        case dedent = "dedent"
        case null = "null"
        case _true = "true"
        case _false = "false"
        case infinityP = "+infinity"
        case infinityN = "-infinity"
        case nan = "nan"
        case double = "double"
        case int = "int"
        case intOct = "int-oct"
        case intHex = "int-hex"
        case intSex = "int-sex"
        case anchor = "&"
        case alias = "*"
        case comma = ","
        case openSB = "["
        case closeSB = "]"
        case dash = "-"
        case openCB = "{"
        case closeCB = "}"
        case key = "key"
        case keyDQ = "key-dq"
        case keySQ = "key-sq"
        case questionMark = "?"
        case colonFO = ":-flow-out"
        case colonFI = ":-flow-in"
        case colon = ":"
        case literal = "|"
        case folded = ">"
        case reserved = "reserved"
        case stringDQ = "string-dq"
        case stringSQ = "string-sq"
        case stringFI = "string-flow-in"
        case stringFO = "string-flow-out"
        case string = "string"
        case end = "end"
    }
}

private typealias TokenPattern = (type: YAML.TokenType, pattern: NSRegularExpression)

private let bBreak = "(?:\\r\\n|\\r|\\n)"

// printable non-space chars,
// except `:`(3a), `#`(23), `,`(2c), `[`(5b), `]`(5d), `{`(7b), `}`(7d)
private let safeIn = "\\x21\\x22\\x24-\\x2b\\x2d-\\x39\\x3b-\\x5a\\x5c\\x5e-\\x7a" +
"\\x7c\\x7e\\x85\\xa0-\\ud7ff\\ue000-\\ufefe\\uff00\\ufffd" +
"\\U00010000-\\U0010ffff"
// with flow indicators: `,`, `[`, `]`, `{`, `}`
private let safeOut = "\\x2c\\x5b\\x5d\\x7b\\x7d" + safeIn
private let plainOutPattern =
"([\(safeOut)]#|:(?![ \\t]|\(bBreak))|[\(safeOut)]|[ \\t])+"
private let plainInPattern =
"([\(safeIn)]#|:(?![ \\t]|\(bBreak))|[\(safeIn)]|[ \\t]|\(bBreak))+"
private let dashPattern = YAMLParser.YAMLExp.regex("^-([ \\t]+(?!#|\(bBreak))|(?=[ \\t\\n]))")
private let finish = "(?= *(,|\\]|\\}|( #.*)?(\(bBreak)|$)))"


private let tokenPatterns: [TokenPattern] = [
    (.yamlDirective, YAMLParser.YAMLExp.regex("^%YAML(?= )")),
    (.docStart, YAMLParser.YAMLExp.regex("^---")),
    (.docend, YAMLParser.YAMLExp.regex("^\\.\\.\\.")),
    (.comment, YAMLParser.YAMLExp.regex("^#.*|^\(bBreak) *(#.*)?(?=\(bBreak)|$)")),
    (.space, YAMLParser.YAMLExp.regex("^ +")),
    (.newLine, YAMLParser.YAMLExp.regex("^\(bBreak) *")),
    (.dash, dashPattern!),
    (.null, YAMLParser.YAMLExp.regex("^(null|Null|NULL|~)\(finish)")),
    (._true, YAMLParser.YAMLExp.regex("^(true|True|TRUE)\(finish)")),
    (._false, YAMLParser.YAMLExp.regex("^(false|False|FALSE)\(finish)")),
    (.infinityP, YAMLParser.YAMLExp.regex("^\\+?\\.(inf|Inf|INF)\(finish)")),
    (.infinityN, YAMLParser.YAMLExp.regex("^-\\.(inf|Inf|INF)\(finish)")),
    (.nan, YAMLParser.YAMLExp.regex("^\\.(nan|NaN|NAN)\(finish)")),
    (.int, YAMLParser.YAMLExp.regex("^[-+]?[0-9]+\(finish)")),
    (.intOct, YAMLParser.YAMLExp.regex("^0o[0-7]+\(finish)")),
    (.intHex, YAMLParser.YAMLExp.regex("^0x[0-9a-fA-F]+\(finish)")),
    (.intSex, YAMLParser.YAMLExp.regex("^[0-9]{2}(:[0-9]{2})+\(finish)")),
    (.double, YAMLParser.YAMLExp.regex("^[-+]?(\\.[0-9]+|[0-9]+(\\.[0-9]*)?)([eE][-+]?[0-9]+)?\(finish)")),
    (.anchor, YAMLParser.YAMLExp.regex("^&\\w+")),
    (.alias, YAMLParser.YAMLExp.regex("^\\*\\w+")),
    (.comma, YAMLParser.YAMLExp.regex("^,")),
    (.openSB, YAMLParser.YAMLExp.regex("^\\[")),
    (.closeSB, YAMLParser.YAMLExp.regex("^\\]")),
    (.openCB, YAMLParser.YAMLExp.regex("^\\{")),
    (.closeCB, YAMLParser.YAMLExp.regex("^\\}")),
    (.questionMark, YAMLParser.YAMLExp.regex("^\\?( +|(?=\(bBreak)))")),
    (.colonFO, YAMLParser.YAMLExp.regex("^:(?!:)")),
    (.colonFI, YAMLParser.YAMLExp.regex("^:(?!:)")),
    (.literal, YAMLParser.YAMLExp.regex("^\\|.*")),
    (.folded, YAMLParser.YAMLExp.regex("^>.*")),
    (.reserved, YAMLParser.YAMLExp.regex("^[@`]")),
    (.stringDQ, YAMLParser.YAMLExp.regex("^\"([^\\\\\"]|\\\\(.|\(bBreak)))*\"")),
    (.stringSQ, YAMLParser.YAMLExp.regex("^'([^']|'')*'")),
    (.stringFO, YAMLParser.YAMLExp.regex("^\(plainOutPattern)(?=:([ \\t]|\(bBreak))|\(bBreak)|$)")),
    (.stringFI, YAMLParser.YAMLExp.regex("^\(plainInPattern)")),
]

private extension YAMLParser {
    typealias TokenMatch = (type: YAML.TokenType, match: String)

    static func escapeErrorContext(_ text: String) -> String {
        let endIndex = text.index(text.startIndex, offsetBy: 50, limitedBy: text.endIndex) ?? text.endIndex
        let escaped = String(text[..<endIndex])
        |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\\r"), template: "\\\\r")
        |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\\n"), template: "\\\\n")
        |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\""), template: "\\\\\"")
        return "near \"\(escaped)\""
    }

    static func tokenize(_ text: String) -> YAMLResult<[TokenMatch]> {
        var text = text
        var matchList: [TokenMatch] = []
        var indents = [0]
        var insideFlow = 0
    next:
        while text.endIndex > text.startIndex {
            for tokenPattern in tokenPatterns {
                let range = YAMLParser.YAMLExp.matchRange(text, regex: tokenPattern.pattern)
                if range.location != NSNotFound {
                    let rangeEnd = range.location + range.length
                    switch tokenPattern.type {

                    case .newLine:
                        let match = (range, text) |> YAMLParser.YAMLExp.substring
                        let lastindent = indents.last ?? 0
                        let rest = match[match.index(after: match.startIndex)...]
                        let spaces = rest.count
                        let nestedBlockSequence =
                        YAMLParser.YAMLExp.matches((rangeEnd, text) |> YAMLParser.YAMLExp.substring, regex: dashPattern!)
                        if spaces == lastindent {
                            matchList.append(TokenMatch(.newLine, match))
                        } else if spaces > lastindent {
                            if insideFlow == 0 {
                                if matchList.last != nil &&
                                    matchList[matchList.endIndex - 1].type == .indent {
                                    indents[indents.endIndex - 1] = spaces
                                    matchList[matchList.endIndex - 1] = TokenMatch(.indent, match)
                                } else {
                                    indents.append(spaces)
                                    matchList.append(TokenMatch(.indent, match))
                                }
                            }
                        } else if nestedBlockSequence && spaces == lastindent - 1 {
                            matchList.append(TokenMatch(.newLine, match))
                        } else {
                            while nestedBlockSequence && spaces < (indents.last ?? 0) - 1
                                    || !nestedBlockSequence && spaces < indents.last ?? 0 {
                                indents.removeLast()
                                matchList.append(TokenMatch(.dedent, ""))
                            }
                            matchList.append(TokenMatch(.newLine, match))
                        }

                    case .dash, .questionMark:
                        let match = (range, text) |> YAMLParser.YAMLExp.substring
                        let index = match.index(after: match.startIndex)
                        let indent = match.count
                        indents.append((indents.last ?? 0) + indent)
                        matchList.append(
                            TokenMatch(tokenPattern.type, String(match[..<index])))
                        matchList.append(TokenMatch(.indent, String(match[index...])))

                    case .colonFO:
                        if insideFlow > 0 {
                            continue
                        }
                        fallthrough

                    case .colonFI:
                        let match = (range, text) |> YAMLParser.YAMLExp.substring
                        matchList.append(TokenMatch(.colon, match))
                        if insideFlow == 0 {
                            indents.append((indents.last ?? 0) + 1)
                            matchList.append(TokenMatch(.indent, ""))
                        }

                    case .openSB, .openCB:
                        insideFlow += 1
                        matchList.append(TokenMatch(tokenPattern.type, (range, text) |> YAMLParser.YAMLExp.substring))

                    case .closeSB, .closeCB:
                        insideFlow -= 1
                        matchList.append(TokenMatch(tokenPattern.type, (range, text) |> YAMLParser.YAMLExp.substring))

                    case .literal, .folded:
                        matchList.append(TokenMatch(tokenPattern.type, (range, text) |> YAMLParser.YAMLExp.substring))
                        text = (rangeEnd, text) |> YAMLParser.YAMLExp.substring
                        let lastindent = indents.last ?? 0
                        let minindent = 1 + lastindent
                        let blockPattern = YAMLParser.YAMLExp.regex(("^(\(bBreak) *)*(\(bBreak)" +
                                                             "( {\(minindent),})[^ ].*(\(bBreak)( *|\\3.*))*)(?=\(bBreak)|$)"))
                        let (lead, rest) = text |> YAMLParser.YAMLExp.splitLead(blockPattern!)
                        text = rest
                        let block = (lead
                                     |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^\(bBreak)"), template: "")
                                     |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^ {0,\(lastindent)}"), template: "")
                                     |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("\(bBreak) {0,\(lastindent)}"), template: "\n")
                        ) + (YAMLParser.YAMLExp.matches(text, regex: YAMLParser.YAMLExp.regex("^\(bBreak)")) && lead.endIndex > lead.startIndex
                             ? "\n" : "")
                        matchList.append(TokenMatch(.string, block))
                        continue next

                    case .stringFO:
                        if insideFlow > 0 {
                            continue
                        }
                        let indent = (indents.last ?? 0)
                        let blockPattern = YAMLParser.YAMLExp.regex(("^\(bBreak)( *| {\(indent),}" +
                                                             "\(plainOutPattern))(?=\(bBreak)|$)"))
                        var block = (range, text)
                        |> YAMLParser.YAMLExp.substring
                        |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^[ \\t]+|[ \\t]+$"), template: "")
                        text = (rangeEnd, text) |> YAMLParser.YAMLExp.substring
                        while true {
                            let range = YAMLParser.YAMLExp.matchRange(text, regex: blockPattern!)
                            if range.location == NSNotFound {
                                break
                            }
                            let s = (range, text) |> YAMLParser.YAMLExp.substring
                            block += "\n" +
                            YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^\(bBreak)[ \\t]*|[ \\t]+$"), template: "")(s)
                            text = (range.location + range.length, text) |> YAMLParser.YAMLExp.substring
                        }
                        matchList.append(TokenMatch(.string, block))
                        continue next

                    case .stringFI:
                        let match = (range, text)
                        |> YAMLParser.YAMLExp.substring
                        |> YAMLParser.YAMLExp.replace(YAMLParser.YAMLExp.regex("^[ \\t]|[ \\t]$"), template: "")
                        matchList.append(TokenMatch(.string, match))

                    case .reserved:
                        return fail(escapeErrorContext(text))

                    default:
                        matchList.append(TokenMatch(tokenPattern.type, (range, text) |> YAMLParser.YAMLExp.substring))
                    }
                    text = (rangeEnd, text) |> YAMLParser.YAMLExp.substring
                    continue next
                }
            }
            return fail(escapeErrorContext(text))
        }
        while indents.count > 1 {
            indents.removeLast()
            matchList.append((.dedent, ""))
        }
        matchList.append((.end, ""))
        return lift(matchList)
    }
}


// MARK: Parser Operators

precedencegroup Functional {
    associativity: left
    higherThan: DefaultPrecedence
}

infix operator <*>: Functional
private func <*> <T, U> (f: YAMLResult<(T) -> U>, x: YAMLResult<T>) -> YAMLResult<U> {
    switch (x, f) {
    case (.error(let e), _): return .error(e)
    case (.value, .error(let e)): return .error(e)
    case (.value(let x), .value(let f)): return . value(f(x))
    }
}

infix operator <^>: Functional
private func <^> <T, U> (f: (T) -> U, x: YAMLResult<T>) -> YAMLResult<U> { x.map(f: f) }

infix operator >>-: Functional
private func >>- <T, U> (x: YAMLResult<T>, f: (T) -> U) -> YAMLResult<U> { x.map(f: f) }

infix operator >>=-: Functional
private func >>=- <T, U> (x: YAMLResult<T>, f: (T) -> YAMLResult<U>) -> YAMLResult<U> { x.flatMap(f: f) }

infix operator >>|: Functional
private func >>| <T, U> (x: YAMLResult<T>, y: YAMLResult<U>) -> YAMLResult<U> { x.flatMap { _ in y } }

infix operator |>: Functional
private func |> <T, U> (x: T, f: (T) -> U) -> U { f(x) }
