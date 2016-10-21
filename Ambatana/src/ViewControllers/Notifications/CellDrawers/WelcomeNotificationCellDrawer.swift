//
//  WelcomeNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 06/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class WelcomeNotificationCellDrawer: BaseNotificationCellDrawer<WelcomeNotificationCell> {

    override func draw(cell: WelcomeNotificationCell, data: NotificationData) {
        cell.titleLabel.text = data.title
        cell.subtitleLabel.text = data.subtitle
        cell.actionButton.setTitle(data.primaryActionText, forState: .Normal)
    }
}
