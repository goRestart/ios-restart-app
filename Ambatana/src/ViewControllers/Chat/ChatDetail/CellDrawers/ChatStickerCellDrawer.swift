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

    private static let autoHideTime: NSTimeInterval = 3
    
    let messageIsMine: Bool
    let autoHide: Bool
    
    init(messageIsMine: Bool, autoHide: Bool) {
        self.messageIsMine = messageIsMine
        self.autoHide = autoHide
    }
    
    override func draw(cell: ChatStickerCell, message: ChatViewMessage, delegate: AnyObject?) {
        guard let url = NSURL(string: message.value) else { return }
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

        if let timeInterval = message.sentAt?.timeIntervalSinceNow where autoHide {
            let diffTime = ChatStickerCellDrawer.autoHideTime + timeInterval
            guard 0.0..<ChatStickerCellDrawer.autoHideTime ~= diffTime else {
                cell.contentView.alpha = 0
                return
            }
            cell.contentView.alpha = CGFloat(diffTime / ChatStickerCellDrawer.autoHideTime)
            UIView.animateWithDuration(diffTime, animations: {
                cell.contentView.alpha = 0
            })
        }
    }
}
