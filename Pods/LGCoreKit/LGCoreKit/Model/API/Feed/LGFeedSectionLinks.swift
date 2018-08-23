
public struct LGFeedSectionLinks: FeedSectionLinks {
    public let seeAll: FeedSectionSeeAllLink
}

extension LGFeedSectionLinks: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case seeAll = "see_all"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        seeAll = try values.decode(LGFeedSectionSeeAllLink.self, forKey: .seeAll)
    }
}
