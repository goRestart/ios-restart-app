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


    func setupChatBannerWith(_ title: String, action: UIAction, buttonIcon: UIImage? = nil) {
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
        var views: [String : Any] = [:]
        views["title"] = titleLabel
        views["action"] = actionButton
        views["close"] = closeButton
        var metrics: [String : Any] = [:]
        metrics["vMargin"] = 7
        metrics["closeSize"] = closeButtonSize
        metrics["closeMargin"] = closeButtonMargin
        metrics["sideMargin"] = sideMargin

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(sideMargin)-[title(>=20)]-(>=8)-[action(>=80)]-(sideMargin)-[close(closeSize)]-(closeMargin)-|", options: [.alignAllCenterY], metrics: metrics, views: views))
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
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.titleLabel?.minimumScaleFactor = 0.8
        actionButton.setTitle(action.text, for: .normal)
        actionButton.setStyle(action.buttonStyle ?? .secondary(fontSize: .small, withBorder: true))
        if let buttonImage = buttonIcon {
            actionButton.setImage(buttonImage, for: .normal)
            actionButton.imageView?.contentMode = .scaleAspectFit
            actionButton.imageEdgeInsets = UIEdgeInsets(top: Metrics.veryShortMargin,
                                                        left: -Metrics.veryShortMargin,
                                                        bottom: Metrics.veryShortMargin,
                                                        right: 0)
        }
        actionButton.addTarget(self, action: #selector(bannerActionButtonTapped), for: .touchUpInside)
        actionButton.setContentCompressionResistancePriority(751, for: .horizontal)
        actionButton.accessibilityId = .chatBannerActionButton

        closeButton.setImage(UIImage(named: "ic_close_dark"), for: .normal)
        closeButton.addTarget(self, action: #selector(bannerCloseButtonTapped), for: .touchUpInside)
        closeButton.accessibilityId = .chatBannerCloseButton
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
