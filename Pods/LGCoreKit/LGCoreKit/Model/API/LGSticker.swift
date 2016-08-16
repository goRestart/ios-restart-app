//
//  LGSticker.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGSticker: Sticker {
    let url: String
    let name: String
    let type: StickerType

    init(url: String, name: String, type: StickerType?) {
        self.url = url
        self.name = name
        self.type = type ?? .Chat
    }
}

extension LGSticker : Decodable {
    
    /**
     Expects a json in the form:
     {
     "url": "https://stickers.letgo.com/en/love_it.png",
     "name": ":love_it:"
     }
     */
    static func decode(j: JSON) -> Decoded<LGSticker> {
        let result = curry(LGSticker.init)
            <^> j <| "url"
            <*> j <| "name"
            <*> j <|? "type"
        
        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGSticker parse error: \(error)")
        }
        
        return result
    }
}

extension LGSticker: UserDefaultsDecodable {
    static func decode(dictionary: [String: AnyObject]) -> LGSticker? {
        guard let url = dictionary["url"] as? String, name = dictionary["name"] as? String else { return nil }
        var type = StickerType.Chat
        if let typeString = dictionary["type"] as? String, stType = StickerType(rawValue: typeString) {
            type = stType
        }
        return LGSticker(url: url, name: name, type: type)
    }
    
    func encode() -> [String: AnyObject] {
        return ["url": url, "name": name, "type": type.rawValue]
    }
}
