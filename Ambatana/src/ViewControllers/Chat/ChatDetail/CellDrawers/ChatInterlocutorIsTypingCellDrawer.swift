//
//  ChatInterlocutorIsTypingCellDrawer.swift
//  LetGo
//
//  Created by Nestor on 13/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class ChatInterlocutorIsTypingCellDrawer: BaseChatCellDrawer<ChatInterlocutorIsTypingCell> {
    
    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }
    
    override func draw(_ cell: ChatInterlocutorIsTypingCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        cell.set(bubbleBackgroundColor: bubbleColor)
        cell.set(userAvatar: message.userAvatarData?.avatarImage, avatarAction: message.userAvatarData?.avatarAction)
    }
}
