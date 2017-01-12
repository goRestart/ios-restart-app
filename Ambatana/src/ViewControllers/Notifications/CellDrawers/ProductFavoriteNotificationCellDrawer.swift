//
//  ProductSoldNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductFavoriteNotificationCellDrawer: BaseNotificationCellDrawer<NotificationCell> {
    
    override func draw(_ cell: NotificationCell, data: NotificationData) {

        switch data.type {
        case let .productFavorite(product, user):
            let userName = user.name
            if let productTitle = product.title, !productTitle.isEmpty {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeLikeWNameWTitle(userName ?? "", productTitle)
            } else {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeLikeWName(userName ?? "")
            }
            cell.iconImage.image = UIImage(named: "ic_favorite")
            let placeholder = LetgoAvatar.avatarWithID(user.id, name: userName)
            if let urlStr = user.avatar, let imageUrl = URL(string: urlStr) {
                cell.primaryImage.lg_setImageWithURL(imageUrl, placeholderImage: placeholder)
            } else {
                cell.primaryImage.image = placeholder
            }
            cell.timeLabel.text = data.date.relativeTimeString(true)
            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeLikeButton, for: .normal)
        default:
            return
        }
    }
}
