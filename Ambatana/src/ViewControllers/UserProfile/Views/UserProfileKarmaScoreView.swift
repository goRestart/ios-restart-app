import Foundation
import LGComponents

final class UserProfileKarmaScoreView: UIView {

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

    var score: Int = 0 {
        didSet {
            updateScore()
        }
    }

    private var verified: Bool {
        return score >= Constants.Reputation.minScore
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
        static let openVerificationsLabelHeight: CGFloat = 48
    }

    required init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let newPosition = progressBackgroundView.width * CGFloat(Constants.Reputation.minScore)/CGFloat(Constants.Reputation.maxScore)
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
        visibilityLabel.text = R.Strings.profileKarmaVisibilityTitle
        visibilityLabel.textColor = .white
        visibilityLabel.font = UIFont.profileKarmaSubtitleBoldFont

        subtitleImageView.image = UIImage(named: "ic_tick")
        subtitleImageView.contentMode = .scaleAspectFit

        subtitleLabel.font = .subtitleFont
        subtitleLabel.textColor = .grayDark
        subtitleLabel.numberOfLines = 0

        progressBackgroundView.backgroundColor = .grayLighter
        progressBackgroundView.cornerRadius = Layout.progressHeight / 2

        progressView.backgroundColor = .grayDisclaimerText
        progressView.cornerRadius = Layout.progressHeight / 2

        progressSeparator.backgroundColor = .verificationGreen
        progressSeparator.cornerRadius = Layout.progressSeparatorWidth / 2

        progressMinKarmaLabel.text = String(Constants.Reputation.minScore)
        progressMinKarmaLabel.textColor = .grayDark
        progressMinKarmaLabel.font = .subtitleFont

        progressMaxKarmaLabel.text = String(Constants.Reputation.maxScore)
        progressMaxKarmaLabel.textColor = .grayDark
        progressMaxKarmaLabel.font = .subtitleFont

        openVerificationsLabel.text = R.Strings.profileKarmaImproveScore
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
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            subtitleLabel.rightAnchor.constraint(equalTo: innerContainer.rightAnchor, constant: -Metrics.shortMargin),

            progressBackgroundView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Layout.progressTopMargin),
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

            horizontalSeparator.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: Metrics.veryBigMargin),
            horizontalSeparator.leftAnchor.constraint(equalTo: outerContainer.leftAnchor, constant: Metrics.margin),
            horizontalSeparator.rightAnchor.constraint(equalTo: outerContainer.rightAnchor, constant: -Metrics.margin),
            horizontalSeparator.heightAnchor.constraint(equalToConstant: Layout.separatorHeight),

            openVerificationsLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: Metrics.veryBigMargin),
            openVerificationsLabel.heightAnchor.constraint(equalToConstant: Layout.openVerificationsLabelHeight),
            openVerificationsLabel.bottomAnchor.constraint(equalTo: innerContainer.bottomAnchor),
            openVerificationsLabel.leftAnchor.constraint(equalTo: outerContainer.leftAnchor, constant: Metrics.margin),
            openVerificationsLabel.rightAnchor.constraint(equalTo: openVerificationsAccessoryView.leftAnchor, constant: -Metrics.shortMargin),
            openVerificationsAccessoryView.rightAnchor.constraint(equalTo: outerContainer.rightAnchor, constant: -Metrics.margin),
            openVerificationsAccessoryView.centerYAnchor.constraint(equalTo: openVerificationsLabel.centerYAnchor),
            openVerificationsAccessoryView.heightAnchor.constraint(equalToConstant: Layout.chevronImageHeight),
            openVerificationsAccessoryView.widthAnchor.constraint(equalToConstant: Layout.chevronImageWidth),
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
        progressViewWidthConstraint?.constant = CGFloat(min(score, Constants.Reputation.maxScore)) / CGFloat(Constants.Reputation.maxScore) * progressBackgroundView.width
        subtitleImageView.isHidden = !verified
        subtitleLeftConstraint?.constant = verified ? Layout.subtitleLeftMarginVerified : Metrics.margin
        updateTitleLabel()
        updateSubtitleLabel()
    }

    private func updateTitleLabel() {
        let points = String(score)
        let pointsString = R.Strings.profileKarmaPointsTitle(points)
        let fullTitle = R.Strings.profileKarmaTitle(pointsString)
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
            subtitleLabel.text = R.Strings.profileKarmaVerifiedSubtitle
        } else {
            let missingPoints = String(Constants.Reputation.minScore-score)
            let points = R.Strings.profileKarmaUnverifiedPointsSubtitle(missingPoints)
            let fullString = R.Strings.profileKarmaUnverifiedSubtitle(points)
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
