//
//  WelcomeNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 06/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class WelcomeNotificationCellDrawer: BaseTableCellDrawer<WelcomeNotificationCell>, NotificationCellDrawer {

    func draw(tableViewCell: UITableViewCell, data: NotificationData) {
        guard let cell = tableViewCell as? WelcomeNotificationCell else { return }

        cell.titleLabel.text = data.title
        cell.subtitleLabel.text = data.subtitle
    }
}
