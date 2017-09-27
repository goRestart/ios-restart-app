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
    private let showFeaturedStripeHelper = ShowFeaturedStripeHelper(featureFlags: FeatureFlags.sharedInstance,
                                                                    myUserRepository: Core.myUserRepository)
    private let myUserRepository: MyUserRepository


    init(myUserRepository: MyUserRepository) {
        self.myUserRepository = myUserRepository
    }

    func registerCell(inCollectionView collectionView: UICollectionView) {
        ListingCellDrawer.registerCell(collectionView)
        ListingCollectionCellDrawer.registerCell(collectionView)
        EmptyCellDrawer.registerCell(collectionView)
    }
    
    func cell(_ model: ListingCellModel, collectionView: UICollectionView, atIndexPath: IndexPath) -> UICollectionViewCell {
        switch model {
        case .listingCell:
            return listingDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .collectionCell:
            return collectionDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .emptyCell:
            return emptyCellDrawer.cell(collectionView, atIndexPath: atIndexPath)
        }
    }
    
    func draw(_ model: ListingCellModel, inCell cell: UICollectionViewCell, delegate: ListingCellDelegate?) {
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
                                   isFree: listing.price.free && freePostingAllowed,
                                   isFeatured: isFeatured,
                                   isMine: isMine,
                                   price: listing.priceString(freeModeAllowed: freePostingAllowed))
            return listingDrawer.draw(data, style: cellStyle, inCell: cell)
        case .collectionCell(let style) where cell is CollectionCell:
            guard let cell = cell as? CollectionCell else { return }
            return collectionDrawer.draw(style, style: cellStyle, inCell: cell)
        case .emptyCell(let vm):
            guard let cell = cell as? EmptyCell else { return }
            return emptyCellDrawer.draw(vm, style: cellStyle, inCell: cell)
        default:
            assert(false, "⛔️ You shouldn't be here")
        }
    }
}
