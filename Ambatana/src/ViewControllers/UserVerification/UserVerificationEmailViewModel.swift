//
//  UserVerificationEmailViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 9/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import RxCocoa

final class UserVerificationEmailViewModel: BaseViewModel {
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker

    weak var navigator: VerifyUserEmailNavigator?
    weak var delegate: BaseViewModelDelegate?

    init(myUserRepository: MyUserRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
    }

    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance)
    }

    func sendVerification(with email: String) {
        guard email.isEmail() else { return }
        myUserRepository.linkAccount(email) { [weak self] result in
            if let error = result.error {
                switch error {
                case .tooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests,
                                                            completion: { self?.verificationFailed() })
                case .network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody,
                                                            completion: { self?.verificationFailed() })
                case .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified, .serverError, .wsChatError,
                     .searchAlertError:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody,
                                                            completion: { self?.verificationFailed() })
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess) {
                    self?.verificationSuccess()
                }
            }
        }
    }

    private func verificationSuccess() {
        trackComplete()
        navigator?.closeEmailVerification()
    }

    private func verificationFailed() {
        navigator?.closeEmailVerification()
    }
}

extension UserVerificationEmailViewModel {
    func trackComplete() {
        let event = TrackerEvent.verifyAccountComplete(.profile, network: .email)
        tracker.trackEvent(event)
    }
}
