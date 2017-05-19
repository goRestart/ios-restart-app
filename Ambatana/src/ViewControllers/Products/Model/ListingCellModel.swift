//
//  ProductListModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/6/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


enum ListingCellModel {
    case listingCell(listing: Listing)
    case collectionCell(type: CollectionCellType)
    case emptyCell(vm: LGEmptyViewModel)
    
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


// MARK: Product

struct ProductData {
    var productID: String?
    var thumbUrl: URL?
    var isFree: Bool
    var isFeatured: Bool
}

enum CollectionCellType: String {
    case You = "selected-for-you"

    var image: UIImage? {
        switch self {
        case .You:
            return UIImage(named: "collection_you")
        }
    }

    var title: String {
        switch self {
        case .You:
            return LGLocalizedString.collectionYouTitle
        }
    }
}
