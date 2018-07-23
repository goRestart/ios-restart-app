//
//  CommunityTabCoordinator.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/7/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGComponents
import LGCoreKit

enum CommunitySource {
    case mainListing
    case tabbar
}

final class CommunityTabCoordinator: TabCoordinator {
    init(source: CommunitySource) {
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let bubbleNotificationManager = LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let viewModel = NotificationsViewModel()
        let featureFlags = FeatureFlags.sharedInstance
        let sessionManager = Core.sessionManager
        let rootViewController = NotificationsViewController(viewModel: viewModel)
        super.init(listingRepository: listingRepository, userRepository: userRepository,
                   chatRepository: chatRepository, myUserRepository: myUserRepository,
                   installationRepository: installationRepository, bubbleNotificationManager: bubbleNotificationManager,
                   keyValueStorage: keyValueStorage, tracker: tracker,
                   rootViewController: rootViewController, featureFlags: featureFlags, sessionManager: sessionManager)
    }

    override func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return true
    }

    override func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    override func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}
