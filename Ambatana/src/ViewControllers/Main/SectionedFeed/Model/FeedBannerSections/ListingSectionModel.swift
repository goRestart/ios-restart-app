import LGCoreKit

struct ListingSectionModel: FeedBannerSection {
    let id: String
    let type: ListingSectionType
    var title: String?
    let links: [String: String]
    let items: [FeedListingData]
    let sectionPosition: SectionPosition
}



