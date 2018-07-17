import LGCoreKit

class RelatedListingListRequester: ListingListRequester {
    
    fileprivate enum ListingType {
        case product, realEstate, car, service
    }
    
    fileprivate let listingType: ListingType
    let itemsPerPage: Int
    fileprivate let listingObjectId: String
    fileprivate let listingRepository: ListingRepository
    fileprivate var offset: Int = 0
    fileprivate let featureFlags: FeatureFlags

    fileprivate var retrieveListingParams: RetrieveListingParams {
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
        let type: RelatedListingListRequester.ListingType
        if listing.isCar {
            type = .car
        } else if listing.isRealEstate {
            type = .realEstate
        } else {
            type = .product
        }
        self.init(listingType: type,
                  listingId: objectId,
                  itemsPerPage: itemsPerPage,
                  listingRepository: Core.listingRepository,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    fileprivate init(listingType: ListingType,
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

fileprivate extension RelatedListingListRequester {
    
    func listingsRetrieval(_ completion: ListingsRequesterCompletion?) {
        let requestCompletion: ListingsCompletion = { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }

        switch (listingType, featureFlags.realEstateEnabled.isActive) {
        case (.product, _), (.realEstate, false):
            listingRepository.indexRelated(listingId: listingObjectId,
                                           params: retrieveListingParams,
                                           completion: requestCompletion)
        case (.realEstate, true):
            listingRepository.indexRelatedRealEstate(listingId: listingObjectId,
                                                     params: retrieveListingParams,
                                                     completion: requestCompletion)
        case (.car, _):
            listingRepository.indexRelatedCars(listingId: listingObjectId,
                                               params: retrieveListingParams,
                                               completion: requestCompletion)
        case (.service, _):
            if featureFlags.showServicesFeatures.isActive {
                listingRepository.indexRelatedServices(listingId: listingObjectId,
                                                   params: retrieveListingParams,
                                                   completion: requestCompletion)
            } else {
                listingRepository.indexRelated(listingId: listingObjectId,
                                               params: retrieveListingParams,
                                               completion: requestCompletion)
            }
        }
    }
}
