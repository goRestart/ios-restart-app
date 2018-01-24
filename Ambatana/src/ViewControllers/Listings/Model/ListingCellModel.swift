//
//  ListingCellModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/6/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import GoogleMobileAds

enum ListingCellModel {
    case listingCell(listing: Listing)
    case collectionCell(type: CollectionCellType)
    case emptyCell(vm: LGEmptyViewModel)
    case advertisement(data: AdvertisementData)
    case mostSearchedItems
    
    init(listing: Listing) {
        self = ListingCellModel.listingCell(listing: listing)
    }

    init(collection: CollectionCellType) {
        self = ListingCellModel.collectionCell(type: collection)
    }

    init(emptyVM: LGEmptyViewModel) {
        self = ListingCellModel.emptyCell(vm: emptyVM)
    }
}


// MARK: Listing

struct ListingData {
    var listing: Listing?
    var delegate: ListingCellDelegate?
    var isFree: Bool
    var isFeatured: Bool
    var featuredShouldShowChatButton: Bool
    var isMine: Bool
    var price: String
    var shouldShowPrice: Bool

    var listingId: String? {
        return listing?.objectId
    }

    var thumbUrl: URL? {
        return listing?.thumbnail?.fileURL
    }

    var title: String? {
        return listing?.title
    }
}

enum CollectionCellType: String {
    case selectedForYou = "selected-for-you"

    var image: UIImage? {
        switch self {
        case .selectedForYou:
            return UIImage(named: "collection_you")
        }
    }

    var title: String {
        switch self {
        case .selectedForYou:
            return LGLocalizedString.collectionYouTitle
        }
    }
}

protocol AdvertisementCellDelegate {
    func updateAdCellHeight(newHeight: CGFloat, forPosition: Int, withBannerView bannerView: GADBannerView)
    func bannerWasTapped(adType: EventParameterAdType,
                         willLeaveApp: EventParameterBoolean,
                         categories: [ListingCategory]?,
                         feedPosition: EventParameterFeedPosition)
}

struct AdvertisementData {
    var adUnitId: String
    var rootViewController: UIViewController
    var adPosition: Int
    var bannerHeight: CGFloat
    var delegate: AdvertisementCellDelegate
    var adRequest: DFPRequest
    var bannerView: GADBannerView?
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio
    var categories: [ListingCategory]?
}
