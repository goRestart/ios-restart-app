import Foundation
import LGComponents

struct BumpUpTimerBarViewMetrics {
    static let height: CGFloat = 64
    static let horitzontalMargin: CGFloat = 20
    static let progressBarHeight: CGFloat = 8
    static let labelHeight: CGFloat = 21
}

class BumpUpTimerBarView: UIView {

    var maxTime: TimeInterval = 0

    private let textContainerView: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let progressBar: UIProgressView = UIProgressView(progressViewStyle: .default)

    private let bottomLineView: UIView = UIView()

    
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

    func updateWith(timeLeft: TimeInterval) {
        guard maxTime > 0 else { return }
        let progress = Float(timeLeft/maxTime)

        let timeColor = colorFor(timeLeft: timeLeft)
        progressBar.progressTintColor = timeColor
        progressBar.setProgress(progress, animated: timeLeft == maxTime)

        timeLabel.text = Int(timeLeft).secondsToPrettyCountdownFormat()
        timeLabel.textColor = timeColor
    }

    private func colorFor(timeLeft: TimeInterval) -> UIColor {
        if timeLeft > TimeInterval.make(hours: 12) {
            return UIColor.asparagus
        } else if timeLeft > TimeInterval.make(hours: 1) {
            return UIColor.macaroniAndCheese
        } else {
            return UIColor.primaryColor
        }
    }

    private func setupUI() {
        titleLabel.text = R.Strings.bumpUpBannerBoostProgressTitle
        titleLabel.font = UIFont.systemBoldFont(size: 17)

        timeLabel.textColor = UIColor.asparagus
        timeLabel.font = UIFont.systemBoldFont(size: 17)

        progressBar.backgroundColor = UIColor.grayLighter
        progressBar.isUserInteractionEnabled = false

        progressBar.setRoundedCorners()

        bottomLineView.backgroundColor = UIColor.grayLight
    }

    private func setupConstraints() {
        let subViews: [UIView] = [textContainerView, progressBar, bottomLineView]
        addSubviewsForAutoLayout(subViews)

        textContainerView.layout(with: self)
            .top(by: Metrics.margin)
            .left(relatedBy: .greaterThanOrEqual)
            .right(relatedBy: .lessThanOrEqual)
            .centerX()

        progressBar.layout(with: self)
            .fillHorizontal(by: Metrics.bigMargin)

        progressBar.layout().height(BumpUpTimerBarViewMetrics.progressBarHeight)
        progressBar.layout(with: textContainerView).below(by: Metrics.veryShortMargin)

        bottomLineView.layout().height(LGUIKitConstants.onePixelSize)
        bottomLineView.layout(with: self).bottom().left().right()

        let textViews: [UIView] = [titleLabel, timeLabel]
        textContainerView.addSubviewsForAutoLayout(textViews)

        titleLabel.layout().height(BumpUpTimerBarViewMetrics.labelHeight)
        titleLabel.layout(with: textContainerView).top().bottom().left()

        titleLabel.layout(with: timeLabel).right(to: .left, by: -5).proportionalHeight()
        timeLabel.layout(with: textContainerView).top().bottom().right()
    }

    private func setAccessibilityIds() {
        titleLabel.set(accessibilityId: .boostTitleLabel)
        timeLabel.set(accessibilityId: .boostTimeLabel)
        progressBar.set(accessibilityId: .boostProgressBar)
    }
}
