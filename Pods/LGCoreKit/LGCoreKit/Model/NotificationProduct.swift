//
//  NotificationProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol NotificationProduct {
    var id: String { get }
    var title: String? { get }
    var image: String? { get }
}
