//
//  BlockedUserCell.swift
//  LetGo
//
//  Created by Dídac on 10/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

class BlockedUserCell: UITableViewCell {

    static let defaultHeight: CGFloat = 76

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var blockedIcon: UIImageView!

    var lines: [CALayer] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        resetUI()
        setAccessibilityIds()
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
        avatarImageView.layer.cornerRadius = avatarImageView.width/2
        avatarImageView.clipsToBounds = true
        userNameLabel.font = UIFont.bigBodyFontLight
        blockedLabel.font = UIFont.smallBodyFontLight

        userNameLabel.textColor = UIColor.blackText
        blockedLabel.textColor = UIColor.blackText
        blockedLabel.isHidden = true
        blockedIcon.isHidden = true
    }

    private func resetUI() {
        avatarImageView.image = UIImage(named: "user_placeholder")
        userNameLabel.text = ""
        blockedLabel.text = LGLocalizedString.chatListBlockedUserLabel
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if (editing) {
            let bgView = UIView()
            selectedBackgroundView = bgView
        } else {
            selectedBackgroundView = nil
        }
        super.setEditing(editing, animated: animated)
        tintColor = UIColor.primaryColor
    }
}

extension BlockedUserCell {
    func setAccessibilityIds() {
        avatarImageView.accessibilityId = AccessibilityId.blockedUserCellAvatarImageView
        userNameLabel.accessibilityId = AccessibilityId.blockedUserCellUserNameLabel
        blockedLabel.accessibilityId = AccessibilityId.blockedUserCellBlockedLabel
        blockedIcon.accessibilityId = AccessibilityId.blockedUserCellBlockedIcon
    }
}
