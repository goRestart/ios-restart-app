import Foundation
import LGCoreKit
import LGComponents

class PasswordlessUsernameCoordinator: Coordinator, PasswordlessUsernameNavigator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager
    private let token: String

    convenience init(token: String) {
        self.init(token: token,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(token: String,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        self.token = token

        let vm = PasswordlessUsernameViewModel(token: token)
        let vc = PasswordlessUsernameViewController(viewModel: vm)
        let navigationController = UINavigationController(rootViewController: vc)
        viewController = navigationController
        vm.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }

    func closePasswordlessConfirmUsername() {
        closeCoordinator(animated: true, completion: nil)
    }

    func openHelp() {
        guard let navCtl = viewController as? UINavigationController else { return }
        let vc = LGHelpBuilder.standard(navCtl).buildHelp()
        navCtl.pushViewController(vc, animated: true)
    }
}

extension PasswordlessUsernameCoordinator: HelpNavigator {
    func closeHelp() {
        guard let navCtl = viewController as? UINavigationController else { return }
        navCtl.popViewController(animated: true)
    }
}
