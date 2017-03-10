//
//  NotificationTextModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 07/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol NotificationTextModule {
    var title: String? { get }
    var body: String { get }
    var deeplink: String? { get }
}
