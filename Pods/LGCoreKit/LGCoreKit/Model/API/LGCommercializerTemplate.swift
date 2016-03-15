//
//  LGCommercializerTemplate.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGCommercializerTemplate: CommercializerTemplate {
    
    // Global iVars
    var objectId: String?
    
    // Commercializer iVars
    var videoURL: String?
    var thumbURL: String?
    var title: String?
    var duration: Int?
    var countryCode: String?
}

extension LGCommercializerTemplate : Decodable {
 
    static func newTemplate(objectId: String?, videoURL: String?, thumbURL: String?,
        title: String?, duration: Int?, countryCode: String?) -> LGCommercializerTemplate {
            return LGCommercializerTemplate(objectId: objectId, videoURL: videoURL, thumbURL: thumbURL,
                title: title, duration: duration, countryCode: countryCode)
    }
    
    /**
     Expects a json in the form:
     
     {
     "template_id": "12345",
     "video_url": "https://www.youtube.com/watch?v=Iqh8iPQpGj0",
     "thumb_url": "https://i.ytimg.com/vi_webp/00A-0HGUv4g/mqdefault.webp",
     "title": "video_1",
     "duration": 31,
     "county_code": "US"
     }
     
     */
    static func decode(j: JSON) -> Decoded<LGCommercializerTemplate> {
        
        let init1 = curry(LGCommercializerTemplate.newTemplate)
                            <^> j <|? "template_id"
                            <*> j <|? "video_url"
                            <*> j <|? "thumb_url"
                            <*> j <|? "title"
        let result = init1  <*> j <|? "duration"
                            <*> j <|? "country_code"
    
        
        if let error = result.error {
            print("LGCommercializer parse error: \(error)")
        }
        
        return result
    }
}
