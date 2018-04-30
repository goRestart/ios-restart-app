//
//  PasswordlessEmailViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 27/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

final class PasswordlessEmailViewModel: BaseViewModel {

    let isContinueActionEnabled = Variable<Bool>(false)

    init(foo: String) {
        // FIXME: implement
    }

    func didChange(email: String?) {
        isContinueActionEnabled.value = email?.isEmail() ?? false
    }

    func didTapContinueWith(email: String) {
        // FIXME: implement
    }

    func didTapHelp() {
        // FIXME: implement
    }
}
