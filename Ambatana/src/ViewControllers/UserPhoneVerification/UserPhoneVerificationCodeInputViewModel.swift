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
    private var timer: Timer?
    private let timerDuration = 50.0

    enum ValidationState {
        case none, validating, success, failure
    }

    let phoneNumber: String
    let showResendCodeOption = Variable<Bool>(false)
    let validationState = Variable<ValidationState>(.none)

    init(phoneNumber: String,
         myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.phoneNumber = phoneNumber
        self.myUserRepository = myUserRepository
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
            .scheduledTimer(timeInterval: timerDuration,
                            target: self,
                            selector: #selector(resendCodeTimerDidFinish),
                            userInfo: nil,
                            repeats: false)

    }

    @objc private func resendCodeTimerDidFinish() {
        showResendCodeOption.value = true
    }

    // MARK: Code validation

    func validate(code: String) {
        validationState.value = .validating
        myUserRepository.validateSMSCode(code) { [weak self] result in
            switch result {
            case .success:
                self?.validationState.value = .success
            case .failure:
                self?.validationState.value = .failure
            }
        }
    }

    func didFinishVerification() {
        navigator?.closePhoneVerificaction()
    }
}
