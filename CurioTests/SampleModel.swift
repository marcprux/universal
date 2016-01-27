import BricBrac

struct SampleModel : BricBrac {
    var allOfField: AllOfField
    var anyOfField: AnyOfField
    var oneOfField: OneOfField
    var notField: NotField

    init(allOfField: AllOfField, anyOfField: AnyOfField, oneOfField: OneOfField, notField: NotField) {
        self.allOfField = allOfField 
        self.anyOfField = anyOfField 
        self.oneOfField = oneOfField 
        self.notField = notField 
    }

    func bric() -> Bric {
        return Bric(object: [ 
        (Keys.allOfField, allOfField.bric()), 
        (Keys.anyOfField, anyOfField.bric()), 
        (Keys.oneOfField, oneOfField.bric()), 
        (Keys.notField, notField.bric()), 
        ]) 
    }

    static func brac(bric: Bric) throws -> SampleModel {
        return try SampleModel( 
        allOfField: bric.bracKey(Keys.allOfField), 
        anyOfField: bric.bracKey(Keys.anyOfField), 
        oneOfField: bric.bracKey(Keys.oneOfField), 
        notField: bric.bracKey(Keys.notField) 
        ) 
    }

    enum Keys : String {
        case allOfField = "allOfField"
        case anyOfField = "anyOfField"
        case oneOfField = "oneOfField"
        case notField = "notField"
    }

    struct AllOfField : BricBrac {
        /// FirstAll
        var p0: FirstAll
        /// SecondAll
        var p1: SecondAll

        init(_ p0: FirstAll, _ p1: SecondAll) {
            self.p0 = p0 
            self.p1 = p1 
        }

        func bric() -> Bric {
            return Bric(merge: [ 
            p0.bric(), 
            p1.bric(), 
            ]) 
        }

        static func brac(bric: Bric) throws -> SampleModel.AllOfField {
            return try SampleModel.AllOfField( 
            FirstAll.brac(bric), 
            SecondAll.brac(bric) 
            ) 
        }

        /// FirstAll
        struct FirstAll : BricBrac {
            var a1: Int
            var a2: String

            init(a1: Int, a2: String) {
                self.a1 = a1 
                self.a2 = a2 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.a1, a1.bric()), 
                (Keys.a2, a2.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.AllOfField.FirstAll {
                return try SampleModel.AllOfField.FirstAll( 
                a1: bric.bracKey(Keys.a1), 
                a2: bric.bracKey(Keys.a2) 
                ) 
            }

            enum Keys : String {
                case a1 = "a1"
                case a2 = "a2"
            }
        }

        /// SecondAll
        struct SecondAll : BricBrac {
            var a3: Bool
            var a4: Double

            init(a3: Bool, a4: Double) {
                self.a3 = a3 
                self.a4 = a4 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.a3, a3.bric()), 
                (Keys.a4, a4.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.AllOfField.SecondAll {
                return try SampleModel.AllOfField.SecondAll( 
                a3: bric.bracKey(Keys.a3), 
                a4: bric.bracKey(Keys.a4) 
                ) 
            }

            enum Keys : String {
                case a3 = "a3"
                case a4 = "a4"
            }
        }
    }

    enum AnyOfField : BricBrac {
        case FirstAnyCase(FirstAny)
        case SecondAnyCase(SecondAny)

        func bric() -> Bric {
            switch self { 
            case .FirstAnyCase(let x): return x.bric() 
            case .SecondAnyCase(let x): return x.bric() 
            } 
        }

        static func brac(bric: Bric) throws -> SampleModel.AnyOfField {
            return try bric.bracOne([ 
            { try .FirstAnyCase(FirstAny.brac(bric)) }, 
            { try .SecondAnyCase(SecondAny.brac(bric)) }, 
            ]) 
        }

        /// FirstAny
        struct FirstAny : BricBrac {
            var b1: Int
            var b2: String

