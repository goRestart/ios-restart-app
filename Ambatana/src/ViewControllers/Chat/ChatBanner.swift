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


    func setupChatBannerWith(_ title: String, action: UIAction) {
        self.action = action
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayLight.cgColor
        backgroundColor = UIColor.white
        isHidden = true

        // subviews
        let titleLabel = UILabel()
        let actionButton = UIButton(type: .custom)
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
        let views: [String : Any] = ["title": titleLabel, "action": actionButton, "close": closeButton]
        let metrics: [String : Any] = ["vMargin": 7, "closeSize": closeButtonSize, "closeMargin": closeButtonMargin, "sideMargin": sideMargin]

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(sideMargin)-[title(>=20)]-(>=8)-[action]-(sideMargin)-[close(closeSize)]-(closeMargin)-|", options: [.alignAllCenterY], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(vMargin)-[title]-(vMargin)-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=vMargin)-[action(30)]-(>=vMargin)-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=vMargin)-[close(closeSize)]-(>=vMargin)-|", options: [], metrics: metrics, views: views))

        layoutIfNeeded()

        // Setup data
        // title label
        titleLabel.textColor = UIColor.grayText
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.mediumBodyFont
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(749, for: .horizontal)
        // action button
        actionButton.setStyle(.secondary(fontSize: .small, withBorder: true))
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.titleLabel?.minimumScaleFactor = 0.8
        actionButton.setTitle(action.text, for: .normal)
        actionButton.addTarget(self, action: #selector(bannerActionButtonTapped), for: .touchUpInside)
        actionButton.setContentCompressionResistancePriority(751, for: .horizontal)
        actionButton.accessibilityId = .expressChatBannerActionButton

        closeButton.setImage(UIImage(named: "ic_close_dark"), for: .normal)
        closeButton.addTarget(self, action: #selector(bannerCloseButtonTapped), for: .touchUpInside)
        closeButton.accessibilityId = .expressChatBannerCloseButton
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
