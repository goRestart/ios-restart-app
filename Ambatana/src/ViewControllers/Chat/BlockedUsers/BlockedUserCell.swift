//
//  BlockedUserCell.swift
//  LetGo
//
//  Created by Dídac on 10/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit
import SDWebImage

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
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected && !editing) {
            setSelected(false, animated: animated)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(contentView.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }

    func setupCellWithUser(user: User, indexPath: NSIndexPath) {
        let tag = indexPath.hash
        userNameLabel.text = user.name
        
        let placeholder = LetgoAvatar.avatarWithID(user.objectId, name: user.name)
        avatarImageView.image = placeholder
        if let avatarURL = user.avatar?.fileURL {
            avatarImageView.sd_setImageWithURL(avatarURL, placeholderImage: placeholder) {
                [weak self] (image, error, cacheType, url)  in
                if error == nil && self?.tag == tag {
                    self?.avatarImageView.image = image
                }
            }
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        avatarImageView.layer.cornerRadius = avatarImageView.width/2
        avatarImageView.clipsToBounds = true
        userNameLabel.font = StyleHelper.conversationUserNameFont
        blockedLabel.font = StyleHelper.conversationBlockedFont

        userNameLabel.textColor = StyleHelper.conversationUserNameColor
        blockedLabel.textColor = StyleHelper.conversationBlockedColor
        blockedLabel.hidden = true
        blockedIcon.hidden = true
    }

    private func resetUI() {
        avatarImageView.image = UIImage(named: "no_photo")
        userNameLabel.text = ""
        blockedLabel.text = LGLocalizedString.chatListBlockedUserLabel
    }

    override func setEditing(editing: Bool, animated: Bool) {
        if (editing) {
            let bgView = UIView()
            selectedBackgroundView = bgView
        } else {
            selectedBackgroundView = nil
        }
        super.setEditing(editing, animated: animated)
        tintColor = StyleHelper.primaryColor
    }
}
