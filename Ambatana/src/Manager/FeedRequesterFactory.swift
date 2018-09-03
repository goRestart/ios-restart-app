import LGCoreKit
import LGComponents

final class FeedRequesterFactory {
    
    static func make(withFeedRepository feedRepository: FeedRepository,
                     location: LGLocationCoordinates2D?,
                     countryCode: String?,
                     variant: String) -> FeedRequester? {
        guard let location = location, let countryCode = countryCode else { return nil }
        let parameters = FeedIndexParameters(countryCode: countryCode,
                                             location: location,
                                             locale: Locale.systemLanguage(),
                                             page: 1,
                                             pageSize: SharedConstants.numListingsPerPageDefault,
                                             variant: variant)
        return FeedRequester(withRepository: feedRepository, params: parameters)
    }
    
}
