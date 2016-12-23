//
//  BuyersInterestedNotificationCellDrawer.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class BuyersInterestedNotificationCellDrawer: BaseNotificationCellDrawer<BuyersInterestedNotificationCell> {

    override func draw(cell: NotificationCell, data: NotificationData) {

        switch data.type {
        case let .BuyersInterested(product, buyers):
            break
//            if let productTitle = product.title where !productTitle.isEmpty {
//                cell.actionLabel.text = LGLocalizedString.notificationsTypeLikeWNameWTitle(userName ?? "", productTitle)
//            } else {
//                cell.actionLabel.text = LGLocalizedString.notificationsTypeLikeWName(userName ?? "")
//            }
//            cell.iconImage.image = UIImage(named: "ic_favorite")
//            let placeholder = LetgoAvatar.avatarWithID(userId, name: userName)
//            if let urlStr = userImage, imageUrl = NSURL(string: urlStr) {
//                cell.primaryImage.lg_setImageWithURL(imageUrl, placeholderImage: placeholder)
//            } else {
//                cell.primaryImage.image = placeholder
//            }
//            cell.timeLabel.text = data.date.relativeTimeString(true)
//            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeLikeButton, forState: .Normal)
        default:
            return
        }
    }
}
