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
        cell.listing = model.listing
        cell.delegate = model.delegate

        if let id = model.listingId {
            cell.setupBackgroundColor(id: id)
        }
        if let thumbURL = model.thumbUrl {
            cell.setupImageUrl(thumbURL)
        }
        if model.isFeatured {
            cell.setupFeaturedStripe()
            switch style {
            case .mainList:
                cell.setupFeaturedListingInfoWith(price: model.price, title: model.title, isMine: model.isMine)
            case .relatedListings:
                cell.hideFeaturedListingInfo()
            }
        } else {
            cell.hideFeaturedListingInfo()
            if model.isFree {
                cell.setupFreeStripe()
            }
        }
    }

    func willDisplay(_ model: ListingData, inCell cell: ListingCell) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cell.relatedListingButton.expand()
        }
    }

}
