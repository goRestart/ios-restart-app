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

            static func from(bumpUp: BumpUpBanner) -> CGFloat {
                return bumpUp.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            }
        }
    }

    private var actionButtonBottom: NSLayoutConstraint?

    var isBumpUpVisisble: Bool { return actionButtonBottom?.constant == 2*Layout.Height.blank + bumpUpHeight }
    let actionButton = UIButton(type: .custom)
    let separator = UIView()
    let bumpUpBanner = BumpUpBanner()

    private var bumpUpHeight: CGFloat { return Layout.Height.from(bumpUp: bumpUpBanner) }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        let height: CGFloat
        if isBumpUpVisisble {
            height = 4*Layout.Height.blank + bumpUpHeight + Layout.Height.actionButton
        } else {
            height = 4*Layout.Height.blank + Layout.Height.actionButton - Layout.Height.blank
        }
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

        actionButton.layout(with: self)
            .topMargin(by: Metrics.shortMargin).rightMargin(by: -Metrics.margin).leftMargin(by: Metrics.margin)
        actionButton.layout(with: self).bottomMargin(by: -Metrics.shortMargin) { [weak self] constraint in
            self?.actionButtonBottom = constraint
        }
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
    }

    func resetCountdown() {
        bumpUpBanner.resetCountdown()
    }

    func hideBumpUp() {
        actionButtonBottom?.constant = -Layout.Height.blank
        bumpUpBanner.isHidden = true
        separator.isHidden = true

        invalidateIntrinsicContentSize()
    }

    func updateBumpUp(withInfo info: BumpUpInfo) {
        bumpUpBanner.updateInfo(info: info)
    }

    func showBumpUp() {
        actionButtonBottom?.constant = -(3*Layout.Height.blank + bumpUpHeight)
        bumpUpBanner.isHidden = false
        separator.isHidden = false
        
        invalidateIntrinsicContentSize()
    }

    private func setupUI() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bumpUpBanner.backgroundColor = UIColor.viewControllerBackground
        separator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bumpUpBanner.isHidden = true
        separator.isHidden = true

        bringSubview(toFront: actionButton)
    }
    
}
