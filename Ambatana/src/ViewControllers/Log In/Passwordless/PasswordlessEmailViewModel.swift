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

    weak var navigator: PasswordlessNavigator?

    private let tracker: TrackerProxy

    init(tracker: TrackerProxy = TrackerProxy.sharedInstance) {
        self.tracker = tracker
    }

    let isContinueActionEnabled = Variable<Bool>(false)

    func didChange(email: String?) {
        isContinueActionEnabled.value = email?.isEmail() ?? false
    }

    func didTapContinueWith(email: String) {
        tracker.trackEvent(.loginEmailSubmit())
        navigator?.openPasswordlessEmailSentTo(email: email)
    }

    func didTapHelp() {
        navigator?.openHelpFromPasswordless()
    }
}
