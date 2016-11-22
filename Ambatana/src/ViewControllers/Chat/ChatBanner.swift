//
//  ChatBanner.swift
//  LetGo
//
//  Created by Dídac on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol ChatBannerDelegate: class {
    func chatBannerDidFinish()
}

class ChatBanner: UIView {

    weak var delegate: ChatBannerDelegate?
    private var action: UIAction?


    func setupChatBannerWith(title: String, action: UIAction) {
        self.action = action
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayLight.CGColor
        backgroundColor = UIColor.white
        hidden = true

        // subviews
        let titleLabel = UILabel()
        let actionButton = UIButton(type: .Custom)
        let closeButton = UIButton()
        addSubview(titleLabel)
        addSubview(actionButton)
        addSubview(closeButton)

        // constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        var closeButtonSize = 0
        var closeButtonMargin = 0
        let sideMargin = 12
        if DeviceFamily.current == .iPhone4 {
            closeButtonSize = 15
            closeButtonMargin = sideMargin
        }
        let views: [String : AnyObject] = ["title": titleLabel, "action": actionButton, "close": closeButton]
        let metrics: [String : AnyObject] = ["vMargin": 7, "closeSize": closeButtonSize, "closeMargin": closeButtonMargin, "sideMargin": sideMargin]

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(sideMargin)-[title(>=20)]-(>=8)-[action]-(sideMargin)-[close(closeSize)]-(closeMargin)-|", options: [.AlignAllCenterY], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(vMargin)-[title]-(vMargin)-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=vMargin)-[action(30)]-(>=vMargin)-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=vMargin)-[close(closeSize)]-(>=vMargin)-|", options: [], metrics: metrics, views: views))

        layoutIfNeeded()

        // Setup data
        // title label
        titleLabel.textColor = UIColor.grayText
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.mediumBodyFont
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(749, forAxis: .Horizontal)
        // action button
        actionButton.setStyle(.Secondary(fontSize: .Small, withBorder: true))
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.titleLabel?.minimumScaleFactor = 0.8
        actionButton.setTitle(action.text, forState: .Normal)
        actionButton.addTarget(self, action: #selector(bannerActionButtonTapped), forControlEvents: .TouchUpInside)
        actionButton.setContentCompressionResistancePriority(751, forAxis: .Horizontal)
        actionButton.accessibilityId = .ExpressChatBannerActionButton

        closeButton.setImage(UIImage(named: "ic_close_dark"), forState: .Normal)
        closeButton.addTarget(self, action: #selector(bannerCloseButtonTapped), forControlEvents: .TouchUpInside)
        closeButton.accessibilityId = .ExpressChatBannerCloseButton
    }

    private dynamic func bannerActionButtonTapped() {
        if let action = action {
            action.action()
        }
        delegate?.chatBannerDidFinish()
    }

    private dynamic func bannerCloseButtonTapped() {
        delegate?.chatBannerDidFinish()
    }
}
