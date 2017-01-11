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
    var timeLeftToNextBump: Int
    var price: String?
    var bumpsLeft: Int
    var primaryBlock: (()->()?)
    var buttonBlock: (()->()?)

    init(free: Bool, timeLeftToNextBump: Int, price: String?, bumpsLeft: Int, primaryBlock: (()->()?), buttonBlock: (()->()?)) {
        self.free = free
        self.timeLeftToNextBump = timeLeftToNextBump
        self.price = price
        self.bumpsLeft = bumpsLeft
        self.primaryBlock = primaryBlock
        self.buttonBlock = buttonBlock
    }
}

class BumpUpBanner: UIView {

    static let iconSize: CGFloat = 20

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var textLabel: UILabel = UILabel()
    private var bumpButton: UIButton = UIButton(type: .Custom)

    private var timer: NSTimer = NSTimer()

    private var isFree: Bool = true

    private var primaryBlock: (()->()?) = { return nil }
    private var buttonBlock: (()->()?) = { return nil }


    // - Rx
    let timeLeft = Variable<Int>(0)
    let text = Variable<NSAttributedString?>(NSAttributedString())

    let disposeBag = DisposeBag()


    // - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRx()
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public Methods

    func updateInfo(info: BumpUpInfo) {
        isFree = info.free
        timeLeft.value = Int(info.timeLeftToNextBump/1000) // timeLeft in seconds
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

        if let price = info.price where !isFree {
            bumpButton.setTitle(price, forState: .Normal)
        } else {
            bumpButton.setTitle(LGLocalizedString.bumpUpBannerFreeButtonTitle, forState: .Normal)
        }

        buttonBlock = info.buttonBlock
        primaryBlock = info.primaryBlock
    }

    dynamic private func openBumpView() {
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
            if secondsLeft < 1 {
                strongSelf.timer.invalidate()
                localizedText = strongSelf.isFree ? LGLocalizedString.bumpUpBannerFreeText : LGLocalizedString.bumpUpBannerPayText
                strongSelf.iconImageView.image = UIImage(named: "red_chevron_up")
            } else {
                strongSelf.iconImageView.image = UIImage(named: "clock")
                localizedText = LGLocalizedString.bumpUpBannerWaitText
            }
            strongSelf.text.value = strongSelf.bubbleText(secondsLeft, text: localizedText)
        }.addDisposableTo(disposeBag)

        text.asObservable().bindTo(textLabel.rx_attributedText).addDisposableTo(disposeBag)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.minimumScaleFactor = 0.5
        iconImageView.image = UIImage(named: "red_chevron_up")
        iconImageView.contentMode = .ScaleAspectFit
        bumpButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        bumpButton.setStyle(.Primary(fontSize: .Small))
        bumpButton.addTarget(self, action: #selector(bumpButtonPressed), forControlEvents: .TouchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openBumpView))
        addGestureRecognizer(tapGesture)
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(openBumpView))
        swipeUpGesture.direction = .Up
        addGestureRecognizer(swipeUpGesture)
    }

    private func setupConstraints() {
        addSubview(containerView)

        // container view
        containerView.layout(with: self).fill().apply()

        containerView.addSubview(textLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(bumpButton)

        // icon
        iconImageView.layout().width(BumpUpBanner.iconSize).height(BumpUpBanner.iconSize).apply()

        iconImageView.layout(with: containerView).left(by: 15).apply()
        iconImageView.layout(with: textLabel).right(to: .Left, by: -10).apply()
        iconImageView.layout(with: containerView).centerY().apply()

        // text label
        textLabel.layout(with: containerView).top().apply()
        textLabel.layout(with: containerView).bottom().apply()
        textLabel.layout(with: bumpButton).right(to: .Left, by: -10).apply()

        // button

        bumpButton.layout(with: containerView).top(by: 5).bottom(by: -5).right(by: -15).apply()
        bumpButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)

        setNeedsLayout()
    }

    private func bubbleText(secondsLeft: Int, text: String) -> NSAttributedString {

        let fullText: NSMutableAttributedString = NSMutableAttributedString()

        if let countdownText = textForCountdown(secondsLeft) {
            var timeTextAttributes = [String : AnyObject]()
            timeTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
            timeTextAttributes[NSFontAttributeName] = UIFont.systemMediumFont(size: 17)

            let timeText = NSAttributedString(string: countdownText, attributes: timeTextAttributes)

            fullText.appendAttributedString(timeText)
            fullText.appendAttributedString(NSAttributedString(string: " "))
        }

        var bumpTextAttributes = [String : AnyObject]()
        bumpTextAttributes[NSForegroundColorAttributeName] = UIColor.blackText
        bumpTextAttributes[NSFontAttributeName] = UIFont.systemMediumFont(size: 15)

        let bumpText = NSAttributedString(string: text,
                                          attributes: bumpTextAttributes)

        fullText.appendAttributedString(bumpText)

        return fullText
    }

    private dynamic func updateTimer() {
        timeLeft.value = timeLeft.value-1
    }

    private func textForCountdown(timeSeconds: Int) -> String? {
        guard timeSeconds > 0 else { return nil }
        let hours = timeSeconds/3600
        let mins = (timeSeconds%3600)/60
        let secs = timeSeconds%60
        return "\(hours):\(mins):\(secs)"
    }

    private func setAccessibilityIds() {
        accessibilityId = .BumpUpBanner
        bumpButton.accessibilityId = .BumpUpBannerButton
        textLabel.accessibilityId = .BumpUpBannerLabel
    }
}
