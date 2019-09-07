import BricBrac

public struct SampleModel : Equatable, Hashable, Codable, KeyedCodable {
    public var allOfField: AllOfField
    public var anyOfField: AnyOfField
    public var oneOfField: OneOfFieldChoice
    /// Should not escape keyword arguments
    public var keywordFields: KeywordFields?
    public var list: [ListItem]?
    public var nested1: Nested1?
    /// Should generate a simple OneOf enum
    public var simpleOneOf: SimpleOneOfChoice?
    public static let codingKeyPaths = (\Self.allOfField, \Self.anyOfField, \Self.oneOfField, \Self.keywordFields, \Self.list, \Self.nested1, \Self.simpleOneOf)

    public init(allOfField: AllOfField, anyOfField: AnyOfField, oneOfField: OneOfFieldChoice, keywordFields: KeywordFields? = nil, list: [ListItem]? = nil, nested1: Nested1? = nil, simpleOneOf: SimpleOneOfChoice? = nil) {
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

        public typealias Sum = AllOf2<FirstAll, SecondAll>

        /// FirstAll
        public struct FirstAll : Equatable, Hashable, Codable, KeyedCodable {
            public var a1: Int
            public var a2: String
            public static let codingKeyPaths = (\Self.a1, \Self.a2)

            public init(a1: Int, a2: String) {
                self.a1 = a1 
                self.a2 = a2 
            }

            public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                case a1
                case a2
            }
        }

        /// SecondAll
        public struct SecondAll : Equatable, Hashable, Codable, KeyedCodable {
            public var a3: Bool
            public var a4: Double
            public static let codingKeyPaths = (\Self.a3, \Self.a4)

            public init(a3: Bool, a4: Double) {
                self.a3 = a3 
                self.a4 = a4 
            }

            public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                case a3
                case a4
            }
        }
    }

    public typealias AnyOfField = AnyOfFieldTypes.Some
    public enum AnyOfFieldTypes {

        public typealias Some = AnyOf2<FirstAny?, SecondAny?>

        /// FirstAny
        public struct FirstAny : Equatable, Hashable, Codable, KeyedCodable {
            public var b1: Int
            public var b2: String
            public static let codingKeyPaths = (\Self.b1, \Self.b2)

            public init(b1: Int, b2: String) {
                self.b1 = b1 
                self.b2 = b2 
            }

            public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                case b1
                case b2
            }
        }

        /// SecondAny
        public struct SecondAny : Equatable, Hashable, Codable, KeyedCodable {
            public var b3: Bool
            public var b4: Double
            public static let codingKeyPaths = (\Self.b3, \Self.b4)

            public init(b3: Bool, b4: Double) {
                self.b3 = b3 
                self.b4 = b4 
            }

            public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                case b3
                case b4
            }
        }
    }

    public typealias OneOfFieldChoice = OneOfFieldTypes.Choice
    public enum OneOfFieldTypes {

        public typealias Choice = OneOf2<FirstOne, SecondOne>

        /// FirstOne
        public struct FirstOne : Equatable, Hashable, Codable, KeyedCodable {
            public var c1: Int
            public var c2: String
            public static let codingKeyPaths = (\Self.c1, \Self.c2)

            public init(c1: Int, c2: String) {
                self.c1 = c1 
                self.c2 = c2 
            }

            public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                case c1
                case c2
            }
        }

        /// SecondOne
        public struct SecondOne : Equatable, Hashable, Codable, KeyedCodable {
            public var c3: Bool
            public var c4: Double
            public static let codingKeyPaths = (\Self.c3, \Self.c4)

            public init(c3: Bool, c4: Double) {
                self.c3 = c3 
                self.c4 = c4 
            }

            public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                case c3
                case c4
            }
        }
    }

    /// Should generate a simple OneOf enum
    public typealias SimpleOneOfChoice = OneOf2<String, Double>

    public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
        case allOfField
        case anyOfField
        case oneOfField
        case keywordFields
        case list
        case nested1
        case simpleOneOf
    }

    /// Should not escape keyword arguments
    public struct KeywordFields : Equatable, Hashable, Codable, KeyedCodable {
        public var `case`: String?
        public var `for`: String?
        public var `in`: String?
        public var `inout`: String?
        public var `let`: String?
        public var `var`: String?
        public var `while`: String?
        public static let codingKeyPaths = (\Self.`case`, \Self.`for`, \Self.`in`, \Self.`inout`, \Self.`let`, \Self.`var`, \Self.`while`)

        public init(`case`: String? = nil, `for`: String? = nil, `in`: String? = nil, `inout`: String? = nil, `let`: String? = nil, `var`: String? = nil, `while`: String? = nil) {
            self.`case` = `case` 
            self.`for` = `for` 
            self.`in` = `in` 
            self.`inout` = `inout` 
            self.`let` = `let` 
            self.`var` = `var` 
            self.`while` = `while` 
        }

        public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
            case `case` = "case"
            case `for` = "for"
            case `in` = "in"
            case `inout` = "inout"
            case `let` = "let"
            case `var` = "var"
            case `while` = "while"
        }
    }

    public struct ListItem : Equatable, Hashable, Codable, KeyedCodable {
        public var prop: LiteralValue
        public static let codingKeyPaths = (\Self.prop)

        public init(prop: LiteralValue = .value) {
            self.prop = prop 
        }

        public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
            case prop
        }

        public enum LiteralValue : String, Equatable, Hashable, Codable, CaseIterable {
            case value
        }
    }

    public struct Nested1 : Equatable, Hashable, Codable, KeyedCodable {
        public var nested2: Nested2
        public static let codingKeyPaths = (\Self.nested2)

        public init(nested2: Nested2) {
            self.nested2 = nested2 
        }

        public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
            case nested2
        }

        public struct Nested2 : Equatable, Hashable, Codable, KeyedCodable {
            public var nested3: Nested3
            public static let codingKeyPaths = (\Self.nested3)

            public init(nested3: Nested3) {
                self.nested3 = nested3 
            }

            public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                case nested3
            }

            public struct Nested3 : Equatable, Hashable, Codable, KeyedCodable {
                public var nested4: Nested4
                public static let codingKeyPaths = (\Self.nested4)

                public init(nested4: Nested4) {
                    self.nested4 = nested4 
                }

                public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                    case nested4
                }

                public struct Nested4 : Equatable, Hashable, Codable, KeyedCodable {
                    public var nested5: Nested5
                    public static let codingKeyPaths = (\Self.nested5)

                    public init(nested5: Nested5) {
                        self.nested5 = nested5 
                    }

                    public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                        case nested5
                    }

                    public struct Nested5 : Equatable, Hashable, Codable, KeyedCodable {
                        public var single: LiteralValue
                        public static let codingKeyPaths = (\Self.single)

                        public init(single: LiteralValue = .value) {
                            self.single = single 
                        }

                        public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
                            case single
                        }

                        public enum LiteralValue : String, Equatable, Hashable, Codable, CaseIterable {
                            case value
                        }
                    }
                }
            }
        }
    }
}
