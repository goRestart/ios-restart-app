//
//  ChatProductView.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol ChatProductViewDelegate: class {
    func productViewDidTapUserAvatar()
    func productViewDidTapProductImage()
}

class ChatProductView: UIView {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    let imageHeight: CGFloat = 64
    let imageWidth: CGFloat = 64
    let margin: CGFloat = 8
    let labelHeight: CGFloat = 20
    let separatorHeight: CGFloat = 0.5
    weak var delegate: ChatProductViewDelegate?
    

    static func chatProductView() -> ChatProductView {
        guard let view = Bundle.main.loadNibNamed("ChatProductView", owner: self, options: nil)?.first as? ChatProductView
            else { return ChatProductView() }
        view.setupUI()
        view.setAccessibilityIds()
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
    }
    
    func setupUI() {
        productImage.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        productImage.backgroundColor = UIColor.placeholderBackgroundColor()
        userName.font = UIFont.chatProductViewUserFont
        productName.font = UIFont.chatProductViewNameFont
        productPrice.font = UIFont.chatProductViewPriceFont
        
        userAvatar.layer.minificationFilter = kCAFilterTrilinear
    }

    func disableProductInteraction() {
        productName.alpha = 0.3
        productPrice.alpha = 0.3
        productImage.alpha = 0.3
        productButton.isEnabled = false
    }

    func disableUserProfileInteraction() {
        userAvatar.alpha = 0.3
        userName.alpha = 0.3
        userButton.isEnabled = false
    }
    
    // MARK: - Actions

    @IBAction func productButtonPressed(_ sender: AnyObject) {
        delegate?.productViewDidTapProductImage()
    }
    
    @IBAction func userButtonPressed(_ sender: AnyObject) {
        delegate?.productViewDidTapUserAvatar()
    }
}


// MARK: - Accessibility

extension ChatProductView {
    func setAccessibilityIds() {
        userName.accessibilityId = .chatProductViewUserNameLabel
        userAvatar.accessibilityId = .chatProductViewUserAvatar
        productName.accessibilityId = .chatProductViewProductNameLabel
        productPrice.accessibilityId = .chatProductViewProductPriceLabel
        productButton.accessibilityId = .chatProductViewProductButton
        userButton.accessibilityId = .chatProductViewUserButton
    }
}
