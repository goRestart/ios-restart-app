
public enum FeedListing {
    case product(Listing)
    case emptyLocation           //  To be removed when app supports location-less products
    
    var hasLocation: Bool {
        guard case .emptyLocation = self else { return true }
        return false
    }
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
            self = try container.decodeAndEmbedListing()
        }
    }
}

extension KeyedDecodingContainer where KeyedDecodingContainer.Key == FeedListing.CodingKeys {
    func decodeAndEmbedListing() throws -> FeedListing {
        let feedListing = try decode(LGFeedProduct.self, forKey: .attributes)
        if let listing = LGFeedProduct.toListing(item: feedListing) {
            return .product(listing)
        }
        return .emptyLocation
    }
}
