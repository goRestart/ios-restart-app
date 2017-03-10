//
//  NotificationModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 24/02/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


public protocol NotificationModular {
    
    var text: NotificationTextModule { get }
    var callToActions: [NotificationCTAModule] { get }
    var basicImage: NotificationImageModule? { get }
    var iconImage: NotificationImageModule? { get }
    var heroImage: NotificationImageModule? { get }
    var thumbnails: [NotificationImageModule]? { get }
}
