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
            // TODO INTRINSIC-CONTENT-SIZE NEEDED
            static let actionButton: CGFloat = 48.0
            static let blanks: CGFloat = 4 * Metrics.shortMargin
            static let bumpUp: CGFloat = 32.0
        }
    }

    let actionButton = UIButton(type: .custom)
    private var actionButtonBottomContainer: NSLayoutConstraint?
    private var actionButtonBottomSeparator: NSLayoutConstraint?

    private let separator = UIView()
    private let bumpUpBanner = BumpUpBanner()

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override var intrinsicContentSize: CGSize {
        let height = Layout.Height.bumpUp + Layout.Height.bumpUp + Layout.Height.actionButton
        return CGSize(width: UIViewNoIntrinsicMetric, height: height) }

    private func setup() {
        setupActionButton()
        setupSeparator()
        setupBumpUpBanner()
        setupUI()
    }

    private func setupActionButton() {
        addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.layout().height(Layout.Height.actionButton)

        actionButton.layout(with: self)
            .topMargin(by: Metrics.shortMargin).rightMargin(by: -Metrics.margin).leftMargin(by: Metrics.margin)
        actionButton.layout(with: self).bottomMargin(by: -Metrics.shortMargin) { [weak self] constraint in
            self?.actionButtonBottomContainer = constraint
            self?.actionButtonBottomContainer?.priority = UILayoutPriorityDefaultLow
        }
        actionButton.setTitle(LGLocalizedString.productMarkAsSoldButton, for: .normal)
        actionButton.setStyle(.terciary)
    }

    private func setupSeparator() {
        addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false

        separator.layout(with: actionButton).below(by: Metrics.shortMargin) { [weak self] constraint in
            self?.actionButtonBottomSeparator = constraint
            self?.actionButtonBottomSeparator?.priority = 999
        }
        separator.layout().height(1)
        separator.layout(with: self).fillHorizontal()
    }

    private func setupBumpUpBanner() {
        addSubview(bumpUpBanner)
        bumpUpBanner.translatesAutoresizingMaskIntoConstraints = false

        bumpUpBanner.layout(with: separator).below(by: Metrics.shortMargin)
        bumpUpBanner.layout(with: self).fillHorizontal()
        bumpUpBanner.layout(with: self).bottomMargin(by: -Metrics.shortMargin)

        bumpUpBanner.updateInfo(info: BumpUpInfo(type: .priced,
                                                 timeSinceLastBump: 10.0,
                                                 maxCountdown: 100.0,
                                                 price: "10.0",
                                                 bannerInteractionBlock: {},
                                                 buttonBlock: {}))
    }

    func resetCountdown() {
        bumpUpBanner.resetCountdown()
    }

    func hideBumpUp() {
        actionButtonBottomSeparator?.priority = UILayoutPriorityDefaultLow
        actionButtonBottomContainer?.priority = 999
        separator.alpha = 0
        bumpUpBanner.alpha = 0
    }

    func showBumpUp() {
        actionButtonBottomContainer?.priority = UILayoutPriorityDefaultLow
        actionButtonBottomSeparator?.priority = 999
        separator.alpha = 1
        bumpUpBanner.alpha = 1
    }

    private func setupUI() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        separator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        bringSubview(toFront: actionButton)
    }
    
}
