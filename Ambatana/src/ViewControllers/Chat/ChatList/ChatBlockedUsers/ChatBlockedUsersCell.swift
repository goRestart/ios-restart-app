//
//  ChatBlockedUsersCell.swift
//  LetGo
//
//  Created by Dídac on 11/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

final class ChatBlockedUserCell: UITableViewCell, ReusableCell {

    static let defaultHeight: CGFloat = 60

    struct Layout {
        static let avatarHeight: CGFloat = 40
    }

    private let avatarImageView: UIImageView = UIImageView()
    private let userNameLabel: UILabel = UILabel()

    var lines: [CALayer] = []

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected && !isEditing) {
            setSelected(false, animated: animated)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(contentView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }

    func setupCellWithUser(_ user: User, indexPath: IndexPath) {
        let tag = (indexPath as NSIndexPath).hash
        userNameLabel.text = user.name

        let placeholder = LetgoAvatar.avatarWithID(user.objectId, name: user.name)
        avatarImageView.image = placeholder
        if let avatarURL = user.avatar?.fileURL {
            avatarImageView.lg_setImageWithURL(avatarURL, placeholderImage: placeholder) {
                [weak self] (result, url) in
                if let image = result.value?.image, self?.tag == tag {
                    self?.avatarImageView.image = image
                }
            }
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        userNameLabel.font = UIFont.bigBodyFontLight
        userNameLabel.textColor = UIColor.blackText
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Layout.avatarHeight / 2
    }

    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([avatarImageView, userNameLabel])

        let cellConstraints = [
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: userNameLabel.leadingAnchor, constant: -Metrics.bigMargin),
            userNameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: Metrics.margin),
            userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(cellConstraints)
        
        avatarImageView.layout().height(Layout.avatarHeight).widthProportionalToHeight()
    }

    private func resetUI() {
        avatarImageView.image = UIImage(named: "user_placeholder")
        userNameLabel.text = ""
    }
}

extension ChatBlockedUserCell {
    func setAccessibilityIds() {
        avatarImageView.set(accessibilityId: .blockedUserCellAvatarImageView)
        userNameLabel.set(accessibilityId: .blockedUserCellUserNameLabel)
    }
}
