import Foundation
import LGCoreKit

protocol RateBuyersNavigator {
    func rateBuyersCancel()
    func rateBuyersFinish(withUser: UserListing, listingId: String?)
    func rateBuyersFinishNotOnLetgo()
}
