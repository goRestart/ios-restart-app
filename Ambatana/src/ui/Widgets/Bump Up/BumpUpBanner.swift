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
    case hidden

    var bannerText: String {
        switch self {
        case .free:
            return LGLocalizedString.bumpUpBannerPayTextImprovement
        case .priced, .hidden:
            return LGLocalizedString.bumpUpBannerPayTextImprovement
        case .restore:
            return LGLocalizedString.bumpUpErrorBumpToken
        }
    }

    var bannerIcon: UIImage? {
        switch self {
        case .free, .priced, .hidden:
            return UIImage(named: "gray_chevron_up")
        case .restore:
            return nil
        }
    }

    var bannerTextIcon: UIImage? {
        switch self {
        case .free, .priced, .hidden:
            return UIImage(named: "ic_lightning")
        case .restore:
            return nil
        }
    }

    var bannerFont: UIFont {
        switch self {
        case .restore:
            return BumpUpBanner.bannerDefaultFont
        case .free, .priced, .hidden:
            return UIFont.systemSemiBoldFont(size: 17)
        }
    }
}

struct BumpUpInfo {
    var type: BumpUpType
    var timeSinceLastBump: TimeInterval
    var maxCountdown: TimeInterval
    var price: String?
    var bannerInteractionBlock: () -> Void
    var buttonBlock: () -> Void
    var boostEnabled: Bool
    var shouldShowProgressBar: Bool

    init(type: BumpUpType, timeSinceLastBump: TimeInterval, maxCountdown: TimeInterval, price: String?, bannerInteractionBlock: @escaping () -> Void,
         buttonBlock: @escaping () -> Void, boostEnabled: Bool, shouldShowProgressBar: Bool ) {
        self.type = type
        self.timeSinceLastBump = timeSinceLastBump
        self.maxCountdown = maxCountdown
        self.price = price
        self.bannerInteractionBlock = bannerInteractionBlock
        self.buttonBlock = buttonBlock
        self.boostEnabled = boostEnabled
        self.shouldShowProgressBar = shouldShowProgressBar
    }
}

class BumpUpBanner: UIView {

    static let bannerDefaultFont: UIFont = UIFont.systemMediumFont(size: 15)

    static let timeLabelWidth: CGFloat = 80
    static let iconSize: CGFloat = 20
    static let iconLeftMargin: CGFloat = 15
    static let timerUpdateInterval: TimeInterval = 1

    private let containerView: UIView = UIView()
    private let improvedTextContainerView: UIView = UIView()
    private let leftIconImageView: UIImageView = UIImageView()
    private let textIconImageView: UIImageView = UIImageView()
    private let timeLabel: UILabel = UILabel()
    private let descriptionLabel: UILabel = UILabel()
    private let bumpButton = LetgoButton(withStyle: .primary(fontSize: .small))

    private var leftIconWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var leftIconLeftMarginConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var textIconWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var textIconLeftMarginConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var timeLabelRightMarginConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var timeLabelWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var textContainerCenterConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var bumpButtonWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()

    private var maxCountdown: TimeInterval = 0
    private var timer: Timer = Timer()

    private(set) var type: BumpUpType = .free

    private var bannerInteractionBlock: () -> Void = {}
    private var buttonBlock: () -> Void = {}

    private var boostEnabled: Bool = false
    private var shouldShowProgressBar: Bool = false

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
        maxCountdown = info.maxCountdown
        boostEnabled = info.boostEnabled
        shouldShowProgressBar = info.shouldShowProgressBar

        var waitingTime: TimeInterval = 0

        switch type {
        case .free:
            waitingTime = info.maxCountdown
            bumpButtonWidthConstraint.isActive = false
            bumpButton.isHidden = true
            bumpButton.setTitle(LGLocalizedString.bumpUpBannerFreeButtonTitle, for: .normal)
        case .priced, .hidden:
            bumpButtonWidthConstraint.isActive = false
            bumpButton.isHidden = true
            waitingTime = info.maxCountdown
            if let price = info.price {
                bumpButton.setTitle(price, for: .normal)
            } else {
                bumpButton.setTitle(LGLocalizedString.bumpUpBannerFreeButtonTitle, for: .normal)
            }
        case .restore:
            bumpButton.isHidden = false
            bumpButtonWidthConstraint.isActive = true
            waitingTime = info.maxCountdown
            bumpButton.setTitle(LGLocalizedString.commonErrorRetryButton, for: .normal)
        }

