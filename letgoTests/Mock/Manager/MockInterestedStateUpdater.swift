@testable import LetGoGodMode
import LGCoreKit

final class MockInterestedStateUpdater: InterestedStateUpdater {
    var myUserRepository: MyUserRepository = MockMyUserRepository()
    var keyValueStorage: KeyValueStorageable = MockKeyValueStorage()
    var listingInterestStates: Set<String> = Set([])
    var contactedProSellerList: [String] = []
    
    func hasContactedProListing(_ listing: Listing) -> Bool {
        guard let listingId = listing.objectId else { return false }
        return contactedProSellerList.contains(listingId)
    }
    
    func hasContactedListing(_ listing: Listing) -> Bool {
        guard let listingId = listing.objectId else { return false }
        return listingInterestStates.contains(listingId)
    }
    
    func interestedIsDisabled(forListing listing: Listing) -> Bool {
        return listing.interestedState(myUserRepository: myUserRepository,
                                       listingInterestStates: listingInterestStates).isDisabled
    }
    func addInterestedState(forListing listing: Listing, completion: (() -> Void)?) {}
    func removeInterestedState(forListing listing: Listing, completion: (() -> Void)?) {}
}
