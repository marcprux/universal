import BricBrac

public struct SampleModel : Equatable, Hashable, Codable {
    public var allOfField: AllOfField
    public var anyOfField: AnyOfField
    public var oneOfField: OneOfFieldChoice
    /// Should not escape keyword arguments
    public var keywordFields: KeywordFields?
    public var list: [ListItem]?
    public var nested1: Nested1?
    /// Should generate a simple OneOf enum
    public var simpleOneOf: SimpleOneOfChoice?

    public init(allOfField: AllOfField, anyOfField: AnyOfField, oneOfField: OneOfFieldChoice, keywordFields: KeywordFields? = .none, list: [ListItem]? = .none, nested1: Nested1? = .none, simpleOneOf: SimpleOneOfChoice? = .none) {
        self.allOfField = allOfField 
        self.anyOfField = anyOfField 
        self.oneOfField = oneOfField 
        self.keywordFields = keywordFields 
        self.list = list 
        self.nested1 = nested1 
        self.simpleOneOf = simpleOneOf 
    }

    public typealias AllOfField = AllOfFieldTypes.Sum
    public enum AllOfFieldTypes {

        /// FirstAll
        public struct FirstAll : Equatable, Hashable, Codable {
            public var a1: Int
            public var a2: String

            public init(a1: Int, a2: String) {
                self.a1 = a1 
                self.a2 = a2 
            }

            public enum CodingKeys : String, CodingKey, CaseIterable {
                case a1
                case a2
            }
        }

        /// SecondAll
        public struct SecondAll : Equatable, Hashable, Codable {
            public var a3: Bool
            public var a4: Double

            public init(a3: Bool, a4: Double) {
                self.a3 = a3 
                self.a4 = a4 
            }

            public enum CodingKeys : String, CodingKey, CaseIterable {
                case a3
                case a4
            }
        }

        public typealias Sum = AllOf2<FirstAll, SecondAll>
    }

    public typealias AnyOfField = AnyOfFieldTypes.Some
    public enum AnyOfFieldTypes {

        /// FirstAny
        public struct FirstAny : Equatable, Hashable, Codable {
            public var b1: Int
            public var b2: String

            public init(b1: Int, b2: String) {
                self.b1 = b1 
                self.b2 = b2 
            }

            public enum CodingKeys : String, CodingKey, CaseIterable {
                case b1
                case b2
            }
        }

        /// SecondAny
        public struct SecondAny : Equatable, Hashable, Codable {
            public var b3: Bool
            public var b4: Double

            public init(b3: Bool, b4: Double) {
                self.b3 = b3 
                self.b4 = b4 
            }

            public enum CodingKeys : String, CodingKey, CaseIterable {
                case b3
                case b4
            }
        }

        public typealias Some = AnyOf2<FirstAny?, SecondAny?>
    }

    public typealias OneOfFieldChoice = OneOfFieldTypes.Choice
    public enum OneOfFieldTypes {

        public typealias Choice = OneOf2<FirstOne, SecondOne>

        /// FirstOne
        public struct FirstOne : Equatable, Hashable, Codable {
            public var c1: Int
            public var c2: String

            public init(c1: Int, c2: String) {
                self.c1 = c1 
                self.c2 = c2 
            }

            public enum CodingKeys : String, CodingKey, CaseIterable {
                case c1
                case c2
            }
        }

        /// SecondOne
        public struct SecondOne : Equatable, Hashable, Codable {
            public var c3: Bool
            public var c4: Double

            public init(c3: Bool, c4: Double) {
                self.c3 = c3 
                self.c4 = c4 
            }

            public enum CodingKeys : String, CodingKey, CaseIterable {
                case c3
                case c4
            }
        }
    }

    /// Should generate a simple OneOf enum
    public typealias SimpleOneOfChoice = OneOf2<String, Double>

    public enum CodingKeys : String, CodingKey, CaseIterable {
        case allOfField
        case anyOfField
        case oneOfField
        case keywordFields
        case list
        case nested1
        case simpleOneOf
    }

    /// Should not escape keyword arguments
    public struct KeywordFields : Equatable, Hashable, Codable {
        public var `case`: String?
        public var `for`: String?
        public var `in`: String?
        public var `inout`: String?
        public var `let`: String?
        public var `var`: String?
        public var `while`: String?

        public init(`case`: String? = .none, `for`: String? = .none, `in`: String? = .none, `inout`: String? = .none, `let`: String? = .none, `var`: String? = .none, `while`: String? = .none) {
            self.`case` = `case` 
            self.`for` = `for` 
            self.`in` = `in` 
            self.`inout` = `inout` 
            self.`let` = `let` 
            self.`var` = `var` 
            self.`while` = `while` 
        }

        public enum CodingKeys : String, CodingKey, CaseIterable {
            case `case` = "case"
            case `for` = "for"
            case `in` = "in"
            case `inout` = "inout"
            case `let` = "let"
            case `var` = "var"
            case `while` = "while"
        }
    }

    public struct ListItem : Equatable, Hashable, Codable {
        public var prop: Prop

        public init(prop: Prop = .value) {
            self.prop = prop 
        }

        public enum CodingKeys : String, CodingKey, CaseIterable {
            case prop
        }

        public enum Prop : String, Equatable, Hashable, Codable, CaseIterable {
            case value
        }
    }

    public struct Nested1 : Equatable, Hashable, Codable {
        public var nested2: Nested2

        public init(nested2: Nested2) {
            self.nested2 = nested2 
        }

        public enum CodingKeys : String, CodingKey, CaseIterable {
            case nested2
        }

        public struct Nested2 : Equatable, Hashable, Codable {
            public var nested3: Nested3

            public init(nested3: Nested3) {
                self.nested3 = nested3 
            }

            public enum CodingKeys : String, CodingKey, CaseIterable {
                case nested3
            }

            public struct Nested3 : Equatable, Hashable, Codable {
                public var nested4: Nested4

                public init(nested4: Nested4) {
                    self.nested4 = nested4 
                }

                public enum CodingKeys : String, CodingKey, CaseIterable {
                    case nested4
                }

                public struct Nested4 : Equatable, Hashable, Codable {
                    public var nested5: Nested5

                    public init(nested5: Nested5) {
                        self.nested5 = nested5 
                    }

                    public enum CodingKeys : String, CodingKey, CaseIterable {
                        case nested5
                    }

                    public struct Nested5 : Equatable, Hashable, Codable {
                        public var single: Single

                        public init(single: Single = .value) {
                            self.single = single 
                        }

                        public enum CodingKeys : String, CodingKey, CaseIterable {
                            case single
                        }

                        public enum Single : String, Equatable, Hashable, Codable, CaseIterable {
                            case value
                        }
                    }
                }
            }
        }
    }
}
