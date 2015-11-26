//
//  LGProductSaveResponse.swift
//  Pods
//
//  Created by Dídac on 28/08/15.
//
//

import Argo

public struct LGProductSaveResponse: ProductResponse {
    
    public let product: Product
    
}

extension LGProductSaveResponse : ResponseObjectSerializable {
    // MARK: - ResponseObjectSerializable
    
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let theProduct : LGProduct = decode(representation) else {
            return nil
        }
        
        self.product = theProduct
    }

}