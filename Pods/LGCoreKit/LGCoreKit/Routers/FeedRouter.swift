import Foundation

enum FeedRouter: URLRequestAuthenticable {
    
    static let feedBasePath = "api/feed"
    
    case index(countryCode: String, locale: String, location: LGLocationCoordinates2D, page: Int, pageSize: Int,
        variant: String)
    
    var endpoint: String {
        switch self {
        case .index:
            return FeedRouter.feedBasePath
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .index:
            return .nonexistent
        }
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .index(countryCode, locale, location, page, pageSize, variant):
            var params = [String : Any]()
            params["country_code"] = countryCode
            params["locale"] = locale
            params["latitude"] = location.latitude
            params["longitude"] = location.longitude
            params["page"] = page
            params["pageSize"] = pageSize
            params["variant"] = variant
            return try Router<FeedBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
}
