//
//  BumpUpBubble.swift
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

class BumpUpBubble: UIView {

    static let iconSize: CGFloat = 20

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var textlabel: UILabel = UILabel()
    private var bumpButton: UIButton = UIButton(type: .Custom)

    private var localizedText: String = ""
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
            bumpButton.setTitle(LGLocalizedString.bumpUpBubbleFreeButtonTitle, forState: .Normal)
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
        timeLeft.asObservable().skip(1).bindNext { [weak self] secondsLeft in
            guard let strongSelf = self else { return }
            if secondsLeft < 1 {
                strongSelf.timer.invalidate()
                strongSelf.localizedText = strongSelf.isFree ? LGLocalizedString.bumpUpBubbleFreeText : LGLocalizedString.bumpUpBubblePayText
                strongSelf.iconImageView.image = UIImage(named: "red_chevron_up")
            } else {
                strongSelf.iconImageView.image = UIImage(named: "clock")
                strongSelf.localizedText = LGLocalizedString.bumpUpBubbleWaitText
            }
            strongSelf.text.value = strongSelf.bubbleText(secondsLeft)
        }.addDisposableTo(disposeBag)

        text.asObservable().bindTo(textlabel.rx_attributedText).addDisposableTo(disposeBag)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        textlabel.numberOfLines = 0
        textlabel.minimumScaleFactor = 0.5
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
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textlabel.translatesAutoresizingMaskIntoConstraints = false
        bumpButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)

        // container view
        let containerTopConstraint = NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal,
                                                        toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let containerBottomConstraint = NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal,
                                                           toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        let containerLeftConstraint = NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .Equal,
                                                         toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let containerRightConstraint = NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .Equal,
                                                          toItem: self, attribute: .Right, multiplier: 1, constant: 0)

        addConstraints([containerTopConstraint, containerBottomConstraint, containerLeftConstraint,
            containerRightConstraint])

        containerView.addSubview(textlabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(bumpButton)

        let iconWidthConstraint = NSLayoutConstraint(item: iconImageView, attribute: .Width, relatedBy: .Equal,
                                                     toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                     constant: BumpUpBubble.iconSize)
        let iconHeightConstraint = NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal,
                                                      toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                      constant: BumpUpBubble.iconSize)
        iconImageView.addConstraints([iconWidthConstraint, iconHeightConstraint])

        // icon
        let iconLeftConstraint = NSLayoutConstraint(item: iconImageView, attribute: .Left, relatedBy: .Equal,
                                                    toItem: containerView, attribute: .Left, multiplier: 1, constant: 15)
        let iconCenterY = NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal,
                                             toItem: containerView, attribute: .CenterY, multiplier: 1, constant: 0)
        let iconToLabelTrailing = NSLayoutConstraint(item: iconImageView, attribute: .Right, relatedBy: .Equal,
                                                     toItem: textlabel, attribute: .Left, multiplier: 1, constant: -10)

        // text label
        let labelTopConstraint = NSLayoutConstraint(item: textlabel, attribute: .Top, relatedBy: .Equal,
                                                    toItem: containerView, attribute: .Top, multiplier: 1, constant: 0)
        let labelBottomConstraint = NSLayoutConstraint(item: textlabel, attribute: .Bottom, relatedBy: .Equal,
                                                       toItem: containerView, attribute: .Bottom, multiplier: 1, constant: 0)
        let labelToButtonTrailing = NSLayoutConstraint(item: textlabel, attribute: .Right, relatedBy: .Equal,
                                                      toItem: bumpButton, attribute: .Left, multiplier: 1, constant: -10)

        // button
        let buttonTopConstraint = NSLayoutConstraint(item: bumpButton, attribute: .Top, relatedBy: .Equal,
                                                    toItem: containerView, attribute: .Top, multiplier: 1, constant: 5)
        let buttonBottomConstraint = NSLayoutConstraint(item: bumpButton, attribute: .Bottom, relatedBy: .Equal,
                                                       toItem: containerView, attribute: .Bottom, multiplier: 1, constant: -5)
        let buttonRightConstraint = NSLayoutConstraint(item: bumpButton, attribute: .Right, relatedBy: .Equal,
                                                        toItem: containerView, attribute: .Right, multiplier: 1, constant: -15)

        bumpButton.setContentCompressionResistancePriority(751, forAxis: .Horizontal)

        containerView.addConstraints([iconLeftConstraint, iconCenterY, iconToLabelTrailing, labelTopConstraint, labelBottomConstraint,
            labelToButtonTrailing, buttonTopConstraint, buttonBottomConstraint, buttonRightConstraint])

        setNeedsLayout()
    }

    private func bubbleText(secondsLeft: Int) -> NSAttributedString {

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

        let bumpText = NSAttributedString(string: localizedText,
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
}

