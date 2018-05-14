//
//  ChatsTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

final class ChatsTabCoordinator: TabCoordinator {

    let chatGroupedViewModel: ChatGroupedViewModel
    let chatConversationsListViewModel: ChatConversationsListViewModel
    
    convenience init() {
        self.init(chatGroupedViewModel: ChatGroupedViewModel(),
                  chatConversationsListViewModel: ChatConversationsListViewModel())
    }
    
    init(chatGroupedViewModel: ChatGroupedViewModel,
         chatConversationsListViewModel: ChatConversationsListViewModel) {
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let bubbleNotificationManager =  LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.chatGroupedViewModel = chatGroupedViewModel
        self.chatConversationsListViewModel = chatConversationsListViewModel
        let rootViewController: UIViewController
        if featureFlags.chatConversationsListWithoutTabs.isActive {
            rootViewController = ChatConversationsListViewController(viewModel: chatConversationsListViewModel)
        } else {
            rootViewController = ChatGroupedViewController(viewModel: chatGroupedViewModel)
        }
        let sessionManager = Core.sessionManager
        super.init(listingRepository: listingRepository,
                  userRepository: userRepository,
                  chatRepository: chatRepository,
                  myUserRepository: myUserRepository,
                  installationRepository: installationRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage,
                  tracker: tracker,
                  rootViewController: rootViewController,
                  featureFlags: featureFlags,
                  sessionManager: sessionManager)
        
        chatGroupedViewModel.tabNavigator = self
        chatConversationsListViewModel.navigator = self
    }

    override func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return true
    }
    
    func setNeedsRefreshConversations() {
        chatGroupedViewModel.setNeedsRefreshConversations()
    }
}

extension ChatsTabCoordinator: ChatsTabNavigator {
    func openBlockedUsers() {
        
    }
}
