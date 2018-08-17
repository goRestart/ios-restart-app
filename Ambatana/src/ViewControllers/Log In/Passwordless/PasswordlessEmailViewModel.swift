//
//  PasswordlessEmailViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 27/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import LGComponents
import RxSwift

final class PasswordlessEmailViewModel: BaseViewModel {

    weak var navigator: PasswordlessNavigator?
    weak var delegate: BaseViewModelDelegate?

    private let sessionManager: SessionManager
    private let tracker: Tracker
    private let installationRepository: InstallationRepository

    init(sessionManager: SessionManager = Core.sessionManager,
         installationRepository: InstallationRepository = Core.installationRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
        self.tracker = tracker
    }

    let isContinueActionEnabled = Variable<Bool>(false)

    func didChange(email: String?) {
        isContinueActionEnabled.value = email?.isEmail() ?? false
    }

    func didTapContinueWith(email: String) {
        sessionManager.requestPasswordlessWith(email: email) { [weak self] result in
            switch result {
            case .success:
                self?.navigator?.openPasswordlessEmailSentTo(email: email)
            case .failure(let error):
                switch error {
                case .scammer:
                    self?.showScammerAlert(email, network: .passwordless)
                case .nonExistingEmail:
                    self?.showDeviceNotAllowedAlert(email, network: .passwordless)
                default:
                    self?.showGenericError()
                }

                break
            }
        }
        tracker.trackEvent(.loginEmailSubmit())
    }

    private func showScammerAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
                                                                type: .scammer) else {
                                                                    return
        }
        navigator?.closeSignUpLogInAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    private func showDeviceNotAllowedAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
                                                                type: .deviceNotAllowed) else {
                                                                    return
        }
        navigator?.closeSignUpLogInAndOpenDeviceNotAllowedAlert(contactURL: contactURL, network: network)
    }

    private func showGenericError() {
        let message = R.Strings.commonErrorGenericBody
        delegate?.vmShowAutoFadingMessage(message, completion: nil)
    }

    func didTapHelp() {
        navigator?.openHelpFromPasswordless()
    }
}
