import Result

typealias ReportingDataSourceResult = Result<Void, ApiError>
typealias ReportingDataSourceCompletion = (ReportingDataSourceResult) -> Void

protocol ReportingDataSource {
    func createUserReport(reporterId: String, reportedId: String, reason: String, comment: String, completion: ReportingDataSourceCompletion?)
    func createListingReport(reporterId: String, reportedId: String, reason: String, comment: String, completion: ReportingDataSourceCompletion?)
    func updateUserReport(reportId: String, score: Int, completion: ReportingDataSourceCompletion?)
    func updateListingReport(reportId: String, score: Int, completion: ReportingDataSourceCompletion?)
}
