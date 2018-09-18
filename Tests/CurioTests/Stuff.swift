import BricBrac

public struct Thing : Equatable, Hashable, Codable {
    public var weight: Int?

    public init(weight: Int? = .none) {
        self.weight = weight 
    }

    public enum CodingKeys : String, CodingKey {
        case weight
    }
}
