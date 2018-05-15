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
            static let bumpUp: CGFloat = 64.0

            static let compressed: CGFloat = 2*Layout.Height.blank + Layout.Height.actionButton

            static func expandedWith(banner: BumpUpBanner) -> CGFloat {
                return 3*Layout.Height.blank + banner.intrinsicContentSize.height + Layout.Height.actionButton
            }
        }
    }

    let actionButton = LetgoButton(withStyle: .terciary)
    private var fullViewContraints: [NSLayoutConstraint] = []
    private var actionButtonCenterY: NSLayoutConstraint?
    private var actionButtonBottomAnchorConstraint: NSLayoutConstraint = NSLayoutConstraint()

    private var actionButtonBottomMargin: CGFloat {
        return -(bumpUpBanner.intrinsicContentSize.height+Layout.Height.blank)
    }

    private let separator = UIView()

    let bumpUpBanner = BumpUpBanner()
    var isBumpUpVisible: Bool { return !bumpUpBanner.isHidden }

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        let height: CGFloat
        if !isBumpUpVisible {
            height = Layout.Height.compressed
        } else {
            height = Layout.Height.expandedWith(banner: bumpUpBanner)
        }
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
    }

    private func setup() {
        addSubviewsForAutoLayout([actionButton, separator, bumpUpBanner])
        setupActionButton()
        setupSeparator()
        setupBumpUpBanner()

        hideBumpUp()
        setupUI()
    }

    private func setupActionButton() {
        actionButton.layout().height(Layout.Height.actionButton)
        actionButton.layout(with: self).fillHorizontal(by: Metrics.margin)
        actionButtonCenterY = actionButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        actionButtonCenterY?.isActive = true

        actionButtonBottomAnchorConstraint = actionButton.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                                  constant: actionButtonBottomMargin)

        fullViewContraints.append(contentsOf: [
            actionButton.topAnchor.constraint(equalTo: topAnchor, constant: Layout.Height.blank),
            actionButtonBottomAnchorConstraint
        ])

        actionButton.setTitle(LGLocalizedString.productMarkAsSoldButton, for: .normal)
    }

    private func setupSeparator() {
        separator.layout(with: actionButton).below(by: Metrics.shortMargin)
        separator.layout().height(1)
        separator.layout(with: self).fillHorizontal()
        separator.applyDefaultShadow()
        separator.layer.shadowOffset = CGSize(width: 0, height: -1)
    }

    private func setupBumpUpBanner() {
        NSLayoutConstraint.activate([
            bumpUpBanner.topAnchor.constraint(equalTo: separator.bottomAnchor),
            bumpUpBanner.leftAnchor.constraint(equalTo: leftAnchor),
            bumpUpBanner.rightAnchor.constraint(equalTo: rightAnchor),
            bumpUpBanner.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }

    func updatePrivateActionsWith(actionsAlpha: CGFloat, bumpBannerAlpha: CGFloat) {
        actionButton.alpha = actionsAlpha
        separator.alpha = actionsAlpha
        bumpUpBanner.alpha = bumpBannerAlpha
    }

    func resetCountdown() {
        bumpUpBanner.resetCountdown()
    }

    func hideBumpUp() {
        bumpUpBanner.isHidden = true
        separator.isHidden = true

        invalidateIntrinsicContentSize()
        fullModeAlignment(false)
    }

    func updateBumpUp(withInfo info: BumpUpInfo) {
        bumpUpBanner.updateInfo(info: info)
        actionButtonBottomAnchorConstraint.constant = actionButtonBottomMargin
    }

    func showBumpUp() {
        bumpUpBanner.isHidden = false
        separator.isHidden = false

        invalidateIntrinsicContentSize()
        fullModeAlignment(true)
    }

    private func setupUI() {
        backgroundColor = .clear
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
