import LGComponents
import LGCoreKit
import UIKit

final class MainCoordinator: Coordinator, MainViewModelNavigator {
    var child: Coordinator?
    var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager


    // MARK: - Lifecycle

    convenience init() {
        self.init(sessionManager: Core.sessionManager,
                  bubbleNotificationManager: MockBubbleNotificationManager())
    }

    init(sessionManager: SessionManager,
         bubbleNotificationManager: BubbleNotificationManager) {
        self.child = nil
        self.coordinatorDelegate = nil
        let viewModel = MainViewModel()
        let viewController = MainViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.viewController = navigationController
        self.presentedAlertController = nil
        self.sessionManager = sessionManager
        self.bubbleNotificationManager = bubbleNotificationManager

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

    private func showLogInSuccessfulAlert() {
        showAlert(message: "Log in successful")
    }

    private func showLogInCancelledAlert() {
        showAlert(message: "Log in cancelled")
    }

    private func showAlert(message: String) {
        guard presentedAlertController == nil else { return }
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.presentedAlertController = nil
        })
        alert.addAction(okAction)
        presentedAlertController = alert
        viewController.present(alert,
                               animated: true,
                               completion: nil)
    }
}
