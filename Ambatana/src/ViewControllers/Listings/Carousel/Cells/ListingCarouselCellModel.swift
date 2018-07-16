//
//  ListingCarouselCellModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 6/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum ListingCarouselCellModel {
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
        return listing.images.compactMap { $0.fileURL }
    }

    var media: [Media] { return listing.media }

    var backgroundColor: UIColor {
        return UIColor.placeholderBackgroundColor(listing.objectId)
    }
    
    static func adapter(_ model: ListingCellModel) -> ListingCarouselCellModel? {
        switch model {
        case let .listingCell(listing):
            return ListingCarouselCellModel.listingCell(listing: listing)
        default:
            return nil
        }
    }
}

extension Media {
    var isPlayable: Bool { return type == .video }
}
