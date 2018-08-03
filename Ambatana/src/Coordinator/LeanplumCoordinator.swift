import Foundation
import LGCoreKit
import LGComponents

protocol LPMessageNavigator: class {
    func closeLPMessage()
}

final class LeanplumCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    convenience init(leanplumMessage: LPMessage) {
        self.init(message: leanplumMessage,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(message: LPMessage,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager

        let vm = LPMessageViewModel(type: message.type,
                                    action: message.action,
                                    headline: message.headline,
                                    subHeadline: message.subHeadline,
                                    image: message.image)
        let vc = LPMessageViewController(vm: vm)
        vc.modalPresentationStyle = .overCurrentContext
        self.viewController = vc

        vm.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }

}

extension LeanplumCoordinator: LPMessageNavigator {
    func closeLPMessage() {
        closeCoordinator(animated: true, completion: nil)
    }
}
