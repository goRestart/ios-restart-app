import LGCoreKit

protocol RecaptchaNavigator: class {
    func recaptchaClose()
    func recaptchaFinishedWithToken(_ token: String, action: LoginActionType)
}

final class RecaptchaViewModel: BaseViewModel {

    weak var navigator: RecaptchaNavigator?
    private let action: LoginActionType
    private let tracker: Tracker

    convenience init(action: LoginActionType) {
        self.init(action: action,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(action: LoginActionType,
         tracker: Tracker) {
        self.action = action
        self.tracker = tracker
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            trackVisit()
        }
    }

    var url: URL? {
        return LetgoURLHelper.buildRecaptchaURL()
    }

    @objc func closeButtonPressed() {
        navigator?.recaptchaClose()
    }

    func startedLoadingURL(_ url: URL) {
        guard let token = tokenFromURL(url) else { return }
        navigator?.recaptchaFinishedWithToken(token, action: action)
    }

    func urlLoaded(_ url: URL) { }


    // MARK: - Private methods

    private func tokenFromURL(_ url: URL) -> String? {
        let queryParams = url.queryParameters
        return queryParams["token"]
    }

    private func trackVisit() {
        let event: TrackerEvent
        switch action {
        case .login:
            event = TrackerEvent.loginCaptcha()
        case .signup:
            event = TrackerEvent.signupCaptcha()
        }
        tracker.trackEvent(event)
    }
}
