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
    var url: String
    var name: String
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
        
        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGSticker parse error: \(error)")
        }
        
        return result
    }
}

extension LGSticker: UserDefaultsDecodable {
    static func decode(dictionary: [String: AnyObject]) -> LGSticker? {
        guard let url = dictionary["url"] as? String, let name = dictionary["name"] as? String else { return nil }
        return LGSticker(url: url, name: name)
    }
    
    func encode() -> [String: AnyObject] {
        return ["url": url, "name": name]
    }
}
