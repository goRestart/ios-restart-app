//
//  BumpUpTimerBarView.swift
//  LetGo
//
//  Created by Dídac on 15/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol BumpUpTimerBarViewDelegate: class {
    func timerBarReachedZero()
}

struct BumpUpTimerBarViewMetrics {
    static let height: CGFloat = 64
    static let horitzontalMargin: CGFloat = 50
    static let progressBarHeight: CGFloat = 8
    static let labelHeight: CGFloat = 21
}

class BumpUpTimerBarView: UIView {

    var maxTime: TimeInterval = 0

    private let textContainerView: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let progressBar: UIProgressView = UIProgressView(progressViewStyle: .default)
    private let progressBarContainerView: UIView = UIView()

    private let bottomLineView: UIView = UIView()


    private var timeIntervalLeft: TimeInterval = 0

    weak var delegate: BumpUpTimerBarViewDelegate?
    
    // - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateWith(timeLeft: TimeInterval) {
        timeIntervalLeft = timeLeft

        let progress = Float(timeLeft/maxTime)

        let timeColor = colorFor(timeLeft: progress)
        progressBar.progressTintColor = timeColor
        progressBar.setProgress(progress, animated: true)

        timeLabel.text = Int(timeLeft).secondsToPrettyCountdownFormat()
        timeLabel.textColor = timeColor
    }

    private func colorFor(timeLeft: Float) -> UIColor {
        if timeLeft > 2/3 {
            return UIColor.asparagus
        } else if timeLeft > 1/3 {
            return UIColor.macaroniAndCheese
        } else {
            return UIColor.primaryColor
        }
    }

    private func setupUI() {
        titleLabel.text = LGLocalizedString.bumpUpBannerBoostProgressTitle
        titleLabel.font = UIFont.systemRegularFont(size: 17)

        timeLabel.textColor = UIColor.asparagus
        timeLabel.font = UIFont.systemBoldFont(size: 17)

        progressBar.backgroundColor = UIColor.grayLighter
        progressBar.isUserInteractionEnabled = false

        progressBarContainerView.backgroundColor = UIColor.clear
        progressBarContainerView.setRoundedCorners()

        bottomLineView.backgroundColor = UIColor.grayLighter
    }

    private func setupConstraints() {
        let subViews: [UIView] = [textContainerView, progressBarContainerView, bottomLineView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subViews)
        addSubviews(subViews)

        textContainerView.layout(with: self)
            .top(by: Metrics.margin)
            .left(relatedBy: .greaterThanOrEqual)
            .right(relatedBy: .lessThanOrEqual)
            .centerX()

        progressBarContainerView.layout(with: self)
            .bottom(by: -Metrics.margin)
            .left(by: BumpUpTimerBarViewMetrics.horitzontalMargin)
            .right(by: -BumpUpTimerBarViewMetrics.horitzontalMargin)
            .centerX()
        progressBarContainerView.layout().height(BumpUpTimerBarViewMetrics.progressBarHeight)
        progressBarContainerView.layout(with: textContainerView).below(by: Metrics.veryShortMargin)

        bottomLineView.layout().height(1)
        bottomLineView.layout(with: self).bottom().left().right()

        let textViews: [UIView] = [titleLabel, timeLabel]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: textViews)
        textContainerView.addSubviews(textViews)

        titleLabel.layout().height(BumpUpTimerBarViewMetrics.labelHeight)
        titleLabel.layout(with: textContainerView).top().bottom().left()

        titleLabel.layout(with: timeLabel).right(to: .left, by: -5).proportionalHeight()
        timeLabel.layout(with: textContainerView).top().bottom().right()

        progressBarContainerView.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.layout(with: progressBarContainerView).fill()
    }

    private func setAccessibilityIds() {
        titleLabel.set(accessibilityId: .boostTitleLabel)
        timeLabel.set(accessibilityId: .boostTimeLabel)
        progressBar.set(accessibilityId: .boostProgressBar)
    }
}
