import Foundation
import LGCoreKit

protocol ListingOwner {
    var ownedListing: Listing { get }
    var listingDetailNavigator: ListingDetailNavigator? { get }
    var myUserRepository: MyUserRepository { get }
}

extension ListingOwner {
    var isMine: Bool { return ownedListing.isMine(myUserRepository: myUserRepository) }
    var isFavoritable: Bool { return !isMine }
}
