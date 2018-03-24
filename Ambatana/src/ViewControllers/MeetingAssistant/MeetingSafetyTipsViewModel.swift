//
//  MeetingSafetyTipsViewModel.swift
//  LetGo
//
//  Created by Dídac on 24/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class MeetingSafetyTipsViewModel: BaseViewModel {

    var titleText: String {
        return "_ Pick a safe, convenient place to meet"
    }

    var subtitleText: String {
        return "_ We recommend meeting during daylight hours at a busy, well-lit, public place like a local coffee shop or bank lobby."
    }

    var sendMeetingButtonIsHidden: Bool {
        return closeCompletion == nil
    }

    var sendMeetingButtonTitle: String {
        return "_ Send meeting"
    }

    var secondaryCloseButtonTitle: String {
        if let _ = closeCompletion {
            return "_ Change meeting"
        } else {
            return "_ Got it"
        }
    }

    var secondaryCloseButtonStyle: ButtonStyle {
        if let _ = closeCompletion {
            return .secondary(fontSize: .big, withBorder: true)
        } else {
            return .primary(fontSize: .big)
        }
    }

    private var closeCompletion: (()->Void)?
    private var keyValueStorage: KeyValueStorageable

    weak var navigator: MeetingAssistantNavigator?


    convenience init(closeCompletion: (()->Void)?) {
        self.init(closeCompletion: closeCompletion, keyValueStorage: KeyValueStorage.sharedInstance)
    }

    init(closeCompletion: (()->Void)?, keyValueStorage: KeyValueStorageable) {
        self.closeCompletion = closeCompletion
        self.keyValueStorage = keyValueStorage
        super.init()

    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        keyValueStorage.meetingSafetyTipsAlreadyShown = true
    }

    func closeTips() {
        navigator?.closeMeetingTipsWith(closeCompletion: nil)
    }

    func closeTipsAndSendMeeting() {
        navigator?.closeMeetingTipsWith(closeCompletion: closeCompletion)
    }

}
