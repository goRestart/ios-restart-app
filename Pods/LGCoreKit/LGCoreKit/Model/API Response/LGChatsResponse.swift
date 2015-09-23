//
//  LGChatsResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

@objc public class LGChatsResponse : ChatsResponse, ResponseObjectSerializable {

    public var chats: [Chat]
    
    // MARK: - Lifecycle
    
    public init() {
        chats = []
    }
    
    // MARK: - ResponseObjectSerializable
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let countryCurrencyInfoDao = RLMCountryCurrencyInfoDAO()
        let currencyHelper = CurrencyHelper(countryCurrencyInfoDAO: countryCurrencyInfoDao)

        // since the response gives distance in the units passed per parameters,
        // we retrieve distance type the same way we do in productlistviewmodel
        var distanceType = DistanceType.Km
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
        
        let json = JSON(representation)
        if let chatsJSON = json.array {
            var parsedChats: [Chat] = []
            for chatJSON in chatsJSON {
                let parsedChat = LGChatParser.chatWithJSON(chatJSON, currencyHelper: currencyHelper, distanceType: distanceType)
                parsedChats.append(parsedChat)
            }
            chats = parsedChats
        }
        else {
            return nil
        }
    }
    
}
