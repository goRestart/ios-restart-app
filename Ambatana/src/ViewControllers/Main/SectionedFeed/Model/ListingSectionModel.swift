import IGListKit
import LGCoreKit

enum ListingSectionType: String {
    case horizontal, vertical
}

struct SectionPosition: Equatable {
    let page: UInt
    let index: UInt
}

struct ListingSectionModel: Diffable {
    let id: String
    let type: ListingSectionType
    var title: String
    let links: [String: String]
    let items: [FeedListingData]
    let sectionPosition: SectionPosition
    
    var diffIdentifier: String {
        return id + sectionPositionString
    }
    
    private var sectionPositionString: String {
        return "-\(sectionPosition.page)-\(sectionPosition.index)"
    }
}
