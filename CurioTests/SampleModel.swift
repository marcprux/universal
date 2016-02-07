import BricBrac


public struct SampleModel : Bricable, Bracable, Breqable {
    public var allOfField: AllOfField
    public var anyOfField: AnyOfField
    public var oneOfField: OneOfField
    public var notField: NotField
    /// Should generate a simple OneOf enum
    public var simpleOneOf: Optional<SimpleOneOf>

    public init(allOfField: AllOfField, anyOfField: AnyOfField, oneOfField: OneOfField, notField: NotField, simpleOneOf: Optional<SimpleOneOf> = nil) {
        self.allOfField = allOfField 
        self.anyOfField = anyOfField 
        self.oneOfField = oneOfField 
        self.notField = notField 
        self.simpleOneOf = simpleOneOf 
    }

    public func bric() -> Bric {
        return Bric(obj: [ 
        Keys.allOfField: allOfField.bric(), 
        Keys.anyOfField: anyOfField.bric(), 
        Keys.oneOfField: oneOfField.bric(), 
        Keys.notField: notField.bric(), 
        Keys.simpleOneOf: simpleOneOf.bric(), 
        ]) 
    }

    public static func brac(bric: Bric) throws -> SampleModel {
        return try SampleModel( 
        allOfField: bric.bracKey(Keys.allOfField), 
        anyOfField: bric.bracKey(Keys.anyOfField), 
        oneOfField: bric.bracKey(Keys.oneOfField), 
        notField: bric.bracKey(Keys.notField), 
        simpleOneOf: bric.bracKey(Keys.simpleOneOf) 
        ) 
    }

    public func breq(other: SampleModel) -> Bool {
        return allOfField.breq(other.allOfField) 
            && anyOfField.breq(other.anyOfField) 
            && oneOfField.breq(other.oneOfField) 
            && notField.breq(other.notField) 
            && simpleOneOf.breq(other.simpleOneOf) 
    }

