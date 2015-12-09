//
//  LGProductsResponse.swift
//  LGCoreKit
//
//  Created by AHL on 1/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGProductsResponse: ProductsResponse {
    
    public let products: [Product]
    
}

extension LGProductsResponse : ResponseObjectSerializable {
    // MARK: - ResponseObjectSerializable
    
    //    [
    //        {see: LGProduct},
    //        ...
    //    ]
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let theLGProducts : [LGProduct] = decode(representation) else {
            return nil
        }
        
        self.products = theLGProducts.map({$0})
    }

}