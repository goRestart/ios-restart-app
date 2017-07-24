//
//  LGSticker.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGSticker: Sticker {
    let url: String
    let name: String
    let type: StickerType

    init(url: String, name: String, type: StickerType?) {
        self.url = url
        self.name = name
        self.type = type ?? .chat
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
    static func decode(_ j: JSON) -> Decoded<LGSticker> {
        let result1 = curry(LGSticker.init)
        let result2 = result1 <^> j <| "url"
        let result3 = result2 <*> j <| "name"
        let result  = result3 <*> j <|? "type"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGSticker parse error: \(error)")
        }        
        return result
    }
}

extension LGSticker: UserDefaultsDecodable {
    static func decode(_ dictionary: [String: Any]) -> LGSticker? {
        guard let url = dictionary["url"] as? String, let name = dictionary["name"] as? String else { return nil }
        var type = StickerType.chat
        if let typeString = dictionary["type"] as? String, let stType = StickerType(rawValue: typeString) {
            type = stType
        }
        return LGSticker(url: url, name: name, type: type)
    }
    
    func encode() -> [String: Any] {
        return ["url": url, "name": name, "type": type.rawValue]
    }
}
