//
//  ProductCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductCellDrawer: BaseCollectionCellDrawer<ProductCell>, GridCellDrawer {
    func draw(_ model: ProductData, style: CellStyle, inCell cell: ProductCell) {
        if let thumbURL = model.thumbUrl {
            cell.setImageUrl(thumbURL)
        }
        if model.isFree {
            cell.setFreeStripe()
        }
    }
}
