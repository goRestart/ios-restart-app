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
     "status": 2,
     "video_duration": 90,
     "created_at": "2016-04-06T14:52:23+0000",
     "updated_at": "2016-04-06T14:53:01+0000",
     "thumb_url": "https:\/\/d3iw9srrgjmmn1.cloudfront.net\/O6z3U5ifFeM757hde5r3AaBcX3obOap9McB-.jpg",
     "share_url": "http:\/\/us.letgo.com\/en\/v\/396a3fed-5f83-4b1f-aab6-6fe7d8f472e3\/1461c093-0dd5-43b7-8e8a-992672dc6010",
     "template_id": "1461c093-0dd5-43b7-8e8a-992672dc6010",
     "video_title": "null",
     "video_high_url": "https:\/\/d3iw9srrgjmmn1.cloudfront.net\/66r2P404Z8q9Mf01K4c1d9Y4m1L9VbRfS-M2l-J2E28f61y2W4e9A5G8KfN6s2\/N8z4A5r2t1K-20K6A3O-F6z7V7g4X47bqee6.mp4",
     "video_low_url": "https:\/\/d3iw9srrgjmmn1.cloudfront.net\/66r2P404Z8q9Mf01K4c1d9Y4m1L9VbRfS-M2l-J2E28f61y2W4e9A5G8KfN6s2\/K5Kf187eN0n1Q-g8n9i6Taq1h0R1i6c0uea-.mp4"
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
                            <*> LGArgo.parseDate(json: j, key: "updated_at")
         let result = init2 <*> LGArgo.parseDate(json: j, key: "created_at")
        
        
        if let error = result.error {
            print("LGCommercializer parse error: \(error)")
        }
        
        return result
    }
}
