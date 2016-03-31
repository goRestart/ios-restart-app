//
//  ChatMessage.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum ChatMessageType: String {
    case Text = "text"
    case Offer = "offer"
}

public protocol ChatMessage: BaseModel {
    var talkerId: String { get }
    var text: String { get }
    var sentAt: NSDate? { get }
    var receivedAt: NSDate? { get }
    var readAt: NSDate? { get }
    var type: ChatMessageType { get }
}
