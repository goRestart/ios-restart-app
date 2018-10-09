import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class ReportOptionsListViewModel: BaseViewModel {
    
    let title: String
    let optionGroup: ReportOptionsGroup
    let showReportButtonActive = BehaviorRelay<Bool>(value: false)
    let showAdditionalNotes = BehaviorRelay<Bool>(value: false)
    private let superReason: ReportOptionType?
    private let tracker: Tracker
    private let reportedId: String
    private let listing: Listing?
    private let source: EventParameterTypePage
    private let reportingRepository: ReportingRepository
    private let featureFlags: FeatureFlaggeable

    var navigator: ReportNavigator?
    private var selectedOption: ReportOption?
    weak var delegate: BaseViewModelDelegate?
    var shouldShowIcons: Bool {
        return featureFlags.reportingFostaSesta.shouldShowIcons
    }

    init(optionGroup: ReportOptionsGroup,
         title: String,
         reportedId: String,
         source: EventParameterTypePage,
         superReason: ReportOptionType? = nil,
         listing: Listing? = nil,
         tracker: Tracker = TrackerProxy.sharedInstance,
         reportingRepository: ReportingRepository = Core.reportingRepository,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.optionGroup = optionGroup
        self.title = title
        self.superReason = superReason
        self.tracker = tracker
        self.reportedId = reportedId
        self.listing = listing
        self.source = source
        self.reportingRepository = reportingRepository
        self.featureFlags = featureFlags
        super.init()
    }

    func didSelect(option: ReportOption) {
        if let child = option.childOptions {
            navigator?.openNextStep(with: child, from: option.type)
        } else {
            showAdditionalNotes.accept(option.type.allowsAdditionalNotes)
            showReportButtonActive.accept(true)
        }

        selectedOption = option
    }

    func didTapReport(with additionalNotes: String?) {
        guard let option = selectedOption else { return }
        guard let type = option.type.reportSentType else { return }

        let completion: (ReportingEmptyResult) -> Void = { [weak self] result in
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
            if let _ = result.value {
                self?.trackReportSent(withAdditionalNotes: additionalNotes != nil)
                self?.navigator?.openReportSentScreen(sentType: type)
            } else if let _ = result.error {
                self?.delegate?.vmShowAlert(R.Strings.commonErrorTitle,
                                            message: R.Strings.commonErrorGenericBody,
                                            cancelLabel: R.Strings.commonOk, actions: [])
            }
        }

        let comment = additionalNotes == "" ? nil : additionalNotes

        self.delegate?.vmShowLoading(nil)
        if type.isForProduct {
            reportingRepository.createListingReport(to: reportedId,
                                                    reason: option.type.rawValue,
                                                    comment: comment,
                                                    completion: completion)
        } else {
            reportingRepository.createUserReport(to: reportedId,
                                                 reason: option.type.rawValue,
                                                 comment: comment,
                                                 completion: completion)
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
