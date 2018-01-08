//
//  LGListingStats.swift
//  LGCoreKit
//
//  Created by Dídac on 26/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ListingStats {
    var viewsCount: Int { get }
    var favouritesCount: Int { get }
}

struct LGListingStats : ListingStats, Decodable {
    let viewsCount: Int
    let favouritesCount: Int
    
    // MARK: Decodable
    
    /*
     {
         "count_favs": 0,
         "count_offers": 0,
         "count_views": 0
     }
     */
    
    enum CodingKeys: String, CodingKey {
        case viewsCount = "count_views"
        case favouritesCount = "count_favs"
    }
}


