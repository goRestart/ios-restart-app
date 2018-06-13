
import LGCoreKit

enum MultiListingPostedStatus {
    
    case servicesImageUpload(params: [ListingCreationParams], images: [UIImage]?)
    case servicesPosting(params: [ListingCreationParams])
    case success(listings: [Listing])
    case error(error: EventParameterPostListingError)
    
    var listings: [Listing] {
        switch self {
        case .servicesPosting, .servicesImageUpload, .error:
            return []
        case .success(let listings):
            return listings
        }
    }
    
    var success: Bool {
        switch self {
        case .success:
            return true
        case .servicesPosting, .servicesImageUpload, .error:
            return false
        }
    }
    
    init(params: [ListingCreationParams],
         images: [UIImage]?) {
        guard let images = images else {
            self = .servicesPosting(params: params)
            return
        }
        self = .servicesImageUpload(params: params,
                                    images: images)
    }
    
    init(params: [ListingCreationParams]) {
        self = .servicesPosting(params: params)
    }
    
    init(listingsResult: ListingsResult) {
        if let listings = listingsResult.value {
            self = .success(listings: listings)
        } else if let error = listingsResult.error {
            self = .error(error: EventParameterPostListingError(error: error))
        } else {
            self = .error(error: .internalError(description: nil))
        }
    }
    
    init(error: RepositoryError) {
        let eventParameterPostListingError = EventParameterPostListingError(error: error)
        self = .error(error: eventParameterPostListingError)
    }
}
