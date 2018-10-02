final class ReportingApiDataSource: ReportingDataSource {

    private let apiClient: ApiClient

    private struct Keys {
        static let reporterIdentity = "reporter-identity"
        static let reportedIdentity = "reported-identity"
        static let reason = "reason"
        static let comment = "comment"
        static let score = "score"
        static let userType = "users-reports"
        static let listingType = "listings-reports"
    }


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - Actions

    func retrieveUserReport(reportId: String, completion: ReportingDataSourceCompletion?) {
        let request = ReportingRouter.showUserReport(id: reportId)
        apiClient.request(request, decoder: ReportingApiDataSource.decoder, completion: completion)
    }

    func retrieveListingReport(reportId: String, completion: ReportingDataSourceCompletion?) {
        let request = ReportingRouter.showListingReport(id: reportId)
        apiClient.request(request, decoder: ReportingApiDataSource.decoder, completion: completion)
    }

    func createUserReport(reporterId: String, reportedId: String, reason: String, comment: String?, completion: ReportingDataSourceEmptyCompletion?) {
        var attributes = [Keys.reporterIdentity: reporterId, Keys.reportedIdentity: reportedId, Keys.reason: reason]
        if let comment = comment {
            attributes[Keys.comment] = comment
        }
        let params: [String: Any] = JsonApi.usersReports.makeCreateRequest(attributes: attributes)
        let request = ReportingRouter.createUserReport(params: params)
        apiClient.request(request, completion: completion)
    }

    func createListingReport(reporterId: String, reportedId: String, reason: String, comment: String?, completion: ReportingDataSourceEmptyCompletion?) {
        var attributes = [Keys.reporterIdentity: reporterId, Keys.reportedIdentity: reportedId, Keys.reason: reason]
        if let comment = comment {
            attributes[Keys.comment] = comment
        }
        let params: [String: Any] = JsonApi.listingsReports.makeCreateRequest(attributes: attributes)
        let request = ReportingRouter.createListingReport(params: params)
        apiClient.request(request, completion: completion)
    }

    func updateUserReport(reportId: String, score: Int, completion: ReportingDataSourceEmptyCompletion?) {
        let attributes: [String: Any] = [Keys.score: score]
        let params: [String: Any] = JsonApi.usersReports.makeUpdateRequest(id: reportId, attributes: attributes)
        let request = ReportingRouter.updateUserReport(id: reportId, params: params)
        apiClient.request(request, completion: completion)
    }

    func updateListingReport(reportId: String, score: Int, completion: ReportingDataSourceEmptyCompletion?) {
        let attributes: [String: Any] = [Keys.score: score]
        let params: [String: Any] = JsonApi.listingsReports.makeUpdateRequest(id: reportId, attributes: attributes)
        let request = ReportingRouter.updateListingReport(id: reportId, params: params)
        apiClient.request(request, completion: completion)
    }
}

extension ReportingApiDataSource {
    fileprivate static func decoder(_ object: Any) -> Report? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let report = try? JSONDecoder().decode(LGReport.self, from: data) else {
                logAndReportParseError(object: object, entity: .report, comment: "could not parse Report")
                return nil
        }
        return report
    }
}
