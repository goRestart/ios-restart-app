import Foundation
import LGCoreKit
import GoogleMobileAds
import MoPub
import LGComponents

enum ListingCellModel {
    case listingCell(listing: Listing)
    case collectionCell(type: CollectionCellType)
    case emptyCell(vm: LGEmptyViewModel)
    case dfpAdvertisement(data: AdvertisementDFPData)
    case mopubAdvertisement(data: AdvertisementMoPubData)
    case adxAdvertisement(data: AdvertisementAdxData)
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

extension InterestedState {
    
    var image: UIImage? {
        switch self {
        case .none: return nil
        case .send(let enabled):
            let alpha: CGFloat = enabled ? 1 : 0.7
            return R.Asset.IconsButtons.IAmInterested.icIamiSend.image.withAlpha(alpha) ?? R.Asset.IconsButtons.IAmInterested.icIamiSend.image
        case .seeConversation: return R.Asset.IconsButtons.IAmInterested.icIamiSeeconv.image
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
    
    var paymentFrequency: String? {
        return listing?.paymentFrequencyString
    }
    
    var serviceListingTypeDisplayText: String? {
        return listing?.service?.servicesAttributes.listingType?.displayName.localizedCapitalized
    }
    
    func titleViewModel(featureFlags: FeatureFlaggeable) -> ListingTitleViewModel? {
        return ListingTitleViewModel(listing: listing,
                                     featureFlags: featureFlags)
    }

}

enum CollectionCellType: String {
    case selectedForYou = "selected-for-you"

    var image: UIImage? {
        switch self {
        case .selectedForYou:
            return R.Asset.ProductCellBanners.collectionYou.image
        }
    }

    var title: String {
        switch self {
        case .selectedForYou:
            return R.Strings.collectionYouTitle
        }
    }
    
    func buildQueryString(from keyValueStorage: KeyValueStorageable) -> String {
        var query: String
        switch self {
        case .selectedForYou:
            query = keyValueStorage[.lastSuggestiveSearches]
                .compactMap { $0.suggestiveSearch.name }
                .reversed()
                .joined(separator: " ")
                .clipMoreThan(wordCount: SharedConstants.maxSelectedForYouQueryTerms)
        }
        return query
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
