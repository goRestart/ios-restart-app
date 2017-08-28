//
//  ListingCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class ListingCellDrawer: BaseCollectionCellDrawer<ListingCell>, GridCellDrawer {
    func draw(_ model: ProductData, style: CellStyle, inCell cell: ListingCell) {
        if let id = model.listingId {
            cell.setBackgroundColor(id: id)
        }
        if let thumbURL = model.thumbUrl {
            cell.setImageUrl(thumbURL)
        }
        if model.isFeatured {
            cell.setFeaturedStripe()
        } else if model.isFree {
            cell.setFreeStripe()
        }
    }
}
