import BricBrac


public struct SampleModel : Bricable, Bracable, Breqable {
    public var allOfField: AllOfField
    public var anyOfField: AnyOfField
    public var oneOfField: OneOfField
    public var notField: NotField
    /// Should not escape keyword arguments
    public var keywordFields: Optional<KeywordFields>
    public var list: Optional<Array<ListItem>>
    public var nested1: Optional<Nested1>
    /// Should generate a simple OneOf enum
    public var simpleOneOf: Optional<SimpleOneOfChoice>

    public init(allOfField: AllOfField, anyOfField: AnyOfField, oneOfField: OneOfField, notField: NotField, keywordFields: Optional<KeywordFields> = nil, list: Optional<Array<ListItem>> = nil, nested1: Optional<Nested1> = nil, simpleOneOf: Optional<SimpleOneOfChoice> = nil) {
        self.allOfField = allOfField 
        self.anyOfField = anyOfField 
        self.oneOfField = oneOfField 
        self.notField = notField 
        self.keywordFields = keywordFields 
        self.list = list 
        self.nested1 = nested1 
        self.simpleOneOf = simpleOneOf 
    }

    public func bric() -> Bric {
        return Bric(obj: [ 
        Keys.allOfField: allOfField.bric(), 
        Keys.anyOfField: anyOfField.bric(), 
        Keys.oneOfField: oneOfField.bric(), 
        Keys.notField: notField.bric(), 
        Keys.keywordFields: keywordFields.bric(), 
        Keys.list: list.bric(), 
        Keys.nested1: nested1.bric(), 
        Keys.simpleOneOf: simpleOneOf.bric(), 
        ]) 
    }

    public static func brac(bric: Bric) throws -> SampleModel {
        return try SampleModel( 
        allOfField: bric.brac(key: Keys.allOfField), 
        anyOfField: bric.brac(key: Keys.anyOfField), 
        oneOfField: bric.brac(key: Keys.oneOfField), 
        notField: bric.brac(key: Keys.notField), 
        keywordFields: bric.brac(key: Keys.keywordFields), 
        list: bric.brac(key: Keys.list), 
        nested1: bric.brac(key: Keys.nested1), 
        simpleOneOf: bric.brac(key: Keys.simpleOneOf) 
        ) 
    }

    public func breq(_ other: SampleModel) -> Bool {
        return allOfField.breq(other.allOfField) 
            && anyOfField.breq(other.anyOfField) 
            && keywordFields.breq(other.keywordFields) 
            && nested1.breq(other.nested1) 
            && notField.breq(other.notField) 
            && oneOfField.breq(other.oneOfField) 
            && list.breq(other.list) 
            && simpleOneOf.breq(other.simpleOneOf) 
    }

    public enum Keys : String {
        case allOfField = "allOfField"
        case anyOfField = "anyOfField"
        case oneOfField = "oneOfField"
        case notField = "notField"
        case keywordFields = "keywordFields"
        case list = "list"
        case nested1 = "nested1"
        case simpleOneOf = "simpleOneOf"
    }

    public struct AllOfField : Bricable, Bracable, Breqable {
        /// FirstAll
        public var p0: FirstAll
        /// SecondAll
        public var p1: SecondAll

        public init(_ p0: FirstAll, _ p1: SecondAll) {
            self.p0 = p0 
            self.p1 = p1 
        }

        public func bric() -> Bric {
            return Bric(merge: [ 
            p0.bric(), 
            p1.bric() 
            ]) 
        }

        public static func brac(bric: Bric) throws -> SampleModel.AllOfField {
            return try SampleModel.AllOfField( 
            FirstAll.brac(bric: bric), 
            SecondAll.brac(bric: bric) 
            ) 
        }

        public func breq(_ other: SampleModel.AllOfField) -> Bool {
            return p0.breq(other.p0) 
                && p1.breq(other.p1) 
        }

        /// FirstAll
        public struct FirstAll : Bricable, Bracable, Breqable {
            public var a1: Int
            public var a2: String

