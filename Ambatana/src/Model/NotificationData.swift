//
//  NotificationData.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum NotificationDataType {
    case Welcome(title: String, subtitle: String)
    case ProductSold(title: String, action: String)
    case ProductLike(title: String, action: String)
}

struct NotificationData {
    let type: NotificationDataType
    let date: NSDate
    let primaryAction: (()->Void)?
    let leftImageAction: UIAction?
    let rightImageAction: UIAction?
    let icon: UIImage?
}
