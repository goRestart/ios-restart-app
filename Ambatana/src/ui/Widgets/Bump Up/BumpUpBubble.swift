//
//  BumpUpBubble.swift
//  LetGo
//
//  Created by Dídac on 02/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift


class BumpUpBubble: UIView {

    static let iconSize: CGFloat = 24
    static let bubbleContentMargin: CGFloat = 14

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var textlabel: UILabel = UILabel()
    private var bumpButton: UIButton = UIButton()

    private var localizedText: String = ""
    private var timer: NSTimer = NSTimer()

    // - Rx
    let timeLeft = Variable<Int>(0)
    let text = Variable<NSAttributedString?>(NSAttributedString())
    let buttonTitle = Variable<String?>("")

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


    func updateInfo(free: Bool, timeLeftToNextBump: Int?, price: Int?) {

        if free {
            localizedText = "_ Bump up for free to sell faster"
        } else if let time = timeLeftToNextBump {
            timeLeft.value = Int(time/1000) // timeLeft in seconds
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
    }


    // - Private Methods

    private func setupRx() {
        timeLeft.asObservable().skip(1).bindNext { [weak self] secondsLeft in
            guard let strongSelf = self else { return }
            if secondsLeft < 1 {
                strongSelf.timer.invalidate()
                strongSelf.localizedText = "_ Bump up to sell faster"
                strongSelf.iconImageView.image = UIImage(named: "arrow_up")
            } else {
                strongSelf.iconImageView.image = UIImage(named: "clock")
                strongSelf.localizedText = "_ to bump up again"
            }
            strongSelf.text.value = strongSelf.bubbleText(secondsLeft)
        }.addDisposableTo(disposeBag)

        text.asObservable().bindTo(textlabel.rx_attributedText).addDisposableTo(disposeBag)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        textlabel.numberOfLines = 0
        iconImageView.image = UIImage(named: "arrow_up")
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textlabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)

        // container view
        let centerXConstraint = NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal,
                                                   toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let containerTopConstraint = NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal,
                                                        toItem: self, attribute: .Top, multiplier: 1,
                                                        constant: BumpUpBubble.bubbleContentMargin)
        let containerBottomConstraint = NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal,
                                                           toItem: self, attribute: .Bottom, multiplier: 1,
                                                           constant: -BumpUpBubble.bubbleContentMargin)

        let containerLeftConstraint = NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .GreaterThanOrEqual,
                                                         toItem: self, attribute: .Left, multiplier: 1,
                                                         constant: BumpUpBubble.bubbleContentMargin)
        let containerRightConstraint = NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .LessThanOrEqual,
                                                          toItem: self, attribute: .Right, multiplier: 1,
                                                          constant: -BumpUpBubble.bubbleContentMargin)

        addConstraints([centerXConstraint, containerTopConstraint, containerBottomConstraint, containerLeftConstraint,
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
                                                    toItem: containerView, attribute: .Left, multiplier: 1, constant: 0)

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
                                                    toItem: containerView, attribute: .Top, multiplier: 1, constant: 10)

        let buttonBottomConstraint = NSLayoutConstraint(item: bumpButton, attribute: .Bottom, relatedBy: .Equal,
                                                       toItem: containerView, attribute: .Bottom, multiplier: 1, constant: 10)

        let buttonRightConstraint = NSLayoutConstraint(item: bumpButton, attribute: .Right, relatedBy: .Equal,
                                                        toItem: containerView, attribute: .Right, multiplier: 1, constant: -15)


        containerView.addConstraints([iconLeftConstraint, iconCenterY, iconToLabelTrailing, labelTopConstraint, labelBottomConstraint,
            labelToButtonTrailing, buttonTopConstraint, buttonBottomConstraint, buttonRightConstraint])
    }

    private func bubbleText(secondsLeft: Int) -> NSAttributedString {

        let fullText: NSMutableAttributedString = NSMutableAttributedString()

        if let countdownText = textForCountdown(secondsLeft) {
            var timeTextAttributes = [String : AnyObject]()
            timeTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
            timeTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

            let timeText = NSAttributedString(string: countdownText, attributes: timeTextAttributes)

            fullText.appendAttributedString(timeText)
            fullText.appendAttributedString(NSAttributedString(string: " "))
        }

        var bumpTextAttributes = [String : AnyObject]()
        bumpTextAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        bumpTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 15)

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

