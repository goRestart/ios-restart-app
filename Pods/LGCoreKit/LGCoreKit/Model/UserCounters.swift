//
//  UserCounters.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol UserCounters {
    var unreadMessages: Int { get }
    var unreadNotifications: Int { get }
}
