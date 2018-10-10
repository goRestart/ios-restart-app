import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

enum ReportStatus {
    case loading
    case pending
    case completed(score: Int)
}

final class ReportUpdateViewModel: BaseViewModel {

    let type: ReportUpdateType
    var navigator: ReportUpdateNavigator?

    let reportStatus = BehaviorRelay<ReportStatus>(value: .loading)
    private var report: BehaviorRelay<Report?> = BehaviorRelay<Report?>(value: nil)
    private let reportingRepository: ReportingRepository
    private let tracker: Tracker
    private let reportId: String
    private let reportedUserId: String
    private let automaticCloseDelay: Double = 2

    weak var delegate: BaseViewModelDelegate?

    init(type: ReportUpdateType,
         reportId: String,
         reportedUserId: String,
         reportingRepository: ReportingRepository = Core.reportingRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.type = type
        self.reportId = reportId
        self.reportedUserId = reportedUserId
        self.reportingRepository = reportingRepository
        self.tracker = tracker
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        retrieveReport()
    }

    func didTapClose() {
        navigator?.closeReportUpdate()
    }

    private func retrieveReport() {
        delegate?.vmShowLoading(nil)
        reportStatus.accept(.loading)
        let completion: (ReportingResult) -> Void = { [weak self] result in
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
            self?.report.accept(result.value)
            if let value = result.value {
                // Check if the user already provided feedback for this Report or not.
                if let score = value.score {
                    self?.reportStatus.accept(.completed(score: score))
                    self?.automaticClose()
                } else {
                    self?.reportStatus.accept(.pending)
                    self?.trackUpdateSent()
                }
            } else if let _ = result.error {
                self?.reportStatus.accept(.pending)
                self?.showErrorAlert(completion: { [weak self] in
                    self?.automaticClose()
                })
            }
        }

        if type.isProductReport {
            reportingRepository.retrieveProductReport(reportId: reportId, completion: completion)
        } else {
            reportingRepository.retrieveUserReport(reportId: reportId, completion: completion)
        }
    }

    func showErrorAlert(completion: (()->Void)? = nil) {
        let action = UIAction(interface: UIActionInterface.text(R.Strings.commonOk), action: {})
        delegate?.vmShowAlertWithTitle(R.Strings.commonErrorTitle,
                                       text: R.Strings.commonErrorGenericBody,
                                       alertType: AlertType.plainAlert, actions: [action], dismissAction: completion)
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
        delay(automaticCloseDelay) { [weak self] in
            self?.navigator?.closeReportUpdate()
        }
    }
}
