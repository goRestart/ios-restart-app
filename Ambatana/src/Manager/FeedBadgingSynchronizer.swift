import LGCoreKit

public typealias RecentItemsCompletion = ([Listing]) -> Void

protocol FeedBadgingSynchronizer {
    var badgeNumber: Int { get }
    
    func retrieveRecentListings(completion: RecentItemsCompletion?)
    func showBadge()
    func hideBadge()
}
