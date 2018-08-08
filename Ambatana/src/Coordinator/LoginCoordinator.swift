import LGCoreKit
import RxSwift
import SafariServices
import LGComponents

enum LoginStyle {
    case fullScreen
    case popup(String)
}

protocol RecaptchaTokenDelegate: class {
    func recaptchaTokenObtained(token: String, action: LoginActionType)
}

final class LoginCoordinator: Coordinator {
    var child: Coordinator?
    var viewController: UIViewController
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    fileprivate var parentViewController: UIViewController?
    fileprivate var presentedViewControllers: [UIViewController] = []
    fileprivate weak var recaptchaTokenDelegate: RecaptchaTokenDelegate?

    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let style: LoginStyle
    fileprivate let loggedInAction: () -> Void
    fileprivate let cancelAction: (() -> Void)?

    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: EventParameterLoginSourceValue,
                     style: LoginStyle,
                     loggedInAction: @escaping (() -> Void),
                     cancelAction: (() -> Void)?) {
        self.init(source: source,
                  style: style,
                  loggedInAction: loggedInAction,
                  cancelAction: cancelAction,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(source: EventParameterLoginSourceValue,
         style: LoginStyle,
         loggedInAction: @escaping (() -> Void),
         cancelAction: (() -> Void)?,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker,
         featureFlags: FeatureFlags,
         sessionManager: SessionManager) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.source = source
        self.style = style
        self.loggedInAction = loggedInAction
        self.cancelAction = cancelAction

        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager
        let viewModel = SignUpViewModel(appearance: .light, source: source)
        switch style {
        case .fullScreen:
            let mainSignUpVC = MainSignUpViewController(viewModel: viewModel)
            let navCtl = UINavigationController(rootViewController: mainSignUpVC)
            self.viewController = navCtl
        case .popup(let message):
            let popUpSignUpVC = PopupSignUpViewController(viewModel: viewModel, topMessage: message)
            self.viewController = popUpSignUpVC
        }
        viewModel.navigator = self
    }
    
    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }

        parentViewController = parent
        viewController.modalTransitionStyle = .crossDissolve
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        if let vc = presentedViewControllers.last {
            presentedViewControllers.removeLast()
            vc.dismissWithPresented(animated: false) { [weak self] in
                self?.dismissViewController(animated: animated, completion: completion)
            }
        } else {
            viewController.dismissWithPresented(animated: animated, completion: completion)
        }
    }
}


// MARK: - MainSignUpNavigator

extension LoginCoordinator: MainSignUpNavigator {
    func cancelMainSignUp() {
        closeRoot(didLogIn: false)
    }

    func closeMainSignUpSuccessful(with myUser: MyUser) {
        closeRoot(didLogIn: true)
    }

    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    func closeMainSignUpAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenDeviceNotAllowedAlert(contactURL: contactURL, network: network)
    }

    func openSignUpEmailFromMainSignUp() {
        let vc: UIViewController
        let vm = SignUpLogInViewModel(source: source, action: .signup)
        vm.navigator = self
        vc = SignUpLogInViewController(viewModel: vm,
                                       appearance: .light,
                                       keyboardFocus: false)
        recaptchaTokenDelegate = vm


        switch style {
        case .fullScreen:
            guard let navCtl = viewController as? UINavigationController else { return }

            navCtl.pushViewController(vc, animated: true)

        case .popup:
            guard viewController is PopupSignUpViewController else { return }

            let navCtl = UINavigationController(rootViewController: vc)
            presentedViewControllers.append(navCtl)
            viewController.present(navCtl, animated: true, completion: nil)
        }
    }

    func openLogInEmailFromMainSignUp() {
        let vc: UIViewController

        let vm = SignUpLogInViewModel(source: source, action: .login)
        vm.navigator = self
        vc = SignUpLogInViewController(viewModel: vm,
                                       appearance: .light,
                                       keyboardFocus: false)

        recaptchaTokenDelegate = vm

        switch style {
        case .fullScreen:
            guard let navCtl = viewController as? UINavigationController else { return }

            navCtl.pushViewController(vc, animated: true)

        case .popup:
            guard viewController is PopupSignUpViewController else { return }

            let navCtl = UINavigationController(rootViewController: vc)
            presentedViewControllers.append(navCtl)
            viewController.present(navCtl, animated: true, completion: nil)
        }
    }

    func openHelpFromMainSignUp() {
        openHelp()
    }
}

// MARK: - V1
// MARK: - SignUpLogInNavigator

extension LoginCoordinator: SignUpLogInNavigator {

    func cancelSignUpLogIn() {
        // called when closing from popup login so it's not closing root only presented controller
        dismissLastPresented(animated: true, completion: nil)
    }

    func closeSignUpLogInSuccessful(with myUser: MyUser) {
        closeRoot(didLogIn: true)
    }

    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    func closeSignUpLogInAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenDeviceNotAllowedAlert(contactURL: contactURL, network: network)
    }

    func openRecaptcha(action: LoginActionType) {
        let topVC = topViewController()

        let vm = RecaptchaViewModel(action: action)
        vm.navigator = self
        let vc = RecaptchaViewController(viewModel: vm)
        presentedViewControllers.append(vc)
        topVC.present(vc, animated: true, completion: nil)
    }

    func openRememberPasswordFromSignUpLogIn(email: String?) {
        openRememberPassword(email: email)
    }

    func openHelpFromSignUpLogin() {
        openHelp()
    }
}


