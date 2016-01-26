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
        cell.stripeIcon.image = nil
        cell.stripeIconWidth.constant = 0
        
        // Thumb
        if let thumbURL = data.thumbUrl {
            cell.setImageUrl(thumbURL)
        }

        // Status (stripe info)
        switch data.status {
        case .Sold, .SoldOld:
            cell.stripeImageView.image = UIImage(named: "stripe_turquoise")
            cell.stripeLabel.textColor = UIColor.whiteColor()
            cell.stripeLabel.text = LGLocalizedString.productListItemSoldStatusLabel
        case .Pending, .Approved, .Discarded, .Deleted:
            if let createdAt = data.date where
                NSDate().timeIntervalSinceDate(createdAt) < Constants.productListNewLabelThreshold {
                    cell.stripeImageView.image = UIImage(named: "stripe_red")
                    cell.stripeLabel.textColor = UIColor.whiteColor()
                    cell.stripeLabel.text = LGLocalizedString.productListItemNewStatusLabel
            }
        }
    }
}