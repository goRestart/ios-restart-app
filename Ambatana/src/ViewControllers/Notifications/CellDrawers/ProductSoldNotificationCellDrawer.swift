//
//  ProductSoldNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductSoldNotificationCellDrawer: BaseNotificationCellDrawer<NotificationCell> {
    
    override func draw(_ cell: NotificationCell, data: NotificationData) {
        switch data.type {
        case let .productSold(productImage):
            cell.actionLabel.text = LGLocalizedString.notificationsTypeSold
            cell.iconImage.image = UIImage(named: "ic_dollar_sold")
            let placeholder = UIImage(named: "product_placeholder")
            if let urlStr = productImage, let imageUrl = URL(string: urlStr) {
                cell.primaryImage.lg_setImageWithURL(imageUrl, placeholderImage: placeholder)
            } else {
                cell.primaryImage.image = placeholder
            }
            cell.timeLabel.text = data.date.relativeTimeString(true)
            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeSoldButton, for: .normal)
        default:
            return
        }
    }
}