            init(b1: Int, b2: String) {
                self.b1 = b1 
                self.b2 = b2 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.b1, b1.bric()), 
                (Keys.b2, b2.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.AnyOfField.FirstAny {
                return try SampleModel.AnyOfField.FirstAny( 
                b1: bric.bracKey(Keys.b1), 
                b2: bric.bracKey(Keys.b2) 
                ) 
            }

            enum Keys : String {
                case b1 = "b1"
                case b2 = "b2"
            }
        }

        /// SecondAny
        struct SecondAny : BricBrac {
            var b3: Bool
            var b4: Double

            init(b3: Bool, b4: Double) {
                self.b3 = b3 
                self.b4 = b4 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.b3, b3.bric()), 
                (Keys.b4, b4.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.AnyOfField.SecondAny {
                return try SampleModel.AnyOfField.SecondAny( 
                b3: bric.bracKey(Keys.b3), 
                b4: bric.bracKey(Keys.b4) 
                ) 
            }

            enum Keys : String {
                case b3 = "b3"
                case b4 = "b4"
            }
        }
    }

    enum OneOfField : BricBrac {
        case FirstOneCase(FirstOne)
        case SecondOneCase(SecondOne)

        func bric() -> Bric {
            switch self { 
            case .FirstOneCase(let x): return x.bric() 
            case .SecondOneCase(let x): return x.bric() 
            } 
        }

        static func brac(bric: Bric) throws -> SampleModel.OneOfField {
            return try bric.bracOne([ 
            { try .FirstOneCase(FirstOne.brac(bric)) }, 
            { try .SecondOneCase(SecondOne.brac(bric)) }, 
            ]) 
        }

        /// FirstOne
        struct FirstOne : BricBrac {
            var c1: Int
            var c2: String

            init(c1: Int, c2: String) {
                self.c1 = c1 
                self.c2 = c2 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.c1, c1.bric()), 
                (Keys.c2, c2.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.OneOfField.FirstOne {
                return try SampleModel.OneOfField.FirstOne( 
                c1: bric.bracKey(Keys.c1), 
                c2: bric.bracKey(Keys.c2) 
                ) 
            }

            enum Keys : String {
                case c1 = "c1"
                case c2 = "c2"
            }
        }

        /// SecondOne
        struct SecondOne : BricBrac {
            var c3: Bool
            var c4: Double

            init(c3: Bool, c4: Double) {
                self.c3 = c3 
                self.c4 = c4 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.c3, c3.bric()), 
                (Keys.c4, c4.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.OneOfField.SecondOne {
                return try SampleModel.OneOfField.SecondOne( 
                c3: bric.bracKey(Keys.c3), 
                c4: bric.bracKey(Keys.c4) 
                ) 
            }

            enum Keys : String {
                case c3 = "c3"
                case c4 = "c4"
            }
        }
    }

    struct NotField : BricBrac {
        var p0: P0
        var p1: P1

        init(_ p0: P0, _ p1: P1) {
            self.p0 = p0 
            self.p1 = p1 
        }

        func bric() -> Bric {
            return Bric(merge: [ 
            p0.bric(), 
            p1.bric(), 
            ]) 
        }

        static func brac(bric: Bric) throws -> SampleModel.NotField {
            return try SampleModel.NotField( 
            P0.brac(bric), 
            P1.brac(bric) 
            ) 
        }

        struct P0 : BricBrac {
            var str: String

            init(str: String) {
                self.str = str 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.str, str.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.NotField.P0 {
                return try SampleModel.NotField.P0( 
                str: bric.bracKey(Keys.str) 
                ) 
            }

            enum Keys : String {
                case str = "str"
            }
        }

        typealias P1 = NotBrac<NotP1>
        struct NotP1 : BricBrac {
            var str: Str

            init(str: Str = .Illegal) {
                self.str = str 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.str, str.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.NotField.NotP1 {
                return try SampleModel.NotField.NotP1( 
                str: bric.bracKey(Keys.str) 
                ) 
            }

            enum Keys : String {
                case str = "str"
            }

            enum Str : String, BricBrac {
                case Illegal = "illegal"
            }
        }
    }
}

