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
    case BannerCell(banner: BannerData)
    
    init(product: Product) {
        self = ProductCellModel.ProductCell(product: product)
    }
    
    init(banner: BannerData) {
        self = ProductCellModel.BannerCell(banner: banner)
    }
}


// MARK: Product

struct ProductData {
    var productID: String?
    var thumbUrl: NSURL?
    var price: String?
}


// MARK: Banner

enum BannerCellStyle: String {
    case SofaBlack = "sofa-black"
    case BicycleBlack = "bicycle-black"
    case PhoneBlack = "phone-black"
    case PlayBlack = "play-black"
    case SofaRed = "sofa-red"
    case BicycleBlue = "bicycle-blue"
    case PhoneYellow = "phone-yellow"
    case PlayBlue = "play-blue"
    
    static var allValues: [BannerCellStyle] {
        return [.SofaBlack, .BicycleBlack, .PhoneBlack, .PlayBlack, .SofaRed, .BicycleBlue, .PhoneYellow, .PlayBlue]
    }
    
    var image: UIImage? {
        switch self {
        case .SofaBlack, .SofaRed:
            return UIImage(named: "BannerSofa")
        case .BicycleBlack, .BicycleBlue:
            return UIImage(named: "BannerBicycle")
        case .PhoneBlack, .PhoneYellow:
            return UIImage(named: "BannerPhone")
        case .PlayBlack, .PlayBlue:
            return UIImage(named: "BannerPlay")
        }
    }
    
    var backColor: UIColor {
        switch self {
        case .SofaBlack, .BicycleBlack, .PhoneBlack, .PlayBlack:
            return UIColor.bannerBlack
        case .SofaRed:
            return UIColor.bannerRed
        case .BicycleBlue:
            return UIColor.bannerLightBlue
        case .PhoneYellow:
            return UIColor.bannerYellow
        case .PlayBlue:
            return UIColor.bannerBlue
        }
    }
    
    static func random() -> BannerCellStyle {
        let n = Int.random(0, 7)
        return BannerCellStyle.allValues[n] ?? .SofaBlack
    }
}

struct BannerData {
    let title: String
    let style: BannerCellStyle = BannerCellStyle.random()
}

enum CollectionCellStyle: String {
    case Gaming = "gaming"
    case Apple = "apple"
    case Transport = "transport"
    case Furniture = "furniture"

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
}
