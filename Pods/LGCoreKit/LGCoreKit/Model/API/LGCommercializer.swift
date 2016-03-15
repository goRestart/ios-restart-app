//
//  LGCommercializer.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGCommercializer: Commercializer {
    
    // Global iVars
    var objectId: String?
    
    // Commercializer iVars
    var status: Int?
    var videoURL: String?
    var thumbURL: String?
    var shareURL: String?
    var templateId: String?
    var title: String?
    var duration: Int?
    var updatedAt : NSDate?
    var createdAt : NSDate?
    
}

extension LGCommercializer : Decodable {
    
    static func newLGCommercializer(status: Int?, videoURL: String?, thumbURL: String?, shareURL: String?,
        templateId: String?, title: String?, duration: Int?, updatedAt: NSDate?, createdAt: NSDate?)
        -> LGCommercializer {
            return LGCommercializer(objectId: nil, status: status, videoURL: videoURL, thumbURL: thumbURL, shareURL: shareURL,
                templateId: templateId, title: title, duration: duration, updatedAt: updatedAt, createdAt: createdAt)
    }
    
    /**
     Expects a json in the form:
     
     {
     "template_id": "12345",
     "video_url": "https://www.youtube.com/watch?v=Iqh8iPQpGj0",
     "thumb_url": "https://i.ytimg.com/vi_webp/00A-0HGUv4g/mqdefault.webp",
     "title": "video_1",
     "duration": 31,
     }
     
     */
    static func decode(j: JSON) -> Decoded<LGCommercializer> {
        
        let init1 = curry(LGCommercializer.newLGCommercializer)
                            <^> j <|? "status"
                            <*> j <|? "video_url"
                            <*> j <|? "thumb_url"
        let init2 = init1   <*> j <|? "share_url"
                            <*> j <|? "template_id"
                            <*> j <|? "title"
                            <*> j <|? "duration"
                            <*> LGArgo.parseDate(json: j, key: "updated_at")
         let result = init2 <*> LGArgo.parseDate(json: j, key: "created_at")
        
        
        if let error = result.error {
            print("LGChat parse error: \(error)")
        }
        
        return result
    }
}
