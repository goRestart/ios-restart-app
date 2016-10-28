//
//  ProductSoldNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class RatingNotificationCellDrawer: BaseNotificationCellDrawer<NotificationCell> {
    
    override func draw(cell: NotificationCell, data: NotificationData) {
        cell.actionLabel.text = data.subtitle
        cell.iconImage.image = data.icon
        if let urlStr = data.letfImage, leftUrl = NSURL(string: urlStr) {
            cell.primaryImage.lg_setImageWithURL(leftUrl, placeholderImage: data.leftImagePlaceholder)
        } else {
            cell.primaryImage.image = data.leftImagePlaceholder
        }
        cell.primaryImageAction = data.leftImageAction
        cell.timeLabel.text = data.date.relativeTimeString(true)
        cell.actionButton.setTitle(data.primaryActionText, forState: .Normal)
    }
}
