//
//  BoostSuccessAlertView.swift
//  LetGo
//
//  Created by Dídac on 22/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import Lottie

class BoostSuccessAlertView: UIView {

    private static let alertSideMargin: CGFloat = 50

    private var blurEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var alertView: UIView = UIView()
    private let animationView = LOTAnimationView(name: "lottie_bump_up_boost_success_animation")
    private var titleLabel: UILabel = UILabel()


    // MARK: - Lifecycle

//    required init(viewModel: PromoteBumpViewModel) {
//        self.viewModel = viewModel
//        super.init(viewModel: viewModel, nibName: nil)
//        modalPresentationStyle = .overCurrentContext
//    }

    init() {
        // TODO: 🦄  Make the cool alert happen!
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIColor.clear
        alertView.cornerRadius = LGUIKitConstants.bigCornerRadius
        alertView.backgroundColor = UIColor.white

        titleLabel.text = "_ YAY BOOST!"
        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.systemBoldFont(size: 27)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0


        animationView.loopAnimation = false
        animationView.play()
    }

    private func setupConstraints() {

        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(blurEffectView)
        blurEffectView.layout(with: self).fill()

        addSubview(alertView)
        alertView.layout(with: self)
            .center()
            .leading(by: BoostSuccessAlertView.alertSideMargin)
            .trailing(by: -BoostSuccessAlertView.alertSideMargin)

        let subviews: [UIView] = [titleLabel, animationView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        alertView.addSubviews(subviews)

        titleLabel.layout(with: alertView)
            .top(by: Metrics.bigMargin)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
            .centerX()

        animationView.layout(with: alertView)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
            .centerX()
        animationView.layout(with: titleLabel).top(to: .bottom, by: Metrics.veryShortMargin)
    }

    func setupAccessibilityIds() {
        alertView.set(accessibilityId: .promoteBumpUpView)
        titleLabel.set(accessibilityId: .promoteBumpUpTitle)
    }
}
