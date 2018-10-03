enum ReportingRouter: URLRequestAuthenticable {

    private static let userReportURL = "/api/users-reports"
    private static let listingReportURL = "/api/listings-reports"

    case showUserReport(id: String)
    case showListingReport(id: String)
    case createUserReport(params: [String: Any])
    case createListingReport(params: [String: Any])
    case updateUserReport(id: String, params: [String: Any])
    case updateListingReport(id: String, params: [String: Any])

    var endpoint: String {
        switch self {
        case .showUserReport, .createUserReport, .updateUserReport:
            return ReportingRouter.userReportURL
        case .showListingReport, .createListingReport, .updateListingReport:
            return ReportingRouter.listingReportURL
        }
    }

    var requiredAuthLevel: AuthLevel {
        return .user
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .showUserReport(let id):
            return try Router<ReportingBaseURL>.show(endpoint: endpoint, objectId: id).asURLRequest()
        case .showListingReport(let id):
            return try Router<ReportingBaseURL>.show(endpoint: endpoint, objectId: id).asURLRequest()
        case .createUserReport(let params):
            return try Router<ReportingBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        case .createListingReport(let params):
            return try Router<ReportingBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        case .updateUserReport(let id, let params):
            return try Router<ReportingBaseURL>.patch(endpoint: endpoint, objectId: id, params: params, encoding: .json).asURLRequest()
        case .updateListingReport(let id, let params):
            return try Router<ReportingBaseURL>.patch(endpoint: endpoint, objectId: id, params: params, encoding: .json).asURLRequest()
        }
    }
}
