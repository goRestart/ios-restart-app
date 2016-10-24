//
//  InterestedBubble.swift
//  LetGo
//
//  Created by Dídac on 23/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


class InterestedBubble: UIView {

    static let iconSize: CGFloat = 24
    static let bubbleContentMargin: CGFloat = 14

    private var containerView: UIView = UIView()
    private var iconImageView: UIImageView = UIImageView()
    private var textlabel: UILabel = UILabel()

    private var text: String?

    // - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func updateInfo(text: String?) {
        textlabel.text = text
    }

    // - Private Methods

    private func setupUI() {
        backgroundColor = UIColor.white
        textlabel.numberOfLines = 0
        textlabel.textColor = UIColor.redText
        textlabel.font = UIFont.mediumBodyFont
        textlabel.text = text
        iconImageView.image = UIImage(named: "ic_user_interested_red")
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
                                                        constant: BubbleNotification.bubbleContentMargin)
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

        containerView.addSubview(textlabel)
        containerView.addSubview(iconImageView)

        let iconWidthConstraint = NSLayoutConstraint(item: iconImageView, attribute: .Width, relatedBy: .Equal,
                                                     toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                     constant: InterestedBubble.iconSize)
        let iconHeightConstraint = NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal,
                                                      toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                      constant: InterestedBubble.iconSize)
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
