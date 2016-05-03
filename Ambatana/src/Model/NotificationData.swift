//
//  NotificationData.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

struct NotificationData {
    let title: String
    let subtitle: String
    let date: NSDate
    let primaryAction: (()->Void)
    let letfImage: String?
    let leftImagePlaceholder: UIImage?
    let leftImageAction: (()->Void)?
    let rightImage: String?
    let rightImageAction: (()->Void)?
    let icon: UIImage?
    let isRead: Bool

    init(title: String, subtitle: String, date: NSDate, isRead: Bool, primaryAction: (()->Void), icon: UIImage? = nil,
         leftImage: String? = nil, leftImagePlaceholder: UIImage? = nil, leftImageAction: (()->Void)? = nil,
         rightImage: String? = nil, rightImageAction: (()->Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.isRead = isRead
        self.icon = icon
        self.primaryAction = primaryAction
        self.leftImagePlaceholder = leftImagePlaceholder
        self.letfImage = leftImage
        self.leftImageAction = leftImageAction
        self.rightImage = rightImage
        self.rightImageAction = rightImageAction
    }
}
