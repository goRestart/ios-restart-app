import Foundation
import LGComponents
import LGCoreKit
import RxSwift

final class ReportUpdateViewModel: BaseViewModel {

    let type: ReportUpdateType
    var navigator: ReportNavigator?
    var report: Variable<Report?> = Variable<Report?>(nil)

    private let reportingRepository: ReportingRepository
    private let tracker: Tracker
    private let reportId: String
    private let reportedUserId: String
    weak var delegate: BaseViewModelDelegate?

    init(type: ReportUpdateType,
         reportId: String,
         reportedUserId: String,
         reportingRepository: ReportingRepository,
         tracker: Tracker) {
        self.type = type
        self.reportId = reportId
        self.reportedUserId = reportedUserId
        self.reportingRepository = reportingRepository
        self.tracker = tracker
        super.init()
        retrieveReport()
    }

    func didTapClose() {
        navigator?.closeReporting()
    }

    private func retrieveReport() {
        delegate?.vmShowLoading(nil)
        let completion: (ReportingResult) -> Void = { [weak self] result in
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
            self?.report.value = result.value
            if let value = result.value {
                // Check if the user already provided feedback for this Report or not.
                if value.score == nil {
                    self?.trackUpdateSent()
                } else {
                    self?.automaticClose()
                }
            } else if let _ = result.error {
                self?.showErrorAlert()
            }
        }

        if type.isProductReport {
            reportingRepository.retrieveProductReport(reportId: reportId, completion: completion)
        } else {
            reportingRepository.retrieveUserReport(reportId: reportId, completion: completion)
        }
    }

    func showErrorAlert() {
        delegate?.vmShowAlert(R.Strings.commonErrorTitle,
                                    message: R.Strings.commonErrorGenericBody,
                                    cancelLabel: R.Strings.commonOk,
                                    actions: [])
    }

    func updateReport(with score: ReportUpdateButtonType, errorBlock: (() -> Void)?) {
        let completion: (ReportingEmptyResult) -> Void = { [weak self] result in
            if let _ = result.value {
                self?.trackUpdateCompleted(score: score)
                self?.automaticClose()
            } else {
                self?.showErrorAlert()
                errorBlock?()
            }
        }

        if type.isProductReport {
            reportingRepository.updateListingReport(reportId: reportId, score: score.rawValue, completion: completion)
        } else {
            reportingRepository.updateUserReport(reportId: reportId, score: score.rawValue, completion: completion)
        }
    }

    // Track when the Update notification is "sent" to the user.
    // i.e: When this screen is opened but hasn't send feedback yet (score == nil)
    private func trackUpdateSent() {
        guard let report = report.value else { return }
        let event: TrackerEvent
        if type.isProductReport {
            event = TrackerEvent.productReportUpdateSent(userId: report.reporterIdentity,
                                                         reportedUserId: reportedUserId,
                                                         listingId: report.reportedIdentity)
        } else {
            event = TrackerEvent.profileReportUpdateSent(userId: report.reporterIdentity,
                                                         reportedUserId: report.reporterIdentity)
        }
        tracker.trackEvent(event)
    }

    private func trackUpdateCompleted(score: ReportUpdateButtonType) {
        guard let report = report.value else { return }
        let event: TrackerEvent
        if type.isProductReport {
            event = TrackerEvent.producReportUpdateCompleted(userId: report.reporterIdentity,
                                                             reportedUserId: reportedUserId,
                                                             listingId: report.reportedIdentity,
                                                             rating: EventParameterReportingRating(reportType: score))
        } else {
            event = TrackerEvent.profileReportUpdateCompleted(userId: report.reporterIdentity,
                                                              reportedUserId: report.reportedIdentity,
                                                              rating: EventParameterReportingRating(reportType: score))
        }
        tracker.trackEvent(event)
    }

    private func automaticClose() {
        delay(1) {
            // TODO: Close once we know how this view will be opened
        }
    }
}
