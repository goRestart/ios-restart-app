import Foundation
import Result

public typealias ReportingResult = Result<Report, RepositoryError>
public typealias ReportingCompletion = (ReportingResult) -> Void

public typealias ReportingEmptyResult = Result<Void, RepositoryError>
public typealias ReportingEmptyCompletion = (ReportingEmptyResult) -> Void

public protocol ReportingRepository {
    func retrieveUserReport(reportId: String, completion: ReportingCompletion?)
    func retrieveProductReport(reportId: String, completion: ReportingCompletion?)
    func createUserReport(to userId: String, reason: String, comment: String, completion: ReportingEmptyCompletion?)
    func createListingReport(to listingId: String, reason: String, comment: String, completion: ReportingEmptyCompletion?)
    func updateUserReport(reportId: String, score: Int, completion: ReportingEmptyCompletion?)
    func updateListingReport(reportId: String, score: Int, completion: ReportingEmptyCompletion?)
}
