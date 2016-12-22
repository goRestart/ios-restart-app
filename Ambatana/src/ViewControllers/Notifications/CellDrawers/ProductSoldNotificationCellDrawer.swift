//
//  ProductSoldNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductSoldNotificationCellDrawer: BaseNotificationCellDrawer<NotificationCell> {
    
    override func draw(cell: NotificationCell, data: NotificationData) {
        switch data.type {
        case let .ProductSold(product, _):
            cell.actionLabel.text = LGLocalizedString.notificationsTypeSold
            cell.iconImage.image = UIImage(named: "ic_dollar_sold")
            let placeholder = UIImage(named: "product_placeholder")
            if let urlStr = product.image, imageUrl = NSURL(string: urlStr) {
                cell.primaryImage.lg_setImageWithURL(imageUrl, placeholderImage: placeholder)
            } else {
                cell.primaryImage.image = placeholder
            }
            cell.timeLabel.text = data.date.relativeTimeString(true)
            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeSoldButton, forState: .Normal)
        default:
            return
        }
    }
}
