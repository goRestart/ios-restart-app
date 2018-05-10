//
//  ChatConversationsListViewModel.swift
//  LetGo
//
//  Created by Nestor on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

final class ChatConversationsListViewModel: BaseViewModel {
    
    weak var navigator: ChatsTabNavigator?
    
    
    // MARK: Navigation
    
    func openBlockedUsers() {
        navigator?.openBlockedUsers()
    }
}
