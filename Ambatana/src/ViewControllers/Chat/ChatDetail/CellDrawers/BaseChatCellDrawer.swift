//
//  BaseChatCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class BaseChatCellDrawer<T: UITableViewCell>: BaseTableCellDrawer<T>, ChatCellDrawer where T: ReusableCell {

    private let autoHideTime: TimeInterval = 3
    private let autoHideFadeTime: TimeInterval = 0.3

    let autoHide: Bool

    init(autoHide: Bool) {
        self.autoHide = autoHide
    }

    /**
    Draw the cell, proxy method to `draw(cell: T...)`
    If the cell is not of type T, it will do nothing.
    If the cell is of type T, it will call the real draw method implemented by the subclass
    
    - parameter cell:     Cell where the message is going to be draw, must be T
    - parameter message:  Message to draw
    - parameter avatar:   Avatar to draw if any
    - parameter delegate: Delegate of the cell if any
    */
    func draw(_ cell: UITableViewCell, message: ChatViewMessage, delegate: AnyObject?) {
        guard let myCell = cell as? T else { return }
        draw(myCell, message: message, delegate: delegate)
        checkAutoHide(myCell, message: message)
    }
    
    /**
    Abstract method that should be implemented by the subclasses.
    */
    func draw(_ cell: T, message: ChatViewMessage, delegate: AnyObject?) {}


    private func checkAutoHide(_ cell: T, message: ChatViewMessage) {
       
        guard let timeInterval = message.sentAt?.timeIntervalSinceNow, autoHide  else { return }
        let diffTime = autoHideTime + timeInterval
        guard 0.0..<autoHideTime ~= diffTime else {
            cell.contentView.alpha = 0
            cell.contentView.isHidden = true
            return
        }
        cell.contentView.isHidden = false
        cell.contentView.alpha = 1
        
        // keep a message hash on content view to be sure that completions happens on the correct cell.
        let messageTag = (message.sentAt as NSDate?)?.hash ?? 0
        cell.contentView.tag = messageTag
        UIView.animate(withDuration: autoHideFadeTime, delay: diffTime, options: .curveEaseIn,
                                   animations: { cell.contentView.alpha = 0 }, completion: { _ in
                                    guard cell.contentView.tag == messageTag else { return }
                                    cell.contentView.isHidden = true
        })
    }
}
