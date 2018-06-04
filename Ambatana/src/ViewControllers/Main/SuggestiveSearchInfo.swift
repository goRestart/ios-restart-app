import Foundation
import LGCoreKit

struct SuggestiveSearchInfo {
    let suggestiveSearches: [SuggestiveSearch]
    let sourceText: String
    
    var count: Int {
        return suggestiveSearches.count
    }
    
    static func empty() -> SuggestiveSearchInfo {
        return SuggestiveSearchInfo(suggestiveSearches: [],
                                    sourceText: "")
    }
}
