//
//  ListingCellModel.swift
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


// MARK: Listing

struct ListingData {
    var listing: Listing?
    var delegate: ListingCellDelegate?
    var isFree: Bool
    var isFeatured: Bool
    var isMine: Bool
    var price: String
    
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
