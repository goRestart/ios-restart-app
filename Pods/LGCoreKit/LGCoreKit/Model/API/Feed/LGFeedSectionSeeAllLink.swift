
public struct LGFeedSectionSeeAllLink: FeedSectionSeeAllLink {
    public let localizedLinkTitle: String
    public let url: URL
    public var type: FeedLinkType?
}

extension LGFeedSectionSeeAllLink: Decodable {

    enum RootCodingKeys: String, CodingKey {
        case url = "href", meta
    }

    enum MetaCodingKeys: String, CodingKey {
        case localizedLinkTitle = "localized_title", type
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let metaContainer = try rootContainer.nestedContainer(keyedBy: MetaCodingKeys.self, forKey: .meta)
        url = try rootContainer.decode(URL.self, forKey: .url)
        localizedLinkTitle = try metaContainer.decode(String.self, forKey: .localizedLinkTitle)
        type = FeedLinkType(rawValue: try metaContainer.decode(String.self, forKey: .type))
    }
}
