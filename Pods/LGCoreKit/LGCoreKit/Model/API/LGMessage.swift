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

    init(objectId: Int?, createdAt: NSDate?, text: String, type: Int?, userId: String){
        if let intId = objectId {
            self.objectId = String(intId)
        }
        self.createdAt = createdAt
        self.text = text
        if let intType = type {
            self.type = MessageType(rawValue: intType) ?? .Text
        }
        else{
            self.type = .Text
        }
        self.userId = userId
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
        }
    */
    public static func decode(j: JSON) -> Decoded<LGMessage> {
        
        let result = curry(LGMessage.init)
            <^> j <|? "id"
            <*> LGArgo.parseDate(json: j, key: "created_at")
            <*> j <| "text"
            <*> j <|? "type"
            <*> j <| "user_id"
        
        if let error = result.error {
            print("LGMessage parse error: \(error)")
        }
        
        return result
    }
}