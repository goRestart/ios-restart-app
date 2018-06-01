import Foundation

enum SpellCorretorRouter: URLRequestAuthenticable {
    
    private static let relaxBaseUrl = "/relax"
    private static let similarBaseUrl = "/similar"

    case relaxQuery(searchTerm: String, params: [String: Any])
    case similarQuery(searchTerm: String, params: [String: Any])
    
    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .relaxQuery(_, let params):
            return try Router<SpellCorrectorBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .similarQuery(_, let params):
            return try Router<SpellCorrectorBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
    
    private var endpoint: String {
        switch self {
        case let .relaxQuery(searchTerm, _):
            return SpellCorretorRouter.relaxBaseUrl + "/\(searchTerm)"
        case let .similarQuery(searchTerm, _):
            return SpellCorretorRouter.similarBaseUrl + "/\(searchTerm)"
        }
    }
}
