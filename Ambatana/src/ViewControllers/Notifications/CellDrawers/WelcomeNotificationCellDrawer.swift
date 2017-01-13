//
//  WelcomeNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 06/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class WelcomeNotificationCellDrawer: BaseNotificationCellDrawer<WelcomeNotificationCell> {

    override func draw(_ cell: WelcomeNotificationCell, data: NotificationData) {
        switch data.type {
        case let .welcome(city):
            cell.titleLabel.text = LGLocalizedString.notificationsTypeWelcomeTitle
            if let city = city, !city.isEmpty {
                cell.subtitleLabel.text = LGLocalizedString.notificationsTypeWelcomeSubtitleWCity(city)
            } else {
                cell.subtitleLabel.text = LGLocalizedString.notificationsTypeWelcomeSubtitle
            }
            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeWelcomeButton, for: .normal)
        default:
            return
        }
    }
}
