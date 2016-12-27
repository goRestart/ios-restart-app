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

            setActionState(cell, completed: data.primaryActionCompleted)
            setupUserImageViews(cell, buyers: buyers)
        default:
            return
        }
    }

    private func setActionState(cell: BuyersInterestedNotificationCell, completed: Bool?) {
        let title: String
        let icon: UIImage?
        if let completed = completed where completed {
            title = LGLocalizedString.notificationsTypeBuyersInterestedButtonDone
            icon = UIImage(named: "ic_check_gray")

            cell.actionButton.layer.borderWidth = 0
            cell.actionButton.setTitleColor(UIColor.gray, forState: .Normal)

            let hSpacing: CGFloat = 5
            cell.actionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: hSpacing, bottom: 0, right: -hSpacing)
            cell.actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2*hSpacing, bottom: 0, right: 3*hSpacing)
        } else {
            title = LGLocalizedString.notificationsTypeLikeButton
            icon = nil
            cell.actionButton.setStyle(.Secondary(fontSize: .Small, withBorder: true))
        }
        cell.actionButton.setTitle(title, forState: .Normal)
        cell.actionButton.setImage(icon, forState: .Normal)
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
