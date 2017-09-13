//
//  NotificationsCounts.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/10/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol UnreadNotificationsCounts {
    var modular: Int { get }
    var total: Int { get }
}
