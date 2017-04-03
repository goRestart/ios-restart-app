//
//  ProductListModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/6/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


enum ProductCellModel {
    case productCell(product: Product)
    case collectionCell(type: CollectionCellType)
    case emptyCell(vm: LGEmptyViewModel)
    
    init(product: Product) {
        self = ProductCellModel.productCell(product: product)
    }

    init(collection: CollectionCellType) {
        self = ProductCellModel.collectionCell(type: collection)
    }

    init(emptyVM: LGEmptyViewModel) {
        self = ProductCellModel.emptyCell(vm: emptyVM)
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
