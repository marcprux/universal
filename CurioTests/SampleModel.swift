import BricBrac

struct SampleModel : BricBrac {
    var allOfField: AllOfFieldType
    var anyOfField: AnyOfFieldType
    var oneOfField: OneOfFieldType
    var notField: NotFieldType

    init(allOfField: AllOfFieldType, anyOfField: AnyOfFieldType, oneOfField: OneOfFieldType, notField: NotFieldType) {
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

    struct AllOfFieldType : BricBrac {
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

        static func brac(bric: Bric) throws -> SampleModel.AllOfFieldType {
            return try SampleModel.AllOfFieldType( 
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

            static func brac(bric: Bric) throws -> SampleModel.AllOfFieldType.FirstAll {
                return try SampleModel.AllOfFieldType.FirstAll( 
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

            static func brac(bric: Bric) throws -> SampleModel.AllOfFieldType.SecondAll {
                return try SampleModel.AllOfFieldType.SecondAll( 
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

    enum AnyOfFieldType : BricBrac {
        case FirstAnyCase(FirstAny)
        case SecondAnyCase(SecondAny)

        func bric() -> Bric {
            switch self { 
            case .FirstAnyCase(let x): return x.bric() 
            case .SecondAnyCase(let x): return x.bric() 
            } 
        }

        static func brac(bric: Bric) throws -> SampleModel.AnyOfFieldType {
            return try bric.bracAny([ 
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

            static func brac(bric: Bric) throws -> SampleModel.AnyOfFieldType.FirstAny {
                return try SampleModel.AnyOfFieldType.FirstAny( 
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

            static func brac(bric: Bric) throws -> SampleModel.AnyOfFieldType.SecondAny {
                return try SampleModel.AnyOfFieldType.SecondAny( 
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

    enum OneOfFieldType : BricBrac {
        case FirstOneCase(FirstOne)
        case SecondOneCase(SecondOne)

        func bric() -> Bric {
            switch self { 
            case .FirstOneCase(let x): return x.bric() 
            case .SecondOneCase(let x): return x.bric() 
            } 
        }

        static func brac(bric: Bric) throws -> SampleModel.OneOfFieldType {
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

            static func brac(bric: Bric) throws -> SampleModel.OneOfFieldType.FirstOne {
                return try SampleModel.OneOfFieldType.FirstOne( 
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

            static func brac(bric: Bric) throws -> SampleModel.OneOfFieldType.SecondOne {
                return try SampleModel.OneOfFieldType.SecondOne( 
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

    struct NotFieldType : BricBrac {
        var p0: P0Type
        var p1: P1Type

        init(_ p0: P0Type, _ p1: P1Type) {
            self.p0 = p0 
            self.p1 = p1 
        }

        func bric() -> Bric {
            return Bric(merge: [ 
            p0.bric(), 
            p1.bric(), 
            ]) 
        }

        static func brac(bric: Bric) throws -> SampleModel.NotFieldType {
            return try SampleModel.NotFieldType( 
            P0Type.brac(bric), 
            P1Type.brac(bric) 
            ) 
        }

        struct P0Type : BricBrac {
            var str: String

            init(str: String) {
                self.str = str 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.str, str.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.NotFieldType.P0Type {
                return try SampleModel.NotFieldType.P0Type( 
                str: bric.bracKey(Keys.str) 
                ) 
            }

            enum Keys : String {
                case str = "str"
            }
        }

        typealias P1Type = NotBrac<NotP1Type>
        struct NotP1Type : BricBrac {
            var str: StrType

            init(str: StrType = .Illegal) {
                self.str = str 
            }

            func bric() -> Bric {
                return Bric(object: [ 
                (Keys.str, str.bric()), 
                ]) 
            }

            static func brac(bric: Bric) throws -> SampleModel.NotFieldType.NotP1Type {
                return try SampleModel.NotFieldType.NotP1Type( 
                str: bric.bracKey(Keys.str) 
                ) 
            }

            enum Keys : String {
                case str = "str"
            }

            enum StrType : String, BricBrac {
                case Illegal = "illegal"
            }
        }
    }
}

