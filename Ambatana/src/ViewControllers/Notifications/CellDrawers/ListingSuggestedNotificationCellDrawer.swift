//
//  ListingSuggestedNotificationCellDrawer.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ListingSuggestedNotificationCellDrawer: BaseNotificationCellDrawer<NotificationCell> {

    override func draw(_ cell: NotificationCell, data: NotificationData) {

        switch data.type {
        case let .listingSuggested(listing, seller: seller):
            let userName = seller.name ?? ""
            if let listingTitle = listing.title, !listingTitle.isEmpty {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeProductSuggestedWTitle(userName, listingTitle)
            } else {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeProductSuggested(userName)
            }
            cell.actionLabel.font = UIFont.notificationSubtitleFont(read: data.isRead)
            cell.iconImage.image = UIImage(named: "ic_fire")
            let placeholder = LetgoAvatar.avatarWithID(seller.id, name: userName)
            if let urlStr = seller.avatar, let imageUrl = URL(string: urlStr) {
                cell.primaryImage.lg_setImageWithURL(imageUrl, placeholderImage: placeholder)
            } else {
                cell.primaryImage.image = placeholder
            }
            cell.timeLabel.text = data.date.relativeTimeString(true)
            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeProductSuggestedButton, for: .normal)
        default:
            return
        }
    }
}
