@testable import LetGoGodMode
import RxSwift

final class MockFeedBadgingSynchronizer: FeedBadgingSynchronizer {
    var badgeNumber: Int = 0
    var lastSessionDate: Date?
    
    func retrieveRecentListings(completion: RecentItemsCompletion?) {}
    func showBadge() {}
    func hideBadge() {}
}
