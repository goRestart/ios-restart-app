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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        resetUI()
        setAccessibilityIds()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatBubbleCell.menuControllerWillHide(_:)),
            name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    func setupUI() {
        bubbleView.layer.cornerRadius = LGUIKitConstants.chatCellCornerRadius
        messageLabel.font = UIFont.bigBodyFont
        dateLabel.font = UIFont.smallBodyFontLight
        
        messageLabel.textColor = UIColor.blackText
        dateLabel.textColor = UIColor.darkGrayText
        
        bubbleView.layer.shouldRasterize = true
        bubbleView.layer.rasterizationScale = UIScreen.main.scale
        backgroundColor = UIColor.clear
    }
    
    func menuControllerWillHide(_ notification: Notification) {
        setSelected(false, animated: true)
    }
    
    func resetUI() {}
}

extension ChatBubbleCell {
    func setAccessibilityIds() {
        messageLabel.accessibilityId = .chatCellMessageLabel
        dateLabel.accessibilityId = .chatCellDateLabel
    }
}
