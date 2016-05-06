//
//  WelcomeNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 06/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class WelcomeNotificationCellDrawer: BaseTableCellDrawer<WelcomeNotificationCell>, NotificationCellDrawer {

    func cellHeight(data: NotificationData) -> CGFloat {
        return WelcomeNotificationCell.cellHeight
    }

    func draw(tableViewCell: UITableViewCell, data: NotificationData) {
        guard let cell = tableViewCell as? NotificationCell else { return }

        cell.titleLabel.font = StyleHelper.notificationTitleFont
        cell.actionLabel.font = StyleHelper.notificationSubtitleFont

        cell.titleLabel.text = data.title
        cell.actionLabel.text = data.subtitle

        cell.timeLabel.text = ""
    }
}
