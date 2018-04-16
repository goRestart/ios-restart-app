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

    let phoneNumber: String
    var showResendCodeOption = Variable<Bool>(false)

    private var timer: Timer?
    private let timerDuration = 7.0

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
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
}
