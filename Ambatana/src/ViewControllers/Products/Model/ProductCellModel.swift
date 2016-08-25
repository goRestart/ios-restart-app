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
    case ProductCell(product: Product)
    case CollectionCell(type: CollectionCellType)
    
    init(product: Product) {
        self = ProductCellModel.ProductCell(product: product)
    }

    init(collection: CollectionCellType) {
        self = ProductCellModel.CollectionCell(type: collection)
    }
}


// MARK: Product

struct ProductData {
    var productID: String?
    var thumbUrl: NSURL?
    var price: String?
}

enum CollectionCellType: String {
    case Gaming = "gaming"
    case Apple = "apple"
    case Transport = "transport"
    case Furniture = "furniture"

    static var allValues: [CollectionCellType] {
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
        }
    }

    var searchTextUS: String {
        switch self {
        case .Gaming:
            return "ps4 xbox pokemon nintendo PS3 game boy Wii atari sega"
        case .Apple:
            return "iphone apple iPad MacBook iPod Mac iMac"
        case .Transport:
            return "bike boat motorcycle car kayak trailer atv truck jeep rims camper cart scooter dirtbike jetski gokart four wheeler bicycle quad bike tractor bmw wheels canoe hoverboard Toyota bmx rv Chevy sub ford paddle Harley yamaha Jeep Honda mustang corvette dodge"
        case .Furniture:
            return "dresser couch furniture desk table patio bed stand chair sofa rug mirror futon bench stool frame recliner lamp cabinet ikea shelf antique bedroom book shelf tables end table bunk beds night stand canopy"
        }
    }
}
