
public protocol Feed {
    var pagination: PaginationLinks { get }
    var sections: [FeedSection] { get }
    var items: [FeedListing] { get }
}

public protocol FeedSection {
    var id: String { get }
    var type: FeedSectionType { get }
    var localizedTitle: String { get }
    var links: FeedSectionLinks { get }
    var items: [FeedListing] { get }
}

public enum FeedSectionType: String, Decodable {
    case horizontalListing = "horizontal_listing"
    case verticalListing = "vertical_listing"
}

public protocol FeedSectionLinks {
    var seeAll: FeedSectionSeeAllLink { get }
}

public enum FeedLinkType: String {
    case feed
}

public protocol FeedSectionSeeAllLink {
    var localizedLinkTitle: String { get }
    var url: URL { get }
    var type: FeedLinkType? { get }
}
