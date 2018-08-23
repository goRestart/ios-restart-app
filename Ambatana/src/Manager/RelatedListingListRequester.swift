import LGCoreKit

final class RelatedListingListRequester: ListingListRequester {
    
    let itemsPerPage: Int
    
    private let listingType: ListingType
    private let listingObjectId: String
    private let listingRepository: ListingRepository
    private var offset: Int = 0
    private let featureFlags: FeatureFlags

    private var retrieveListingParams: RetrieveListingParams {
        var params = RetrieveListingParams()
        params.numListings = itemsPerPage
        params.offset = offset
        return params
    }

    convenience init(listingId: String, itemsPerPage: Int) {
        self.init(listingType: .product,
                  listingId: listingId,
                  itemsPerPage: itemsPerPage,
                  listingRepository: Core.listingRepository,
                  featureFlags: FeatureFlags.sharedInstance)
    }
    
    convenience init?(listing: Listing, itemsPerPage: Int) {
        guard let objectId = listing.objectId else { return nil }
        self.init(listingType: listing.listingType,
                  listingId: objectId,
                  itemsPerPage: itemsPerPage,
                  listingRepository: Core.listingRepository,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    private init(listingType: ListingType,
         listingId: String,
         itemsPerPage: Int,
         listingRepository: ListingRepository,
         featureFlags: FeatureFlags) {
        self.listingType = listingType
        self.listingObjectId = listingId
        self.listingRepository = listingRepository
        self.itemsPerPage = itemsPerPage
        self.featureFlags = featureFlags
    }
    
    var isFirstPage: Bool = true

    func canRetrieve() -> Bool {
        return true
    }
    
    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        offset = 0
        listingsRetrieval(completion)
    }
    
    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        isFirstPage = false
        listingsRetrieval(completion)
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(_ newOffset: Int) {}

    func duplicate() -> ListingListRequester {
        let r = RelatedListingListRequester(listingType: listingType,
                                            listingId: listingObjectId,
                                            itemsPerPage: itemsPerPage,
                                            listingRepository: listingRepository,
                                            featureFlags: FeatureFlags.sharedInstance)
        r.offset = offset
        return r
    }
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        return nil
    }
    var countryCode: String? {
        return nil
    }

    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? RelatedListingListRequester else { return false }
        return listingObjectId == requester.listingObjectId
    }
}

private extension RelatedListingListRequester {
    
    func listingsRetrieval(_ completion: ListingsRequesterCompletion?) {
        index(listingObjectId, retrieveListingParams) { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }
    
    private var index: ((String, RetrieveListingParams, ListingsCompletion?) -> ()) {
        switch listingType {
        case .product:
            return listingRepository.indexRelated
        case .realEstate:
            return featureFlags.realEstateEnabled.isActive ?
                listingRepository.indexRelatedRealEstate : listingRepository.indexRelated
        case .car:
            return listingRepository.indexRelatedCars
        case .service:
            return listingRepository.indexRelatedServices
        }
    }
}

private enum ListingType {
    case product, realEstate, car, service
}

private extension Listing {
    var listingType: ListingType {
        switch self {
        case .car:
            return .car
        case .service:
            return .service
        case .realEstate:
            return .realEstate
        case .product:
            return .product
        }
    }
}
