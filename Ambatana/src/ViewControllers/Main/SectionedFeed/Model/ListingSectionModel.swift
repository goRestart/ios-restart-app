import IGListKit
import LGCoreKit

enum ListingSectionType: String {
    case horizontal, vertical
}

struct ListingSectionModel: Diffable {
    let id: String
    let type: ListingSectionType
    var title: String
    let links: [String: String]
    let items: [FeedListingData]
    
    var diffIdentifier: String {
        return id
    }
}
