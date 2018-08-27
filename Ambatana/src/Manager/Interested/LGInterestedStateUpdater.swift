import LGCoreKit

final class LGInterestedStateUpdater: InterestedStateUpdater {
    
    let myUserRepository: MyUserRepository
    let keyValueStorage: KeyValueStorageable
    
    var listingInterestStates: Set<String> {
        didSet {
            keyValueStorage.interestingListingIDs = listingInterestStates
        }
    }
    
    var dictInterestedStates: [String: InterestedState] {
        let empty = [String: InterestedState]()
        let dict: [String: InterestedState] = listingInterestStates.reduce(empty) {
            (dict, identifier) -> [String: InterestedState] in
            var dict = dict
            dict[identifier] = .seeConversation
            return dict
        }
        return dict
    }
    
    let contactedProSellerList: [String]
    
    init(myUserRepository: MyUserRepository = Core.myUserRepository,
         keyValueStorage: KeyValueStorageable = KeyValueStorage.sharedInstance) {
        self.myUserRepository = myUserRepository
        self.listingInterestStates = keyValueStorage.interestingListingIDs
        self.contactedProSellerList = keyValueStorage.proSellerAlreadySentPhoneInChat
        self.keyValueStorage = keyValueStorage
    }
}

extension LGInterestedStateUpdater {
    
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
    
    func addInterestedState(forListing listing: Listing, completion: (()-> Void)?) {
        guard let listingId = listing.objectId else { return }
        listingInterestStates.update(with: listingId)
        completion?()
    }
    
    func removeInterestedState(forListing listing: Listing, completion: (()-> Void)?) {
        guard let listingId = listing.objectId else { return }
        listingInterestStates.remove(listingId)
        completion?()
    }
}

extension InterestedState {
    var isDisabled: Bool {
        switch self {
        case .send(enabled: let enabled):
            return !enabled
        case .none, .seeConversation: return false
        }
    }
}
