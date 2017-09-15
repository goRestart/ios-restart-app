//
//  NotificationModel.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 13/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol NotificationModel: BaseModel {
    var createdAt: Date { get }
    var isRead: Bool { get }
    var campaignType: String? { get }
    var modules: NotificationModular { get }
}
