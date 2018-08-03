//
enum CarsInfoRouter: URLRequestAuthenticable {

    static let carsMakeListURL = "car-makes"

    case index(params: [String: Any])

    var endpoint: String {
        switch self {
        case .index:
            return CarsInfoRouter.carsMakeListURL
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
        case let .index(params):
            return try Router<CarsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
}
