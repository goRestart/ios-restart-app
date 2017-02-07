//
//  RateBuyersView.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class RateBuyersView: UIView {

    private let imageMargin: CGFloat = 40
    private let imageDiameter: CGFloat = 110
    private let textsHMargin: CGFloat = 40
    private let textsVMargin: CGFloat = 20
    private let buttonHeight: CGFloat = 50

    private let header = UIView()
    var headerTopMarginConstraint = NSLayoutConstraint()
    let tableView = UITableView()
    let notOnLetgoButton = UIButton(type: .system)


    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect.zero)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if header.height != tableView.contentInset.top {
            tableView.contentInset.top = header.bottom
        }
    }

    private func setupViews() {
        backgroundColor = UIColor.grayBackground
        let buttonSeparator = UIView()
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [header, buttonSeparator, notOnLetgoButton, tableView])
        addSubviews([header, buttonSeparator, notOnLetgoButton, tableView])

        header.layout(with: self).leading().trailing().top() { self.headerTopMarginConstraint = $0 }
        notOnLetgoButton.layout(with: self).leading().trailing().bottom()
        notOnLetgoButton.layout().height(buttonHeight)
        buttonSeparator.layout(with: self).leading().trailing()
        buttonSeparator.layout(with: notOnLetgoButton).bottom(to: .top)
        buttonSeparator.layout().height(LGUIKitConstants.onePixelSize)
        tableView.layout(with: self).top().leading().trailing()
        tableView.layout(with: buttonSeparator).bottom(to: .top)

        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none

        buttonSeparator.backgroundColor = UIColor.grayLight
        notOnLetgoButton.setTitleColor(UIColor.redText, for: .normal)
        notOnLetgoButton.setTitle(LGLocalizedString.rateBuyersNotOnLetgoButton, for: .normal)
        notOnLetgoButton.backgroundColor = UIColor.grayBackground

        setupHeaderViews()
    }

    private func setupHeaderViews() {
        let iconImage = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [iconImage, titleLabel, messageLabel])
        header.addSubviews([iconImage, titleLabel, messageLabel])

        iconImage.layout(with: header).top(by: imageMargin).centerX()
        iconImage.layout().widthEqualsHeight(size: imageDiameter)
        titleLabel.layout(with: header).leading(by: textsHMargin).trailing(by: -textsHMargin)
        titleLabel.layout(with: iconImage).top(to: .bottom, by: textsVMargin)
        messageLabel.layout(with: header).leading(by: textsHMargin).trailing(by: -textsHMargin).bottom(by: -textsVMargin)
        messageLabel.layout(with: titleLabel).top(to: .bottom, by: textsVMargin)

        iconImage.clipsToBounds = true
        iconImage.cornerRadius = imageDiameter/2
        iconImage.contentMode = .scaleAspectFill
        iconImage.image = UIImage(named: "emoji_congrats")
        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.systemMediumFont(size: 17)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = LGLocalizedString.rateBuyersMessage
        messageLabel.textColor = UIColor.darkGrayText
        messageLabel.font = UIFont.mediumBodyFont
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.text = LGLocalizedString.rateBuyersSubMessage
    }
}
