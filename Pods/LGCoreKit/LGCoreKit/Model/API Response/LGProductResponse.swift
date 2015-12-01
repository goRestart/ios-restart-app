//
//  LGProductResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 07/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGProductResponse: ProductResponse {
    
    public let product: Product
    
}

extension LGProductResponse : ResponseObjectSerializable {
    // MARK: - ResponseObjectSerializable
    
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let theProduct : LGProduct = decode(representation) else {
            return nil
        }
        
        self.product = theProduct
    }
}
