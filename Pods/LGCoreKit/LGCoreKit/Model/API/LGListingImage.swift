//
//  LGListingImage.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 10/11/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

struct LGListingImage: Codable {
    let id: String
    let url: URL
    
    static func mapToFiles(_ listingImageArray: [LGListingImage]) -> [File] {
        return listingImageArray.map { LGFile(id: $0.id, url: $0.url) }
    }
}
