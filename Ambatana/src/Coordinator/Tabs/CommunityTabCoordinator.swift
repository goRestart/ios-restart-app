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
    case navBar
    case tabbar
}

final class CommunityTabCoordinator: TabCoordinator {
    init(source: CommunitySource) {
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let sessionManager = Core.sessionManager
        let bubbleNotificationManager = LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance

        let viewModel = CommunityViewModel(communityRepository: Core.communityRepository,
                                           sessionManager: Core.sessionManager,
                                           source: source,
                                           tracker: tracker)
        let rootViewController = CommunityViewController(viewModel: viewModel)

        super.init(listingRepository: listingRepository, userRepository: userRepository,
                   chatRepository: chatRepository, myUserRepository: myUserRepository,
                   installationRepository: installationRepository, bubbleNotificationManager: bubbleNotificationManager,
                   keyValueStorage: keyValueStorage, tracker: tracker,
                   rootViewController: rootViewController, featureFlags: featureFlags,
                   sessionManager: sessionManager, deeplinkMailBox: LGDeepLinkMailBox.sharedInstance)

        viewModel.navigator = self
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

extension CommunityTabCoordinator: CommunityTabNavigator {
    func closeCommunity() {
        closeCoordinator(animated: true, completion: nil)
    }

    func openLogin() {
        guard !sessionManager.loggedIn else { return }
        let vc = LoginBuilder.modal.buildMainSignIn(withSource: .community, loginAction: nil, cancelAction: nil)
        let nav = UINavigationController(rootViewController: vc)
        viewController.present(nav, animated: true)
    }
}
