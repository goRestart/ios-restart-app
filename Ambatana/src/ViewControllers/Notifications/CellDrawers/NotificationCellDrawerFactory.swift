//
//  NotificationCellDrawerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class NotificationCellDrawerFactory {

    static let estimatedRowHeight: CGFloat = 80
    // Not updated to Listing as it is going to be remove: ABIOS-2662
    static func drawerForNotificationData(_ notification: NotificationData) -> NotificationCellDrawer {
        switch notification.type {
        case .listingFavorite:
            return ListingFavoriteNotificationCellDrawer()
        case .listingSold:
            return ListingSoldNotificationCellDrawer()
        case .rating, .ratingUpdated:
            return RatingNotificationCellDrawer()
        case .buyersInterested:
            return BuyersInterestedNotificationCellDrawer()
        case .listingSuggested:
            return ListingSuggestedNotificationCellDrawer()
        case .facebookFriendshipCreated:
            return FacebookFriendshipNotificationCellDrawer()
        case .modular:
            return ModularNotificationCellDrawer()
        }
    }

    static func registerCells(_ tableView: UITableView) {
        BaseNotificationCellDrawer<NotificationCell>.registerCell(tableView)
        BaseNotificationCellDrawer<BuyersInterestedNotificationCell>.registerCell(tableView)
        BaseNotificationCellDrawer<ModularNotificationCell>.registerClassCell(tableView)
    }
}
