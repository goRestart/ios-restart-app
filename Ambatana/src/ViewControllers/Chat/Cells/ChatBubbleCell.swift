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
        
        messageLabel.textColor = StyleHelper.chatCellMessageColor
        dateLabel.textColor = StyleHelper.chatCellTimeColor
        
        bubbleView.layer.shadowColor = UIColor.blackColor().CGColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 0)
        bubbleView.layer.shadowRadius = 1
        bubbleView.layer.shadowOpacity = 0.3
        bubbleView.layer.shouldRasterize = true
        bubbleView.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    func menuControllerWillHide(notification: NSNotification) {
        setSelected(false, animated: true)
    }
    
    func resetUI() {}
}
