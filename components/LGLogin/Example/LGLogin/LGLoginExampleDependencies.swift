import LGComponents
import LGCoreKit

class LGLoginExampleDependencies {
    let loginFactory: LoginComponentFactory
    let sessionManager: SessionManager
    let bubbleNotificationManager: BubbleNotificationManager

    init() {
        let loginConfig = LoginConfig(signUpEmailTermsAndConditionsAcceptRequired: false)
        self.loginFactory = LGLogin(config: loginConfig)
        self.sessionManager = Core.sessionManager
        self.bubbleNotificationManager = MockBubbleNotificationManager()
    }
}
