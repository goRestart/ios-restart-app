import Foundation
import LGCoreKit

final class ReportCoordinator: Coordinator {

    enum ReportCoordinatorType {
        case product
        case user

        fileprivate var options: ReportOptionsGroup {
            switch self {
            case .product: return ReportOptionsBuilder.reportProductOptions()
            case .user: return ReportOptionsBuilder.reportUserOptions()
            }
        }

        fileprivate var title: String {
            switch self {
            case .product: return "Report listing" // FIXME: Localize
            case .user: return "Report user"
            }
        }
    }

    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    var viewController: UIViewController
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager

    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let type: ReportCoordinatorType

    convenience init(type: ReportCoordinatorType) {
        self.init(bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  sessionManager: Core.sessionManager,
                  type: type)
    }

    init(bubbleNotificationManager: BubbleNotificationManager,
         featureFlags: FeatureFlaggeable,
         sessionManager: SessionManager,
         type: ReportCoordinatorType) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager
        self.type = type

        let vm = ReportOptionsListViewModel(optionGroup: type.options, title: type.title)
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

extension ReportCoordinator: ReportNavigator {

    func openNextStep(with options: ReportOptionsGroup) {
        guard let navCtl = viewController as? UINavigationController else { return }
        let vm = ReportOptionsListViewModel(optionGroup: options, title: type.title)
        vm.navigator = self
        let vc = ReportOptionsListViewController(viewModel: vm)
        navCtl.pushViewController(vc, animated: true)
    }

    func openThankYouScreen() {
        // TODO
        print("🤡 Thank You!")
    }

    func closeReporting() {
        closeCoordinator(animated: true, completion: nil)
    }
}
