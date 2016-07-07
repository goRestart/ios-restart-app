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
}


// MARK: Banner

enum BannerCellStyle: Int {
    case SofaBlack
    case BicycleBlack
    case PhoneBlack
    case PlayBlack
    case SofaRed
    case BicycleBlue
    case PhoneYellow
    case PlayBlue
    
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
            return UIColor.blackColor().colorWithAlphaComponent(0.4)
        case .SofaRed:
            return UIColor.primaryColor.colorWithAlphaComponent(0.7)
        case .BicycleBlue:
            return UIColor.terciaryColor.colorWithAlphaComponent(0.7)
        case .PhoneYellow:
            return UIColor.init(rgb: 0xf1b83d, alpha: 0.7)
        case .PlayBlue:
            return UIColor.init(rgb: 0x538fd1, alpha: 0.7)
        }
    }
    
    static func random() -> BannerCellStyle {
        let n = Int(arc4random_uniform(8))
        return BannerCellStyle.init(rawValue: n) ?? .SofaBlack
    }
}

struct BannerData {
    let title: String
    let style: BannerCellStyle = BannerCellStyle.random()
}
