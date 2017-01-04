//
//  ProductCarouselCellModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 6/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum ProductCarouselCellModel {
    case productCell(product: Product)
    
    init(product: Product) {
        self = .ProductCell(product: product)
    }
    
    static func adapter(_ model: ProductCellModel) -> ProductCarouselCellModel? {
        switch model {
        case .ProductCell(let product):
            return ProductCarouselCellModel.ProductCell(product: product)
        default:
            return nil
        }
    }
}
