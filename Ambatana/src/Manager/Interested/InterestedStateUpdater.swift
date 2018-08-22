import LGCoreKit

protocol InterestedStateUpdater {
    var myUserRepository: MyUserRepository { get }
    var keyValueStorage: KeyValueStorageable { get }
    var listingInterestStates: Set<String> { get set }
    var contactedProSellerList: [String] { get }
    
    func hasContactedProListing(_ listing: Listing) -> Bool
    func hasContactedListing(_ listing: Listing) -> Bool
    func interestedIsDisabled(forListing listing: Listing) -> Bool
    func addInterestedState(forListing listing: Listing, completion: (()-> Void)?)
    func removeInterestedState(forListing listing: Listing, completion: (()-> Void)?)
}
