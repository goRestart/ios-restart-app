//
//  LGUserProductRelationResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Alamofire
import SwiftyJSON

public class LGUserProductRelationResponse : ResponseObjectSerializable {
    
    // Constant
    private static let isFavoritedKey = "is_favorited"
    private static let isReportedKey = "is_reported"
    
    public var isFavorited: Bool
    public var isReported: Bool
    
    // MARK: - Lifecycle
    
    public init() {
        isFavorited = false
        isReported = false
    }
    
    // MARK: - ResponseObjectSerializable
    //    {
    //      "is_reported": false,
    //      "is_favorited": false
    //    }
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)
        
        if let favorited = json[LGUserProductRelationResponse.isFavoritedKey].bool, let reported = json[LGUserProductRelationResponse.isReportedKey].bool {
            isFavorited = favorited
            isReported = reported
        }
        else {
            return nil
        }
    }
}