            public init(a1: Int, a2: String) {
                self.a1 = a1 
                self.a2 = a2 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.a1: a1.bric(), 
                Keys.a2: a2.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.AllOfField.FirstAll {
                return try SampleModel.AllOfField.FirstAll( 
                a1: bric.brac(key: Keys.a1), 
                a2: bric.brac(key: Keys.a2) 
                ) 
            }

            public func breq(_ other: SampleModel.AllOfField.FirstAll) -> Bool {
                return a1.breq(other.a1) 
                    && a2.breq(other.a2) 
            }

            public enum Keys : String {
                case a1 = "a1"
                case a2 = "a2"
            }

            public typealias BricState = (a1: Int, a2: String)
        }

        /// SecondAll
        public struct SecondAll : Bricable, Bracable, Breqable {
            public var a3: Bool
            public var a4: Double

            public init(a3: Bool, a4: Double) {
                self.a3 = a3 
                self.a4 = a4 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.a3: a3.bric(), 
                Keys.a4: a4.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.AllOfField.SecondAll {
                return try SampleModel.AllOfField.SecondAll( 
                a3: bric.brac(key: Keys.a3), 
                a4: bric.brac(key: Keys.a4) 
                ) 
            }

            public func breq(_ other: SampleModel.AllOfField.SecondAll) -> Bool {
                return a3.breq(other.a3) 
                    && a4.breq(other.a4) 
            }

            public enum Keys : String {
                case a3 = "a3"
                case a4 = "a4"
            }

            public typealias BricState = (a3: Bool, a4: Double)
        }

        public typealias BricState = (p0: FirstAll, p1: SecondAll)
    }

    public struct AnyOfField : Bricable, Bracable, Breqable {
        /// FirstAny
        public var p0: Optional<FirstAny>
        /// SecondAny
        public var p1: Optional<SecondAny>

        public init(_ p0: Optional<FirstAny> = nil, _ p1: Optional<SecondAny> = nil) {
            self.p0 = p0 
            self.p1 = p1 
        }

        public func bric() -> Bric {
            return Bric(merge: [ 
            p0.bric(), 
            p1.bric() 
            ]) 
        }

        public static func brac(bric: Bric) throws -> SampleModel.AnyOfField {
            let anyOf: (Optional<FirstAny>, Optional<SecondAny>) = try bric.brac(anyOf: FirstAny.brac, SecondAny.brac) 
            return SampleModel.AnyOfField( 
            anyOf.0,  
            anyOf.1 
            ) 
        }

        public func breq(_ other: SampleModel.AnyOfField) -> Bool {
            return p0.breq(other.p0) 
                && p1.breq(other.p1) 
        }

        /// FirstAny
        public struct FirstAny : Bricable, Bracable, Breqable {
            public var b1: Int
            public var b2: String

            public init(b1: Int, b2: String) {
                self.b1 = b1 
                self.b2 = b2 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.b1: b1.bric(), 
                Keys.b2: b2.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.AnyOfField.FirstAny {
                return try SampleModel.AnyOfField.FirstAny( 
                b1: bric.brac(key: Keys.b1), 
                b2: bric.brac(key: Keys.b2) 
                ) 
            }

            public func breq(_ other: SampleModel.AnyOfField.FirstAny) -> Bool {
                return b1.breq(other.b1) 
                    && b2.breq(other.b2) 
            }

            public enum Keys : String {
                case b1 = "b1"
                case b2 = "b2"
            }

            public typealias BricState = (b1: Int, b2: String)
        }

        /// SecondAny
        public struct SecondAny : Bricable, Bracable, Breqable {
            public var b3: Bool
            public var b4: Double

            public init(b3: Bool, b4: Double) {
                self.b3 = b3 
                self.b4 = b4 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.b3: b3.bric(), 
                Keys.b4: b4.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.AnyOfField.SecondAny {
                return try SampleModel.AnyOfField.SecondAny( 
                b3: bric.brac(key: Keys.b3), 
                b4: bric.brac(key: Keys.b4) 
                ) 
            }

            public func breq(_ other: SampleModel.AnyOfField.SecondAny) -> Bool {
                return b3.breq(other.b3) 
                    && b4.breq(other.b4) 
            }

            public enum Keys : String {
                case b3 = "b3"
                case b4 = "b4"
            }

            public typealias BricState = (b3: Bool, b4: Double)
        }

        public typealias BricState = (p0: Optional<FirstAny>, p1: Optional<SecondAny>)
    }

