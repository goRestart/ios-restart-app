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

    func setupWith(dfpData: AdvertisementDFPData) {
        guard let bannerView = dfpData.bannerView else { return }
        bannerView.frame = contentView.frame
        contentView.addSubviewForAutoLayout(bannerView)
        bannerView.layout(with: contentView).fill()
        bannerView.set(accessibilityId: .advertisementCellBanner)
    }
    
    func setupWith(moPubData: AdvertisementMoPubData) {
        guard let moPubView = moPubData.moPubView else { return }
        moPubView.frame = contentView.frame
        contentView.addSubviewForAutoLayout(moPubView)
        moPubView.layout(with: contentView).fill()
        moPubView.set(accessibilityId: .advertisementCellBanner)
    }
    
    func setupWith(adxData: AdvertisementAdxData) {
        guard let adxNativeView = adxData.adxNativeView else { return }
        setupWith(adContentView: adxNativeView)
    }
    
    func setupWith(adContentView: UIView) {
        contentView.addSubviewForAutoLayout(adContentView)
        adContentView.frame = contentView.frame
        adContentView.layout(with: contentView).fill()
        adContentView.set(accessibilityId: .advertisementCellBanner)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        resetUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
