//
//  RateBuyersView.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class RateBuyersView: UIView {

    private let imageMargin: CGFloat = 10
    private let imageDiameter: CGFloat = 110
    private let textsHMargin: CGFloat = 40

    private let header = UIView()
    var headerTopMarginConstraint = NSLayoutConstraint()
    let tableView = UITableView()


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
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [header, tableView])
        addSubviews([header, tableView])

        header.layout(with: self).leading().trailing().top() { self.headerTopMarginConstraint = $0 }
        tableView.layout(with: self).top().leading().trailing().bottom()

        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none

        setupHeaderViews()
    }

    private func setupHeaderViews() {
        let iconImage = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [iconImage, titleLabel, messageLabel])
        header.addSubviews([iconImage, titleLabel, messageLabel])

        iconImage.layout(with: header).top(by: imageMargin).centerX()
        iconImage.layout().width(imageDiameter).widthProportionalToHeight()
        titleLabel.layout(with: header).leading(by: textsHMargin).trailing(by: -textsHMargin)
        titleLabel.layout(with: iconImage).below(by: Metrics.margin)
        messageLabel.layout(with: header).leading(by: textsHMargin).trailing(by: -textsHMargin).bottom(by: -50)
        messageLabel.layout(with: titleLabel).below(by: Metrics.veryShortMargin)

        iconImage.clipsToBounds = true
        iconImage.contentMode = .scaleAspectFit
        iconImage.image = #imageLiteral(resourceName: "emoji_congrats")
        titleLabel.textColor = UIColor.lgBlack
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