    public enum OneOfField : Bricable, Bracable, Breqable {
        case firstOneCase(FirstOne)
        case secondOneCase(SecondOne)

        public init(_ arg: FirstOne) {
            self = .firstOneCase(arg) 
        }

        public init(_ arg: SecondOne) {
            self = .secondOneCase(arg) 
        }

        public func bric() -> Bric {
            switch self { 
            case .firstOneCase(let x): return x.bric() 
            case .secondOneCase(let x): return x.bric() 
            } 
        }

        public static func brac(bric: Bric) throws -> SampleModel.OneOfField {
            return try bric.brac(oneOf: [ 
            { try .firstOneCase(FirstOne.brac(bric: bric)) }, 
            { try .secondOneCase(SecondOne.brac(bric: bric)) }, 
            ]) 
        }

        public func breq(_ other: SampleModel.OneOfField) -> Bool {
            switch (self, other) { 
            case let (.firstOneCase(lhs), .firstOneCase(rhs)): return lhs.breq(rhs) 
            case let (.secondOneCase(lhs), .secondOneCase(rhs)): return lhs.breq(rhs) 
            default: return false 
            } 
        }

        /// FirstOne
        public struct FirstOne : Bricable, Bracable, Breqable {
            public var c1: Int
            public var c2: String

            public init(c1: Int, c2: String) {
                self.c1 = c1 
                self.c2 = c2 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.c1: c1.bric(), 
                Keys.c2: c2.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.OneOfField.FirstOne {
                return try SampleModel.OneOfField.FirstOne( 
                c1: bric.brac(key: Keys.c1), 
                c2: bric.brac(key: Keys.c2) 
                ) 
            }

            public func breq(_ other: SampleModel.OneOfField.FirstOne) -> Bool {
                return c1.breq(other.c1) 
                    && c2.breq(other.c2) 
            }

            public enum Keys : String {
                case c1 = "c1"
                case c2 = "c2"
            }

            public typealias BricState = (c1: Int, c2: String)
        }

        /// SecondOne
        public struct SecondOne : Bricable, Bracable, Breqable {
            public var c3: Bool
            public var c4: Double

            public init(c3: Bool, c4: Double) {
                self.c3 = c3 
                self.c4 = c4 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.c3: c3.bric(), 
                Keys.c4: c4.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.OneOfField.SecondOne {
                return try SampleModel.OneOfField.SecondOne( 
                c3: bric.brac(key: Keys.c3), 
                c4: bric.brac(key: Keys.c4) 
                ) 
            }

            public func breq(_ other: SampleModel.OneOfField.SecondOne) -> Bool {
                return c3.breq(other.c3) 
                    && c4.breq(other.c4) 
            }

            public enum Keys : String {
                case c3 = "c3"
                case c4 = "c4"
            }

            public typealias BricState = (c3: Bool, c4: Double)
        }
    }

    public struct NotField : Bricable, Bracable, Breqable {
        public var p0: P0
        public var p1: P1

        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0 
            self.p1 = p1 
        }

        public func bric() -> Bric {
            return Bric(merge: [ 
            p0.bric(), 
            p1.bric() 
            ]) 
        }

        public static func brac(bric: Bric) throws -> SampleModel.NotField {
            return try SampleModel.NotField( 
            P0.brac(bric: bric), 
            P1.brac(bric: bric) 
            ) 
        }

        public func breq(_ other: SampleModel.NotField) -> Bool {
            return p0.breq(other.p0) 
                && p1.breq(other.p1) 
        }

        public struct P0 : Bricable, Bracable, Breqable {
            public var str: String

            public init(str: String) {
                self.str = str 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.str: str.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.NotField.P0 {
                return try SampleModel.NotField.P0( 
                str: bric.brac(key: Keys.str) 
                ) 
            }

            public func breq(_ other: SampleModel.NotField.P0) -> Bool {
                return str.breq(other.str) 
            }

            public enum Keys : String {
                case str = "str"
            }

            public typealias BricState = String
        }

        public typealias P1 = NotBrac<NotP1>
        public struct NotP1 : Bricable, Bracable, Breqable {
            public var str: Str

