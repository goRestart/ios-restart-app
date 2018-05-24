import LGComponents
import LGCoreKit
import UIKit

final class MainCoordinator: Coordinator,
                             MainViewModelNavigator,
                             EmbeddedLoginViewModelNavigator,
                             MainSignUpNavigator,
                             SignUpLogInNavigator,
                             RecaptchaNavigator,
                             RememberPasswordNavigator,
                             HelpNavigator {
    var child: Coordinator?
    var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController {
        return navigationController
    }
    var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager
    private let navigationController: UINavigationController
    private weak var presentedNavigationController: UINavigationController?
    fileprivate weak var recaptchaTokenDelegate: RecaptchaTokenDelegate?


    // MARK: - Lifecycle

    convenience init() {
        self.init(sessionManager: Core.sessionManager,
                  bubbleNotificationManager: MockBubbleNotificationManager())
    }

    init(sessionManager: SessionManager,
         bubbleNotificationManager: BubbleNotificationManager) {
        self.child = nil
        self.coordinatorDelegate = nil
        self.presentedAlertController = nil
        self.sessionManager = sessionManager
        self.bubbleNotificationManager = bubbleNotificationManager
        let viewModel = MainViewModel()
        let viewController = MainViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        self.presentedNavigationController = nil

        viewModel.navigator = self
    }


    // MARK: - Coordinator

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismiss(animated: animated, completion: completion)
    }


    // MARK: - MainViewModelNavigator

    func openFullScreenLogin() {
        let config = LoginConfig(signUpEmailTermsAndConditionsAcceptRequired: false)
        let factory = LoginComponentFactory(config: config)
        let coordinator = factory.makeLoginCoordinator(source: .install,
                                                       style: .fullScreen,
                                                       loggedInAction: showLogInSuccessfulAlert,
                                                       cancelAction: showLogInCancelledAlert)
        openChild(coordinator: coordinator,
                  parent: viewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }

    func openPopUpLogin() {
        let config = LoginConfig(signUpEmailTermsAndConditionsAcceptRequired: false)
        let factory = LoginComponentFactory(config: config)
        let coordinator = factory.makeLoginCoordinator(source: .install,
                                                       style: .popup("You need to show you how to log in from a pop up 💅🏻"),
                                                       loggedInAction: showLogInSuccessfulAlert,
                                                       cancelAction: showLogInCancelledAlert)
        openChild(coordinator: coordinator,
                  parent: viewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }

    func openEmbeddedLogin() {
        let config = LoginConfig(signUpEmailTermsAndConditionsAcceptRequired: false)
        let factory = LoginComponentFactory(config: config)
        let signUpViewModel = factory.makeTourSignUpViewModel(source: .install)
        signUpViewModel.navigator = self
        let viewModel = EmbeddedLoginViewModel(signUpViewModel: signUpViewModel)
        viewModel.navigator = self
        let viewController = EmbeddedLoginViewController(viewModel: viewModel)
        signUpViewModel.delegate = viewController
        navigationController.pushViewController(viewController, animated: true)
    }


    // MARK: - MainSignUpNavigator

    func cancelMainSignUp() {
        closeEmbeddedLogin()
    }

    func closeMainSignUpSuccessful(with myUser: MyUser) {
        showAlert(message: "Log in successful") { [weak self] in
            self?.closeEmbeddedLogin()
        }
    }

    func closeMainSignUpAndOpenScammerAlert(contactURL: URL,
                                            network: EventParameterAccountNetwork) {
        showAlert(message: "You are a scammer") { [weak self] in
            self?.closeEmbeddedLogin()
        }
    }

    func closeMainSignUpAndOpenDeviceNotAllowedAlert(contactURL: URL,
                                                     network: EventParameterAccountNetwork) {
        showAlert(message: "Device not allowed") { [weak self] in
            self?.closeEmbeddedLogin()
        }
    }

    func openSignUpEmailFromMainSignUp(termsAndConditionsEnabled: Bool) {
        let config = LoginConfig(signUpEmailTermsAndConditionsAcceptRequired: termsAndConditionsEnabled)
        let factory = LoginComponentFactory(config: config)
        let signUpLogInViewController: UIViewController
        (signUpLogInViewController, recaptchaTokenDelegate) = factory.makeTourSignUpLogInViewController(source: .install,
                                                                                                        action: .signup,
                                                                                                        navigator: self)
        let navCtl = UINavigationController(rootViewController: signUpLogInViewController)
        navCtl.modalPresentationStyle = .custom
        navCtl.modalTransitionStyle = .crossDissolve
        viewController.present(navCtl,
                               animated: true,
                               completion: nil)
        presentedNavigationController = navCtl
    }

    func openLogInEmailFromMainSignUp(termsAndConditionsEnabled: Bool) {
        // will never be called
    }

    func openHelpFromMainSignUp() {
        showAlert(message: "Open help!")
    }

    func open(url: URL) {
        showAlert(message: "Open \(url.absoluteString)")
    }


    // MARK: - SignUpLogInNavigator

    func cancelSignUpLogIn() {
        closeSignUpLogIn()
    }

    func closeSignUpLogInSuccessful(with myUser: MyUser) {
        closeSignUpLogIn()
    }

    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL,
                                             network: EventParameterAccountNetwork) {
        closeSignUpLogIn()
    }

    func closeSignUpLogInAndOpenDeviceNotAllowedAlert(contactURL: URL,
                                                      network: EventParameterAccountNetwork) {
        closeSignUpLogIn()
    }

    private func closeSignUpLogIn() {
        presentedNavigationController?.dismiss(animated: true,
                                               completion: nil)
    }

    func openRecaptcha(action: LoginActionType) {
        let viewModel = RecaptchaViewModel(action: action)
        viewModel.navigator = self
        let viewController = RecaptchaViewController(viewModel: viewModel)
        topNavigationController.present(viewController,
                                        animated: true,
                                        completion: nil)
    }

    func openRememberPasswordFromSignUpLogIn(email: String?) {
        let viewModel = RememberPasswordViewModel(source: .install,
                                                  email: email)
        viewModel.navigator = self
        let viewController = RememberPasswordViewController(viewModel: viewModel,
                                                            appearance: .dark)
        topNavigationController.pushViewController(viewController,
                                                   animated: true)
    }

    func openHelpFromSignUpLogin() {
        let viewModel = HelpViewModel()
        viewModel.navigator = self
        let vc = HelpViewController(viewModel: viewModel)
        presentedNavigationController?.pushViewController(vc, animated: true)
    }


    // MARK: - EmbeddedLoginViewModelNavigator

    func closeEmbeddedLogin() {
        navigationController.popViewController(animated: true)
    }


    // MARK: - RecaptchaNavigator

    func recaptchaClose() {
        recaptchaViewController?.dismiss(animated: true, completion: nil)
    }

    func recaptchaFinishedWithToken(_ token: String,
                                    action: LoginActionType) {
        recaptchaViewController?.dismiss(animated: true) { [weak self] in
            self?.recaptchaTokenDelegate?.recaptchaTokenObtained(token: token, action: action)
        }
    }

    private var recaptchaViewController: RecaptchaViewController? {
        return topNavigationController.presentedViewController as? RecaptchaViewController
    }


    // MARK: - RememberPasswordNavigator

    func closeRememberPassword() {
        // called after the remember password network request calls back
        presentedNavigationController?.popViewController(animated: true)
    }


    // MARK: - HelpNavigator

    func closeHelp() {
        presentedNavigationController?.popViewController(animated: true)
    }


    // MARK: - Helpers

    private func showLogInSuccessfulAlert() {
        showAlert(message: "Log in successful")
    }

    private func showLogInCancelledAlert() {
        showAlert(message: "Log in cancelled")
    }

    private func showAlert(message: String,
                           completion: (() -> Void)? = nil) {
        guard presentedAlertController == nil else { return }
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: { [weak self] _ in
            self?.presentedAlertController = nil
        })
        alert.addAction(okAction)
        presentedAlertController = alert

        topNavigationController.present(alert,
                                        animated: true,
                                        completion: completion)
    }

    private var topNavigationController: UINavigationController {
        return presentedNavigationController ?? navigationController
    }
}
