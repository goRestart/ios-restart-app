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
    var status: CommercializerStatus
    var videoHighURL: String?
    var videoLowURL: String?
    var thumbURL: String?
    var shareURL: String?
    var templateId: String?
    var title: String?
    var duration: Int?
    var updatedAt : NSDate?
    var createdAt : NSDate?
    
}

extension LGCommercializer : Decodable {
    
    static func newLGCommercializer(status: CommercializerStatus, videoHighURL: String?, videoLowURL: String?,
                                    thumbURL: String?, shareURL: String?, templateId: String?, title: String?,
                                    duration: Int?, updatedAt: NSDate?, createdAt: NSDate?)
        -> LGCommercializer {
            return LGCommercializer(objectId: nil, status: status, videoHighURL: videoHighURL, videoLowURL: videoLowURL,
                                    thumbURL: thumbURL, shareURL: shareURL, templateId: templateId, title: title,
                                    duration: duration, updatedAt: updatedAt, createdAt: createdAt)
    }
    
    /**
     Expects a json in the form:
     
     {
     "videos": [
      {
     "status": 2,
     "video_duration": 45,
     "created_at": "2016-04-07T10:29:18+0000",
     "updated_at": "2016-04-07T10:29:47+0000",
     "thumb_url": "https:\/\/d3iw9srrgjmmn1.cloudfront.net\/p-R4y3M-b-Q4I4E3v9peE-T2K3p3M0r8y4Ee.jpg",
     "share_url": "http:\/\/us.letgo.com\/en\/v\/9fc19de9-c48d-4c16-b651-b2062ebc04ea\/ad09ec1c-9314-4fee-b007-3f96cf91a077",
     "template_id": "ad09ec1c-9314-4fee-b007-3f96cf91a077",
     "video_title": "null",
     "video_high_url": "https:\/\/d3iw9srrgjmmn1.cloudfront.net\/o65d1b3bCfi0M-k-Se8cY3rb26w1xfzaZ412MblbA7m65-acOaJ-3-d8Md1fje\/k4i410Z-K9i-54cff4Zbk-Eal611t0c9jbe-.mp4",
     "video_low_url": "https:\/\/d3iw9srrgjmmn1.cloudfront.net\/o65d1b3bCfi0M-k-Se8cY3rb26w1xfzaZ412MblbA7m65-acOaJ-3-d8Md1fje\/xaeaIdV4Ob9b26I4d2x1q6Zb111cI6f2f-d3.mp4"
      },
     ...
     ],
     "can_create_videos": true
     }
     
     */
    static func decode(j: JSON) -> Decoded<LGCommercializer> {
        
        let init1 = curry(LGCommercializer.newLGCommercializer)
                            <^> LGArgo.parseCommercializerStatus(j, key: "status")
                            <*> j <|? "video_high_url"
                            <*> j <|? "video_low_url"
                            <*> j <|? "thumb_url"
        let init2 = init1   <*> j <|? "share_url"
                            <*> j <|? "template_id"
                            <*> j <|? "video_title"
                            <*> j <|? "video_duration"
                            <*> j <|? "updated_at"
         let result = init2 <*> j <|? "created_at"
        
        
        if let error = result.error {
            print("LGCommercializer parse error: \(error)")
        }
        
        return result
    }
}
