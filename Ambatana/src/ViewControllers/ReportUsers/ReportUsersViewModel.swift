//
//  ReportUsersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ReportUsersViewModelDelegate: class {

    func reportUsersViewModelDidUpdateReasons(viewModel: ReportUsersViewModel)
    func reportUsersViewModelDidStartSendingReport(viewModel: ReportUsersViewModel)
    func reportUsersViewModel(viewModel: ReportUsersViewModel, didSendReport successMsg: String)
    func reportUsersViewModel(viewModel: ReportUsersViewModel, failedSendingReport errorMsg: String)

}

class ReportUsersViewModel: BaseViewModel {

    weak var delegate: ReportUsersViewModelDelegate?

    private let userRepository: UserRepository

    private let userReported: User
    private let origin: EventParameterTypePage
    private let reportReasons: [ReportUserReason]
    private var reasonSelected: ReportUserReason?

    convenience init(origin: EventParameterTypePage, userReported: User) {
        let userRepository = Core.userRepository
        self.init(origin: origin, userReported: userReported, userRepository: userRepository)
    }

    init(origin: EventParameterTypePage, userReported: User, userRepository: UserRepository) {
        self.userRepository = userRepository
        self.origin = origin
        self.userReported = userReported
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
        return reportReasons.indexOf(reasonSelected)
    }

    func imageForReasonAtIndex(index: Int) -> UIImage? {
        return reportReasons[index].image
    }

    func textForReasonAtIndex(index: Int) -> String {
        return reportReasons[index].text
    }

    func isReasonSelectedAtIndex(index: Int) -> Bool {
        guard let reasonSelected = reasonSelected else { return false }
        return reportReasons[index] == reasonSelected
    }

    func selectedReasonAtIndex(index: Int) {
        let reasonToSelect = reportReasons[index]
        if reasonSelected == reasonToSelect {
            reasonSelected = nil
        } else {
            reasonSelected = reasonToSelect
        }
        delegate?.reportUsersViewModelDidUpdateReasons(self)
    }
    
    func sendReport(comment: String?) {
        guard let reasonSelected = reasonSelected else { return }
        
        trackReport(reasonSelected)
        
        delegate?.reportUsersViewModelDidStartSendingReport(self)
        
        let params = ReportUserParams(reason: reasonSelected, comment: comment)
        userRepository.saveReport(userReported, params: params) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                strongSelf.delegate?.reportUsersViewModel(strongSelf,
                    didSendReport: LGLocalizedString.reportUserSendOk)
            } else if let error = result.error {
                if case .Internal(let string) = error where string == "Not modified in API" {
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
    
    private func trackReport(reason: ReportUserReason) {
        let trackerEvent = TrackerEvent.profileReport(origin, reportedUser: userReported, reason: reason.eventReason)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}


extension ReportUserReason {

    static func all() -> [ReportUserReason] {
        return [.Offensive, .Scammer, .Mia, .Suspicious, .Inactive, .ProhibitedItems, .Spammer, .CounterfeitItems,
            .Others]
    }

    var image: UIImage? {
        switch self {
        case .Offensive:
            return UIImage(named: "ic_report_offensive")
        case .Scammer:
            return UIImage(named: "ic_report_scammer")
        case .Mia:
            return UIImage(named: "ic_report_mia")
        case .Suspicious:
            return UIImage(named: "ic_report_suspicious")
        case .Inactive:
            return UIImage(named: "ic_report_inactive")
        case .ProhibitedItems:
            return UIImage(named: "ic_report_prohibited")
        case .Spammer:
            return UIImage(named: "ic_report_spammer")
        case .CounterfeitItems:
            return UIImage(named: "ic_report_counterfeit")
        case .Others:
            return UIImage(named: "ic_report_others")
        }
    }

    var text: String {
        switch self {
        case .Offensive:
            return LGLocalizedString.reportUserOffensive
        case .Scammer:
            return LGLocalizedString.reportUserScammer
        case .Mia:
            return LGLocalizedString.reportUserMia
        case .Suspicious:
            return LGLocalizedString.reportUserSuspcious
        case .Inactive:
            return LGLocalizedString.reportUserInactive
        case .ProhibitedItems:
            return LGLocalizedString.reportUserProhibitedItems
        case .Spammer:
            return LGLocalizedString.reportUserSpammer
        case .CounterfeitItems:
            return LGLocalizedString.reportUserCounterfeit
        case .Others:
            return LGLocalizedString.reportUserOthers
        }
    }

    var eventReason: EventParameterReportReason {
        switch self {
        case .Offensive:
            return .Offensive
        case .Scammer:
            return .Scammer
        case .Mia:
            return .Mia
        case .Suspicious:
            return .Suspicious
        case .Inactive:
            return .Inactive
        case .ProhibitedItems:
            return .ProhibitedItems
        case .Spammer:
            return .Spammer
        case .CounterfeitItems:
            return .CounterfeitItems
        case .Others:
            return .Other
        }
    }
}
