import UIKit

public protocol LoginComponentFactory {
    var config: LoginComponentConfig { get set }

    func makeLoginCoordinator(source: EventParameterLoginSourceValue,
                              style: LoginStyle,
                              loggedInAction: @escaping (() -> Void),
                              cancelAction: (() -> Void)?) -> LoginCoordinator
    func makeTourSignUpViewModel(source: EventParameterLoginSourceValue) -> SignUpViewModel
    func makeTourSignUpLogInViewController(source: EventParameterLoginSourceValue,
                                           action: LoginActionType,
                                           navigator: SignUpLogInNavigator) -> (UIViewController, RecaptchaTokenDelegate?)
}
