
public enum FeedListing {
    case product(Listing)
}

extension FeedListing: Decodable {
    
    enum ListingType: String, Decodable {
        case product
    }
    
    enum CodingKeys: String, CodingKey {
        case type, attributes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ListingType.self, forKey: .type)
        switch type {
        case .product:
            let feedProduct = try container.decode(LGFeedProduct.self, forKey: .attributes)
            self = .product(LGFeedProduct.toListing(item: feedProduct))
        }
    }
}
