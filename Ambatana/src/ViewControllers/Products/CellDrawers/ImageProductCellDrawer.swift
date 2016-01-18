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

        //Doesn't make sense to show like/chat actions if product is mine.
        cell.setupActions(showActions && !data.isMine, delegate: delegate, indexPath: data.indexPath)
        cell.priceLabel.text = data.price ?? ""
        cell.likeButton.setImage(data.isFavorite ?
            UIImage(named: "ic_product_like_on") : UIImage(named: "ic_product_like_off"),
            forState: UIControlState.Normal)

        // Thumb
        if let thumbURL = data.thumbUrl {
            cell.setImageUrl(thumbURL)
        }

        // Status (stripe info)
        switch data.status {
        case .Sold, .SoldOld:
            cell.stripeImageView.image = UIImage(named: "stripe_white")
            cell.stripeLabel.textColor = StyleHelper.soldColor
            cell.stripeLabel.text = LGLocalizedString.productListItemSoldStatusLabel.capitalizedString
            cell.stripeIcon.image = UIImage(named: "ic_sold_stripe")

        case .Pending, .Approved, .Discarded, .Deleted:
            if let createdAt = data.date where
                NSDate().timeIntervalSinceDate(createdAt) < Constants.productListNewLabelThreshold {
                    cell.stripeImageView.image = UIImage(named: "stripe_white")
                    cell.stripeLabel.textColor = StyleHelper.primaryColor
                    cell.stripeLabel.text = createdAt.simpleTimeStringForDate()
                    cell.stripeIcon.image = UIImage(named: "ic_new_stripe")
            }
        }
    }
}