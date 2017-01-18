//
//  BumpUpBanner.swift
//  LetGo
//
//  Created by Dídac on 02/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

struct BumpUpInfo {
    var free: Bool
    var timeSinceLastBump: Int
    var price: String?
    var primaryBlock: (()->()?)
    var buttonBlock: (()->()?)

    init(free: Bool, timeSinceLastBump: Int, price: String?, primaryBlock: @escaping (()->()?), buttonBlock: @escaping (()->()?)) {
        self.free = free
        self.timeSinceLastBump = timeSinceLastBump
        self.price = price
        self.primaryBlock = primaryBlock
        self.buttonBlock = buttonBlock
    }
}

class BumpUpBanner: UIView {

    static let iconSize: CGFloat = 20

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var textLabel: UILabel = UILabel()
    private var bumpButton: UIButton = UIButton(type: .custom)

    private var timer: Timer = Timer()

    private var isFree: Bool = true

    private var primaryBlock: (()->()?) = { return nil }
    private var buttonBlock: (()->()?) = { return nil }

    private let featureFlags: FeatureFlags = FeatureFlags.sharedInstance

    // - Rx
    let timeLeft = Variable<Int>(0)
    let text = Variable<NSAttributedString?>(NSAttributedString())

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
        isFree = info.free

        // bumpUpFreeTimeLimit is the time limit in hours
        let timeLimitInSecs = Int(featureFlags.bumpUpFreeTimeLimit) * 60 * 60
        timeLeft.value = timeLimitInSecs - Int(info.timeSinceLastBump/1000)
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

        bumpButton.isEnabled = timeLeft.value < 1

        if let price = info.price, !isFree {
            bumpButton.setTitle(price, for: .normal)
        } else {
            bumpButton.setTitle(LGLocalizedString.bumpUpBannerFreeButtonTitle, for: .normal)
        }

        buttonBlock = info.buttonBlock
        primaryBlock = info.primaryBlock
    }

    dynamic private func bannerTapped() {
        primaryBlock()
    }

    dynamic private func bannerSwipped() {
        primaryBlock()
    }

    dynamic private func bumpButtonPressed() {
        buttonBlock()
    }


    // - Private Methods

    private func setupRx() {
        let secondsLeft = timeLeft.asObservable().skip(1)
        secondsLeft.bindNext { [weak self] secondsLeft in
            guard let strongSelf = self else { return }
            let localizedText: String
            if secondsLeft <= 1 {
                strongSelf.timer.invalidate()
                localizedText = strongSelf.isFree ? LGLocalizedString.bumpUpBannerFreeText : LGLocalizedString.bumpUpBannerPayText
                strongSelf.iconImageView.image = UIImage(named: "red_chevron_up")
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
        timeLeft.value = timeLeft.value-1
    }

    private func setAccessibilityIds() {
        accessibilityId = .bumpUpBanner
        bumpButton.accessibilityId = .bumpUpBannerButton
        textLabel.accessibilityId = .bumpUpBannerLabel
    }
}
