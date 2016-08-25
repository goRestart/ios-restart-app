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
    func productViewDidTapUserReview()
    func productViewDidCloseUserReviewTooltip()
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
    @IBOutlet weak var reviewButton: UIButton!

    var userRatingTooltip: Tooltip?

    let imageHeight: CGFloat = 64
    let imageWidth: CGFloat = 64
    let margin: CGFloat = 8
    let labelHeight: CGFloat = 20
    let separatorHeight: CGFloat = 0.5
    weak var delegate: ChatProductViewDelegate?


    static func chatProductView() -> ChatProductView {
        let view = NSBundle.mainBundle().loadNibNamed("ChatProductView", owner: self, options: nil).first as? ChatProductView
        view?.setupUI()
        view?.setAccessibilityIds()
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
        productImage.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        productImage.backgroundColor = UIColor.placeholderBackgroundColor()
        userName.font = UIFont.chatProductViewUserFont
        productName.font = UIFont.chatProductViewNameFont
        productPrice.font = UIFont.chatProductViewPriceFont
        
        userAvatar.layer.minificationFilter = kCAFilterTrilinear

        reviewButton.setStyle(.Review)
        reviewButton.hidden = true
        reviewButton.setTitle(LGLocalizedString.chatUserRatingButtonTitle, forState: .Normal)
    }

    func showReviewButton(showButton: Bool, withTooltip: Bool) {
        userName.hidden = showButton && FeatureFlags.userRatings
        reviewButton.hidden = !showButton || !FeatureFlags.userRatings
        if showButton && withTooltip && FeatureFlags.userRatings {
            showUserRatingTooltip()
        }
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
        reviewButton.enabled = false
    }
    
    // MARK: - Actions

    @IBAction func productButtonPressed(sender: AnyObject) {
        delegate?.productViewDidTapProductImage()
    }
    
    @IBAction func userButtonPressed(sender: AnyObject) {
        delegate?.productViewDidTapUserAvatar()
    }

    @IBAction func reviewButtonPressed(sender: AnyObject) {
        delegate?.productViewDidTapUserReview()
    }
}


// MARK: - Tooltip

extension ChatProductView {
    private func showUserRatingTooltip() {
        guard userRatingTooltip == nil else { return }
        guard let superView = superview else { return }

        userRatingTooltip = Tooltip(targetView: reviewButton, superView: superView, title: tooltipText(),
                                    style: .Black(closeEnabled: true), peakOnTop: true, actionBlock: { [weak self] in
                                        self?.delegate?.productViewDidTapUserReview()
            }, closeBlock: { [weak self] in
                self?.delegate?.productViewDidCloseUserReviewTooltip()
        })

        guard let tooltip = userRatingTooltip else { return }
        self.addSubview(tooltip)
        setupExternalConstraintsForTooltip(tooltip, targetView: reviewButton, containerView: self)

        self.layoutIfNeeded()
    }

    private func tooltipText() -> NSAttributedString {
        var newTextAttributes = [String : AnyObject]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let newText = NSAttributedString(string: LGLocalizedString.chatStickersTooltipNew, attributes: newTextAttributes)

        var titleTextAttributes = [String : AnyObject]()
        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let titleText = NSAttributedString(string: LGLocalizedString.chatUserRatingButtonTooltip,
                                           attributes: titleTextAttributes)

        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.appendAttributedString(NSAttributedString(string: " "))
        fullTitle.appendAttributedString(titleText)

        return fullTitle
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        // As userRatingTooltip titleLabel & close button are out of boundaries we intercept touches to handle manually
        let superResult = super.hitTest(point, withEvent: event)
        guard let userRatingTooltip = userRatingTooltip where superResult == nil else { return superResult }

        
        let tooltipTitleConvertedPoint = userRatingTooltip.titleLabel.convertPoint(point, fromView: self)
        let insideTooltipTitle = userRatingTooltip.titleLabel.pointInside(tooltipTitleConvertedPoint, withEvent: event)
        let tooltipCloseButtonConvertedPoint = userRatingTooltip.closeButton.convertPoint(point, fromView: self)
        let insideTooltipCloseButton = userRatingTooltip.closeButton.pointInside(tooltipCloseButtonConvertedPoint,
                                                                                 withEvent: event)
        if insideTooltipTitle {
            return userRatingTooltip.titleLabel
        } else if insideTooltipCloseButton {
            return userRatingTooltip.closeButton
        } else {
            return nil
        }
    }
}

extension ChatProductView {
    func setAccessibilityIds() {
        userName.accessibilityId = .ChatProductViewUserNameLabel
        userAvatar.accessibilityId = .ChatProductViewUserAvatar
        productName.accessibilityId = .ChatProductViewProductNameLabel
        productPrice.accessibilityId = .ChatProductViewProductPriceLabel
        productButton.accessibilityId = .ChatProductViewProductButton
        userButton.accessibilityId = .ChatProductViewUserButton
        reviewButton.accessibilityId = .ChatProductViewReviewButton
    }
}
