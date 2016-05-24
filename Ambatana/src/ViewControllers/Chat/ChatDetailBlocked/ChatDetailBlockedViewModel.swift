//
//  ChatDetailBlockedViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ChatDetailBlockedViewModel: BaseViewModel {
    private let myUserRepository: MyUserRepository
    private let forbiddenChat: Chat
    private let otherUser: User?

    var productName: String? {
        return forbiddenChat.product.name
    }
    var productImageUrl: NSURL? {
        return forbiddenChat.product.thumbnail?.fileURL
    }
    var productPrice: String {
        return forbiddenChat.product.priceString()
    }
    var otherUserAvatarUrl: NSURL? {
        return otherUser?.avatar?.fileURL
    }
    var otherUserID: String? {
        return otherUser?.objectId
    }
    var otherUserName: String? {
        return otherUser?.name
    }

    convenience init?(forbiddenChat: Chat) {
        let myUserRepository = Core.myUserRepository
        self.init(myUserRepository: myUserRepository, forbiddenChat: forbiddenChat)
    }

    init?(myUserRepository: MyUserRepository, forbiddenChat: Chat) {
        self.myUserRepository = myUserRepository
        self.forbiddenChat = forbiddenChat
        self.otherUser = ChatDetailBlockedViewModel.getOtherUserFromChat(forbiddenChat,
                                                                         myUserRepository: myUserRepository)
        super.init()
    }
}

private extension ChatDetailBlockedViewModel {
    private static func getOtherUserFromChat(chat: Chat, myUserRepository: MyUserRepository) -> User? {
        guard let myUser = myUserRepository.myUser else { return nil }
        return chat.otherUser(myUser: myUser)
    }
}
