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
                                                       loggedInAction: { print("loggedInAction!") },
                                                       cancelAction: nil)
        openChild(coordinator: coordinator,
                  parent: viewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }
}
