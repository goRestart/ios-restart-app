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

    let topButton = UIButton(type: .custom)
    private var topButtonBottomContainer: NSLayoutConstraint?
    private var topButtonBottomSeparator: NSLayoutConstraint?

    let separator = UIView()
    let bumpUpBanner = BumpUpBanner()

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

    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: 64.0 + 48.0) }

    private func setup() {
        setupTopButton()
        setupSeparator()
        setupBumpUpBanner()
        setupUI()
    }

    private func setupTopButton() {
        addSubview(topButton)
        topButton.translatesAutoresizingMaskIntoConstraints = false
        topButton.layout().height(48.0)

        topButton.layout(with: self)
            .topMargin(by: 8.0).rightMargin(by: -16.0).leftMargin(by: 16.0)
        topButton.layout(with: self).bottomMargin(by: -8) { [weak self] constraint in
            self?.topButtonBottomContainer = constraint
            self?.topButtonBottomContainer?.priority = UILayoutPriorityDefaultLow
        }
        topButton.setTitle("Mark as Sold", for: .normal)
        topButton.setStyle(.terciary)
    }

    private func setupSeparator() {
        addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false

        separator.layout(with: topButton).below(by: 8.0) { [weak self] constraint in
            self?.topButtonBottomSeparator = constraint
            self?.topButtonBottomSeparator?.priority = 999
        }
        separator.layout().height(1 / UIScreen.main.scale)
        separator.layout(with: self).fillHorizontal()
    }

    private func setupBumpUpBanner() {
        addSubview(bumpUpBanner)
        bumpUpBanner.translatesAutoresizingMaskIntoConstraints = false

        bumpUpBanner.layout(with: separator).below(by: 8.0)
        bumpUpBanner.layout(with: self).fillHorizontal()
        bumpUpBanner.layout(with: self).bottomMargin(by: -8.0)

        bumpUpBanner.updateInfo(info: BumpUpInfo(type: .priced,
                                                 timeSinceLastBump: 10.0,
                                                 maxCountdown: 100.0,
                                                 price: "10.0",
                                                 bannerInteractionBlock: {},
                                                 buttonBlock: {}))
    }

    func hideBumpUp() {
        topButtonBottomSeparator?.priority = UILayoutPriorityDefaultLow
        topButtonBottomContainer?.priority = 999
        separator.alpha = 0
        bumpUpBanner.alpha = 0
    }

    func showBumpUp() {
        topButtonBottomContainer?.priority = UILayoutPriorityDefaultLow
        topButtonBottomSeparator?.priority = 999
        separator.alpha = 1
        bumpUpBanner.alpha = 1
    }

    private func setupUI() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        separator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)

        bringSubview(toFront: topButton)
    }

}
