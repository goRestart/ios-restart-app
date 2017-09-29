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
            cell.setupBackgroundColor(id: id)
        }
        if let thumbURL = model.thumbUrl {
            cell.setupImageUrl(thumbURL)
        }
        if model.isFeatured {
            cell.setupFeaturedStripe()
            cell.hidePriceView()
            switch style {
            case .mainList:
                cell.setupFeaturedListingInfoWith(price: model.price, title: model.title, isMine: model.isMine,
                                                listing: model.listing, delegate: model.delegate)
            case .relatedListings:
                cell.hideFeaturedListingInfo()
            }
        } else {
            cell.hideFeaturedListingInfo()
            cell.setupPriceView(price: model.price)
            if model.isFree {
                cell.setupFreeStripe()
            }
        }
    }
}
