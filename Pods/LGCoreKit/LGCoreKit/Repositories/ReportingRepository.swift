import Foundation
import Result

public typealias ReportingResult = Result<Void, RepositoryError>
public typealias ReportingCompletion = (ReportingResult) -> Void

public protocol ReportingRepository {
    func createUserReport(to userId: String, reason: String, comment: String, completion: ReportingCompletion?)
    func createListingReport(to listingId: String, reason: String, comment: String, completion: ReportingCompletion?)
    func updateUserReport(reportId: String, score: Int, completion: ReportingCompletion?)
    func updateListingReport(reportId: String, score: Int, completion: ReportingCompletion?)
}
