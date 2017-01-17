//
//  ReportUsersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

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
                                                          didSendReport: LGLocalizedString.reportUserSendOk)
            } else if let error = result.error {
                if error.isNotModified() {
                    strongSelf.delegate?.reportUsersViewModel(strongSelf,
                                                              failedSendingReport: LGLocalizedString.reportUserErrorAlreadyReported)
                } else {
                    strongSelf.delegate?.reportUsersViewModel(strongSelf,
                                                              failedSendingReport: LGLocalizedString.reportUserSendFailure)
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
            return UIImage(named: "ic_report_offensive")
        case .scammer:
            return UIImage(named: "ic_report_scammer")
        case .mia:
            return UIImage(named: "ic_report_mia")
        case .suspicious:
            return UIImage(named: "ic_report_suspicious")
        case .inactive:
            return UIImage(named: "ic_report_inactive")
        case .prohibitedItems:
            return UIImage(named: "ic_report_prohibited")
        case .spammer:
            return UIImage(named: "ic_report_spammer")
        case .counterfeitItems:
            return UIImage(named: "ic_report_counterfeit")
        case .others:
            return UIImage(named: "ic_report_others")
        }
    }

    var text: String {
        switch self {
        case .offensive:
            return LGLocalizedString.reportUserOffensive
        case .scammer:
            return LGLocalizedString.reportUserScammer
        case .mia:
            return LGLocalizedString.reportUserMia
        case .suspicious:
            return LGLocalizedString.reportUserSuspcious
        case .inactive:
            return LGLocalizedString.reportUserInactive
        case .prohibitedItems:
            return LGLocalizedString.reportUserProhibitedItems
        case .spammer:
            return LGLocalizedString.reportUserSpammer
        case .counterfeitItems:
            return LGLocalizedString.reportUserCounterfeit
        case .others:
            return LGLocalizedString.reportUserOthers
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
