import LGCoreKit

final public class LoginComponentFactory {
    public var config: LoginComponentConfig
    private let bubbleNotificationManager: BubbleNotificationManager
    private let tracker: Tracker
    private let sessionManager: SessionManager


    // MARK: - Lifecycle

    public convenience init(config: LoginComponentConfig) {
        self.init(config: config,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    private init(config: LoginComponentConfig,
                 bubbleNotificationManager: BubbleNotificationManager,
                 tracker: Tracker,
                 sessionManager: SessionManager
                 ) {
        self.config = config
        self.bubbleNotificationManager = bubbleNotificationManager
        self.tracker = tracker
        self.sessionManager = sessionManager
    }


    // MARK: - Factory

    public func makeLoginCoordinator(source: EventParameterLoginSourceValue,
                                     style: LoginStyle,
                                     loggedInAction: @escaping (() -> Void),
                                     cancelAction: (() -> Void)?) -> LoginCoordinator {
        return LoginCoordinator(source: source,
                                style: style,
                                loggedInAction: loggedInAction,
                                cancelAction: cancelAction,
                                bubbleNotificationManager: bubbleNotificationManager,
                                tracker: tracker,
                                sessionManager: sessionManager,
                                termsAndConditionsEnabled: config.signUpEmailTermsAndConditionsAcceptRequired)
    }

    public func makeTourSignUpViewModel(source: EventParameterLoginSourceValue) -> SignUpViewModel {
        return SignUpViewModel(appearance: .dark,
                               source: source,
                               termsAndConditionsEnabled: config.signUpEmailTermsAndConditionsAcceptRequired)
    }
}
