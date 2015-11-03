//
//  LGProductsFavouriteResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 02/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGProductsFavouriteResponse: ProductsFavouriteResponse {
    
    public let products: [Product]
    
}

extension LGProductsFavouriteResponse : ResponseObjectSerializable {
    // MARK: - ResponseObjectSerializable
    
    //    [
    //        {...},
    //        {...}
    //      ...
    //    ]
    
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let theLGProducts : [LGProduct] = decode(representation) else {
            return nil
        }
        
        self.products = theLGProducts.map({$0})
    }
}
