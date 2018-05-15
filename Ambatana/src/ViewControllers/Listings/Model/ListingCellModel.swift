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
    case promo(data: PromoCellData, delegate: ListingCellDelegate?)
    
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
    
    init(promoData: PromoCellData, delegate: ListingCellDelegate?) {
        self = ListingCellModel.promo(data: promoData, delegate: delegate)
    }
}


// MARK: Listing

enum InterestedState: Equatable {
    case send(enabled: Bool)
    case seeConversation
    case none

    static func ==(lhs: InterestedState, rhs: InterestedState) -> Bool {
        switch (lhs, rhs) {
        case (.send(let lEnabled), .send(let rEnabled)):
            return lEnabled == rEnabled
        case (.seeConversation, .seeConversation): return true
        case (.none, .none): return true
        case (.send(_), _): return false
        case (_, .send(_)): return false
        case (.seeConversation, _): return false
        case (_, .seeConversation): return false
        }
    }
}

struct ListingData {
    var listing: Listing?
    var delegate: ListingCellDelegate?
    var isFree: Bool
    var isFeatured: Bool
    var isMine: Bool
    var price: String
    let imageSize: CGSize
    let currentLocation: LGLocation?
    let interestedState: InterestedState?

    var listingId: String? {
        return listing?.objectId
    }

    var thumbUrl: URL? {
        return listing?.thumbnail?.fileURL
    }

    var mediaThumbUrl: URL? {
        return listing?.mediaThumbnail?.file.fileURL
    }

    var mediaThumbType: MediaType? {
        return listing?.mediaThumbnail?.type
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
    var adRequested: Bool
    var categories: [ListingCategory]?
    
    var nativeAdRequest: MPNativeAdRequest?
    var moPubNativeAd: MPNativeAd?
    var moPubView: UIView?
}

struct AdvertisementAdxData {
    let adUnitId: String
    let rootViewController: UIViewController
    let adPosition: Int
    let bannerHeight: CGFloat
    let adRequested: Bool
    let categories: [ListingCategory]?
    
    let adLoader: GADAdLoader
    let adxNativeView: UIView?
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

struct PromoCellData {
    var appereance: CellAppereance
    var arrangement: PromoCellArrangement
    var title: String
    var image: UIImage
}
