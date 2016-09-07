//
//  LGProductStats.swift
//  LGCoreKit
//
//  Created by Dídac on 26/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

public struct LGProductStats : ProductStats {
    public var viewsCount: Int
    public var favouritesCount: Int
}

extension LGProductStats: Decodable {

    /**
     Expects a json in the form:

     {
     "count_favs": 0,
     "count_offers": 0,
     "count_views": 0
     }
     */
    public static func decode(j: JSON) -> Decoded<LGProductStats> {

        return curry(LGProductStats.init)
            <^> j <| "count_views"
            <*> j <| "count_favs"
    }
}
