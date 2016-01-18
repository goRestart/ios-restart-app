//
//  ImageProductCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

class ImageProductCellDrawer: BaseCollectionCellDrawer<ProductCell>, ProductCellDrawer {

    private let showActions: Bool

    init(showActions: Bool) {
        self.showActions = showActions
    }

    func cellHeightForThumbnailHeight(height: CGFloat) -> CGFloat {
        return showActions ? height + ProductCell.buttonsContainerShownHeight : height
    }

    func draw(collectionCell: UICollectionViewCell, data: ProductCellData) {
        draw(collectionCell, data: data, delegate: nil)
    }

    func draw(collectionCell: UICollectionViewCell, data: ProductCellData, delegate: ProductCellDelegate?) {
        guard let cell = collectionCell as? ProductCell else { return }
        cell.setCellWidth(data.cellWidth)
        cell.setupActions(showActions, delegate: delegate, indexPath: data.indexPath)
        cell.priceLabel.text = data.price ?? ""
        cell.likeButton.setImage(data.isFavorite ?
            UIImage(named: "ic_product_like_on") : UIImage(named: "ic_product_like_off"),
            forState: UIControlState.Normal)
        cell.likeButton.enabled = !data.isMine
        
        // Thumb
        if let thumbURL = data.thumbUrl {
            cell.setImageUrl(thumbURL)
        }

        // Status (stripe)
        switch data.status {
        case .Sold, .SoldOld:
            cell.stripeImageView.image = UIImage(named: "stripe_sold")
            cell.stripeLabel.text = LGLocalizedString.productListItemSoldStatusLabel
            cell.chatButton.enabled = false

        case .Pending, .Approved, .Discarded, .Deleted:
            if let createdAt = data.date where
                NSDate().timeIntervalSinceDate(createdAt) < Constants.productListNewLabelThreshold {
                    cell.stripeImageView.image = UIImage(named: "stripe_new")
                    cell.stripeLabel.text = LGLocalizedString.productListItemNewStatusLabel
            }
            cell.chatButton.enabled = !data.isMine
        }
    }
}