//
//  LGCommercializerProduct.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 5/4/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

public struct LGCommercializerProduct: CommercializerProduct {
    public let objectId: String?
    public let thumbnailURL: String?
}

extension LGCommercializerProduct: Decodable {
    public static func decode(j: JSON) -> Decoded<LGCommercializerProduct> {
        
        let init1 = curry(LGCommercializerProduct.init)
            <^> j <|? "id"
            <*> j <|? ["thumb", "url"]
        
        return init1
    }
}
