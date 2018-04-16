//
//  BoostSuccessAlertView.swift
//  LetGo
//
//  Created by Dídac on 22/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import Lottie

final class BoostSuccessAlertView: UIView {

    private static let animationHeight: CGFloat = 180
    private static let alertSideMargin: CGFloat = 50

    private var blurEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var alertView: UIView = UIView()
    private let animationView = LOTAnimationView(name: "lottie_bump_up_boost_success_animation")
    private var titleLabel: UILabel = UILabel()


    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
        startAnimation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        alertView.cornerRadius = LGUIKitConstants.bigCornerRadius
        alertView.backgroundColor = UIColor.white

        blurEffectView.alpha = 0.2

        titleLabel.text = LGLocalizedString.bumpUpBoostSuccessAlertText
        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.systemBoldFont(size: 25)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        animationView.contentMode = .scaleAspectFit
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeBoostSuccessAlert))
        addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {

        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(blurEffectView)
        blurEffectView.layout(with: self).fill()

        addSubview(alertView)

        alertView.layout(with: self)
            .centerY()
            .fillHorizontal(by: BoostSuccessAlertView.alertSideMargin)

        let subviews: [UIView] = [titleLabel, animationView]
        alertView.addSubviewsForAutoLayout(subviews)

        animationView.layout().height(BoostSuccessAlertView.animationHeight)
        animationView.layout(with: alertView)
            .top(by: Metrics.bigMargin)
            .fillHorizontal(by: Metrics.veryBigMargin)

        animationView.layout(with: titleLabel).above(by: -Metrics.veryShortMargin)

        titleLabel.layout(with: alertView)
            .bottom(by: -Metrics.bigMargin)
            .fillHorizontal(by: Metrics.veryBigMargin)
    }

    func startAnimation() {
        animationView.loopAnimation = false
        animationView.play()
    }

    private func setupAccessibilityIds() {
        alertView.set(accessibilityId: .boostSucceededAlert)
        animationView.set(accessibilityId: .boostSuccededAlertAnimationView)
        titleLabel.set(accessibilityId: .boostSuccededAlertLabel)
    }

    @objc private func closeBoostSuccessAlert() {
        animationView.stop()
        removeFromSuperview()
    }
}
