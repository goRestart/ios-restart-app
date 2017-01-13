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


    func updateInfo(_ text: String?) {
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
        let centerXConstraint = NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal,
                                                   toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let containerTopConstraint = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal,
                                                        toItem: self, attribute: .top, multiplier: 1,
                                                        constant: BubbleNotification.bubbleContentMargin)
        let containerBottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal,
                                                           toItem: self, attribute: .bottom, multiplier: 1,
                                                           constant: -BubbleNotification.bubbleContentMargin)

        let containerLeftConstraint = NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .greaterThanOrEqual,
                                                         toItem: self, attribute: .left, multiplier: 1,
                                                         constant: BubbleNotification.bubbleContentMargin)
        let containerRightConstraint = NSLayoutConstraint(item: containerView, attribute: .right, relatedBy: .lessThanOrEqual,
                                                          toItem: self, attribute: .right, multiplier: 1,
                                                          constant: -BubbleNotification.bubbleContentMargin)

        addConstraints([centerXConstraint, containerTopConstraint, containerBottomConstraint, containerLeftConstraint,
            containerRightConstraint])

        containerView.addSubview(textlabel)
        containerView.addSubview(iconImageView)

        let iconWidthConstraint = NSLayoutConstraint(item: iconImageView, attribute: .width, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1,
                                                     constant: InterestedBubble.iconSize)
        let iconHeightConstraint = NSLayoutConstraint(item: iconImageView, attribute: .height, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1,
                                                      constant: InterestedBubble.iconSize)
        iconImageView.addConstraints([iconWidthConstraint, iconHeightConstraint])

        // text label
        let iconCenterY = NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal,
                                             toItem: containerView, attribute: .centerY, multiplier: 1, constant: 0)

        let iconToLabelTrailing = NSLayoutConstraint(item: iconImageView, attribute: .right, relatedBy: .equal,
                                                     toItem: textlabel, attribute: .left, multiplier: 1, constant: -10)

        let labelTopConstraint = NSLayoutConstraint(item: textlabel, attribute: .top, relatedBy: .equal,
                                                    toItem: containerView, attribute: .top, multiplier: 1, constant: 0)
        let labelBottomConstraint = NSLayoutConstraint(item: textlabel, attribute: .bottom, relatedBy: .equal,
                                                       toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)

        let labelRightConstraint = NSLayoutConstraint(item: textlabel, attribute: .right, relatedBy: .equal,
                                                      toItem: containerView, attribute: .right, multiplier: 1, constant: 0)

        let iconLeftConstraint = NSLayoutConstraint(item: iconImageView, attribute: .left, relatedBy: .equal,
                                                    toItem: containerView, attribute: .left, multiplier: 1, constant: 0)

        containerView.addConstraints([iconCenterY, iconToLabelTrailing, labelTopConstraint, labelBottomConstraint,
            labelRightConstraint, iconLeftConstraint])
    }
}
