//
//  ProductCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductCellDrawer: BaseCollectionCellDrawer<ProductCell>, GridCellDrawer {
    func draw(model: ProductData, inCell cell: ProductCell) {
       
        //Disabling actions, price and stripe icon
        cell.setupActions(false, delegate: nil, indexPath: nil)
        cell.setCellWidth(cell.frame.width)
        
        if FeatureFlags.showPriceOnListings {
            cell.priceLabel.text = model.price
            cell.priceGradientView.hidden = false
        } else {
            cell.priceLabel.text = ""
            cell.priceGradientView.hidden = true
        }

        if let thumbURL = model.thumbUrl {
            cell.setImageUrl(thumbURL)
        }
    }
}
