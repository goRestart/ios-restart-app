//
//  BubbleNotification.swift
//  LetGo
//
//  Created by Dídac on 18/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum BubbleStyle {
    case Interested
    case Action

    var bgColor: UIColor {
        switch self {
        case .Interested:
            return UIColor.black
        case .Action:
            return UIColor.white
        }
    }

    var textColor: UIColor {
        switch self {
        case .Interested:
            return UIColor.white
        case .Action:
            return UIColor.blackText
        }
    }
}


class BubbleNotification: UIView {

    static let iconSize: CGFloat = 24
    static let buttonHeight: CGFloat = 30
    static let buttonMaxWidth: CGFloat = 150
    static let bubbleContentMargin: CGFloat = 14
    static let statusBarHeight: CGFloat = 20

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var textlabel: UILabel = UILabel()
    private var actionButton: UIButton = UIButton(type: .Custom)

    var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()

    private var style: BubbleStyle = .Action
    private var text: String?
    private var icon: UIImage?
    private var action: UIAction?


    // - Lifecycle

    convenience init(style: BubbleStyle, text: String?, icon: UIImage?, action: UIAction?) {
        self.init()
        self.style = style
        self.text = text
        self.icon = icon
        self.action = action
        setupConstraints()
        setupUI()
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

    func closeBubble() {
        self.bottomConstraint.constant = 0
        UIView.animateWithDuration(0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self ] _ in
            self?.removeBubble()
        }
    }

    // MARK : - Private methods

    private func setupUI() {
        backgroundColor = style.bgColor
        textlabel.numberOfLines = 0
        textlabel.textColor = style.textColor
        textlabel.font = UIFont.mediumBodyFont
        textlabel.text = text
        iconImageView.image = icon
        if let action = action {
            actionButton.setStyle(.Secondary(fontSize: .Small, withBorder: true))
            actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
            actionButton.setTitle(action.text, forState: .Normal)
            actionButton.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
            actionButton.accessibilityId =  action.accessibilityId
        }
    }

    dynamic private func buttonTapped() {
        guard let action = action else { return }
        action.action()
        closeBubble()
    }

    private func setupConstraints() {

        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textlabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)

        // container view
        let centerXConstraint = NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal,
                                                   toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let containerTopConstraint = NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal,
                                                        toItem: self, attribute: .Top, multiplier: 1,
                                                        constant: BubbleNotification.bubbleContentMargin + BubbleNotification.statusBarHeight)
        let containerBottomConstraint = NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal,
                                                           toItem: self, attribute: .Bottom, multiplier: 1,
                                                           constant: -BubbleNotification.bubbleContentMargin)

        let containerLeftConstraint = NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .GreaterThanOrEqual,
                                                         toItem: self, attribute: .Left, multiplier: 1,
                                                         constant: BubbleNotification.bubbleContentMargin)
        let containerRightConstraint = NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .LessThanOrEqual,
                                                          toItem: self, attribute: .Right, multiplier: 1,
                                                          constant: -BubbleNotification.bubbleContentMargin)

        addConstraints([centerXConstraint, containerTopConstraint, containerBottomConstraint, containerLeftConstraint,
            containerRightConstraint])

        switch style {
        case .Interested:
            setupInterestedStyleConstraints()
        case .Action:
            setupActionStyleConstraints()
        }
        layoutIfNeeded()
    }

    private func setupInterestedStyleConstraints() {
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

    private func setupActionStyleConstraints() {
        containerView.addSubview(textlabel)
        containerView.addSubview(actionButton)

        // text label
        let buttonCenterY = NSLayoutConstraint(item: actionButton, attribute: .CenterY, relatedBy: .Equal,
                                             toItem: containerView, attribute: .CenterY, multiplier: 1, constant: 0)

        let labelToButtonTrailing = NSLayoutConstraint(item: textlabel, attribute: .Right, relatedBy: .Equal,
                                                     toItem: actionButton, attribute: .Left, multiplier: 1, constant: -10)

        let labelTopConstraint = NSLayoutConstraint(item: textlabel, attribute: .Top, relatedBy: .Equal,
                                                    toItem: containerView, attribute: .Top, multiplier: 1, constant: 0)
        let labelBottomConstraint = NSLayoutConstraint(item: textlabel, attribute: .Bottom, relatedBy: .Equal,
                                                       toItem: containerView, attribute: .Bottom, multiplier: 1, constant: 0)

        let buttonRightConstraint = NSLayoutConstraint(item: actionButton, attribute: .Right, relatedBy: .Equal,
                                                      toItem: containerView, attribute: .Right, multiplier: 1, constant: 0)

        let labelLeftConstraint = NSLayoutConstraint(item: textlabel, attribute: .Left, relatedBy: .Equal,
                                                    toItem: containerView, attribute: .Left, multiplier: 1, constant: 0)


        containerView.addConstraints([buttonCenterY, labelToButtonTrailing, labelTopConstraint, labelBottomConstraint,
            buttonRightConstraint, labelLeftConstraint])


        // button view
        let buttonWidth: CGFloat = action != nil ? BubbleNotification.buttonMaxWidth : 0

        let buttonWidthConstraint = NSLayoutConstraint(item: actionButton, attribute: .Width, relatedBy: .LessThanOrEqual,
                                                       toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                       constant: buttonWidth)
        let buttonHeightConstraint = NSLayoutConstraint(item: actionButton, attribute: .Height, relatedBy: .Equal,
                                                        toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                        constant: BubbleNotification.buttonHeight)
        actionButton.addConstraints([buttonWidthConstraint, buttonHeightConstraint])
    }
}
