import Foundation
import LGComponents

struct BumpUpTimerBarViewMetrics {
    static let height: CGFloat = 64
    static let horitzontalMargin: CGFloat = 20
    static let progressBarHeight: CGFloat = 8
    static let labelHeight: CGFloat = 21
}

final class BumpUpTimerBarView: UIView {

    enum Layout {
        static let dotsTagOffset = 100
        static let topPointerVerticalOffset: CGFloat = -12
        static let progressBarSideMargin: CGFloat = 50
        static let firstDotMargin: CGFloat = -2
        static let topPointerPeakHeight: CGFloat = 2
        static let topPointerPeakWidth: CGFloat = 4
    }

    private var multiDayTextConstraints: [NSLayoutConstraint] = []
    private var oneDayTextConstraints: [NSLayoutConstraint] = []
    private var progressBarDotsArray: [UIView] = []

    var maxTime: TimeInterval = 0
    private var type: BumpUpTimerType = .oneDay

    private let textContainerView: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let progressBar: UIProgressView = UIProgressView(progressViewStyle: .default)

    private let bottomLineView: UIView = UIView()

    private let expandViewIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.Monetization.grayChevronDown.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var topPointerContainer: UIView = UIView()
    private var topPointerLabel: UIRoundedLabelWithPadding = {
        let label = UIRoundedLabelWithPadding()
        label.text = R.Strings.bumpUpBannerMultiDayProgressTopTag
        label.backgroundColor = UIColor.grayDark
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 7)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.padding = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        return label
    }()
    private var topPointerPeakImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.tooltipPeakCenterBlack.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.grayDark
        imageView.contentMode = .scaleToFill
        return imageView
    }()


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

    override func layoutSubviews() {
        super.layoutSubviews()
        progressBar.setRoundedCorners()
    }

    func updateUIWith(type: BumpUpTimerType) {
        self.type = type

        titleLabel.text = titleLabelTextFor(timeLeft: nil)
        titleLabel.font = type.isMultiDay ? UIFont.systemSemiBoldFont(size: 15) : UIFont.systemBoldFont(size: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        timeLabel.font = type.isMultiDay ? UIFont.systemSemiBoldFont(size: 15) : UIFont.systemBoldFont(size: 17)
        timeLabel.adjustsFontSizeToFitWidth = true

        setupProgressBarExtraComponents()
    }

    func updateWith(timeLeft: TimeInterval) {
        guard maxTime > 0 else { return }
        let progress = Float(timeLeft/maxTime)

        let timeColor = colorFor(timeLeft: timeLeft)
        progressBar.progressTintColor = timeColor
        progressBar.setProgress(progress, animated: timeLeft == maxTime)

        titleLabel.text = titleLabelTextFor(timeLeft: timeLeft)
        timeLabel.text = type.textForTimeWith(timeLeft: timeLeft)
        timeLabel.textColor = timeColor

        updateTopLabelPosition(timeLeft: timeLeft)
    }

    private func colorFor(timeLeft: TimeInterval) -> UIColor {
        guard !type.isMultiDay else { return UIColor.asparagus }
        if timeLeft > TimeInterval.make(hours: 12) {
            return UIColor.asparagus
        } else if timeLeft > TimeInterval.make(hours: 1) {
            return UIColor.macaroniAndCheese
        } else {
            return UIColor.primaryColor
        }
    }

    private func titleLabelTextFor(timeLeft: TimeInterval?) -> String {
        guard type.isMultiDay else {
            return R.Strings.bumpUpBannerBoostProgressTitle
        }
        guard let timeLeft = timeLeft else {
            return R.Strings.bumpUpBannerMultiDayProgressTitle
        }
        return timeLeft > TimeInterval.make(days: 1) ?
            R.Strings.bumpUpBannerMultiDayProgressTitle :
            R.Strings.bumpUpBannerMultiDayProgressTitle1DayRemaining
    }

    private func setupUI() {
        titleLabel.text = R.Strings.bumpUpBannerBoostProgressTitle
        titleLabel.font = UIFont.systemBoldFont(size: 17)

        timeLabel.textColor = UIColor.asparagus
        timeLabel.font = UIFont.systemBoldFont(size: 17)

        progressBar.backgroundColor = UIColor.grayLighter
        progressBar.isUserInteractionEnabled = false
        bottomLineView.backgroundColor = UIColor.grayLight

        topPointerContainer.isHidden = true
    }

    private func setupProgressBarExtraComponents() {
        removePreviousDots()
        guard let dotsCount = type.dotsCount, type.isMultiDay else {
            NSLayoutConstraint.deactivate(multiDayTextConstraints)
            NSLayoutConstraint.activate(oneDayTextConstraints)
            return
        }
        let spacingMultiplier: CGFloat = CGFloat(1)/CGFloat(dotsCount)

        for i in 0..<dotsCount {
            let dot = UIView()
            dot.backgroundColor = UIColor.pageIndicatorTintColorDark
            dot.layer.cornerRadius = 2

            dot.tag = Layout.dotsTagOffset + (dotsCount - i)
            progressBar.addSubviewForAutoLayout(dot)

            let dotSizeConstraints = [
                dot.heightAnchor.constraint(equalToConstant: 4),
                dot.widthAnchor.constraint(equalToConstant: 4)
            ]
            NSLayoutConstraint.activate(dotSizeConstraints)

            if i == 0 {
                let firstDotConstraints = [dot.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: Layout.firstDotMargin),
                                           dot.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor)]
                NSLayoutConstraint.activate(firstDotConstraints)
            } else {
                let multiplier: CGFloat = (CGFloat(dotsCount - i)*spacingMultiplier)
                let dotTrailingConstraint = NSLayoutConstraint(item: dot,
                                                               attribute: .trailing,
                                                               relatedBy: .equal,
                                                               toItem: progressBar,
                                                               attribute: .trailing,
                                                               multiplier: multiplier,
                                                               constant: 0)
                let newDotConstraints = [dotTrailingConstraint,
                                         dot.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor)]
                NSLayoutConstraint.activate(newDotConstraints)
            }
            progressBarDotsArray.append(dot)
        }

        NSLayoutConstraint.deactivate(oneDayTextConstraints)
        NSLayoutConstraint.activate(multiDayTextConstraints)
    }

    private func removePreviousDots() {
        progressBarDotsArray.forEach { $0.removeFromSuperview() }
        progressBarDotsArray = []
    }

    private func updateTopLabelPosition(timeLeft: TimeInterval) {
        guard let dotsCount = type.dotsCount, type.isMultiDay, dotsCount > 0 else {
            topPointerContainer.isHidden = true
            return
        }
        let period = maxTime/Double(dotsCount)
        guard period > 0 else {
            topPointerContainer.isHidden = true
            return
        }
        let currentPeriod = timeLeft/period
        let dotIdForPeriod = Int(floor(currentPeriod))

        if let selectedDot = (progressBar.subviews.filter { $0.tag == Layout.dotsTagOffset + dotIdForPeriod }).first {
            topPointerContainer.isHidden = false
            let topPointerConstraints = [topPointerContainer.centerXAnchor.constraint(equalTo: selectedDot.centerXAnchor),
                                         topPointerContainer.centerYAnchor.constraint(equalTo: selectedDot.centerYAnchor,
                                                                                  constant: Layout.topPointerVerticalOffset)]
            NSLayoutConstraint.activate(topPointerConstraints)

        } else {
            topPointerContainer.isHidden = true
        }
    }

    private func setupConstraints() {
        let subViews: [UIView] = [textContainerView, progressBar, bottomLineView, topPointerContainer]
        addSubviewsForAutoLayout(subViews)

        textContainerView.layout(with: self)
            .top(by: Metrics.shortMargin)
            .left(relatedBy: .greaterThanOrEqual)
            .right(relatedBy: .lessThanOrEqual)
            .centerX()

        progressBar.layout(with: self)
            .fillHorizontal(by: Metrics.bigMargin)

        progressBar.layout().height(BumpUpTimerBarViewMetrics.progressBarHeight)
        progressBar.layout(with: textContainerView).below(by: Metrics.margin)

        bottomLineView.layout().height(LGUIKitConstants.onePixelSize)
        bottomLineView.layout(with: self).bottom().left().right()

        let textViews: [UIView] = [titleLabel, timeLabel]
        textContainerView.addSubviewsForAutoLayout(textViews)

        oneDayTextConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Metrics.veryShortMargin),
            timeLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor)
        ]

        NSLayoutConstraint.activate(oneDayTextConstraints)

        multiDayTextConstraints = [
            timeLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: Metrics.veryShortMargin),
            titleLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor)
        ]

        topPointerContainer.addSubviewsForAutoLayout([topPointerLabel, topPointerPeakImageView])

        let topPointerContainerConstraints = [
            topPointerLabel.leadingAnchor.constraint(equalTo: topPointerContainer.leadingAnchor),
            topPointerLabel.trailingAnchor.constraint(equalTo: topPointerContainer.trailingAnchor),
            topPointerLabel.topAnchor.constraint(equalTo: topPointerContainer.topAnchor),

            topPointerLabel.bottomAnchor.constraint(equalTo: topPointerPeakImageView.topAnchor),
            topPointerLabel.centerXAnchor.constraint(equalTo: topPointerPeakImageView.centerXAnchor),
            topPointerPeakImageView.heightAnchor.constraint(equalToConstant: Layout.topPointerPeakHeight),
            topPointerPeakImageView.widthAnchor.constraint(equalToConstant: Layout.topPointerPeakWidth),
            topPointerPeakImageView.bottomAnchor.constraint(equalTo: topPointerContainer.bottomAnchor)
        ]
        NSLayoutConstraint.activate(topPointerContainerConstraints)
    }

    private func setAccessibilityIds() {
        titleLabel.set(accessibilityId: .boostTitleLabel)
        timeLabel.set(accessibilityId: .boostTimeLabel)
        progressBar.set(accessibilityId: .boostProgressBar)
    }
}
