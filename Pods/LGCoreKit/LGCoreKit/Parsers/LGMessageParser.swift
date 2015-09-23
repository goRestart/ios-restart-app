//
//  LGMessageParser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public class LGMessageParser {
    
    // Constant
    // > JSON keys
    private static let objectIdJSONKey = "id"
    private static let createdAtJSONKey = "created_at"
    
    private static let textJSONKey = "text"
    private static let typeJSONKey = "type"
    private static let userIdJSONKey = "user_id"
    
    // MARK: - Public methods
    
    //[
    //    {
    //        "id": 3,
    //        "text": "hola que ase 3",
    //        "type": 0,
    //        "created_at": "2015-09-11T09:03:02+0000",
    //        "user_id": "cnF522ALeS"
    //    },
    //    ...
    //]
    public static func messageWithJSON(json: JSON) -> LGMessage {
        let message = LGMessage()
//        message.objectId = json[LGMessageParser.objectIdJSONKey].string  // @ahl: id ignored
        if let updatedAtStr = json[LGMessageParser.createdAtJSONKey].string, let date = LGDateFormatter.sharedInstance.dateFromString(updatedAtStr) {
            message.createdAt = date
        }
        message.text = json[LGMessageParser.textJSONKey].string
        if let typeRawType = json[LGMessageParser.typeJSONKey].int, let type = MessageType(rawValue: typeRawType) {
            message.type = type
        }
        message.userId = json[LGMessageParser.userIdJSONKey].string
        return message
    }
}
