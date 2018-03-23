//
//  ListingCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class ListingCellDrawer: BaseCollectionCellDrawer<ListingCell>, GridCellDrawer {
    
    private let featureFlags: FeatureFlags
    
    init(featureFlags: FeatureFlags = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
        super.init()
    }
    
    // MARK:- Public
    
    func draw(_ model: ListingData, style: CellStyle, inCell cell: ListingCell) {
        cell.listing = model.listing
        cell.delegate = model.delegate
        
        if let id = model.listingId {
            cell.set(accessibilityId: .listingCell(listingId: id))
            cell.setupBackgroundColor(id: id)
        }
        
        if let thumbURL = model.thumbUrl {
            cell.setupImageUrl(thumbURL, imageSize: model.imageSize)
        }
        
        configThumbnailArea(model, style: style, inCell: cell)
        configWhiteAreaUnderThumbnailImage(model, style: style, inCell: cell)
        configDiscardedProduct(model, inCell: cell)
    }
    
    func willDisplay(_ model: ListingData, inCell cell: ListingCell) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cell.relatedListingButton.expand()
        }
    }
    
    
    // MARK:- Private

    private func configThumbnailArea(_ model: ListingData, style: CellStyle, inCell cell: ListingCell) {
        configStrips(model, inCell: cell)
        configProductInfoInImage(model, style: style, inCell: cell)
    }
    
    private func configProductInfoInImage(_ model: ListingData, style: CellStyle, inCell cell: ListingCell) {
        guard style == .mainList else { return }
        
        switch featureFlags.addPriceTitleDistanceToListings {
        case .baseline, .control: break
        case .infoInImage:
            cell.showCompleteProductInfoInImage(price: model.price, title: model.title, distance: model.distanceToListing)
        case .infoWithWhiteBackground:
            cell.showDistanceOnlyInImage(distance: model.distanceToListing)
        }
    }
    
    private func configStrips(_ model: ListingData, inCell cell: ListingCell) {
        if model.isFeatured {
            cell.setupFeaturedStripe(withTextColor: UIColor.blackText)
        } else if model.isFree {
            cell.setupFreeStripe()
        }
    }
    
    private func configWhiteAreaUnderThumbnailImage(_ model: ListingData, style: CellStyle, inCell cell: ListingCell) {
        guard style == .mainList else { return }
        let flag = featureFlags.addPriceTitleDistanceToListings
        if model.isFeatured {
            cell.setupFeaturedListingInfoWith(price: model.price,
                                              title: model.title,
                                              isMine: model.isMine,
                                              hideProductDetail: flag.hideDetailInFeaturedArea)
        } else {
            cell.setupNonFeaturedProductInfoUnderImage(price: model.price,
                                                      title: model.title,
                                                      shouldShow: flag.showDetailInNormalCell)
        }
    }
    
    private func configDiscardedProduct(_ model: ListingData, inCell cell: ListingCell) {
        if featureFlags.discardedProducts.isActive {
            let isDiscarded = model.listing?.status.isDiscarded ?? false
            let isAllowedToBeEdited = model.listing?.status.discardedReason?.isAllowedToBeEdited ?? false
            cell.show(isDiscarded: isDiscarded && isAllowedToBeEdited, reason: model.listing?.status.discardedReason?.message)
        } else {
            cell.show(isDiscarded: false)
        }
    }
}
