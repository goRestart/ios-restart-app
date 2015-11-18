//
//  LGUserProductRelationResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGUserProductRelationResponse {
    
    public let userProductRelation : UserProductRelation
    
}

extension LGUserProductRelationResponse : ResponseObjectSerializable {
    
    // Constant
    private static let isFavoritedKey = "is_favorited"
    private static let isReportedKey = "is_reported"
    
    // MARK: - ResponseObjectSerializable
    //    {
    //      "is_reported": false,
    //      "is_favorited": false
    //    }
    
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let relation : LGUserProductRelation = decode(representation) else {
            return nil
        }
        
        self.userProductRelation = relation
    }
}