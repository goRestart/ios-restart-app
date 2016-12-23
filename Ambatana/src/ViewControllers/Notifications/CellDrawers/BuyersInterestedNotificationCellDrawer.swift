//
//  BuyersInterestedNotificationCellDrawer.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class BuyersInterestedNotificationCellDrawer: BaseNotificationCellDrawer<BuyersInterestedNotificationCell> {

    override func draw(cell: BuyersInterestedNotificationCell, data: NotificationData) {
        switch data.type {
        case let .BuyersInterested(product, buyers):
            let buyersCount = buyers.count
            if let productTitle = product.title where !productTitle.isEmpty {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeBuyersInterestedWTitle(buyersCount, productTitle)
            } else {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeBuyersInterested(buyersCount)
            }
            cell.iconImage.image = UIImage(named: "ic_user")

            let placeholder = UIImage(named: "product_placeholder")
            if let urlStr = product.image, imageUrl = NSURL(string: urlStr) {
                cell.primaryImage.lg_setImageWithURL(imageUrl, placeholderImage: placeholder)
            } else {
                cell.primaryImage.image = placeholder
            }
            cell.timeLabel.text = data.date.relativeTimeString(true)
            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeLikeButton, forState: .Normal)
        default:
            return
        }
    }
}
