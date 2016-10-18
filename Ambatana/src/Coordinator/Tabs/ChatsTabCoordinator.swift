//
//  ChatsTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

final class ChatsTabCoordinator: TabCoordinator {

    convenience init() {
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let chatGroupedVM = ChatGroupedViewModel()
        let rootViewController = ChatGroupedViewController(viewModel: chatGroupedVM)
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository, keyValueStorage: keyValueStorage, tracker: tracker,
                  rootViewController: rootViewController)

        chatGroupedVM.tabNavigator = self
    }

    override func shouldHideSellButtonAtViewController(viewController: UIViewController) -> Bool {
        return true
    }
}

extension ChatsTabCoordinator: ChatsTabNavigator {

}
