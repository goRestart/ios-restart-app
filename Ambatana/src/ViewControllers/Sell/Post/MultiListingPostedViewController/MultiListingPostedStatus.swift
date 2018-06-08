
import LGCoreKit

enum MultiListingPostedStatus {
    
    case posting(images: [UIImage]?, video: RecordedVideo?, params: [ListingCreationParams])
    case success(listings: [Listing])
    case error(error: EventParameterPostListingError)
    
    var listings: [Listing] {
        switch self {
        case .posting, .error:
            return []
        case .success(let listings):
            return listings
        }
    }
    
    var success: Bool {
        switch self {
        case .success:
            return true
        case .posting, .error:
            return false
        }
    }
    
    init(images: [UIImage]?,
         video: RecordedVideo?,
         params: [ListingCreationParams]) {
        self = .posting(images: images, video: video, params: params)
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
