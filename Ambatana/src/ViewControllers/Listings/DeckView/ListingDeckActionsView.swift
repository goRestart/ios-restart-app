//
//  ListingDeckActionsView.swift
//  LetGo
//
//  Created by Facundo Menzella on 25/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import LGCoreKit

final class ListingDeckActionView: UIView {

    private struct Layout {
        struct Height {
            static let actionButton: CGFloat = 48.0
            static let blank: CGFloat = Metrics.shortMargin
            static let bumpUp: CGFloat = 40.0
        }
    }

    let actionButton = UIButton(type: .custom)
    private var fullViewContraints: [NSLayoutConstraint] = []
    private var actionButtonCenterY: NSLayoutConstraint?

    let separator = UIView()

    let bumpUpBanner = BumpUpBanner()
    var isBumpUpVisisble: Bool { return !bumpUpBanner.isHidden }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        let height: CGFloat = 4*Layout.Height.blank + Layout.Height.bumpUp + Layout.Height.actionButton
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
    }

    private func setup() {
        setupActionButton()
        setupSeparator()
        setupBumpUpBanner()

        hideBumpUp()
        setupUI()
    }

    private func setupActionButton() {
        addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.layout().height(Layout.Height.actionButton)

        actionButton.layout(with: self).fillHorizontal(by: Metrics.margin)

        actionButtonCenterY = actionButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        actionButtonCenterY?.isActive = true

        let bottom = -(Layout.Height.bumpUp + 2*Layout.Height.blank)
        fullViewContraints.append(contentsOf: [
            actionButton.topAnchor.constraint(equalTo: topAnchor, constant: Layout.Height.blank),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom)
            ])

        actionButton.setTitle(LGLocalizedString.productMarkAsSoldButton, for: .normal)
        actionButton.setStyle(.terciary)
    }

    private func setupSeparator() {
        addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false

        separator.layout(with: actionButton).below(by: Metrics.shortMargin)
        separator.layout().height(1)
        separator.layout(with: self).fillHorizontal()
    }

    private func setupBumpUpBanner() {
        addSubview(bumpUpBanner)
        bumpUpBanner.translatesAutoresizingMaskIntoConstraints = false

        bumpUpBanner.layout(with: separator).below(by: Layout.Height.blank)
        bumpUpBanner.layout(with: self).fillHorizontal()
        bumpUpBanner.layout().height(Layout.Height.bumpUp)
    }

    func resetCountdown() {
        bumpUpBanner.resetCountdown()
    }

    func hideBumpUp() {
        bumpUpBanner.isHidden = true
        separator.isHidden = true

        invalidateIntrinsicContentSize()
    }

    func updateBumpUp(withInfo info: BumpUpInfo) {
        bumpUpBanner.updateInfo(info: info)
    }

    func showBumpUp() {
        bumpUpBanner.isHidden = false
        separator.isHidden = false

        fullModeAlignment(true)
    }

    private func setupUI() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bumpUpBanner.backgroundColor = UIColor.viewControllerBackground
        separator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bumpUpBanner.isHidden = true
        separator.isHidden = true

        bringSubview(toFront: actionButton)

        fullModeAlignment(false)
    }

    private func fullModeAlignment(_ isEnabled: Bool) {
        fullViewContraints.forEach {
            $0.isActive = isEnabled
        }
        actionButtonCenterY?.isActive = !isEnabled
    }
    
}
