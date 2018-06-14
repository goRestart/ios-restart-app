import LGCoreKit
import LGComponents

protocol UserListingListRequester: ListingListRequester {
    var userObjectId: String? { get set }
}

class UserFavoritesListingListRequester: UserListingListRequester {
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        // method needed for protocol implementation, not used for user
        return nil
    }
    var countryCode: String? {
        // method needed for protocol implementation, not used for user
        return nil
    }

    var itemsPerPage: Int = SharedConstants.numListingsPerPageDefault
    var userObjectId: String?
    private var offset: Int = 0
    let listingRepository: ListingRepository
    let locationManager: LocationManager

    convenience init() {
        self.init(listingRepository: Core.listingRepository, locationManager: Core.locationManager)
    }

    init(listingRepository: ListingRepository, locationManager: LocationManager) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
    }
    
    var isFirstPage: Bool = true

    func canRetrieve() -> Bool {
        return userObjectId != nil
    }
    
    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        updateInitialOffset(0)
        listingsRetrieval(completion)
    }
    
    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        isFirstPage = false
        listingsRetrieval(completion)
    }

    private func listingsRetrieval(_ completion: ListingsRequesterCompletion?) {
        guard let userId = userObjectId else { return }
        listingRepository.indexFavorites(userId: userId, numberOfResults: itemsPerPage, resultsOffset: offset) { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(_ newOffset: Int) {
        offset = newOffset
    }

    func duplicate() -> ListingListRequester {
        let r = UserFavoritesListingListRequester()
        r.userObjectId = userObjectId
        return r
    }

    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? UserFavoritesListingListRequester else { return false }
        return userObjectId == requester.userObjectId
    }
}


class UserStatusesListingListRequester: UserListingListRequester {
    
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        // method needed for protocol implementation, not used for user
        return nil
    }
    var countryCode: String? {
        // method needed for protocol implementation, not used for user
        return nil
    }
    
    let itemsPerPage: Int
    var userObjectId: String? = nil
    // Related to DiscardedProducts ABTest, `statuses` has been changed to a closure to be able to
    // dynamically ask for the required listing codes.
    private let statuses: () -> [ListingStatusCode]
    private let listingRepository: ListingRepository
    private let locationManager: LocationManager
    private var offset: Int = 0

    convenience init(statuses:@escaping () -> [ListingStatusCode], itemsPerPage: Int) {
        self.init(listingRepository: Core.listingRepository, locationManager: Core.locationManager, statuses: statuses,
                  itemsPerPage: itemsPerPage)
    }

    init(listingRepository: ListingRepository, locationManager: LocationManager, statuses: @escaping () -> [ListingStatusCode],
         itemsPerPage: Int) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.statuses = statuses
        self.itemsPerPage = itemsPerPage
    }
    
    var isFirstPage: Bool {
        return offset == 0
    }

    func canRetrieve() -> Bool {
        return userObjectId != nil
    }

    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        offset = 0
        listingsRetrieval(completion)
    }
    
    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        listingsRetrieval(completion)
    }
    
    private func listingsRetrieval(_ completion: ListingsRequesterCompletion?) {
        guard let userId = userObjectId else { return  }
        listingRepository.index(userId: userId, params: retrieveListingsParams) { [weak self] result in
            if let products = result.value, !products.isEmpty {
                self?.offset += products.count
                //User posted previously -> Store it
                KeyValueStorage.sharedInstance.userPostProductPostedPreviously = true
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(_ newOffset: Int) { }

    func duplicate() -> ListingListRequester {
        let r = UserStatusesListingListRequester(statuses: statuses, itemsPerPage: itemsPerPage)
        r.offset = offset
        r.userObjectId = userObjectId
        return r
    }

    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? UserStatusesListingListRequester else { return false }
        return userObjectId == requester.userObjectId
    }
    
    private var retrieveListingsParams: RetrieveListingParams {
        var params: RetrieveListingParams = RetrieveListingParams()
        params.offset = offset
        params.numListings = itemsPerPage
        if let currentLocation = locationManager.currentLocation {
            params.coordinates = LGLocationCoordinates2D(location: currentLocation)
        }
        params.countryCode = locationManager.currentLocation?.countryCode
        params.sortCriteria = .creation
        params.statuses = statuses()
        return params
    }
}
