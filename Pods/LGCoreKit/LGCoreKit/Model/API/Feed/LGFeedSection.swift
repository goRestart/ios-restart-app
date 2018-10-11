
public struct LGFeedSection: FeedSection {
    public let id: String
    public let type: FeedSectionType?
    public let localizedTitle: String?
    public let links: FeedSectionLinks
    public let items: [FeedListing]
}

extension LGFeedSection: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id, type, localizedTitle = "localized_title", links, items
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        type = try? values.decode(FeedSectionType.self, forKey: .type)
        localizedTitle = try values.decodeIfPresent(String.self, forKey: .localizedTitle)
        links = try values.decode(LGFeedSectionLinks.self, forKey: .links)
        items = try values.decode(FailableDecodableArray<FeedListing>.self, forKey: .items).validElements.filter {
            switch $0 {
            case .category, .product: return true
            case .emptyLocation: return false
            }            
        }
    }
}
