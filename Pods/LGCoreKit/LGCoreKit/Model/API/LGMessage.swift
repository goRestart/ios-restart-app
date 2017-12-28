//
//  LGMessage.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGMessage: Message {

    // Global iVars
    public var objectId: String?
    public var createdAt: Date?

    // Message iVars
    public var text: String
    public var type: MessageType
    public var userId: String
    public var warningStatus: MessageWarningStatus
    public var isRead: Bool
    
    init(objectId: Int?, createdAt: Date?, text: String, type: Int?, userId: String, status: Int?, isRead: Bool?){
        if let intId = objectId {
            self.objectId = String(intId)
        }
        self.createdAt = createdAt
        self.text = text

        if let intType = type {
            self.type = MessageType(rawValue: intType) ?? .text
        } else {
            self.type = .text
        }
        self.userId = userId

        let intStatus = status ?? 0
        self.warningStatus = MessageWarningStatus(rawValue: intStatus) ?? .normal
        self.isRead = isRead ?? false
    }
}

extension LGMessage {
    public init() {
        self.type = .text
        self.text = ""
        self.userId = ""
        self.warningStatus = .normal
        self.isRead = false
    }
}

extension LGMessage : Decodable {

    /**
    Expects a json in the form:

        {
            "id": 3,
            "text": "hola que ase 3",
            "type": 0,
            "created_at": "2015-09-11T09:03:02+0000",
            "user_id": "cnF522ALeS"
            "is_read": 0
        }
    */
    public static func decode(_ j: JSON) -> Decoded<LGMessage> {
        let result1 = curry(LGMessage.init)
        let result2 = result1 <^> j <|? "id"
        let result3 = result2 <*> j <|? "created_at"
        let result4 = result3 <*> j <| "text"
        let result5 = result4 <*> j <|? "type"
        let result6 = result5 <*> j <| "user_id"
        let result7 = result6 <*> j <|? "status"
        let result  = result7 <*> j <|? "is_read"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGMessage parse error: \(error)")
        }
        return result
    }
}