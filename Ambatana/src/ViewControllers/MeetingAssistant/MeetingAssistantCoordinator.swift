import Foundation
import LGCoreKit
import LGComponents

final class MeetingAssistantCoordinator: Coordinator {

    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController {
        return navigationController
    }
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    fileprivate let navigationController: UINavigationController

    // MARK: Lifecycle

    convenience init(viewModel: MeetingAssistantViewModel) {
        self.init(bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager,
                  viewModel: viewModel)
    }

    init(bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager,
         viewModel: MeetingAssistantViewModel) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager

        let vc = MeetingAssistantViewController(viewModel: viewModel)
        let navVC = UINavigationController(rootViewController: vc)
        navigationController = navVC
        viewModel.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

// MARK: - FiltersNavigator

extension MeetingAssistantCoordinator: MeetingAssistantNavigator {
    func openEditLocation(withViewModel viewModel: EditLocationViewModel) {
        let vc = EditLocationViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func meetingCreationDidFinish() {
        closeCoordinator(animated: true, completion: nil)
    }

    func openMeetingTipsWith(closeCompletion: (()->Void)?) {
        let tipsVM = MeetingSafetyTipsViewModel(closeCompletion: closeCompletion)
        tipsVM.navigator = self
        let tipsVC = MeetingSafetyTipsViewController(viewModel: tipsVM)
        viewController.present(tipsVC, animated: true, completion: nil)
    }

    func closeMeetingTipsWith(closeCompletion: (()->Void)?) {
        viewController.dismiss(animated: true, completion: closeCompletion)
    }

}