// MARK: - RememberPasswordNavigator

extension LoginCoordinator: RememberPasswordNavigator {
    func closeRememberPassword() {
        guard let navCtl = currentNavigationController() else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - HelpNavigator

extension LoginCoordinator: HelpNavigator {
    func closeHelp() {
        guard let navCtl = currentNavigationController() else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - RecaptchaNavigator

extension LoginCoordinator: RecaptchaNavigator {
    func recaptchaClose() {
        guard topViewController() is RecaptchaViewController else { return }
        dismissLastPresented(animated: true, completion: nil)
    }

    func recaptchaFinishedWithToken(_ token: String, action: LoginActionType) {
        guard topViewController() is RecaptchaViewController else { return }
        dismissLastPresented(animated: true) { [weak self] in
            self?.recaptchaTokenDelegate?.recaptchaTokenObtained(token: token, action: action)
        }
    }
}

// MARK: - Common Navigator

extension LoginCoordinator {
    func open(url: URL) {
        let vc = topViewController()
        vc.openInAppWebViewWith(url: url)
    }
}


// MARK: - Private

fileprivate extension LoginCoordinator {
    func closeRoot(didLogIn: Bool) {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            if didLogIn {
                strongSelf.loggedInAction()
            } else {
                if let action = strongSelf.cancelAction {
                    action()
                }
            }
        }
    }

    func closeRootAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        dismissViewController(animated: true) { [weak self] in
            let contact = UIAction(
                interface: .button(R.Strings.loginScammerAlertContactButton, .primary(fontSize: .medium)),
                action: {
                    self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network, reason: .accountUnderReview))
                    self?.closeCoordinator(animated: false) {
                        self?.parentViewController?.openInAppWebViewWith(url: contactURL)
                    }

            })
            let keepBrowsing = UIAction(
                interface: .button(R.Strings.loginScammerAlertKeepBrowsingButton, .secondary(fontSize: .medium,
                                                                                                     withBorder: false)),
                action: {
                    self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network, reason: .accountUnderReview))
                    self?.closeCoordinator(animated: false, completion: nil)
            })
            let actions = [contact, keepBrowsing]
            self?.parentViewController?.showAlertWithTitle(R.Strings.loginScammerAlertTitle,
                                                           text: R.Strings.loginScammerAlertMessage,
                                                           alertType: .iconAlert(icon: R.Asset.IconsButtons.icModerationAlert.image),
                                                           buttonsLayout: .vertical, actions: actions)
            self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network, reason: .accountUnderReview))
        }
    }

    func closeRootAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        dismissViewController(animated: true) { [weak self] in
            let contact = UIAction(
                interface: .button(R.Strings.loginDeviceNotAllowedAlertContactButton, .primary(fontSize: .medium)),
                action: {
                    self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network, reason: .secondDevice))
                    self?.closeCoordinator(animated: false) {
                        self?.parentViewController?.openInAppWebViewWith(url: contactURL)
                    }

            })
            let keepBrowsing = UIAction(
                interface: .button(R.Strings.loginDeviceNotAllowedAlertOkButton, .secondary(fontSize: .medium,
                                                                                                     withBorder: false)),
                action: {
                    self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network, reason: .secondDevice))
                    self?.closeCoordinator(animated: false, completion: nil)
            })
            let actions = [contact, keepBrowsing]
            self?.parentViewController?.showAlertWithTitle(R.Strings.loginDeviceNotAllowedAlertTitle,
                                                           text: R.Strings.loginDeviceNotAllowedAlertMessage,
                                                           alertType: .iconAlert(icon: R.Asset.IconsButtons.icDeviceBlockedAlert.image),
                                                           buttonsLayout: .vertical, actions: actions)
            self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network, reason: .secondDevice))
        }
    }

    func openHelp() {
        guard let navCtl = currentNavigationController() else { return }

        let vm = HelpViewModel()
        vm.navigator = self
        let vc = HelpViewController(viewModel: vm)
        navCtl.pushViewController(vc, animated: true)
    }

    func openRememberPassword(email: String?) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = RememberPasswordViewModel(source: source, email: email)
        vm.navigator = self
        let vc = RememberPasswordViewController(viewModel: vm, appearance: .light)
        navCtl.pushViewController(vc, animated: true)
    }

    fileprivate func topViewController() -> UIViewController {
        return presentedViewControllers.last ?? viewController
    }

    func currentNavigationController() -> UINavigationController? {
        return topViewController() as? UINavigationController
    }

    func topPresentedController() -> UIViewController {
        var current = topViewController()
        while let presented = current.presentedViewController {
            current = presented
        }
        return current
    }

    func dismissLastPresented(animated: Bool, completion: (() -> Void)?) {
        guard let lastPresented = presentedViewControllers.last else {
            completion?()
            return
        }
        presentedViewControllers.removeLast()
        lastPresented.dismiss(animated: animated, completion: completion)
    }
}
