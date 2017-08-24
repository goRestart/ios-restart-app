//
//  ListingSoldNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ListingSoldNotificationCellDrawer: BaseNotificationCellDrawer<NotificationCell> {
    
    override func draw(_ cell: NotificationCell, data: NotificationData) {
        switch data.type {
        case let .listingSold(listingImage):
            cell.actionLabel.text = LGLocalizedString.notificationsTypeSold
            cell.actionLabel.font = UIFont.notificationSubtitleFont(read: data.isRead)
            cell.iconImage.image = UIImage(named: "ic_dollar_sold")
            let placeholder = UIImage(named: "product_placeholder")
            if let urlStr = listingImage, let imageUrl = URL(string: urlStr) {
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
