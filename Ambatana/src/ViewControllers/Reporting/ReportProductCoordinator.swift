import Foundation
import LGCoreKit

final class ReportProductCoordinator: Coordinator {

    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    var viewController: UIViewController
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager

    fileprivate let featureFlags: FeatureFlaggeable

    convenience init() {
        self.init(bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(bubbleNotificationManager: BubbleNotificationManager,
         featureFlags: FeatureFlaggeable,
         sessionManager: SessionManager) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager

        let vm = ReportOptionsListViewModel(optionGroup: ReportOptionsBuilder.reportProductOptions())
        let vc = ReportOptionsListViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        viewController = nav
        vm.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismiss(animated: animated, completion: completion)
    }
}

extension ReportProductCoordinator: ReportProductNavigator {

    func openNextStep(with options: ReportOptionsGroup) {
        guard let navCtl = viewController as? UINavigationController else { return }
        let vm = ReportOptionsListViewModel(optionGroup: options)
        vm.navigator = self
        let vc = ReportOptionsListViewController(viewModel: vm)
        navCtl.pushViewController(vc, animated: true)
    }

    func openThankYouScreen() {
        // TODO
        print("🤡 Thank You!")
    }
}
