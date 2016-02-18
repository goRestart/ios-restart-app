//
//  ChatProductView.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol ChatProductViewDelegate {
    func productViewDidTapBackButton()
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
    
    @IBOutlet weak var maskImage: UIImageView!
    
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var avatarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var productTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var productRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var productBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var distanceBetweenLabelsConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userNameLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var productInfoRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backArrow: UIImageView!

    
    let imageHeight: CGFloat = 64
    let imageWidth: CGFloat = 64
    let margin: CGFloat = 8
    let labelHeight: CGFloat = 20
    let separatorHeight: CGFloat = 0.5
    var delegate: ChatProductViewDelegate?
    
    
    static func chatProductView() -> ChatProductView? {
        let view = NSBundle.mainBundle().loadNibNamed("ChatProductView", owner: self, options: nil).first as? ChatProductView
        view?.setupUI()
        return view
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() {
        backArrow.alpha = 0
        backButton.enabled = false
        productImage.layer.cornerRadius = StyleHelper.defaultCornerRadius

        userName.font = StyleHelper.chatProductViewUserFont
        productName.font = StyleHelper.chatProductViewNameFont
        productPrice.font = StyleHelper.chatProductViewPriceFont
        
        userAvatar.layer.minificationFilter = kCAFilterTrilinear
    }
    
    func minimize() {
        backgroundTopConstraint.constant = 20
        backgroundLeftConstraint.constant = 50
        avatarTopConstraint.constant = 4
        avatarLeftConstraint.constant = 0
        avatarBottomConstraint.constant = 4
        productTopConstraint.constant = 4
        productRightConstraint.constant = 4
        productBottomConstraint.constant = 4
        distanceBetweenLabelsConstraint.constant = 0
        userNameLeftConstraint.constant = 6
        productInfoRightConstraint.constant = 6
        backButton.enabled = true
    }
    
    func maximize() {
        backgroundTopConstraint.constant = 0
        backgroundLeftConstraint.constant = 0
        avatarTopConstraint.constant = 8
        avatarLeftConstraint.constant = 8
        avatarBottomConstraint.constant = 8
        productTopConstraint.constant = 8
        productRightConstraint.constant = 8
        productBottomConstraint.constant = 8
        distanceBetweenLabelsConstraint.constant = 4
        userNameLeftConstraint.constant = 8
        productInfoRightConstraint.constant = 8
        backButton.enabled = false
    }
    
    
    // MARK: - Actions
    
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        delegate?.productViewDidTapBackButton()
    }
    
    @IBAction func productButtonPressed(sender: AnyObject) {
        delegate?.productViewDidTapProductImage()
    }
    
    @IBAction func userButtonPressed(sender: AnyObject) {
        delegate?.productViewDidTapUserAvatar()
    }
}
