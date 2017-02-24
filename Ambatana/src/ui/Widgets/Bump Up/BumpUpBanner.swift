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
}

struct BumpUpInfo {
    var type: BumpUpType
    var timeSinceLastBump: Int
    var price: String?
    var primaryBlock: (() -> ()?)
    var buttonBlock: (() -> ()?)

    init(type: BumpUpType, timeSinceLastBump: Int, price: String?, primaryBlock: @escaping (()->()?), buttonBlock: @escaping (()->()?)) {
        self.type = type
        self.timeSinceLastBump = timeSinceLastBump
        self.price = price
        self.primaryBlock = primaryBlock
        self.buttonBlock = buttonBlock
    }
}

class BumpUpBanner: UIView {

    static let iconSize: CGFloat = 20
    static let timerUpdateInterval: TimeInterval = 1
    static let secsToMillisecsRatio = 1000

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var textLabel: UILabel = UILabel()
    private var bumpButton: UIButton = UIButton(type: .custom)

    private var timer: Timer = Timer()

    private var type: BumpUpType = .free

    private var primaryBlock: (()->()?) = { return nil }
    private var buttonBlock: (()->()?) = { return nil }

    private let featureFlags: FeatureFlags = FeatureFlags.sharedInstance

    // - Rx
    let timeLeft = Variable<Int>(0)
    let text = Variable<NSAttributedString?>(NSAttributedString())
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

        // bumpUpFreeTimeLimit is the time limit in milliseconds
        timeLeft.value = info.timeSinceLastBump == 0 ? 0 : featureFlags.bumpUpFreeTimeLimit - info.timeSinceLastBump
        startCountdown()
        bumpButton.isEnabled = timeLeft.value < 1


        switch type {
        case .free:
            bumpButton.setTitle(LGLocalizedString.bumpUpBannerFreeButtonTitle, for: .normal)
        case .priced:
            if let price = info.price {
                bumpButton.setTitle(price, for: .normal)
            } else {
                bumpButton.setTitle(LGLocalizedString.bumpUpBannerFreeButtonTitle, for: .normal)
            }
        case .restore:
            bumpButton.setTitle(LGLocalizedString.commonErrorRetryButton, for: .normal)
        }

        buttonBlock = info.buttonBlock
        primaryBlock = info.primaryBlock
    }

    func resetCountdown() {
        // Update countdown with full waiting time
        timeLeft.value = featureFlags.bumpUpFreeTimeLimit
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
        timeLeft.asObservable().map { $0 <= 1 }.bindTo(readyToBump).addDisposableTo(disposeBag)

        let secondsLeft = timeLeft.asObservable().map{ $0/BumpUpBanner.secsToMillisecsRatio }.skip(1)

        secondsLeft.bindNext { [weak self] secondsLeft in
            guard let strongSelf = self else { return }
            let localizedText: String
            if secondsLeft <= 0 {
                strongSelf.timer.invalidate()
                switch strongSelf.type {
                case .free:
                    localizedText = LGLocalizedString.bumpUpBannerFreeText
                    strongSelf.iconImageView.image = UIImage(named: "red_chevron_up")
                case .priced:
                    localizedText = LGLocalizedString.bumpUpBannerPayText
                    strongSelf.iconImageView.image = UIImage(named: "red_chevron_up")
                case .restore:
                    localizedText = LGLocalizedString.bumpUpErrorBumpToken
                    strongSelf.iconImageView.image = nil
                }
                strongSelf.bumpButton.isEnabled = true
            } else {
                strongSelf.iconImageView.image = UIImage(named: "clock")
                localizedText = LGLocalizedString.bumpUpBannerWaitText
                strongSelf.bumpButton.isEnabled = false
            }
            strongSelf.text.value = strongSelf.bubbleText(secondsLeft: secondsLeft, text: localizedText)
        }.addDisposableTo(disposeBag)

        text.asObservable().bindTo(textLabel.rx.attributedText).addDisposableTo(disposeBag)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.minimumScaleFactor = 0.5
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
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [containerView, iconImageView, textLabel, bumpButton])
        // container view
        containerView.layout(with: self).fill()

        containerView.addSubview(textLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(bumpButton)

        // icon
        iconImageView.layout().width(BumpUpBanner.iconSize).height(BumpUpBanner.iconSize)

        iconImageView.layout(with: containerView).left(by: 15)
        iconImageView.layout(with: textLabel).right(to: .left, by: -10)
        iconImageView.layout(with: containerView).centerY()

        // text label
        textLabel.layout(with: containerView).top()
        textLabel.layout(with: containerView).bottom()
        textLabel.layout(with: bumpButton).right(to: .left, by: -10)

        // button
        bumpButton.layout(with: containerView).top(by: 10).bottom(by: -10).right(by: -15)
        bumpButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
    }

    private func bubbleText(secondsLeft: Int, text: String) -> NSAttributedString {

        let fullText: NSMutableAttributedString = NSMutableAttributedString()

        if let countdownText = secondsLeft.secondsToCountdownFormat(), secondsLeft > 0 {
            var timeTextAttributes = [String : AnyObject]()
            timeTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
            timeTextAttributes[NSFontAttributeName] = UIFont.systemMediumFont(size: 17)

            let timeText = NSAttributedString(string: countdownText, attributes: timeTextAttributes)

            fullText.append(timeText)
            fullText.append(NSAttributedString(string: " "))
        }

        var bumpTextAttributes = [String : AnyObject]()
        bumpTextAttributes[NSForegroundColorAttributeName] = UIColor.blackText
        bumpTextAttributes[NSFontAttributeName] = UIFont.systemMediumFont(size: 15)

        let bumpText = NSAttributedString(string: text,
                                          attributes: bumpTextAttributes)

        fullText.append(bumpText)

        return fullText
    }

    private dynamic func updateTimer() {
        timeLeft.value = timeLeft.value-(Int(BumpUpBanner.timerUpdateInterval)*BumpUpBanner.secsToMillisecsRatio)
    }

    private func setAccessibilityIds() {
        accessibilityId = .bumpUpBanner
        bumpButton.accessibilityId = .bumpUpBannerButton
        textLabel.accessibilityId = .bumpUpBannerLabel
    }
}
