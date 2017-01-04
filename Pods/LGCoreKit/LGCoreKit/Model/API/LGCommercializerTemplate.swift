//
//  LGCommercializerTemplate.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGCommercializerTemplate: CommercializerTemplate {
    
    // Global iVars
    var objectId: String?
    
    // Commercializer iVars
    var thumbURL: String?
    var title: String?
    var duration: Int?
    var countryCode: String?
    var videoM3u8URL: String?
    var videoHighURL: String?
    var videoLowURL: String?
}

extension LGCommercializerTemplate : Decodable {

    static func decode(_ j: JSON) -> Decoded<LGCommercializerTemplate> {
        
        let init1 = curry(LGCommercializerTemplate.init)
                            <^> j <|? "template_id"
                            <*> j <|? "thumb_url"
                            <*> j <|? "title"
                            <*> j <|? "duration"
                            <*> j <|? "country_code"
        let result = init1  <*> j <|? "video_m3u8_url"
                            <*> j <|? "video_high_url"
                            <*> j <|? "video_low_url"

        
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "LGCommercializer parse error: \(error)")
        }
        
        return result
    }
}
