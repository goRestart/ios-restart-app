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
import MoPub

enum ListingCellModel {
    case listingCell(listing: Listing)
    case collectionCell(type: CollectionCellType)
    case emptyCell(vm: LGEmptyViewModel)
    case dfpAdvertisement(data: AdvertisementDFPData)
    case mopubAdvertisement(data: AdvertisementMoPubData)
    case adxAdvertisement(data: AdvertisementAdxData)
    case mostSearchedItems(data: MostSearchedItemsCardData)
    
    init(listing: Listing) {
        self = ListingCellModel.listingCell(listing: listing)
    }

    init(collection: CollectionCellType) {
        self = ListingCellModel.collectionCell(type: collection)
    }

    init(emptyVM: LGEmptyViewModel) {
        self = ListingCellModel.emptyCell(vm: emptyVM)
    }

    var listing: Listing? {
        switch self {
        case .listingCell(let listing):
            return listing
        default:
            return nil
        }
    }
    
    init(mostSearchedItemsData: MostSearchedItemsCardData) {
        self = ListingCellModel.mostSearchedItems(data: mostSearchedItemsData)
    }
}


// MARK: Listing

struct ListingData {
    var listing: Listing?
    var delegate: ListingCellDelegate?
    var isFree: Bool
    var isFeatured: Bool
    var isMine: Bool
    var price: String
    let imageSize: CGSize
    let currentLocation: LGLocation?
    
    var listingId: String? {
        return listing?.objectId
    }

    var thumbUrl: URL? {
        return listing?.thumbnail?.fileURL
    }

    var title: String? {
        return listing?.title
    }
    
    var distanceToListing: Double? {
        guard let listingPosition = listing?.location,
              let userLocation = currentLocation?.location else { return nil }
        return userLocation.distanceTo(listingPosition).roundNearest(0.1)
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

struct AdvertisementDFPData {
    var adUnitId: String
    var rootViewController: UIViewController
    var adPosition: Int
    var bannerHeight: CGFloat
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio
    var adRequested: Bool
    var categories: [ListingCategory]?
    
    var adRequest: DFPRequest
    var bannerView: GADBannerView?
}

struct AdvertisementMoPubData {
    var adUnitId: String
    var rootViewController: UIViewController
    var adPosition: Int
    var bannerHeight: CGFloat
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio
    var adRequested: Bool
    var categories: [ListingCategory]?
    
    var nativeAdRequest: MPNativeAdRequest?
    var moPubNativeAd: MPNativeAd?
    var moPubView: UIView?
}

struct AdvertisementAdxData {
    var adUnitId: String
    var rootViewController: UIViewController
    var adPosition: Int
    var bannerHeight: CGFloat
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio
    var adRequested: Bool
    var categories: [ListingCategory]?
    
    var adLoader: GADAdLoader
    var adxNativeView: UIView?
}

enum AdProviderType {
    case dfp
    case moPub
}

struct MostSearchedItemsCardData {
    let icon: UIImage? = UIImage(named: "trending_icon")
    let title: String = LGLocalizedString.trendingItemsCardTitle
    let actionTitle: String = LGLocalizedString.trendingItemsCardAction
}
