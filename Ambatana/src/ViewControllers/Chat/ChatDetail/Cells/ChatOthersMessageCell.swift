//
//  ChatOthersMessageCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 19/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import LGComponents

class ChatOthersMessageCell: ChatBubbleCell, ReusableCell {

    let bubbleView: UIView = {
        let view = UIView()
        view.cornerRadius = LGUIKitConstants.mediumCornerRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.backgroundColor = .chatOthersBubbleBgColor
        return view
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bigBodyFont
        label.textColor = UIColor.blackText
        label.numberOfLines = 0
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.smallBodyFontLight
        label.textColor = UIColor.darkGrayText
        return label
    }()

    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = ChatBubbleLayout.avatarSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        imageView.isHidden = true
        return imageView
    }()

    var bubbleBottomMargin: NSLayoutConstraint?
    var bubbleLeftMargin: NSLayoutConstraint?
    let type: ChatBubbleCellType = .othersMessage

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for position: ChatBubbleCellPosition) {
        configure(for: position, type: .othersMessage)
        // FIXME: activate when the user image is included in the data
        // avatarImageView.isHidden = !position.showOtherUserAvatar
        // Change bubbleLeftMargin to leave room for the avatar
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleView.backgroundColor = selected ? UIColor.chatOthersBubbleBgColorSelected : UIColor.chatOthersBubbleBgColor
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([bubbleView, messageLabel, dateLabel, avatarImageView])
        setupConstraints()
        backgroundColor = .clear
    }

    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            avatarImageView.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -ChatBubbleLayout.minBubbleMargin),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: ChatBubbleLayout.margin),
            messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.veryBigMargin),
            dateLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            dateLabel.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.dateHeight),
            dateLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: ChatBubbleLayout.bigMargin),
            dateLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -ChatBubbleLayout.margin),
            dateLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -ChatBubbleLayout.margin),
        ]

        let bubbleBottom = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.veryShortMargin)
        let bubbleLeft = bubbleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin)

        bubbleBottomMargin = bubbleBottom
        bubbleLeftMargin = bubbleLeft

        constraints.append(contentsOf: [bubbleBottom, bubbleLeft])
        NSLayoutConstraint.activate(constraints)
    }

    private func setAccessibilityIds() {
        setDefaultAccessibilityIds()
        set(accessibilityId: .chatCellContainer(type: .othersMessage))
    }
}
