import LGCoreKit

class RecentListingsRequester {
    
    private let listingRepository: ListingRepository
    
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(listingRepository: Core.listingRepository)
    }
    
    init(listingRepository: ListingRepository) {
        self.listingRepository = listingRepository
    }
    
    
    // MARK: - Requests
    
    func retrieveRecentItems(completion: ListingsRequesterCompletion?) {
        let params = RetrieveListingParams()
        listingRepository.index(params) { [weak self] result in
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }
}