            public init(str: Str = .illegal) {
                self.str = str 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.str: str.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.NotField.NotP1 {
                return try SampleModel.NotField.NotP1( 
                str: bric.brac(key: Keys.str) 
                ) 
            }

            public func breq(_ other: SampleModel.NotField.NotP1) -> Bool {
                return str.breq(other.str) 
            }

            public enum Keys : String {
                case str = "str"
            }

            public enum Str : String, Bricable, Bracable, Breqable {
                case illegal = "illegal"
            }

            public typealias BricState = Str
        }

        public typealias BricState = (p0: P0, p1: P1)
    }

    /// Should not escape keyword arguments
    public struct KeywordFields : Bricable, Bracable, Breqable {
        public var `case`: Optional<String>
        public var `for`: Optional<String>
        public var `in`: Optional<String>
        public var `inout`: Optional<String>
        public var `let`: Optional<String>
        public var `var`: Optional<String>
        public var `while`: Optional<String>

        public init(`case`: Optional<String> = nil, `for`: Optional<String> = nil, `in`: Optional<String> = nil, `inout`: Optional<String> = nil, `let`: Optional<String> = nil, `var`: Optional<String> = nil, `while`: Optional<String> = nil) {
            self.`case` = `case` 
            self.`for` = `for` 
            self.`in` = `in` 
            self.`inout` = `inout` 
            self.`let` = `let` 
            self.`var` = `var` 
            self.`while` = `while` 
        }

        public func bric() -> Bric {
            return Bric(obj: [ 
            Keys.`case`: `case`.bric(), 
            Keys.`for`: `for`.bric(), 
            Keys.`in`: `in`.bric(), 
            Keys.`inout`: `inout`.bric(), 
            Keys.`let`: `let`.bric(), 
            Keys.`var`: `var`.bric(), 
            Keys.`while`: `while`.bric(), 
            ]) 
        }

        public static func brac(bric: Bric) throws -> SampleModel.KeywordFields {
            return try SampleModel.KeywordFields( 
            case: bric.brac(key: Keys.`case`), 
            for: bric.brac(key: Keys.`for`), 
            in: bric.brac(key: Keys.`in`), 
            `inout`: bric.brac(key: Keys.`inout`), 
            `let`: bric.brac(key: Keys.`let`), 
            `var`: bric.brac(key: Keys.`var`), 
            while: bric.brac(key: Keys.`while`) 
            ) 
        }

        public func breq(_ other: SampleModel.KeywordFields) -> Bool {
            return `case`.breq(other.`case`) 
                && `for`.breq(other.`for`) 
                && `in`.breq(other.`in`) 
                && `inout`.breq(other.`inout`) 
                && `let`.breq(other.`let`) 
                && `var`.breq(other.`var`) 
                && `while`.breq(other.`while`) 
        }

        public enum Keys : String {
            case `case` = "case"
            case `for` = "for"
            case `in` = "in"
            case `inout` = "inout"
            case `let` = "let"
            case `var` = "var"
            case `while` = "while"
        }

        public typealias BricState = (`case`: Optional<String>, `for`: Optional<String>, `in`: Optional<String>, `inout`: Optional<String>, `let`: Optional<String>, `var`: Optional<String>, `while`: Optional<String>)
    }

    public struct ListItem : Bricable, Bracable, Breqable {
        public var prop: Prop

        public init(prop: Prop = .value) {
            self.prop = prop 
        }

        public func bric() -> Bric {
            return Bric(obj: [ 
            Keys.prop: prop.bric(), 
            ]) 
        }

        public static func brac(bric: Bric) throws -> SampleModel.ListItem {
            return try SampleModel.ListItem( 
            prop: bric.brac(key: Keys.prop) 
            ) 
        }

        public func breq(_ other: SampleModel.ListItem) -> Bool {
            return prop.breq(other.prop) 
        }

        public enum Keys : String {
            case prop = "prop"
        }

        public enum Prop : String, Bricable, Bracable, Breqable {
            case value = "value"
        }

        public typealias BricState = Prop
    }

    public struct Nested1 : Bricable, Bracable, Breqable {
        public var nested2: Nested2

        public init(nested2: Nested2) {
            self.nested2 = nested2 
        }

        public func bric() -> Bric {
            return Bric(obj: [ 
            Keys.nested2: nested2.bric(), 
            ]) 
        }