    public enum Keys : String {
        case allOfField = "allOfField"
        case anyOfField = "anyOfField"
        case oneOfField = "oneOfField"
        case notField = "notField"
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
            FirstAll.brac(bric), 
            SecondAll.brac(bric) 
            ) 
        }

        public func breq(other: SampleModel.AllOfField) -> Bool {
            return p0.breq(other.p0) && 
            p1.breq(other.p1) 
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
                a1: bric.bracKey(Keys.a1), 
                a2: bric.bracKey(Keys.a2) 
                ) 
            }

            public func breq(other: SampleModel.AllOfField.FirstAll) -> Bool {
                return a1.breq(other.a1) 
                    && a2.breq(other.a2) 
            }

            public enum Keys : String {
                case a1 = "a1"
                case a2 = "a2"
            }
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
                a3: bric.bracKey(Keys.a3), 
                a4: bric.bracKey(Keys.a4) 
                ) 
            }

            public func breq(other: SampleModel.AllOfField.SecondAll) -> Bool {
                return a3.breq(other.a3) 
                    && a4.breq(other.a4) 
            }

            public enum Keys : String {
                case a3 = "a3"
                case a4 = "a4"
            }
        }
    }

    public enum AnyOfField : Bricable, Bracable, Breqable {
        case FirstAnyCase(FirstAny)
        case SecondAnyCase(SecondAny)

        public init(_ arg: FirstAny) {
            self = .FirstAnyCase(arg) 
        }

        public init(_ arg: SecondAny) {
            self = .SecondAnyCase(arg) 
        }

        public func bric() -> Bric {
            switch self { 
            case .FirstAnyCase(let x): return x.bric() 
            case .SecondAnyCase(let x): return x.bric() 
            } 
        }

        public static func brac(bric: Bric) throws -> SampleModel.AnyOfField {
            return try bric.bracOne([ 
            { try .FirstAnyCase(FirstAny.brac(bric)) }, 
            { try .SecondAnyCase(SecondAny.brac(bric)) }, 
            ]) 
        }

        public func breq(other: SampleModel.AnyOfField) -> Bool {
            switch (self, other) { 
            case let (.FirstAnyCase(lhs), .FirstAnyCase(rhs)): return lhs.breq(rhs) 
            case let (.SecondAnyCase(lhs), .SecondAnyCase(rhs)): return lhs.breq(rhs) 
            default: return false 
            } 
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
                b1: bric.bracKey(Keys.b1), 
                b2: bric.bracKey(Keys.b2) 
                ) 
            }

            public func breq(other: SampleModel.AnyOfField.FirstAny) -> Bool {
                return b1.breq(other.b1) 
                    && b2.breq(other.b2) 
            }

            public enum Keys : String {
                case b1 = "b1"
                case b2 = "b2"
            }
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
                b3: bric.bracKey(Keys.b3), 
                b4: bric.bracKey(Keys.b4) 
                ) 
            }

            public func breq(other: SampleModel.AnyOfField.SecondAny) -> Bool {
                return b3.breq(other.b3) 
                    && b4.breq(other.b4) 
            }

            public enum Keys : String {
                case b3 = "b3"
                case b4 = "b4"
            }
        }
    }

    public enum OneOfField : Bricable, Bracable, Breqable {
        case FirstOneCase(FirstOne)
        case SecondOneCase(SecondOne)

        public init(_ arg: FirstOne) {
            self = .FirstOneCase(arg) 
        }

        public init(_ arg: SecondOne) {
            self = .SecondOneCase(arg) 
        }

        public func bric() -> Bric {
            switch self { 
            case .FirstOneCase(let x): return x.bric() 
            case .SecondOneCase(let x): return x.bric() 
            } 
        }

        public static func brac(bric: Bric) throws -> SampleModel.OneOfField {
            return try bric.bracOne([ 
            { try .FirstOneCase(FirstOne.brac(bric)) }, 
            { try .SecondOneCase(SecondOne.brac(bric)) }, 
            ]) 
        }

        public func breq(other: SampleModel.OneOfField) -> Bool {
            switch (self, other) { 
            case let (.FirstOneCase(lhs), .FirstOneCase(rhs)): return lhs.breq(rhs) 
            case let (.SecondOneCase(lhs), .SecondOneCase(rhs)): return lhs.breq(rhs) 
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
                c1: bric.bracKey(Keys.c1), 
                c2: bric.bracKey(Keys.c2) 
                ) 
            }

            public func breq(other: SampleModel.OneOfField.FirstOne) -> Bool {
                return c1.breq(other.c1) 
                    && c2.breq(other.c2) 
            }

            public enum Keys : String {
                case c1 = "c1"
                case c2 = "c2"
            }
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
                c3: bric.bracKey(Keys.c3), 
                c4: bric.bracKey(Keys.c4) 
                ) 
            }

            public func breq(other: SampleModel.OneOfField.SecondOne) -> Bool {
                return c3.breq(other.c3) 
                    && c4.breq(other.c4) 
            }

            public enum Keys : String {
                case c3 = "c3"
                case c4 = "c4"
            }
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
            P0.brac(bric), 
            P1.brac(bric) 
            ) 
        }

        public func breq(other: SampleModel.NotField) -> Bool {
            return p0.breq(other.p0) && 
            p1.breq(other.p1) 
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
                str: bric.bracKey(Keys.str) 
                ) 
            }

            public func breq(other: SampleModel.NotField.P0) -> Bool {
                return str.breq(other.str) 
            }

            public enum Keys : String {
                case str = "str"
            }
        }

        public typealias P1 = NotBrac<NotP1>
        public struct NotP1 : Bricable, Bracable, Breqable {
            public var str: Str

            public init(str: Str = .Illegal) {
                self.str = str 
            }

            public func bric() -> Bric {
                return Bric(obj: [ 
                Keys.str: str.bric(), 
                ]) 
            }

            public static func brac(bric: Bric) throws -> SampleModel.NotField.NotP1 {
                return try SampleModel.NotField.NotP1( 
                str: bric.bracKey(Keys.str) 
                ) 
            }

            public func breq(other: SampleModel.NotField.NotP1) -> Bool {
                return str.breq(other.str) 
            }

            public enum Keys : String {
                case str = "str"
            }

            public enum Str : String, Bricable, Bracable, Breqable {
                case Illegal = "illegal"
            }
        }
    }

    /// Should generate a simple OneOf enum
    public typealias SimpleOneOf = OneOf2<String, Double>
}
