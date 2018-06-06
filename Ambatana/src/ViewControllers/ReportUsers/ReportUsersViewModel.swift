import LGCoreKit
import LGComponents

protocol ReportUsersViewModelDelegate: class {

    func reportUsersViewModelDidUpdateReasons(_ viewModel: ReportUsersViewModel)
    func reportUsersViewModelDidStartSendingReport(_ viewModel: ReportUsersViewModel)
    func reportUsersViewModel(_ viewModel: ReportUsersViewModel, didSendReport successMsg: String)
    func reportUsersViewModel(_ viewModel: ReportUsersViewModel, failedSendingReport errorMsg: String)

}

class ReportUsersViewModel: BaseViewModel {

    weak var delegate: ReportUsersViewModelDelegate?

    private let userRepository: UserRepository

    private let userReportedId: String
    private let origin: EventParameterTypePage
    private let reportReasons: [ReportUserReason]
    private var reasonSelected: ReportUserReason?

    convenience init(origin: EventParameterTypePage, userReportedId: String) {
        let userRepository = Core.userRepository
        self.init(origin: origin, userReportedId: userReportedId, userRepository: userRepository)
    }

    init(origin: EventParameterTypePage, userReportedId: String, userRepository: UserRepository) {
        self.userRepository = userRepository
        self.origin = origin
        self.userReportedId = userReportedId
        self.reportReasons = ReportUserReason.all()

        super.init()
    }


    // MARK: - Public

    var saveButtonEnabled: Bool {
        return reasonSelected != nil
    }

    var reportReasonsCount: Int {
        return reportReasons.count
    }

    var selectedReasonIndex: Int? {
        guard let reasonSelected = reasonSelected else { return nil }
        return reportReasons.index(of: reasonSelected)
    }

    func imageForReasonAtIndex(_ index: Int) -> UIImage? {
        return reportReasons[index].image
    }

    func textForReasonAtIndex(_ index: Int) -> String {
        return reportReasons[index].text
    }

    func isReasonSelectedAtIndex(_ index: Int) -> Bool {
        guard let reasonSelected = reasonSelected else { return false }
        return reportReasons[index] == reasonSelected
    }

    func selectedReasonAtIndex(_ index: Int) {
        let reasonToSelect = reportReasons[index]
        if reasonSelected == reasonToSelect {
            reasonSelected = nil
        } else {
            reasonSelected = reasonToSelect
        }
        delegate?.reportUsersViewModelDidUpdateReasons(self)
    }
    
    func sendReport(_ comment: String?) {
        guard let reasonSelected = reasonSelected else { return }
        
        trackReport(reasonSelected)
        
        delegate?.reportUsersViewModelDidStartSendingReport(self)
        
        let params = ReportUserParams(reason: reasonSelected, comment: comment)
        
        userRepository.saveReport(userReportedId, params: params) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                strongSelf.delegate?.reportUsersViewModel(strongSelf,
                                                          didSendReport: R.Strings.reportUserSendOk)
            } else if let error = result.error {
                if error.isNotModified() {
                    strongSelf.delegate?.reportUsersViewModel(strongSelf,
                                                              failedSendingReport: R.Strings.reportUserErrorAlreadyReported)
                } else {
                    strongSelf.delegate?.reportUsersViewModel(strongSelf,
                                                              failedSendingReport: R.Strings.reportUserSendFailure)
                }
            }
        }
    }
    
    
    
    // MARK: - Private methods
    
    private func trackReport(_ reason: ReportUserReason) {
        let trackerEvent = TrackerEvent.profileReport(origin, reportedUserId: userReportedId, reason: reason.eventReason)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}


extension ReportUserReason {

    static func all() -> [ReportUserReason] {
        return [.offensive, .scammer, .mia, .suspicious, .inactive, .prohibitedItems, .spammer, .counterfeitItems,
            .others]
    }

    var image: UIImage? {
        switch self {
        case .offensive:
            return R.Asset.IconsButtons.icReportOffensive.image
        case .scammer:
            return R.Asset.IconsButtons.icReportScammer.image
        case .mia:
            return R.Asset.IconsButtons.icReportMia.image
        case .suspicious:
            return R.Asset.IconsButtons.icReportSuspicious.image
        case .inactive:
            return R.Asset.IconsButtons.icReportInactive.image
        case .prohibitedItems:
            return R.Asset.IconsButtons.icReportProhibited.image
        case .spammer:
            return R.Asset.IconsButtons.icReportSpammer.image
        case .counterfeitItems:
            return R.Asset.IconsButtons.icReportCounterfeit.image
        case .others:
            return R.Asset.IconsButtons.icReportOthers.image
        }
    }

    var text: String {
        switch self {
        case .offensive:
            return R.Strings.reportUserOffensive
        case .scammer:
            return R.Strings.reportUserScammer
        case .mia:
            return R.Strings.reportUserMia
        case .suspicious:
            return R.Strings.reportUserSuspcious
        case .inactive:
            return R.Strings.reportUserInactive
        case .prohibitedItems:
            return R.Strings.reportUserProhibitedItems
        case .spammer:
            return R.Strings.reportUserSpammer
        case .counterfeitItems:
            return R.Strings.reportUserCounterfeit
        case .others:
            return R.Strings.reportUserOthers
        }
    }

    var eventReason: EventParameterReportReason {
        switch self {
        case .offensive:
            return .offensive
        case .scammer:
            return .scammer
        case .mia:
            return .mia
        case .suspicious:
            return .suspicious
        case .inactive:
            return .inactive
        case .prohibitedItems:
            return .prohibitedItems
        case .spammer:
            return .spammer
        case .counterfeitItems:
            return .counterfeitItems
        case .others:
            return .other
        }
    }
}
