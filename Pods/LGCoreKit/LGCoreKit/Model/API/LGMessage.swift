//
//  LGMessage.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

public struct LGMessage: Message {

    // Global iVars
    public var objectId: String?
    public var createdAt: NSDate?

    // Message iVars
    public var text: String
    public var type: MessageType
    public var userId: String
    public var status: MessageStatus?

    init(objectId: Int?, createdAt: NSDate?, text: String, type: Int?, userId: String, status: Int?){
        if let intId = objectId {
            self.objectId = String(intId)
        }
        self.createdAt = createdAt
        self.text = text

        if let intType = type {
            self.type = MessageType(rawValue: intType) ?? .Text
        } else{
            self.type = .Text
        }
        self.userId = userId

        if let intStatus = status {
            self.status = MessageStatus(rawValue: intStatus)
        }

    }
}

extension LGMessage {
    public init() {
        self.type = .Text
        self.text = ""
        self.userId = ""
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
    public static func decode(j: JSON) -> Decoded<LGMessage> {

        let init1 = curry(LGMessage.init)
            <^> j <|? "id"
            <*> LGArgo.parseDate(json: j, key: "created_at")
            <*> j <| "text"
            <*> j <|? "type"
            <*> j <| "user_id"

        let result = init1  <*> j <|? "is_read"

        if let error = result.error {
            print("LGMessage parse error: \(error)")
        }

        return result
    }
}
