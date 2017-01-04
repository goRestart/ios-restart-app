//
//  ChatStickerCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ChatStickerCellDrawer: BaseChatCellDrawer<ChatStickerCell> {

    let messageIsMine: Bool

    init(messageIsMine: Bool, autoHide: Bool) {
        self.messageIsMine = messageIsMine

        super.init(autoHide: autoHide)
    }
    
    override func draw(_ cell: ChatStickerCell, message: ChatViewMessage, delegate: AnyObject?) {
        guard let url = URL(string: message.value) else { return }
        if messageIsMine {
            cell.rightImage.lg_setImageWithURL(url, placeholderImage: nil) { (result, url) in
                if let _ = result.error {
                    cell.rightImage.image = UIImage(named: "sticker_error")
                }
            }
            
            cell.leftImage.image = nil
        } else {
            cell.leftImage.lg_setImageWithURL(url, placeholderImage: nil) { (result, url) in
                if let _ = result.error {
                    cell.leftImage.image = UIImage(named: "sticker_error")
                }
            }
            cell.rightImage.image = nil
        }
    }
}
