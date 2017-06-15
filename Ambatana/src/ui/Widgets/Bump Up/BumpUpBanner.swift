//
//  BumpUpBanner.swift
//  LetGo
//
//  Created by Dídac on 02/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

enum BumpUpType {
    case free
    case priced
    case restore

    var bannerText: String {
        switch self {
        case .free:
            return LGLocalizedString.bumpUpBannerFreeText
        case .priced:
            return LGLocalizedString.bumpUpBannerPayText
        case .restore:
            return LGLocalizedString.bumpUpErrorBumpToken
        }
    }

    var bannerIcon: UIImage? {
        switch self {
        case .free:
            return UIImage(named: "red_chevron_up")
        case .priced:
            return UIImage(named: "red_chevron_up")
        case .restore:
            return nil
        }
    }
}

struct BumpUpInfo {
    var type: BumpUpType
    var timeSinceLastBump: TimeInterval
    var price: String?
    var primaryBlock: () -> Void
    var buttonBlock: () -> Void

    init(type: BumpUpType, timeSinceLastBump: TimeInterval, price: String?, primaryBlock: @escaping () -> Void, buttonBlock: @escaping () -> Void ) {
        self.type = type
        self.timeSinceLastBump = timeSinceLastBump
        self.price = price
        self.primaryBlock = primaryBlock
        self.buttonBlock = buttonBlock
    }
}

class BumpUpBanner: UIView {

    static let timeLabelWidth: CGFloat = 70
    static let iconSize: CGFloat = 20
    static let iconLeftMargin: CGFloat = 15
    static let timerUpdateInterval: TimeInterval = 1

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var timeLabel: UILabel = UILabel()
    private var descriptionLabel: UILabel = UILabel()
    private var bumpButton: UIButton = UIButton(type: .custom)

    private var iconWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var iconLeftMarginConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var marginBetweenLabelsConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var timeLabelWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    

    private var timer: Timer = Timer()

    private(set) var type: BumpUpType = .free

    private var primaryBlock: () -> Void = {}
    private var buttonBlock: () -> Void = {}

    private let featureFlags: FeatureFlags = FeatureFlags.sharedInstance

    // - Rx
    let timeIntervalLeft = Variable<TimeInterval>(0)
    let timeLabelText = Variable<String?>(nil)
    let descriptionLabelText = Variable<String?>(nil)
    let readyToBump = Variable<Bool>(false)
    let disposeBag = DisposeBag()


    // - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupRx()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public Methods

    func updateInfo(info: BumpUpInfo) {
        type = info.type

        var waitingTime: TimeInterval = 0

        switch type {
        case .free:
            waitingTime = Constants.bumpUpFreeTimeLimit
            bumpButton.setTitle(LGLocalizedString.bumpUpBannerFreeButtonTitle, for: .normal)
        case .priced:
            waitingTime = Constants.bumpUpPaidTimeLimit
            if let price = info.price {
                bumpButton.setTitle(price, for: .normal)
            } else {
                bumpButton.setTitle(LGLocalizedString.bumpUpBannerFreeButtonTitle, for: .normal)
            }
        case .restore:
            waitingTime = Constants.bumpUpPaidTimeLimit
            bumpButton.setTitle(LGLocalizedString.commonErrorRetryButton, for: .normal)
        }

        let timeShouldBeZero = info.timeSinceLastBump <= 0 || (waitingTime - info.timeSinceLastBump < 0)
        timeIntervalLeft.value = timeShouldBeZero ? 0 :waitingTime - info.timeSinceLastBump
        startCountdown()
        bumpButton.isEnabled = timeIntervalLeft.value < 1

        buttonBlock = info.buttonBlock
        primaryBlock = info.primaryBlock
    }

    func resetCountdown() {
        // Update countdown with full waiting time
        switch type {
        case .free:
            timeIntervalLeft.value = Constants.bumpUpFreeTimeLimit
        case .priced, .restore:
            timeIntervalLeft.value = Constants.bumpUpPaidTimeLimit
        }
        startCountdown()
    }

    func stopCountdown() {
        timer.invalidate()
    }

    private func startCountdown() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: BumpUpBanner.timerUpdateInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    dynamic private func bannerTapped() {
        guard readyToBump.value else { return }
        primaryBlock()
    }

    dynamic private func bannerSwipped() {
        guard readyToBump.value else { return }
        primaryBlock()
    }

    dynamic private func bumpButtonPressed() {
        guard readyToBump.value else { return }
        buttonBlock()
    }


    // - Private Methods

