//
//  SearchAlertsPlaceholderView.swift
//  LetGo
//
//  Created by Dídac on 26/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import LGComponents

final class SearchAlertsPlaceholderView: UIView {

    private struct Layout {
        static let iconWidth: CGFloat = 65
        static let iconHeight: CGFloat = 65
        static let buttonWidth: CGFloat = 200
        static let buttonHeight: CGFloat = 50
    }

    private let iconView: UIImageView = UIImageView()
    private let messageLabel: UILabel = UILabel()
    let actionButton: LetgoButton = LetgoButton()

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWith(state: SearchAlertsState) {
        iconView.image = state.icon
        messageLabel.text = state.text
        actionButton.setTitle(state.buttonTitle, for: .normal)
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        iconView.contentMode = .scaleAspectFit
        messageLabel.font = UIFont.systemFont(ofSize: 17)
        messageLabel.textColor = UIColor.blackText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        actionButton.setStyle(.primary(fontSize: .big))
    }

    private func setupConstraints() {
        let subviews = [iconView, messageLabel, actionButton]
        addSubviewsForAutoLayout(subviews)

        iconView.layout()
            .height(Layout.iconHeight)
            .width(Layout.iconWidth)
        actionButton.layout()
            .height(Layout.buttonHeight)
            .width(Layout.buttonWidth)

        let constraints = [
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor),
            messageLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: Metrics.veryBigMargin),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.veryBigMargin),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.veryBigMargin),
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Metrics.veryBigMargin),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Metrics.veryBigMargin)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupAccessibilityIds() {
        iconView.set(accessibilityId: .searchAlertsPlaceholderIcon)
        messageLabel.set(accessibilityId: .searchAlertsPlaceholderText)
        actionButton.set(accessibilityId: .searchAlertsPlaceholderButton)
    }
}
