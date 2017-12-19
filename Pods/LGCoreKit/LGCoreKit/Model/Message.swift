//
//  Message.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public enum MessageType: Int {
    case text = 0
    case offer = 1
    case sticker = 2
}

public enum MessageWarningStatus: Int {
    case normal
    case suspicious
}

public protocol Message: BaseModel {
    var text: String { get }
    var type: MessageType { get }
    var userId: String { get }
    var createdAt: Date? { get }
    var isRead: Bool { get }
    var warningStatus: MessageWarningStatus { get }
}
