//
//  BubbleNotification.swift
//  LetGo
//
//  Created by Dídac on 18/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


class BubbleNotification: UIView {

    static let iconSize: CGFloat = 24

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var textlabel: UILabel = UILabel()

    var heightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()

    private var text: String?
    private var icon: UIImage?


    // - Lifecycle

    convenience init(text: String?, icon: UIImage?) {
        self.init()
        self.text = text
        self.icon = icon
        setupUI()
        setupConstraints()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupOnView(parentView: UIView) {
        // bubble constraints
        let bubbleLeftConstraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal,
                                                      toItem: parentView, attribute: .Left, multiplier: 1, constant: 0)
        let bubbleRightConstraint = NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal,
                                                       toItem: parentView, attribute: .Right, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal,
                                                     toItem: parentView, attribute: .Top, multiplier: 1, constant: 0)
        parentView.addConstraints([bubbleLeftConstraint, bubbleRightConstraint, bottomConstraint])
    }

    func showBubble() {
        // delay to let the setup build the view properly
        delay(0.1) { [weak self] in
            self?.bottomConstraint.constant = self?.height ?? 0
            UIView.animateWithDuration(0.3, animations: {
                self?.layoutIfNeeded()
            })
        }
    }

    func removeBubble() {
        self.removeFromSuperview()
    }

    dynamic private func closeBubble() {
        self.bottomConstraint.constant = 0
        UIView.animateWithDuration(0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self ] _ in
            self?.removeBubble()
        }
    }

    // - Private Methods

    private func setupUI() {
        backgroundColor = UIColor.black
        textlabel.numberOfLines = 0
        textlabel.textColor = UIColor.whiteText
        textlabel.font = UIFont.mediumBodyFont
        textlabel.text = text
        iconImageView.image = icon

        let _ = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(closeBubble), userInfo: nil,
                                                       repeats: false)
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
                                                        toItem: self, attribute: .Top, multiplier: 1, constant: 34)
        let containerBottomConstraint = NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal,
                                                           toItem: self, attribute: .Bottom, multiplier: 1, constant: -14)

        let containerLeftConstraint = NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .GreaterThanOrEqual,
                                                         toItem: self, attribute: .Left, multiplier: 1, constant: 14)
        let containerRightConstraint = NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .LessThanOrEqual,
                                                          toItem: self, attribute: .Right, multiplier: 1, constant: -14)

        addConstraints([centerXConstraint, containerTopConstraint, containerBottomConstraint, containerLeftConstraint,
            containerRightConstraint])

        containerView.addSubview(textlabel)
        containerView.addSubview(iconImageView)

        // icon view
        let iconWidth = icon != nil ? BubbleNotification.iconSize : 0

        let iconWidthConstraint = NSLayoutConstraint(item: iconImageView, attribute: .Width, relatedBy: .Equal,
                                                     toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                     constant: iconWidth)
        let iconHeightConstraint = NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal,
                                                      toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                      constant: BubbleNotification.iconSize)
        iconImageView.addConstraints([iconWidthConstraint, iconHeightConstraint])

        // text label
        let iconCenterY = NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal,
                                             toItem: containerView, attribute: .CenterY, multiplier: 1, constant: 0)
        
        let iconToLabelTrailing = NSLayoutConstraint(item: iconImageView, attribute: .Right, relatedBy: .Equal,
                                                     toItem: textlabel, attribute: .Left, multiplier: 1, constant: -10)

        let labelTopConstraint = NSLayoutConstraint(item: textlabel, attribute: .Top, relatedBy: .Equal,
                                                    toItem: containerView, attribute: .Top, multiplier: 1, constant: 0)
        let labelBottomConstraint = NSLayoutConstraint(item: textlabel, attribute: .Bottom, relatedBy: .Equal,
                                                       toItem: containerView, attribute: .Bottom, multiplier: 1, constant: 0)

        let labelRightConstraint = NSLayoutConstraint(item: textlabel, attribute: .Right, relatedBy: .Equal,
                                                      toItem: containerView, attribute: .Right, multiplier: 1, constant: 0)

        let iconLeftConstraint = NSLayoutConstraint(item: iconImageView, attribute: .Left, relatedBy: .Equal,
                                                    toItem: containerView, attribute: .Left, multiplier: 1, constant: 0)

        containerView.addConstraints([iconCenterY, iconToLabelTrailing, labelTopConstraint, labelBottomConstraint,
            labelRightConstraint, iconLeftConstraint])
    }
}
