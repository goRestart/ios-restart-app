//
//  FacebookFrienshipNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 17/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

class FacebookFriendshipNotificationCellDrawer: BaseNotificationCellDrawer<NotificationCell> {

    override func draw(_ cell: NotificationCell, data: NotificationData) {
        switch data.type {
        case let .facebookFriendshipCreated(user, facebookUsername):
            let userName = user.name ?? ""
            cell.actionLabel.text = LGLocalizedString.notificationsTypeFacebookFriend(facebookUsername, userName)
            cell.iconImage.image = UIImage(named: "ic_fire") //TODO CHANGE BY FACEBOOK ICON
            let placeholder = LetgoAvatar.avatarWithID(user.id, name: userName)
            if let urlStr = user.avatar, let imageUrl = URL(string: urlStr) {
                cell.primaryImage.lg_setImageWithURL(imageUrl, placeholderImage: placeholder)
            } else {
                cell.primaryImage.image = placeholder
            }
            cell.timeLabel.text = data.date.relativeTimeString(true)
            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeFacebookFriendButton, for: .normal)
        default:
            return
        }
    }
}
