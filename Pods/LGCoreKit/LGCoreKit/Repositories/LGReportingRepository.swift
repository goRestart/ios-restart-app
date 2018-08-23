import Foundation
import Result

final class LGReportingRepository: ReportingRepository {

    private let dataSource: ReportingDataSource
    private let myUserRepository: MyUserRepository

    // MARK: - Lifecycle

    init(dataSource: ReportingDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }

    func retrieveUserReport(reportId: String, completion: ReportingCompletion?) {
        dataSource.retrieveUserReport(reportId: reportId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func retrieveProductReport(reportId: String, completion: ReportingCompletion?) {
        dataSource.retrieveUserReport(reportId: reportId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func createUserReport(to userId: String, reason: String, comment: String, completion: ReportingEmptyCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(Result<Void, RepositoryError>(error: .internalError(message: "Missing MyUser objectId")))
            return
        }
        dataSource.createUserReport(reporterId: myUserId, reportedId: userId, reason: reason, comment: comment) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func createListingReport(to listingId: String, reason: String, comment: String, completion: ReportingEmptyCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(Result<Void, RepositoryError>(error: .internalError(message: "Missing MyUser objectId")))
            return
        }
        dataSource.createListingReport(reporterId: myUserId, reportedId: listingId, reason: reason, comment: comment) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func updateUserReport(reportId: String, score: Int, completion: ReportingEmptyCompletion?) {
        dataSource.updateUserReport(reportId: reportId, score: score) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func updateListingReport(reportId: String, score: Int, completion: ReportingEmptyCompletion?) {
        dataSource.updateUserReport(reportId: reportId, score: score) { result in
            handleApiResult(result, completion: completion)
        }
    }
}

