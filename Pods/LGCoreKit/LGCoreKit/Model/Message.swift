//
//  Message.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public enum MessageType: Int {
    case Text = 0
    case Offer = 1
    case Sticker = 2
}

public enum MessageWarningStatus: Int {
    case Normal
    case Suspicious
}

public protocol Message: BaseModel {
    var text: String { get }
    var type: MessageType { get }
    var userId: String { get }
    var createdAt: NSDate? { get }
    var isRead: Bool { get }
    var warningStatus: MessageWarningStatus { get }
}
