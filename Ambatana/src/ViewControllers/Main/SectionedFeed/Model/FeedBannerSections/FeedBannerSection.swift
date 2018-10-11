import IGListKit

protocol FeedBannerSection: Diffable {
    var id: String { get }
    var sectionPosition: SectionPosition { get }
}

extension FeedBannerSection {
    
    var diffIdentifier: String {
        return id + sectionPositionString
    }
    
    private var sectionPositionString: String {
        return "-\(sectionPosition.page)-\(sectionPosition.index)"
    }
}

struct SectionPosition: Equatable {
    let page: UInt
    let index: UInt
}