        let timeShouldBeZero = info.timeSinceLastBump <= 0 || (waitingTime - info.timeSinceLastBump < 0)
        timeIntervalLeft.value = timeShouldBeZero ? 0 : waitingTime - info.timeSinceLastBump
        startCountdown()
        bumpButton.isEnabled = timeIntervalLeft.value < 1

        buttonBlock = info.buttonBlock
        bannerInteractionBlock = info.bannerInteractionBlock
    }

    func resetCountdown() {
        // Update countdown with full waiting time
        switch type {
        case .free:
            timeIntervalLeft.value = maxCountdown
        case .priced, .restore, .hidden:
            timeIntervalLeft.value = maxCountdown
        }
        startCountdown()
    }

    func stopCountdown() {
        timer.invalidate()
    }
    
    func executeBannerInteractionBlock() {
        guard readyToBump.value else { return }
        bannerInteractionBlock()
    }

    private func startCountdown() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: BumpUpBanner.timerUpdateInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private func bannerTapped() {
        executeBannerInteractionBlock()
    }

    @objc private func bannerSwipped() {
        executeBannerInteractionBlock()
    }

    @objc private func bumpButtonPressed() {
        guard readyToBump.value else { return }
        buttonBlock()
    }


    // - Private Methods

    private func setupRx() {
        
        timeIntervalLeft.asObservable().map { $0 <= 1 }.bind(to: readyToBump).disposed(by: disposeBag)

        timeIntervalLeft.asObservable().skip(1).bind { [weak self] secondsLeft in
            guard let strongSelf = self else { return }
            let localizedText: String
            var descriptionFont = BumpUpBanner.bannerDefaultFont
            if secondsLeft <= 0 {
                strongSelf.timer.invalidate()
                localizedText = strongSelf.type.bannerText
                strongSelf.leftIconImageView.image = strongSelf.type.bannerIcon
                strongSelf.textIconImageView.image = strongSelf.type.bannerTextIcon
                descriptionFont = strongSelf.type.bannerFont
                strongSelf.bumpButton.isEnabled = true
            } else {
                strongSelf.textIconImageView.image = nil
                strongSelf.leftIconImageView.image = UIImage(named: "clock")
                localizedText = LGLocalizedString.bumpUpBannerWaitText
                strongSelf.bumpButton.isEnabled = false
            }
            strongSelf.updateIconsConstraints()
            if secondsLeft > 0 {
                strongSelf.timeLabelText.value = Int(secondsLeft).secondsToCountdownFormat()
                strongSelf.timeLabelRightMarginConstraint.constant = -Metrics.shortMargin
                strongSelf.timeLabelWidthConstraint.constant = BumpUpBanner.timeLabelWidth
                strongSelf.textContainerCenterConstraint.isActive = false
            } else {
                strongSelf.timeLabelText.value = nil
                strongSelf.timeLabelRightMarginConstraint.constant = 0
                strongSelf.timeLabelWidthConstraint.constant = 0
                if strongSelf.type == .restore {
                    strongSelf.textContainerCenterConstraint.isActive = false
                }
            }
            strongSelf.descriptionLabelText.value = localizedText
            strongSelf.descriptionLabel.font = descriptionFont
        }.disposed(by: disposeBag)

        timeLabelText.asObservable().bind(to: timeLabel.rx.text).disposed(by: disposeBag)
        descriptionLabelText.asObservable().bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        
        timeLabel.numberOfLines = 1
        timeLabel.adjustsFontSizeToFitWidth = false
        timeLabel.textAlignment = .center
        timeLabel.textColor = UIColor.primaryColorHighlighted
        timeLabel.font = UIFont.systemMediumFont(size: 17)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = UIColor.blackText
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = BumpUpBanner.bannerDefaultFont
        
        leftIconImageView.image = UIImage(named: "red_chevron_up")
        leftIconImageView.contentMode = .scaleAspectFit

        textIconImageView.image = nil
        textIconImageView.contentMode = .scaleAspectFit
        
        bumpButton.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
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

        let improvedTextViews: [UIView] = [textIconImageView, descriptionLabel]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: improvedTextViews)
        improvedTextContainerView.addSubviews(improvedTextViews)

        let subviews: [UIView] = [leftIconImageView, timeLabel, improvedTextContainerView, bumpButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        containerView.addSubviews(subviews)
        
        leftIconImageView.layout().width(BumpUpBanner.iconSize, constraintBlock: { [weak self] in
            self?.leftIconWidthConstraint = $0
        }).height(BumpUpBanner.iconSize)

        leftIconImageView.layout(with: containerView).left(by: BumpUpBanner.iconLeftMargin, constraintBlock: { [weak self] in
            self?.leftIconLeftMarginConstraint = $0
        })
        leftIconImageView.layout(with: timeLabel).right(to: .left, by: -10)
        leftIconImageView.layout(with: containerView).centerY()

        timeLabel.layout(with: containerView).top()
        timeLabel.layout(with: containerView).bottom()
        timeLabel.layout().width(BumpUpBanner.timeLabelWidth, relatedBy: .greaterThanOrEqual, constraintBlock: { [weak self] in
            self?.timeLabelWidthConstraint = $0
        })
        timeLabel.layout(with: improvedTextContainerView).right(to: .left, by: -Metrics.shortMargin, constraintBlock: { [weak self] in
            self?.timeLabelRightMarginConstraint = $0
        })
        timeLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)

        improvedTextContainerView.layout(with: containerView).top()
        improvedTextContainerView.layout(with: containerView).bottom()
        improvedTextContainerView.layout(with: containerView).centerX(constraintBlock: { [weak self] in
            self?.textContainerCenterConstraint = $0
        })
        improvedTextContainerView.layout(with: bumpButton).right(to: .left, by: -10, relatedBy: .lessThanOrEqual)
        improvedTextContainerView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)


        textIconImageView.layout().width(BumpUpBanner.iconSize, constraintBlock: { [weak self] in
            self?.textIconWidthConstraint = $0
        }).height(BumpUpBanner.iconSize)
        textIconImageView.layout(with: improvedTextContainerView).left()
        textIconImageView.layout(with: improvedTextContainerView).centerY()
        textIconImageView.layout(with: descriptionLabel).right(to: .left, by: -Metrics.shortMargin, constraintBlock:{ [weak self] in
            self?.textIconLeftMarginConstraint = $0
        })

        descriptionLabel.layout(with: improvedTextContainerView).top()
        descriptionLabel.layout(with: improvedTextContainerView).bottom()
        descriptionLabel.layout(with: improvedTextContainerView).right()
        descriptionLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)

        bumpButton.layout(with: containerView).top(by: 10).bottom(by: -10).right(by: -15)
        bumpButton.layout().width(BumpUpBanner.timeLabelWidth, relatedBy: .greaterThanOrEqual, constraintBlock: { [weak self] in
            self?.bumpButtonWidthConstraint = $0
        })
        bumpButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    }

    private func updateIconsConstraints() {

        let leftIconWidth: CGFloat = leftIconImageView.image != nil ? BumpUpBanner.iconSize : 0
        let leftIconLeftMargin: CGFloat = leftIconImageView.image != nil ? BumpUpBanner.iconLeftMargin : 0

        leftIconWidthConstraint.constant = leftIconWidth
        leftIconLeftMarginConstraint.constant = leftIconLeftMargin

        let textIconWidth: CGFloat = textIconImageView.image != nil ? BumpUpBanner.iconSize : 0
        let textIconLeftMargin: CGFloat = textIconImageView.image != nil ? -Metrics.shortMargin : 0

        textIconWidthConstraint.constant = textIconWidth
        textIconLeftMarginConstraint.constant = textIconLeftMargin

        layoutIfNeeded()
    }

    @objc private dynamic func updateTimer() {
        timeIntervalLeft.value = timeIntervalLeft.value-BumpUpBanner.timerUpdateInterval
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .bumpUpBanner)
        bumpButton.set(accessibilityId: .bumpUpBannerButton)
        timeLabel.set(accessibilityId: .bumpUpBannerLabel)
    }
}
