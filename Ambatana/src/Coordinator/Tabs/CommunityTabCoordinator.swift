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

final class CommunityTabCoordinator: TabCoordinator {
    init() {
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
}
