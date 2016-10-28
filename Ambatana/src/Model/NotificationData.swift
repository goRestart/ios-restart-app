//
//  NotificationData.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum NotificationDataType {
    case Welcome, ProductFavorite, ProductSold, Rating, RatingUpdated
}

struct NotificationData {
    let type: NotificationDataType
    let title: String
    let subtitle: String
    let date: NSDate
    let primaryAction: (() -> Void)
    let primaryActionText: String

    let letfImage: String?
    let leftImagePlaceholder: UIImage?
    let leftImageAction: (() -> Void)?
    let icon: UIImage?
    let isRead: Bool

    init(type: NotificationDataType, title: String, subtitle: String, date: NSDate, isRead: Bool,
         primaryAction: (() -> Void), primaryActionText: String, icon: UIImage? = nil, leftImage: String? = nil,
         leftImagePlaceholder: UIImage? = nil, leftImageAction: (() -> Void)? = nil) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.isRead = isRead
        self.icon = icon
        self.primaryAction = primaryAction
        self.primaryActionText = primaryActionText
        self.leftImagePlaceholder = leftImagePlaceholder
        self.letfImage = leftImage
        self.leftImageAction = leftImageAction
    }
}
