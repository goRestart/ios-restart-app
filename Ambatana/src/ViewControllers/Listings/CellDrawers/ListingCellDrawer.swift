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
            cell.setupImageUrl(thumbURL, imageSize: model.imageSize)
        }
        if model.isFeatured {
            cell.setupFeaturedStripe(withTextColor: UIColor.blackText)
            if style == .mainList {
                cell.setupFeaturedListingInfoWith(price: model.price, title: model.title, isMine: model.isMine)
            }
        } else if model.shouldShowPrice {
            cell.setupPriceView(price: model.price)
        } else if model.isFree {
            cell.setupFreeStripe()
        }
    }

    func willDisplay(_ model: ListingData, inCell cell: ListingCell) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cell.relatedListingButton.expand()
        }
    }

}
