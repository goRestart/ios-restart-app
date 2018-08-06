//
//  ListingCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

final class ListingCellDrawer: BaseCollectionCellDrawer<ListingCell>, GridCellDrawer {
    
    private let featureFlags: FeatureFlags
    private let preventMessagesToPro: Bool
    
    init(featureFlags: FeatureFlags = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
        self.preventMessagesToPro = featureFlags.preventMessagesFromFeedToProUsers.isActive
        super.init()
    }
    
    // MARK:- Public
    
    func draw(_ model: ListingData, style: CellStyle, inCell cell: ListingCell, isPrivateList: Bool) {
        cell.listing = model.listing
        cell.delegate = model.delegate
        
        if let id = model.listingId {
            cell.set(accessibilityId: .listingCell(listingId: id))
            cell.setupBackgroundColor(id: id)
        }
        
        if model.mediaThumbType == .video,
            let thumbURL = model.mediaThumbUrl {
            cell.setupGifUrl(thumbURL, imageSize: model.imageSize, preventMessagesToPro: preventMessagesToPro)
        } else if let thumbURL = model.thumbUrl {
            cell.setupImageUrl(thumbURL, imageSize: model.imageSize, preventMessagesToPro: preventMessagesToPro)
        }
        
        configThumbnailArea(model, style: style, inCell: cell)
        configWhiteAreaUnderThumbnailImage(model, style: style, inCell: cell, isPrivateList: isPrivateList)
        configDiscardedProduct(model, inCell: cell)
    }
    
    func willDisplay(_ model: ListingData, inCell cell: ListingCell) {
        guard shouldShowInterestedButtonFor(model), let interestedState = model.interestedState else { return }
        cell.setupWith(interestedState: interestedState)
    }
    
    
    // MARK:- Private

    private func configThumbnailArea(_ model: ListingData, style: CellStyle, inCell cell: ListingCell) {
        configStrips(model, inCell: cell)
    }
    
    private func configStrips(_ model: ListingData, inCell cell: ListingCell) {
        if model.isFeatured {
            cell.setupFeaturedStripe(withTextColor: UIColor.blackText)
        } else if model.isFree {
            cell.setupFreeStripe()
        }
    }
    
    private func configWhiteAreaUnderThumbnailImage(_ model: ListingData, style: CellStyle, inCell cell: ListingCell,
                                                    isPrivateList: Bool) {
        guard style == .mainList || style == .serviceList else { return }
        let listingCanBeBumped = model.listing?.status == .approved || model.listing?.status == .pending
        
        let showBumpUpCTA = model.isMine &&
        featureFlags.showSellFasterInProfileCells.isActive &&
        featureFlags.pricedBumpUpEnabled &&
        isPrivateList && listingCanBeBumped
        
        let canShowPaymentFrequency = featureFlags.servicesPaymentFrequency.isActive
        
        if model.isFeatured {
            // According to the bussines login all the featured items (services, cards, real estates, etc),
            // must show the title, the description and the red button, that the reason of the hideProductDetail: false.
            cell.setupFeaturedListingInfoWith(price: model.price,
                                              paymentFrequency: canShowPaymentFrequency ? model.paymentFrequency : nil,
                                              title: model.title,
                                              isMine: model.isMine,
                                              hideProductDetail: false,
                                              shouldShowBumpUpCTA: showBumpUpCTA)
        } else {
            cell.setupNonFeaturedProductInfoUnderImage(price: model.price,
                                                       paymentFrequency: canShowPaymentFrequency ? model.paymentFrequency : nil,
                                                       title: model.title,
                                                       shouldShow: (style == .serviceList),
                                                       shouldShowBumpUpCTA: showBumpUpCTA);
        }
    }

    private func shouldShowInterestedButtonFor(_ model: ListingData) -> Bool {
        let shouldShowDiscarded = model.listing?.status.isDiscarded ?? false
        return !model.isMine && featureFlags.shouldShowIAmInterestedInFeed.isVisible && !shouldShowDiscarded
    }
    
    private func configDiscardedProduct(_ model: ListingData, inCell cell: ListingCell) {
        let isDiscarded = model.listing?.status.isDiscarded ?? false
        let isAllowedToBeEdited = model.listing?.status.discardedReason?.isAllowedToBeEdited ?? false
        cell.show(isDiscarded: isDiscarded && isAllowedToBeEdited, reason: model.listing?.status.discardedReason?.message)
    }
}
