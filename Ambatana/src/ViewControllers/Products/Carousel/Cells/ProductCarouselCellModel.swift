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
        self = .productCell(product: product)
    }

    var product: Product {
        switch self {
        case let .productCell(product):
            return product
        }
    }

    var images: [URL] {
        return product.images.flatMap { $0.fileURL }
    }

    var backgroundColor: UIColor {
        return UIColor.placeholderBackgroundColor(product.objectId)
    }
    
    static func adapter(_ model: ListingCellModel) -> ProductCarouselCellModel? {
        switch model {
        case .productCell(let product):
            return ProductCarouselCellModel.productCell(product: product)
        default:
            return nil
        }
    }
}
