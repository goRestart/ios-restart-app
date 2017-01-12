//
//  BuyersInterestedNotificationCellDrawer.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class BuyersInterestedNotificationCellDrawer: BaseNotificationCellDrawer<BuyersInterestedNotificationCell> {

    override func draw(_ cell: BuyersInterestedNotificationCell, data: NotificationData) {
        switch data.type {
        case let .buyersInterested(product, buyers):
            let buyersCount = buyers.count
            if let productTitle = product.title, !productTitle.isEmpty {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeBuyersInterestedWTitle(buyersCount, productTitle)
            } else {
                cell.actionLabel.text = LGLocalizedString.notificationsTypeBuyersInterested(buyersCount)
            }
            cell.iconImage.image = UIImage(named: "ic_user")

            let placeholder = UIImage(named: "product_placeholder")
            if let urlStr = product.image, let imageUrl = URL(string: urlStr) {
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

    private func setActionState(_ cell: BuyersInterestedNotificationCell, completed: Bool?) {
        let title: String
        let icon: UIImage?
        if let completed = completed, completed {
            title = LGLocalizedString.notificationsTypeBuyersInterestedButtonDone
            icon = UIImage(named: "ic_check_gray")

            cell.actionButton.layer.borderWidth = 0
            cell.actionButton.setTitleColor(UIColor.gray, for: .normal)

            let hSpacing: CGFloat = 5
            cell.actionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: hSpacing, bottom: 0, right: -hSpacing)
            cell.actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2*hSpacing, bottom: 0, right: 3*hSpacing)
        } else {
            title = LGLocalizedString.notificationsTypeBuyersInterestedButton
            icon = nil
            cell.actionButton.setStyle(.secondary(fontSize: .small, withBorder: true))
        }
        cell.actionButton.setTitle(title, for: .normal)
        cell.actionButton.setImage(icon, for: .normal)
    }

    private func setupUserImageViews(_ cell: BuyersInterestedNotificationCell, buyers: [NotificationUser]) {
        for (index, imageView) in cell.userImageViews.enumerated() {
            let buyer: NotificationUser? = index < buyers.count ? buyers[index] : nil
            setupUserImageView(imageView, buyer: buyer)
        }
    }

    private func setupUserImageView(_ imageView: UIImageView, buyer: NotificationUser?) {
        guard let buyer = buyer else {
            imageView.image = nil
            return
        }

        let placeholder = LetgoAvatar.avatarWithID(buyer.id, name: buyer.name)
        if let urlStr = buyer.avatar, let url = URL(string: urlStr) {
            imageView.lg_setImageWithURL(url, placeholderImage: placeholder)
        } else {
            imageView.image = placeholder
        }
    }
}
