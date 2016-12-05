//
//  ChatHeadData.swift
//  LetGo
//
//  Created by Albert Hernández López on 03/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct ChatHeadData {
    let id: String
    let imageURL: NSURL?
    let placeholder: UIImage?

    init(id: String, imageURL: NSURL?, placeholder: UIImage?) {
        self.id = id
        self.imageURL = imageURL
        self.placeholder = placeholder
    }

    init?(chat: Chat, myUser: MyUser) {
        guard let id = chat.objectId else { return nil }
        let otherUser = chat.otherUser(myUser: myUser)
        let placeholder = LetgoAvatar.avatarWithID(otherUser.objectId, name: otherUser.name)
        self.init(id: id, imageURL: otherUser.avatar?.fileURL, placeholder: placeholder)
    }

    init?(conversation: ChatConversation) {
        guard let id = conversation.objectId else { return nil }
        let interlocutor = conversation.interlocutor
        let placeholder = LetgoAvatar.avatarWithID(interlocutor?.objectId, name: interlocutor?.name)
        self.init(id: id, imageURL: interlocutor?.avatar?.fileURL, placeholder: placeholder)
    }
}
