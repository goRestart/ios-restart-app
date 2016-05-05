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
        let view = NSBundle.mainBundle().loadNibNamed("ChatProductView", owner: self, options: nil).first as? ChatProductView
        view?.setupUI()
        return view!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
    }
    
    func setupUI() {
        productImage.layer.cornerRadius = StyleHelper.defaultCornerRadius
        productImage.backgroundColor = StyleHelper.conversationCellBgColor
        userName.font = StyleHelper.chatProductViewUserFont
        productName.font = StyleHelper.chatProductViewNameFont
        productPrice.font = StyleHelper.chatProductViewPriceFont
        
        userAvatar.layer.minificationFilter = kCAFilterTrilinear
    }

    func disableProductInteraction() {
        productName.alpha = 0.3
        productPrice.alpha = 0.3
        productImage.alpha = 0.3
        productButton.enabled = false
    }

    func disableUserProfileInteraction() {
        userAvatar.alpha = 0.3
        userName.alpha = 0.3
        userButton.enabled = false
    }
    
    // MARK: - Actions

    @IBAction func productButtonPressed(sender: AnyObject) {
        delegate?.productViewDidTapProductImage()
    }
    
    @IBAction func userButtonPressed(sender: AnyObject) {
        delegate?.productViewDidTapUserAvatar()
    }
}
