import LGCoreKit
import LGComponents

protocol RecaptchaTokenDelegate: class {
    func recaptchaTokenObtained(token: String, action: LoginActionType)
}

final class RecaptchaViewModel: BaseViewModel {

    weak var delegate: RecaptchaTokenDelegate?
    private let action: LoginActionType
    private let tracker: Tracker
    
    var router: RecaptchaPasswordWireframe?

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
        router?.closeRecaptcha()
    }

    func startedLoadingURL(_ url: URL) {
        guard let token = tokenFromURL(url) else { return }
        router?.closeRecaptcha()
        delegate?.recaptchaTokenObtained(token: token, action: action)
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
