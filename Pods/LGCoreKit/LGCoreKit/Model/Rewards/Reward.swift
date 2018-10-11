
public protocol Reward {
    var id: String { get }
    var type: RewardType { get }
    var points: Int { get }
}

public enum RewardType: String, Decodable {
    case amazon5 = "amazon_5", amazon10 = "amazon_10", amazon50  = "amazon_50"
    
    static let allValues: [RewardType] = [.amazon5, .amazon10, .amazon50]
}
