//
//  UserProfileKarmaScoreView.swift
//  LetGo
//
//  Created by Isaac Roldan on 27/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class UserProfileKarmaScoreView: UIView {

    private let innerContainer = UIView()
    private let outerContainer = UIView()
    private let visibilityImageView = UIImageView()
    private let visibilityLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let subtitleImageView = UIImageView()
    private let progressBackgroundView = UIView()
    private let progressView = UIView()
    private let progressSeparator = UIView()
    private let progressMinKarmaLabel = UILabel()
    private let progressMaxKarmaLabel = UILabel()
    private let badgeImageView = UIImageView()
    private let horizontalSeparator = UIView()
    private let openVerificationsLabel = UILabel()
    private let openVerificationsAccessoryView = UIImageView()

    private var subtitleLeftConstraint: NSLayoutConstraint?
    private var progressSeparatorXCenterConstraint: NSLayoutConstraint?
    private var progressViewWidthConstraint: NSLayoutConstraint?

    private let minKarmaValue: Int = 50
    private let maxKarmaValue: Int = 80

    var score: Int = 0 {
        didSet {
            updateScore()
        }
    }

    private var verified: Bool {
        return score >= minKarmaValue
    }

    private struct Layout {
        static let containerMargin: CGFloat = 2
        static let subtitleLeftMarginVerified: CGFloat = 35
        static let subtitleLeftMarginUnVerified: CGFloat = 15
        static let outerCornerRadius: CGFloat = 10
        static let innerCornerRadius: CGFloat = 9
        static let progressHeight: CGFloat = 8
        static let innerContainerTopMargin: CGFloat = 33
        static let eyeImageTopMargin: CGFloat = 8
        static let eyeImageLeftMargin: CGFloat = 8
        static let eyeImageHeight: CGFloat = 18
        static let tickImageHeight: CGFloat = 15
        static let progressTopMargin: CGFloat = 22
        static let progressRightMargin: CGFloat = 55
        static let karmaLabelTopMargin: CGFloat = 7
        static let progressSeparatorWidth: CGFloat = 5
        static let progressSeparatorHeight: CGFloat = 16
        static let badgeImageHeight: CGFloat = 30
        static let chevronImageHeight: CGFloat = 13
        static let chevronImageWidth: CGFloat = 8
        static let separatorHeight: CGFloat = 1
    }

    required init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 200)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let newPosition = progressBackgroundView.width * CGFloat(minKarmaValue)/CGFloat(maxKarmaValue)
        if progressSeparatorXCenterConstraint?.constant != newPosition {
            progressSeparatorXCenterConstraint?.constant = newPosition
        }
    }

    private func setupUI() {
        addSubviewsForAutoLayout([outerContainer, innerContainer, visibilityImageView, visibilityLabel, titleLabel,
                                  subtitleLabel, subtitleImageView, progressBackgroundView, progressView,
                                  progressSeparator, progressMinKarmaLabel, progressMaxKarmaLabel, badgeImageView,
                                  horizontalSeparator, openVerificationsLabel, openVerificationsAccessoryView])

        outerContainer.backgroundColor = .grayDisclaimerText
        outerContainer.layer.cornerRadius = Layout.outerCornerRadius
        innerContainer.backgroundColor = .white
        innerContainer.layer.cornerRadius = Layout.innerCornerRadius

        visibilityImageView.image = UIImage(named: "ic_karma_eye")
        visibilityImageView.contentMode = .scaleAspectFit
        visibilityLabel.text = LGLocalizedString.profileKarmaVisibilityTitle
        visibilityLabel.textColor = .white
        visibilityLabel.font = UIFont.profileKarmaSubtitleBoldFont

        subtitleImageView.image = UIImage(named: "ic_tick")
        subtitleImageView.contentMode = .scaleAspectFit

        subtitleLabel.font = .subtitleFont
        subtitleLabel.textColor = .grayDark

        progressBackgroundView.backgroundColor = .grayLighter
        progressBackgroundView.cornerRadius = Layout.progressHeight / 2

        progressView.backgroundColor = .grayDisclaimerText
        progressView.cornerRadius = Layout.progressHeight / 2

        progressSeparator.backgroundColor = .verificationGreen
        progressSeparator.cornerRadius = Layout.progressSeparatorWidth / 2

        progressMinKarmaLabel.text = String(minKarmaValue)
        progressMinKarmaLabel.textColor = .grayDark
        progressMinKarmaLabel.font = .subtitleFont

        progressMaxKarmaLabel.text = String(maxKarmaValue)
        progressMaxKarmaLabel.textColor = .grayDark
        progressMaxKarmaLabel.font = .subtitleFont

        openVerificationsLabel.text = LGLocalizedString.profileKarmaImproveScore
        openVerificationsLabel.textColor = .black
        openVerificationsLabel.font = .profileKarmaOpenVerificationFont

        horizontalSeparator.backgroundColor = .grayLight

        openVerificationsAccessoryView.image = UIImage(named: "right_chevron")
        openVerificationsAccessoryView.contentMode = .scaleAspectFit

        badgeImageView.contentMode = .scaleAspectFit

        setupConstraints()
    }

    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            outerContainer.topAnchor.constraint(equalTo: topAnchor),
            outerContainer.leftAnchor.constraint(equalTo: leftAnchor),
            outerContainer.rightAnchor.constraint(equalTo: rightAnchor),
            outerContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            innerContainer.topAnchor.constraint(equalTo: outerContainer.topAnchor, constant: Layout.innerContainerTopMargin),
            innerContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.containerMargin),
            innerContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.containerMargin),
            innerContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.containerMargin),
            visibilityImageView.topAnchor.constraint(equalTo: outerContainer.topAnchor, constant: Layout.eyeImageTopMargin),
            visibilityImageView.leftAnchor.constraint(equalTo: outerContainer.leftAnchor, constant: Layout.eyeImageLeftMargin),
            visibilityImageView.heightAnchor.constraint(equalToConstant: Layout.eyeImageHeight),
            visibilityImageView.widthAnchor.constraint(equalTo: visibilityImageView.heightAnchor),
            visibilityLabel.centerYAnchor.constraint(equalTo: visibilityImageView.centerYAnchor),
            visibilityLabel.leftAnchor.constraint(equalTo: visibilityImageView.rightAnchor, constant: Metrics.veryShortMargin),

            titleLabel.topAnchor.constraint(equalTo: innerContainer.topAnchor, constant: Metrics.margin),
            titleLabel.leftAnchor.constraint(equalTo: outerContainer.leftAnchor, constant: Metrics.margin),
            subtitleImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            subtitleImageView.leftAnchor.constraint(equalTo: outerContainer.leftAnchor, constant: Metrics.margin),
            subtitleImageView.heightAnchor.constraint(equalToConstant: Layout.tickImageHeight),
            subtitleImageView.widthAnchor.constraint(equalTo: subtitleImageView.heightAnchor),
            subtitleLabel.centerYAnchor.constraint(equalTo: subtitleImageView.centerYAnchor),

            progressBackgroundView.topAnchor.constraint(equalTo: subtitleImageView.bottomAnchor, constant: Layout.progressTopMargin),
            progressBackgroundView.leftAnchor.constraint(equalTo: outerContainer.leftAnchor, constant: Metrics.margin),
            progressBackgroundView.rightAnchor.constraint(equalTo: innerContainer.rightAnchor, constant: -Layout.progressRightMargin),
            progressBackgroundView.heightAnchor.constraint(equalToConstant: Layout.progressHeight),
            progressMaxKarmaLabel.topAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor, constant: Layout.karmaLabelTopMargin),
            progressMaxKarmaLabel.rightAnchor.constraint(equalTo: progressBackgroundView.rightAnchor),
            progressMinKarmaLabel.topAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor, constant: Layout.karmaLabelTopMargin),
            progressMinKarmaLabel.centerXAnchor.constraint(equalTo: progressSeparator.centerXAnchor),
            progressSeparator.centerYAnchor.constraint(equalTo: progressBackgroundView.centerYAnchor),
            progressSeparator.widthAnchor.constraint(equalToConstant: Layout.progressSeparatorWidth),
            progressSeparator.heightAnchor.constraint(equalToConstant: Layout.progressSeparatorHeight),
            progressView.leftAnchor.constraint(equalTo: progressBackgroundView.leftAnchor),
            progressView.topAnchor.constraint(equalTo: progressBackgroundView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor),
            badgeImageView.rightAnchor.constraint(equalTo: outerContainer.rightAnchor, constant: -Metrics.margin),
            badgeImageView.heightAnchor.constraint(equalToConstant: Layout.badgeImageHeight),
            badgeImageView.widthAnchor.constraint(equalTo: badgeImageView.heightAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: progressBackgroundView.centerYAnchor),

            openVerificationsLabel.bottomAnchor.constraint(equalTo: outerContainer.bottomAnchor, constant: -Metrics.margin),
            openVerificationsLabel.leftAnchor.constraint(equalTo: outerContainer.leftAnchor, constant: Metrics.margin),
            openVerificationsLabel.rightAnchor.constraint(equalTo: openVerificationsAccessoryView.leftAnchor, constant: -Metrics.shortMargin),
            openVerificationsAccessoryView.rightAnchor.constraint(equalTo: outerContainer.rightAnchor, constant: -Metrics.margin),
            openVerificationsAccessoryView.centerYAnchor.constraint(equalTo: openVerificationsLabel.centerYAnchor),
            openVerificationsAccessoryView.heightAnchor.constraint(equalToConstant: Layout.chevronImageHeight),
            openVerificationsAccessoryView.widthAnchor.constraint(equalToConstant: Layout.chevronImageWidth),
            horizontalSeparator.topAnchor.constraint(equalTo: openVerificationsLabel.topAnchor, constant: -Metrics.margin),
            horizontalSeparator.leftAnchor.constraint(equalTo: outerContainer.leftAnchor, constant: Metrics.margin),
            horizontalSeparator.rightAnchor.constraint(equalTo: outerContainer.rightAnchor, constant: -Metrics.margin),
            horizontalSeparator.heightAnchor.constraint(equalToConstant: Layout.separatorHeight)
        ]

        let subtitleLeft = subtitleLabel.leftAnchor.constraint(equalTo: outerContainer.leftAnchor)
        constraints.append(subtitleLeft)
        subtitleLeftConstraint = subtitleLeft

        let progressSeparatorXCenter = progressSeparator.centerXAnchor.constraint(equalTo: progressBackgroundView.leftAnchor)
        constraints.append(progressSeparatorXCenter)
        progressSeparatorXCenterConstraint = progressSeparatorXCenter

        let progressViewWidth = progressView.widthAnchor.constraint(equalToConstant: 0)
        constraints.append(progressViewWidth)
        progressViewWidthConstraint = progressViewWidth

        NSLayoutConstraint.activate(constraints)
    }

    private func updateScore() {
        progressView.backgroundColor = verified ? .verificationGreen : .grayDisclaimerText
        badgeImageView.image = verified ? UIImage(named: "ic_karma_badge_active") : UIImage(named: "ic_karma_badge_inactive")
        progressViewWidthConstraint?.constant = CGFloat(min(score, maxKarmaValue)) / CGFloat(maxKarmaValue) * progressBackgroundView.width
        subtitleImageView.isHidden = !verified
        subtitleLeftConstraint?.constant = verified ? Layout.subtitleLeftMarginVerified : Metrics.bigMargin
        updateTitleLabel()
        updateSubtitleLabel()
    }

    private func updateTitleLabel() {
        let points = String(score)
        let pointsString = LGLocalizedString.profileKarmaPointsTitle(points)
        let fullTitle = LGLocalizedString.profileKarmaTitle(pointsString)
        let range = (fullTitle as NSString).range(of: pointsString)

        let attributedString = NSMutableAttributedString(string: fullTitle, attributes: [
            .font: UIFont.profileKarmaScoreTitleFont,
            .foregroundColor: UIColor.lgBlack
            ])

        let scoreColor: UIColor = verified ? .verificationGreen : .grayDisclaimerText
        attributedString.addAttribute(.foregroundColor, value: scoreColor, range: range)
        titleLabel.attributedText = attributedString
    }

    private func updateSubtitleLabel() {
        if verified {
            subtitleLabel.text = LGLocalizedString.profileKarmaVerifiedSubtitle
        } else {
            let missingPoints = String(minKarmaValue-score)
            let points = LGLocalizedString.profileKarmaUnverifiedPointsSubtitle(missingPoints)
            let fullString = LGLocalizedString.profileKarmaUnverifiedSubtitle(points)
            let range = (fullString as NSString).range(of: points)

            let attributedString = NSMutableAttributedString(string: fullString, attributes: [
                .font: UIFont.subtitleFont,
                .foregroundColor: UIColor.grayDark
                ])
            attributedString.addAttribute(.font, value: UIFont.profileKarmaSubtitleBoldFont, range: range)
            subtitleLabel.attributedText = attributedString
        }
    }
}
