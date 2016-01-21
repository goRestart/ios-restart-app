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

        cell.likeButtonEnabled = !data.isMine
        let likeButtonImage: UIImage?
        if cell.likeButtonEnabled {
            likeButtonImage = data.isFavorite ?
                UIImage(named: "ic_product_like_on") : UIImage(named: "ic_product_like_off")
            
        } else {
            likeButtonImage = UIImage(named: "ic_product_like_disabled")
        }
        cell.likeButton.setImage(likeButtonImage, forState: .Normal)
        
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
            cell.chatButtonEnabled = false

        case .Pending, .Approved, .Discarded, .Deleted:
            if let createdAt = data.date where
                NSDate().timeIntervalSinceDate(createdAt) < Constants.productListNewLabelThreshold {
                    cell.stripeImageView.image = UIImage(named: "stripe_white")
                    cell.stripeLabel.textColor = StyleHelper.primaryColor
                    cell.stripeLabel.text = createdAt.simpleTimeStringForDate()
                    cell.stripeIcon.image = UIImage(named: "ic_new_stripe")
            }
            cell.chatButtonEnabled = !data.isMine
        }
        
        let chatButtonImage: UIImage?
        if cell.chatButtonEnabled {
            chatButtonImage = UIImage(named: "ic_product_chat")
        } else {
            chatButtonImage = UIImage(named: "ic_product_chat_disabled")
        }
        cell.chatButton.setImage(chatButtonImage, forState: .Normal)
    }
}