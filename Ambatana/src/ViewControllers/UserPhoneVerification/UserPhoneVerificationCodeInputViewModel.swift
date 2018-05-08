//
//  UserPhoneVerificationCodeInputViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

final class UserPhoneVerificationCodeInputViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?

    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    private var timer: Timer?

    enum ValidationState {
        case none
        case validating
        case success
        case failure(message: String)
    }

    let phoneNumber: String
    let showResendCodeOption = Variable<Bool>(false)
    let validationState = Variable<ValidationState>(.none)
    let resendCodeCountdown = Variable<Int>(50)

    init(phoneNumber: String,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.phoneNumber = phoneNumber
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        super.init()
        setupResendCodeTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func viewWillDisappear() {
        timer?.invalidate()
    }

    // MARK: Resend Code Timer

    private func setupResendCodeTimer() {
        timer = Timer
            .scheduledTimer(timeInterval: 1,
                            target: self,
                            selector: #selector(resendCodeTimerDidChange),
                            userInfo: nil,
                            repeats: true)

    }

    @objc private func resendCodeTimerDidChange() {
        guard resendCodeCountdown.value > 0 else {
            timer?.invalidate()
            showResendCodeOption.value = true
            return
        }

        resendCodeCountdown.value -= 1
    }

    // MARK: Code validation

    func validate(code: String) {
        validationState.value = .validating
        myUserRepository.validateSMSCode(code) { [weak self] result in
            switch result {
            case .success:
                self?.validationState.value = .success
                self?.tracker.trackEvent(.verifyAccountComplete(.smsVerification, network: .sms))
            case .failure:
                self?.validationState.value = .failure(message: LGLocalizedString.phoneVerificationCodeInputViewErrorMessage)
            }
        }
    }

    func didFinishVerification() {
        navigator?.closePhoneVerificaction()
    }
}