    private func setupRx() {
        timeIntervalLeft.asObservable().map { $0 <= 1 }.bindTo(readyToBump).addDisposableTo(disposeBag)

        timeIntervalLeft.asObservable().skip(1).bindNext { [weak self] secondsLeft in
            guard let strongSelf = self else { return }
            let localizedText: String
            if secondsLeft <= 0 {
                strongSelf.timer.invalidate()
                localizedText = strongSelf.type.bannerText
                strongSelf.iconImageView.image = strongSelf.type.bannerIcon
                strongSelf.bumpButton.isEnabled = true
            } else {
                strongSelf.iconImageView.image = UIImage(named: "clock")
                localizedText = LGLocalizedString.bumpUpBannerWaitText
                strongSelf.bumpButton.isEnabled = false
            }
            strongSelf.updateIconConstraints()
            if secondsLeft > 0 {
                strongSelf.timeLabelText.value = Int(secondsLeft).secondsToCountdownFormat()
                strongSelf.marginBetweenLabelsConstraint.constant = -Metrics.shortMargin
                strongSelf.timeLabelWidthConstraint.constant = BumpUpBanner.timeLabelWidth
            } else {
                strongSelf.timeLabelText.value = nil
                strongSelf.marginBetweenLabelsConstraint.constant = 0
                strongSelf.timeLabelWidthConstraint.constant = 0
            }
            strongSelf.descriptionLabelText.value = localizedText
        }.addDisposableTo(disposeBag)

        timeLabelText.asObservable().bindTo(timeLabel.rx.text).addDisposableTo(disposeBag)
        descriptionLabelText.asObservable().bindTo(descriptionLabel.rx.text).addDisposableTo(disposeBag)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        
        timeLabel.numberOfLines = 1
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor = 0.5
        timeLabel.textColor = UIColor.primaryColorHighlighted
        timeLabel.font = UIFont.systemMediumFont(size: 17)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = UIColor.blackText
        descriptionLabel.font = UIFont.systemMediumFont(size: 15)
        
        iconImageView.image = UIImage(named: "red_chevron_up")
        iconImageView.contentMode = .scaleAspectFit
        
        bumpButton.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        bumpButton.setStyle(.primary(fontSize: .small))
        bumpButton.addTarget(self, action: #selector(bumpButtonPressed), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bannerTapped))
        addGestureRecognizer(tapGesture)
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(bannerSwipped))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
    }

    private func setupConstraints() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layout(with: self).fill()
        
        let subviews: [UIView] = [iconImageView, timeLabel, descriptionLabel, bumpButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        containerView.addSubviews(subviews)
        
        iconImageView.layout().width(BumpUpBanner.iconSize, constraintBlock: { [weak self] in
            self?.iconWidthConstraint = $0
        }).height(BumpUpBanner.iconSize)

        iconImageView.layout(with: containerView).left(by: BumpUpBanner.iconLeftMargin, constraintBlock: { [weak self] in
            self?.iconLeftMarginConstraint = $0
        })
        iconImageView.layout(with: timeLabel).right(to: .left, by: -10)
        iconImageView.layout(with: containerView).centerY()

        
        timeLabel.layout(with: containerView).top()
        timeLabel.layout(with: containerView).bottom()
        timeLabel.layout(with: descriptionLabel).right(to: .left, by: -Metrics.shortMargin, constraintBlock: { [weak self] in
            self?.marginBetweenLabelsConstraint = $0
        })
        timeLabel.layout().width(BumpUpBanner.timeLabelWidth, constraintBlock: { [weak self] in
            self?.timeLabelWidthConstraint = $0
        })
        
        descriptionLabel.layout(with: containerView).top()
        descriptionLabel.layout(with: containerView).bottom()
        descriptionLabel.layout(with: bumpButton).right(to: .left, by: -10)

        bumpButton.layout(with: containerView).top(by: 10).bottom(by: -10).right(by: -15)
        bumpButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
    }

    private func updateIconConstraints() {

        let iconWidth: CGFloat = iconImageView.image != nil ? BumpUpBanner.iconSize : 0
        let iconLeftMargin: CGFloat = iconImageView.image != nil ? BumpUpBanner.iconLeftMargin : 0

        iconWidthConstraint.constant = iconWidth
        iconLeftMarginConstraint.constant = iconLeftMargin

        layoutIfNeeded()
    }

    private dynamic func updateTimer() {
        timeIntervalLeft.value = timeIntervalLeft.value-BumpUpBanner.timerUpdateInterval
    }

    private func setAccessibilityIds() {
        accessibilityId = .bumpUpBanner
        bumpButton.accessibilityId = .bumpUpBannerButton
        timeLabel.accessibilityId = .bumpUpBannerLabel
    }
}
