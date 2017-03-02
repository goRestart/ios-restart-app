//
//  ProductCarouselCellModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 6/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum ProductCarouselCellModel: ProductAble {
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
    
    static func adapter(_ model: ProductCellModel) -> ProductCarouselCellModel? {
        switch model {
        case .productCell(let product):
            return ProductCarouselCellModel.productCell(product: product)
        default:
            return nil
        }
    }
}

protocol ProductAble {
    var product: Product { get }
}

extension Array where Element: ProductAble {
    func indexFor(product: Product?) -> Int? {
        guard let product = product else { return nil }
        for i in 0..<self.count {
            if self[i].product.objectId == product.objectId {
                return i
            }
        }
        return nil
    }
}
