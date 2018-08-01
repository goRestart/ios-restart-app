import Foundation
import LGCoreKit
import LGComponents
import RxSwift

final class ReportOptionsListViewModel: BaseViewModel {
    
    let title: String
    let optionGroup: ReportOptionsGroup
    let showReportButtonActive = Variable<Bool>(false)
    let showAdditionalNotes = Variable<Bool>(false)
    private let superReason: ReportOptionType?
    private let tracker: Tracker
    private let reportedId: String
    private let listing: Listing?
    private let source: EventParameterTypePage
    private let reportingRepository: ReportingRepository

    var navigator: ReportNavigator?
    private var selectedOption: ReportOption?

    init(optionGroup: ReportOptionsGroup,
         title: String,
         tracker: Tracker,
         reportedId: String,
         source: EventParameterTypePage,
         reportingRepository: ReportingRepository,
         superReason: ReportOptionType? = nil,
         listing: Listing? = nil) {
        self.optionGroup = optionGroup
        self.title = title
        self.superReason = superReason
        self.tracker = tracker
        self.reportedId = reportedId
        self.listing = listing
        self.source = source
        self.reportingRepository = reportingRepository
        super.init()
    }

    func didSelect(option: ReportOption) {
        if let child = option.childOptions {
            navigator?.openNextStep(with: child, from: option.type)
        } else {
            showAdditionalNotes.value = option.type.allowsAdditionalNotes
            showReportButtonActive.value = true
        }

        selectedOption = option
    }

    func didTapReport(with additionalNotes: String?) {
        guard let option = selectedOption else { return }
        guard let type = option.type.reportSentType else { return }
        if type.isForProduct {
            reportingRepository.createListingReport(to: reportedId,
                                                    reason: option.type.rawValue,
                                                    comment: additionalNotes ?? "") { [weak self] result in
                                                        self?.trackReportSent(withAdditionalNotes: additionalNotes != nil)
                                                        self?.navigator?.openReportSentScreen(type: type)
            }
        } else {
            reportingRepository.createUserReport(to: reportedId,
                                                 reason: option.type.rawValue,
                                                 comment: additionalNotes ?? "") { [weak self] result in
                                                    self?.trackReportSent(withAdditionalNotes: additionalNotes != nil)
                                                    self?.navigator?.openReportSentScreen(type: type)
            }
        }
    }

    func didTapClose() {
        navigator?.closeReporting()
    }

    private func trackReportSent(withAdditionalNotes: Bool) {
        guard let option = selectedOption else { return }
        guard let type = option.type.reportSentType else { return }

        let reason = superReason ?? option.type
        let subreason: ReportOptionType? = superReason != nil ? option.type : nil

        let event: TrackerEvent
        if let listing = listing, type.isForProduct {
            event = TrackerEvent.productReport(listing: listing,
                                               reason: reason,
                                               subreason: subreason,
                                               hasComment: EventParameterBoolean(bool: withAdditionalNotes))
        } else {
            event = TrackerEvent.userReport(typePage: EventParameterTypePage.chat,
                                            reportedUserId: reportedId,
                                            reason: reason,
                                            subreason: subreason,
                                            hasComment: EventParameterBoolean(bool: withAdditionalNotes))
        }

        tracker.trackEvent(event)
    }
}
