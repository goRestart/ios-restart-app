enum ServicesInfoRouter: URLRequestAuthenticable {
    
    static let localeParamKey: String = "locale"
    private static let serviceTypesListURLPathString: String = "/service-types"
    
    case index(params: [String: Any])
    
    private var endpoint: String {
        switch self {
        case .index:
            return ServicesInfoRouter.serviceTypesListURLPathString
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
        case let .index(params):
            return try Router<ServicesBaseURL>.index(endpoint: endpoint,
                                                     params: params).asURLRequest()
        }
    }
}
