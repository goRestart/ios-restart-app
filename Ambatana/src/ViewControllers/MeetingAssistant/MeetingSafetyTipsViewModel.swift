import Foundation
import LGComponents

final class MeetingSafetyTipsViewModel: BaseViewModel {

    var titleText: String {
        return R.Strings.meetingCreationTipsViewTitle
    }

    var subtitleText: String {
        return R.Strings.meetingCreationTipsViewSubtitle
    }

    var sendMeetingButtonIsHidden: Bool {
        return closeCompletion == nil
    }

    var sendMeetingButtonTitle: String {
        return R.Strings.meetingCreationTipsViewSendButton
    }

    var secondaryCloseButtonTitle: String {
        if let _ = closeCompletion {
            return R.Strings.meetingCreationTipsViewChangeButton
        } else {
            return R.Strings.meetingCreationTipsViewGotitButton
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
    private let keyValueStorage: KeyValueStorageable

    var navigator: MeetingSafetyTipsNavigator?

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
