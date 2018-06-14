enum ServicesInfoRouter: URLRequestAuthenticable {
    
    private static let serviceTypesListURLPathString: String = "/service-types"
    
    case index(locale: String)
    
    private var endpoint: String {
        switch self {
        case .index(let locale):
            return ServicesInfoRouter.serviceTypesListURLPathString + "/\(locale)"
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .index:
            return AuthLevel.nonexistent
        }
    }
    
    var reportingBlacklistedApiError: Array<ApiError> {
        return [ApiError.scammer]
    }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .index:
            return try Router<ServicesBaseURL>.index(endpoint: endpoint,
                                                     params: [:]).asURLRequest()
        }
    }
}
