import Foundation

enum ChallengerRouter: URLRequestAuthenticable {
    
    private static let challengesBasePath = "challenges"
    
    case indexChallenges
    
    var endpoint: String {
        switch self {
        case .indexChallenges:
            return ChallengerRouter.challengesBasePath
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .indexChallenges:
            return .user
        }
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .indexChallenges:
            return try Router<ChallengerBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        }
    }
}
