//
//  PromoteBumpViewController.swift
//  LetGo
//
//  Created by Dídac on 10/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class PromoteBumpViewController: BaseViewController {

    private static let alertSideMargin: CGFloat = 50

    private var blurEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var alertView: UIView = UIView()
    private var titleLabel: UILabel = UILabel()
    private var iconView: UIImageView = UIImageView()
    private var sellFasterButton = LetgoButton(withStyle: .primary(fontSize: .big))
    private var laterButton: UIButton = UIButton(type: .system)

    private weak var viewModel: PromoteBumpViewModel?

    
    // MARK: - Lifecycle

    required init(viewModel: PromoteBumpViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        setupForModalWithNonOpaqueBackground()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
    }


    // MARK: - Private methods

    private func setupUI() {

        view.backgroundColor = UIColor.clear
        alertView.cornerRadius = LGUIKitConstants.bigCornerRadius
        alertView.backgroundColor = UIColor.white

        titleLabel.text = viewModel?.titleText
        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.systemBoldFont(size: 27)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        iconView.image = viewModel?.sellFasterImage
        iconView.contentMode = .scaleAspectFit

        sellFasterButton.frame = CGRect(x: 0, y: 0, width: 0, height: LGUIKitConstants.mediumButtonHeight)
        sellFasterButton.setTitle(viewModel?.sellFasterText, for: .normal)
        sellFasterButton.addTarget(self, action: #selector(sellFaster), for: .touchUpInside)

        laterButton.setTitle(viewModel?.laterText, for: .normal)
        laterButton.titleLabel?.font = UIFont.systemRegularFont(size: 15)
        laterButton.setTitleColor(UIColor.grayText, for: .normal)
        laterButton.addTarget(self, action: #selector(laterPressed), for: .touchUpInside)
    }

    private func setupConstraints() {

        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(blurEffectView)
        blurEffectView.layout(with: view).fill()

        view.addSubview(alertView)
        alertView.layout(with: view)
            .center()
            .leading(by: PromoteBumpViewController.alertSideMargin)
            .trailing(by: -PromoteBumpViewController.alertSideMargin)

        let subviews: [UIView] = [titleLabel, iconView, sellFasterButton, laterButton]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        alertView.addSubviews(subviews)

        titleLabel.layout(with: alertView)
            .top(by: Metrics.bigMargin)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
            .centerX()

        iconView.layout(with: alertView)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
            .centerX()
        iconView.layout(with: titleLabel).top(to: .bottom, by: Metrics.veryShortMargin)

        sellFasterButton.layout().height(LGUIKitConstants.mediumButtonHeight)
        sellFasterButton.layout(with: alertView)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
            .centerX()
        sellFasterButton.layout(with: iconView).top(to: .bottom, by: Metrics.shortMargin)

        laterButton.layout(with: alertView)
            .bottom(by: -Metrics.margin)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
            .centerX()
        laterButton.layout(with: sellFasterButton).top(to: .bottom, by: Metrics.margin)
    }

    func setupAccessibilityIds() {
        alertView.set(accessibilityId: .promoteBumpUpView)
        titleLabel.set(accessibilityId: .promoteBumpUpTitle)
        sellFasterButton.set(accessibilityId: .promoteBumpUpSellFasterButton)
        laterButton.set(accessibilityId: .promoteBumpUpLaterButton)
    }


    // MARK: - Actions

    @objc func sellFaster() {
        // open product detail & bump
        viewModel?.sellFasterButtonPressed()
    }

    @objc func laterPressed() {
        viewModel?.laterButtonPressed()
    }
}
