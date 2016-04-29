//
//  ProductSoldNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductNotificationCellDrawer: BaseTableCellDrawer<NotificationCell>, NotificationCellDrawer {

    func cellHeight() -> CGFloat {
        return 74
    }

    func draw(tableViewCell: UITableViewCell, data: NotificationData) {
        guard let cell = tableViewCell as? NotificationCell else { return }

        cell.titleLabel.text = data.title
        cell.actionLabel.text = data.subtitle
        cell.iconImage.image = data.icon
        if let urlStr = data.letfImage, leftUrl = NSURL(string: urlStr) {
            cell.primaryImage.lg_setImageWithURL(leftUrl)
        } else {
            cell.primaryImage.image = nil
        }
        if let urlStr = data.rightImage, rightUrl = NSURL(string: urlStr) {
            cell.secondaryImage.lg_setImageWithURL(rightUrl)
        } else {
            cell.secondaryImage.image = nil
        }

        cell.primaryImageAction = data.leftImageAction
        cell.secondaryImageAction = data.rightImageAction

        //TODO: DATE
    }
}
