//
//  Installation.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public protocol Installation: BaseModel {
    var badge: Int { get set }
    var userId: String? { get set }
    var username: String? { get set }
    var channels: [AnyObject]? { get set }
    func setDeviceTokenFromData(deviceTokenData: NSData?)
}
