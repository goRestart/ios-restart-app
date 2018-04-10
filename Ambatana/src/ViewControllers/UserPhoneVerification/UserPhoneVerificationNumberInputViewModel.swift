//
//  SMSPhoneInputViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 03/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import RxCocoa

struct CountryPhoneCode {
    let code: Int
    let name: String
}

final class UserPhoneVerificationNumberInputViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?

    var country: Driver<CountryPhoneCode?> { return .just(nil) }
    var isContinueActionEnabled: Driver<Bool> { return .just(false) }

    init(fake: String? = "") {
        super.init()
    }

    func didTapCountryButton() {
        navigator?.openCountrySelector()
    }

    func didTapContinueButton() {
        navigator?.openCodeInput()
    }
}
