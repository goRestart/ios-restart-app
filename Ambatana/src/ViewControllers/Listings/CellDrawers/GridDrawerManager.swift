//
//  GridCellDrawerFactory.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import LGCoreKit

enum CellStyle {
    case mainList, relatedListings
}

class GridDrawerManager {

    var cellStyle: CellStyle = .mainList
    var freePostingAllowed: Bool = true

    private let listingDrawer = ListingCellDrawer()
    private let collectionDrawer = ListingCollectionCellDrawer()
    private let emptyCellDrawer = EmptyCellDrawer()
    private let advertisementDFPDrawer = AdvertisementDFPCellDrawer()
    private let advertisementMoPubDrawer = AdvertisementMoPubCellDrawer()
    private let advertisementAdxDrawer = AdvertisementAdxCellDrawer()
    private let mostSearchedItemsDrawer = MostSearchedItemsCellDrawer()
    private let showFeaturedStripeHelper = ShowFeaturedStripeHelper(featureFlags: FeatureFlags.sharedInstance,
                                                                    myUserRepository: Core.myUserRepository)
    private let promoDrawer = PromoCellDrawer()
    
    private let myUserRepository: MyUserRepository
    private let locationManager: LocationManager

    init(myUserRepository: MyUserRepository, locationManager: LocationManager) {
        self.myUserRepository = myUserRepository
        self.locationManager = locationManager
    }

    func registerCell(inCollectionView collectionView: UICollectionView) {
        ListingCellDrawer.registerClassCell(collectionView)
        ListingCollectionCellDrawer.registerClassCell(collectionView)
        EmptyCellDrawer.registerClassCell(collectionView)
        AdvertisementDFPCellDrawer.registerClassCell(collectionView)
        AdvertisementMoPubCellDrawer.registerClassCell(collectionView)
        AdvertisementAdxCellDrawer.registerClassCell(collectionView)
        MostSearchedItemsCellDrawer.registerClassCell(collectionView)
        PromoCellDrawer.registerClassCell(collectionView)
    }
    
    func cell(_ model: ListingCellModel, collectionView: UICollectionView, atIndexPath: IndexPath) -> UICollectionViewCell {
        switch model {
        case .listingCell:
            return listingDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .collectionCell:
            return collectionDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .emptyCell:
            return emptyCellDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .dfpAdvertisement:
            return advertisementDFPDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .mopubAdvertisement:
            return advertisementMoPubDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .adxAdvertisement:
            return advertisementAdxDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .mostSearchedItems:
            return mostSearchedItemsDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .promo:
            return promoDrawer.cell(collectionView, atIndexPath: atIndexPath)
        }
    }

    func willDisplay(_ model: ListingCellModel,
                     inCell cell: UICollectionViewCell,
                     delegate: ListingCellDelegate?,
                     imageSize: CGSize,
                     interestedState: InterestedState?) {
        switch model {
        case let .listingCell(listing) where cell is ListingCell:
            guard let cell = cell as? ListingCell else { return }
            let isFeatured = showFeaturedStripeHelper.shouldShowFeaturedStripeFor(listing: listing)
            var isMine = false
            if let listingUserId = listing.user.objectId,
                let myUserId = myUserRepository.myUser?.objectId,
                listingUserId == myUserId {
                isMine = true
            }
            let data = ListingData(listing: listing,
                                   delegate: delegate,
                                   isFree: listing.price.isFree && freePostingAllowed,
                                   isFeatured: isFeatured,
                                   isMine: isMine,
                                   price: listing.priceString(freeModeAllowed: freePostingAllowed),
                                   imageSize: imageSize,
                                   currentLocation: locationManager.currentLocation,
                                   interestedState: interestedState)
            listingDrawer.willDisplay(data, inCell: cell)
        case .dfpAdvertisement(let adData):
            guard let cell = cell as? AdvertisementCell else { return }
            advertisementDFPDrawer.willDisplay(adData, inCell: cell)
        case .mopubAdvertisement(let adData):
            guard let cell = cell as? AdvertisementCell else { return }
            advertisementMoPubDrawer.willDisplay(adData, inCell: cell)
        case .adxAdvertisement(let adData):
            guard let cell = cell as? AdvertisementCell else { return }
            advertisementAdxDrawer.willDisplay(adData, inCell: cell)
        default:
            return
        }
    }
    
    func draw(_ model: ListingCellModel,
              inCell cell: UICollectionViewCell,
              delegate: ListingCellDelegate?,
              imageSize: CGSize)
    {
        switch model {
        case let .listingCell(listing) where cell is ListingCell:
            guard let cell = cell as? ListingCell else { return }
            let isFeatured = showFeaturedStripeHelper.shouldShowFeaturedStripeFor(listing: listing)
            var isMine = false
            if let listingUserId = listing.user.objectId,
                let myUserId = myUserRepository.myUser?.objectId,
                listingUserId == myUserId {
                isMine = true
            }
            let data = ListingData(listing: listing,
                                   delegate: delegate,
                                   isFree: listing.price.isFree && freePostingAllowed,
                                   isFeatured: isFeatured,
                                   isMine: isMine,
                                   price: listing.priceString(freeModeAllowed: freePostingAllowed),
                                   imageSize: imageSize,
                                   currentLocation: locationManager.currentLocation,
                                   interestedState: .send(enabled: true))
            return listingDrawer.draw(data, style: cellStyle, inCell: cell)
        case .collectionCell(let style) where cell is CollectionCell:
            guard let cell = cell as? CollectionCell else { return }
            return collectionDrawer.draw(style, style: cellStyle, inCell: cell)
        case .emptyCell(let vm):
            guard let cell = cell as? EmptyCell else { return }
            return emptyCellDrawer.draw(vm, style: cellStyle, inCell: cell)
        case .dfpAdvertisement(let adData):
            guard let cell = cell as? AdvertisementCell else { return }
            return advertisementDFPDrawer.draw(adData, style: cellStyle, inCell: cell)
        case .mopubAdvertisement(let adData):
            guard let cell = cell as? AdvertisementCell else { return }
            return advertisementMoPubDrawer.draw(adData, style: cellStyle, inCell: cell)
        case .adxAdvertisement(let adData):
            guard let cell = cell as? AdvertisementCell else { return }
            return advertisementAdxDrawer.draw(adData, style: cellStyle, inCell: cell)
        case .mostSearchedItems(let data):
            guard let cell = cell as? MostSearchedItemsListingListCell else { return }
            return mostSearchedItemsDrawer.draw(data, style: cellStyle, inCell: cell)
        case .promo(let data, let delegate):
            guard let cell = cell as? PromoCell else { return }
            cell.delegate = delegate
            return promoDrawer.draw(data, style: cellStyle, inCell: cell)
        default:
            assert(false, "⛔️ You shouldn't be here")
        }
    }
}
