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
        self.setupUI()
        self.resetUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatBubbleCell.menuControllerWillHide(_:)),
            name: UIMenuControllerWillHideMenuNotification, object: nil)
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
        bubbleView.layer.rasterizationScale = UIScreen.mainScreen().scale
        backgroundColor = UIColor.clearColor()
    }
    
    func menuControllerWillHide(notification: NSNotification) {
        setSelected(false, animated: true)
    }
    
    func resetUI() {}
}
