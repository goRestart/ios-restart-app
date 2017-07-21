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
    
    convenience init() {
        self.init(chatGroupedViewModel: ChatGroupedViewModel())
    }
    
    init(chatGroupedViewModel: ChatGroupedViewModel) {
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let bubbleNotificationManager =  LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.chatGroupedViewModel = chatGroupedViewModel
        let rootViewController = ChatGroupedViewController(viewModel: chatGroupedViewModel)
        let sessionManager = Core.sessionManager
        super.init(listingRepository: listingRepository,
                  userRepository: userRepository,
                  chatRepository: chatRepository,
                  oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage,
                  tracker: tracker,
                  rootViewController: rootViewController,
                  featureFlags: featureFlags,
                  sessionManager: sessionManager)
        
        chatGroupedViewModel.tabNavigator = self
    }

    override func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return true
    }
    
    func setNeedsRefreshConversations() {
        chatGroupedViewModel.setNeedsRefreshConversations()
    }
}

extension ChatsTabCoordinator: ChatsTabNavigator {
    
}
