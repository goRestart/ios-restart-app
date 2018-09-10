import LGCoreKit
import LGComponents

final class SectionedFeedRequester {
    
    private var requester: FeedRequester?
    private var firstCallCountryCode: String?
    
    private let feedRepository: FeedRepository
    private let locationManager: LocationManager
    private let variant: String
    
    init(withFeedRepository feedRepository: FeedRepository = Core.feedRepository,
         locationManager: LocationManager = Core.locationManager,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance){
        self.feedRepository = feedRepository
        self.locationManager = locationManager
        let currentLocation = locationManager.currentLocation
        self.variant = "\(featureFlags.sectionedFeedABTestIntValue)"
        requester = buildRequester(location: currentLocation?.location,
                                   countryCode: currentLocation?.countryCode)
    }
    
    func updateFeedRequester(withCurrentPlace currentPlace: Place) {
        requester = buildRequester(location: currentPlace.location,
                                   countryCode: currentPlace.postalAddress?.countryCode)
    }
    
    func retrieveFirst(_ completion: @escaping FeedCompletion) {
        requester?.retrieve(completion)
    }
    
    func retrieveNext(withUrl url: URL, completion: @escaping FeedCompletion) {
        requester?.retrieve(nextURL: url, completion)
    }
    
    private func buildRequester(location: LGLocationCoordinates2D?,
                                countryCode: String?) -> FeedRequester? {
        guard let location = location else { return nil }
        guard let countryCodeString = countryCode ?? firstCallCountryCode ?? locationManager.currentLocation?.countryCode else { return nil }
        firstCallCountryCode = countryCodeString
        let parameters = FeedIndexParameters(countryCode: countryCodeString,
                                             location: location,
                                             locale: Locale.systemLanguage(),
                                             page: 1,
                                             pageSize: SharedConstants.numListingsPerPageDefault,
                                             variant: variant)
        return FeedRequester(withRepository: feedRepository, params: parameters)
    }
}
