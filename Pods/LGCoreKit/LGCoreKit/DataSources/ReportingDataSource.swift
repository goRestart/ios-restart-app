import Result

typealias ReportingDataSourceResult = Result<Report, ApiError>
typealias ReportingDataSourceCompletion = (ReportingDataSourceResult) -> Void

typealias ReportingDataSourceEmptyResult = Result<Void, ApiError>
typealias ReportingDataSourceEmptyCompletion = (ReportingDataSourceEmptyResult) -> Void

protocol ReportingDataSource {
    func retrieveUserReport(reportId: String, completion: ReportingDataSourceCompletion?)
    func retrieveListingReport(reportId: String, completion: ReportingDataSourceCompletion?)
    func createUserReport(reporterId: String, reportedId: String, reason: String, comment: String, completion: ReportingDataSourceEmptyCompletion?)
    func createListingReport(reporterId: String, reportedId: String, reason: String, comment: String, completion: ReportingDataSourceEmptyCompletion?)
    func updateUserReport(reportId: String, score: Int, completion: ReportingDataSourceEmptyCompletion?)
    func updateListingReport(reportId: String, score: Int, completion: ReportingDataSourceEmptyCompletion?)
}
