//
//  NotificationData.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum NotificationDataType {
    case News(title: String, subtitle: String)
    case ProductSold(title: String, action: String)
    case ProductLike(title: String, action: String)
}

struct NotificationData {
    let type: NotificationDataType
    let date: NSDate
    let primaryAction: (()->Void)
    let letfImage: String?
    let leftImageAction: (()->Void)?
    let rightImage: String?
    let rightImageAction: (()->Void)?
    let icon: UIImage?
    let isRead: Bool

    init(type: NotificationDataType, date: NSDate, isRead: Bool, primaryAction: (()->Void), icon: UIImage? = nil,
         leftImage: String? = nil, leftImageAction: (()->Void)? = nil, rightImage: String? = nil,
         rightImageAction: (()->Void)? = nil) {
        self.type = type
        self.date = date
        self.isRead = isRead
        self.icon = icon
        self.primaryAction = primaryAction
        self.letfImage = leftImage
        self.leftImageAction = leftImageAction
        self.rightImage = rightImage
        self.rightImageAction = rightImageAction
    }
}
