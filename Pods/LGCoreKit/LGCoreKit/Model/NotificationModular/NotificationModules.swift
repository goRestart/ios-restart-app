//
//  TextNotificationModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/02/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


public enum ImageShape: String {
    case square = "square"
    case circle = "circle"
}

public protocol NotificationTextModule {
    var title: String? { get }
    var body: String { get }
    var deeplink: String? { get }
}

public protocol NotificationCTAModule {
    var title: String { get }
    var deeplink: String { get }
}

public protocol NotificationImageModule {
    var shape: ImageShape? { get }
    var imageURL: String { get }
    var deeplink: String? { get }
}
