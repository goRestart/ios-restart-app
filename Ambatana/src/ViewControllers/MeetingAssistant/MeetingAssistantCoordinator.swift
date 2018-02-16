//
//  MeetingAssistantCoordinator.swift
//  LetGo
//
//  Created by Dídac on 22/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class MeetingAssistantCoordinator: Coordinator {

    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController {
        return navigationController
    }
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    fileprivate var navigationController = UINavigationController()

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

        viewModel.navigator = self
        let vc = MeetingAssistantViewController(viewModel: viewModel)
        let navVC = UINavigationController(rootViewController: vc)
        navigationController = navVC
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
    func sendMeeting(meeting: AssistantMeeting) {
        print("🤡  THE COORDINATORL!")

    }
}