        public static func brac(bric: Bric) throws -> SampleModel.Nested1 {
            return try SampleModel.Nested1( 
            nested2: bric.brac(key: Keys.nested2) 
            ) 
        }

        public func breq(_ other: SampleModel.Nested1) -> Bool {
            return nested2.breq(other.nested2) 
        }

        public enum Keys : String {
            case nested2 = "nested2"
        }

        public struct Nested2 : Bricable, Bracable, Breqable {
            public var nested3: Nested3

            public init(nested3: Nested3) {
                self.nested3 = nested3 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.nested3: nested3.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.Nested1.Nested2 {
                return try SampleModel.Nested1.Nested2( 
                nested3: bric.brac(key: Keys.nested3) 
                ) 
            }

            public func breq(_ other: SampleModel.Nested1.Nested2) -> Bool {
                return nested3.breq(other.nested3) 
            }

            public enum Keys : String {
                case nested3 = "nested3"
            }

            public struct Nested3 : Bricable, Bracable, Breqable {
                public var nested4: Nested4

                public init(nested4: Nested4) {
                    self.nested4 = nested4 
                }

                public func bric() -> Bric {
                    return Bric(obj: [ 
                    Keys.nested4: nested4.bric(), 
                    ]) 
                }

                public static func brac(bric: Bric) throws -> SampleModel.Nested1.Nested2.Nested3 {
                    return try SampleModel.Nested1.Nested2.Nested3( 
                    nested4: bric.brac(key: Keys.nested4) 
                    ) 
                }

                public func breq(_ other: SampleModel.Nested1.Nested2.Nested3) -> Bool {
                    return nested4.breq(other.nested4) 
                }

                public enum Keys : String {
                    case nested4 = "nested4"
                }

                public struct Nested4 : Bricable, Bracable, Breqable {
                    public var nested5: Nested5

                    public init(nested5: Nested5) {
                        self.nested5 = nested5 
                    }

                    public func bric() -> Bric {
                        return Bric(obj: [ 
                        Keys.nested5: nested5.bric(), 
                        ]) 
                    }

                    public static func brac(bric: Bric) throws -> SampleModel.Nested1.Nested2.Nested3.Nested4 {
                        return try SampleModel.Nested1.Nested2.Nested3.Nested4( 
                        nested5: bric.brac(key: Keys.nested5) 
                        ) 
                    }

                    public func breq(_ other: SampleModel.Nested1.Nested2.Nested3.Nested4) -> Bool {
                        return nested5.breq(other.nested5) 
                    }

                    public enum Keys : String {
                        case nested5 = "nested5"
                    }

                    public struct Nested5 : Bricable, Bracable, Breqable {
                        public var single: Single

                        public init(single: Single = .value) {
                            self.single = single 
                        }

                        public func bric() -> Bric {
                            return Bric(obj: [ 
                            Keys.single: single.bric(), 
                            ]) 
                        }

                        public static func brac(bric: Bric) throws -> SampleModel.Nested1.Nested2.Nested3.Nested4.Nested5 {
                            return try SampleModel.Nested1.Nested2.Nested3.Nested4.Nested5( 
                            single: bric.brac(key: Keys.single) 
                            ) 
                        }

                        public func breq(_ other: SampleModel.Nested1.Nested2.Nested3.Nested4.Nested5) -> Bool {
                            return single.breq(other.single) 
                        }

                        public enum Keys : String {
                            case single = "single"
                        }

                        public enum Single : String, Bricable, Bracable, Breqable {
                            case value = "value"
                        }

                        public typealias BricState = Single
                    }

                    public typealias BricState = Nested5
                }

                public typealias BricState = Nested4
            }

            public typealias BricState = Nested3
        }

        public typealias BricState = Nested2
    }

    /// Should generate a simple OneOf enum
    public typealias SimpleOneOfChoice = OneOf2<String, Double>

    public typealias BricState = (allOfField: AllOfField, anyOfField: AnyOfField, oneOfField: OneOfField, notField: NotField, keywordFields: Optional<KeywordFields>, list: Optional<Array<ListItem>>, nested1: Optional<Nested1>, simpleOneOf: Optional<SimpleOneOfChoice>)
}
