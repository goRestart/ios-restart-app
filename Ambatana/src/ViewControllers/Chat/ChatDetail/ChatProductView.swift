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
    var showUserReviews: Bool = false
    
    let imageHeight: CGFloat = 64
    let imageWidth: CGFloat = 64
    let margin: CGFloat = 8
    let labelHeight: CGFloat = 20
    let separatorHeight: CGFloat = 0.5
    weak var delegate: ChatProductViewDelegate?
    

    static func chatProductView(_ showUserReviews: Bool) -> ChatProductView {
        guard let view = Bundle.main.loadNibNamed("ChatProductView", owner: self, options: nil)?.first as? ChatProductView
            else { return ChatProductView() }
        view.showUserReviews = showUserReviews
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

        reviewButton.setStyle(.review)
        reviewButton.isHidden = true
        reviewButton.setTitle(LGLocalizedString.chatUserRatingButtonTitle, for: UIControlState())
    }

    func showReviewButton(_ showButton: Bool, withTooltip: Bool) {
        userName.isHidden = showButton && showUserReviews
        reviewButton.isHidden = !showButton || !showUserReviews
        if showButton && withTooltip && showUserReviews {
            showUserRatingTooltip()
        }
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
        reviewButton.isEnabled = false
    }
    
    // MARK: - Actions

    @IBAction func productButtonPressed(_ sender: AnyObject) {
        delegate?.productViewDidTapProductImage()
    }
    
    @IBAction func userButtonPressed(_ sender: AnyObject) {
        delegate?.productViewDidTapUserAvatar()
    }

    @IBAction func reviewButtonPressed(_ sender: AnyObject) {
        delegate?.productViewDidTapUserReview()
    }
}


// MARK: - Tooltip

extension ChatProductView {
    fileprivate func showUserRatingTooltip() {
        guard userRatingTooltip == nil else { return }
        guard let superView = superview else { return }

        userRatingTooltip = Tooltip(targetView: reviewButton, superView: superView, title: tooltipText(),
                                    style: .black(closeEnabled: true), peakOnTop: true, actionBlock: { [weak self] in
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
        var newTextAttributes = [String : Any]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let newText = NSAttributedString(string: LGLocalizedString.commonNew, attributes: newTextAttributes)

        var titleTextAttributes = [String : Any]()
        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.white
        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let titleText = NSAttributedString(string: LGLocalizedString.chatUserRatingButtonTooltip,
                                           attributes: titleTextAttributes)

        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.append(NSAttributedString(string: " "))
        fullTitle.append(titleText)

        return fullTitle
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // As userRatingTooltip titleLabel & close button are out of boundaries we intercept touches to handle manually
        let superResult = super.hitTest(point, with: event)
        guard let userRatingTooltip = userRatingTooltip, superResult == nil else { return superResult }

        
        let tooltipTitleConvertedPoint = userRatingTooltip.titleLabel.convert(point, from: self)
        let insideTooltipTitle = userRatingTooltip.titleLabel.point(inside: tooltipTitleConvertedPoint, with: event)
        let tooltipCloseButtonConvertedPoint = userRatingTooltip.closeButton.convert(point, from: self)
        let insideTooltipCloseButton = userRatingTooltip.closeButton.point(inside: tooltipCloseButtonConvertedPoint,
                                                                                 with: event)
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
        userName.accessibilityId = .chatProductViewUserNameLabel
        userAvatar.accessibilityId = .chatProductViewUserAvatar
        productName.accessibilityId = .chatProductViewProductNameLabel
        productPrice.accessibilityId = .chatProductViewProductPriceLabel
        productButton.accessibilityId = .chatProductViewProductButton
        userButton.accessibilityId = .chatProductViewUserButton
        reviewButton.accessibilityId = .chatProductViewReviewButton
    }
}
