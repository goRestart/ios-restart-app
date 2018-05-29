import Alamofire

enum ImageMultiplierRouter: URLRequestAuthenticable {

    case multipleIds(params: [String : Any])
    
    static let endpoint = "/api/products/image-multiplier"
    
    var requiredAuthLevel: AuthLevel {
        return .user
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .multipleIds(let params):
            return try Router<APIBaseURL>.create(endpoint: ImageMultiplierRouter.endpoint, params: params, encoding: .json).asURLRequest()
        }
    }
}

