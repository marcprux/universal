import BricBrac

public struct Thing : Equatable, Hashable, Codable, KeyedCodable {
    public var weight: Int?
    public static let codingKeyPaths = (\Self.weight)

    public init(weight: Int? = nil) {
        self.weight = weight 
    }

    public init(from decoder: Decoder) throws {
        func keytype<Value>(_ kp: KeyPath<Self, Value>) -> Value.Type { Value.self } 
        let values = try decoder.container(keyedBy: CodingKeys.self) 
        self.weight = try values.decodeValue(keytype(\.weight), forKey: .weight) 
    }

    public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
        case weight
    }
}
