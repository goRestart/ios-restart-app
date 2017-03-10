//
//  NotificationImageModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 07/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol NotificationImageModule {
    var shape: NotificationImageShape? { get }
    var imageURL: String { get }
    var deeplink: String? { get }
}
