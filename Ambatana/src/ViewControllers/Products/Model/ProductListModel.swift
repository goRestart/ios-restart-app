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
    
    static func adaptProduct(product: Product) -> ProductCellModel {
        return ProductCellModel.ProductCell(product: product)
    }
    
    init(product: Product) {
        self = ProductCellModel.ProductCell(product: product)
    }
    
    init(banner: BannerData) {
        self = ProductCellModel.BannerCell(banner: banner)
    }
    
    func adaptBanner(banner: BannerData) -> ProductCellModel {
        return ProductCellModel.BannerCell(banner: banner)
    }
}

struct ProductData {
    var productID: String?
    var thumbUrl: NSURL?
}

struct BannerData {
    var title: String
}
