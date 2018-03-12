//
//  AdvertisementCell.swift
//  LetGo
//
//  Created by Dídac on 12/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

class AdvertisementCell: UICollectionViewCell, ReusableCell {

    func setupWith(adData: AdvertisementData) {
        guard let bannerView = adData.bannerView else { return }
        bannerView.frame = contentView.frame
        contentView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.layout(with: contentView).fill()
        bannerView.set(accessibilityId: .advertisementCellBanner)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        resetUI()
        setAccessibilityIds()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    private func resetUI() {
        contentView.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .advertisementCell)
    }
}
