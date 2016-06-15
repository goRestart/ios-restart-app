//
//  ImageProductCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

class ImageProductCellDrawer: BaseCollectionCellDrawer<ProductCell>, ProductCellDrawer {

    func cellHeightForThumbnailHeight(height: CGFloat) -> CGFloat {
        return height
    }

    func draw(collectionCell: UICollectionViewCell, data: ProductCellData) {
        draw(collectionCell, data: data, delegate: nil)
    }

    func draw(collectionCell: UICollectionViewCell, data: ProductCellData, delegate: ProductCellDelegate?) {
        guard let cell = collectionCell as? ProductCell else { return }
        cell.setCellWidth(data.cellWidth)

        //Disabling actions, price and stripe icon
        cell.setupActions(false, delegate: nil, indexPath: data.indexPath)
        cell.priceLabel.text = ""
        cell.priceGradientView.hidden = true
        
        // Thumb
        if let thumbURL = data.thumbUrl {
            cell.setImageUrl(thumbURL)
        }
    }
}