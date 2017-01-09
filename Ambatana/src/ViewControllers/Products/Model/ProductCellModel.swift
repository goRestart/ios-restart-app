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
}

enum CollectionCellType: String {
    case Gaming = "gaming"
    case Apple = "apple"
    case Transport = "transport"
    case Furniture = "furniture"
    case You = "selected-for-you"
    
    static var generalCollections: [CollectionCellType] {
        return [.Gaming, .Apple, .Transport, .Furniture]
    }

    var image: UIImage? {
        switch self {
        case .Gaming:
            return UIImage(named: "collection_gaming")
        case .Apple:
            return UIImage(named: "collection_apple")
        case .Transport:
            return UIImage(named: "collection_transport")
        case .Furniture:
            return UIImage(named: "collection_home")
        case .You:
            return UIImage(named: "collection_you")
        }
    }

    var title: String {
        switch self {
        case .Gaming:
            return LGLocalizedString.collectionGamingTitle
        case .Apple:
            return LGLocalizedString.collectionAppleTitle
        case .Transport:
            return LGLocalizedString.collectionTransportTitle
        case .Furniture:
            return LGLocalizedString.collectionFurnitureTitle
        case .You:
            return LGLocalizedString.collectionYouTitle
        }
    }
}
