//
//  BuyersInterestedNotificationCellDrawer.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class BuyersInterestedNotificationCellDrawer: BaseNotificationCellDrawer<BuyersInterestedNotificationCell> {

    override func draw(cell: BuyersInterestedNotificationCell, data: NotificationData) {
        switch data.type {
        case let .BuyersInterested(product, buyers):
            let buyersCount = buyers.count
            if let productTitle = product.title where !productTitle.isEmpty {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeBuyersInterestedWTitle(buyersCount, productTitle)
            } else {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeBuyersInterested(buyersCount)
            }
            cell.iconImage.image = UIImage(named: "ic_user")

            let placeholder = UIImage(named: "product_placeholder")
            if let urlStr = product.image, imageUrl = NSURL(string: urlStr) {
                cell.primaryImage.lg_setImageWithURL(imageUrl, placeholderImage: placeholder)
            } else {
                cell.primaryImage.image = placeholder
            }
            cell.timeLabel.text = data.date.relativeTimeString(true)
            cell.actionButton.setTitle(LGLocalizedString.notificationsTypeLikeButton, forState: .Normal)

            setupUserImageViews(cell, buyers: buyers)
        default:
            return
        }
    }

    private func setupUserImageViews(cell: BuyersInterestedNotificationCell, buyers: [NotificationUser]) {
        for (index, imageView) in cell.userImageViews.enumerate() {
            let buyer: NotificationUser? = index < buyers.count ? buyers[index] : nil
            setupUserImageView(imageView, buyer: buyer)
        }
    }

    private func setupUserImageView(imageView: UIImageView, buyer: NotificationUser?) {
        guard let buyer = buyer else {
            imageView.image = nil
            return
        }

        let placeholder = LetgoAvatar.avatarWithID(buyer.id, name: buyer.name)
        if let urlStr = buyer.avatar, url = NSURL(string: urlStr) {
            imageView.lg_setImageWithURL(url, placeholderImage: placeholder)
        } else {
            imageView.image = placeholder
        }
    }
}
