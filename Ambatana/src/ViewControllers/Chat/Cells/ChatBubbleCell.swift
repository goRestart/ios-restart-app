//
//  ChatBubbleCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

class ChatBubbleCell: UITableViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillHide:",
            name: UIMenuControllerWillHideMenuNotification, object: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    func setupUI() {
        bubbleView.layer.cornerRadius = 4
        messageLabel.font = StyleHelper.chatCellMessageFont
        dateLabel.font = StyleHelper.chatCellTimeFont
        userNameLabel.font = StyleHelper.chatCellUserNameFont
        
        messageLabel.textColor = StyleHelper.chatCellMessageColor
        dateLabel.textColor = StyleHelper.chatCellTimeColor
        userNameLabel.textColor = StyleHelper.chatCellUserNameColor
    }
    
    func menuControllerWillHide(notification: NSNotification) {
        setSelected(false, animated: true)
    }
    
    func resetUI() {}
}
