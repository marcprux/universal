@_exported import BricBrac

/// Generated by Curio
public struct Thing : Equatable, Hashable, Codable, KeyedCodable {
    public var weight: Int?
    public static let codingKeyPaths = (\Self.weight as KeyPath)
    public static let codableKeys: Dictionary<PartialKeyPath<Self>, CodingKeys> = [\Self.weight as KeyPath : CodingKeys.weight]

    public init(weight: Int? = nil) {
        self.weight = weight 
    }

    public init(from decoder: Decoder) throws {
        try decoder.forbidAdditionalProperties(notContainedIn: CodingKeys.allCases) 
        let values = try decoder.container(keyedBy: CodingKeys.self) 
        self.weight = try values.decodeOptional(Int.self, forKey: .weight) 
    }

    public enum CodingKeys : String, CodingKey, Hashable, Codable, CaseIterable {
        case weight
        public var keyDescription: String? {
            switch self {
            case .weight: return nil
             } 
        }

        public typealias CodingOwner = Thing
    }
}
