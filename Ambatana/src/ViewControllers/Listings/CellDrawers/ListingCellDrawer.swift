//
//  ListingCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class ListingCellDrawer: BaseCollectionCellDrawer<ListingCell>, GridCellDrawer {
    func draw(_ model: ListingData, style: CellStyle, inCell cell: ListingCell) {
        if let id = model.listingId {
            cell.setBackgroundColor(id: id)
        }
        if let thumbURL = model.thumbUrl {
            cell.setImageUrl(thumbURL)
        }
        if model.isFeatured {
            cell.setFeaturedStripe()
            switch style {
            case .mainList:
                cell.setFeaturedListingInfoWith(price: model.price, title: model.title, isMine: model.isMine,
                                                listing: model.listing, delegate: model.delegate)
            case .relatedListings:
                cell.hideFeaturedListingInfo()
            }
        } else {
            cell.hideFeaturedListingInfo()
        }
        if model.isFree {
            cell.setFreeStripe()
        }
    }
}
