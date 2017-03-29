//
//  ProductCarouselCellModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 6/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum ProductCarouselCellModel {
    case listingCell(listing: Listing)
    
    init(listing: Listing) {
        self = .listingCell(listing: listing)
    }

    var listing: Listing {
        switch self {
        case let .listingCell(listing):
            return listing
        }
    }

    var images: [URL] {
        return listing.images.flatMap { $0.fileURL }
    }

    var backgroundColor: UIColor {
        return UIColor.placeholderBackgroundColor(listing.objectId)
    }
    
    static func adapter(_ model: ListingCellModel) -> ProductCarouselCellModel? {
        switch model {
        case let .productCell(product):
            return ProductCarouselCellModel.listingCell(listing: .product(product))
        case let .carCell(car):
            return ProductCarouselCellModel.listingCell(listing: .car(car))
        default:
            return nil
        }
    }
}
