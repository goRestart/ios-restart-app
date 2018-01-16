//
//  AdvertisementCell.swift
//  LetGo
//
//  Created by Dídac on 12/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdvertisementCell: UICollectionViewCell, ReusableCell, GADBannerViewDelegate {

    var heightDelegate: AdvertisementCellHeightDelegate?
    var cellIndex: Int?
    var banner: DFPBannerView?

    func setupWith(adData: AdvertisementData) {
        cellIndex = adData.adPosition

        if let loadedBanner = adData.bannerView {
            banner = loadedBanner as? DFPBannerView
        } else {
            banner = DFPBannerView(adSize: kGADAdSizeFluid)

            self.heightDelegate = adData.heightDelegate
            self.cellIndex = adData.adPosition

            banner?.adUnitID = adData.adUnitId
            banner?.rootViewController = adData.rootViewController

            banner?.delegate = self
            banner?.validAdSizes = [NSValueFromGADAdSize(kGADAdSizeFluid)]

            banner?.load(DFPRequest())
        }

        guard let bannerView = banner else { return }
        contentView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.layout(with: contentView).fill()
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
        banner = nil
        cellIndex = nil
        heightDelegate = nil
    }

    private func setAccessibilityIds() {
        accessibilityId = .advertisementCell
        banner?.accessibilityId = .advertisementCellBanner
    }

    
    // MARK: - GADBannerViewDelegate

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard let hDelegate = heightDelegate, let index = cellIndex else { return }
        hDelegate.updateAdCellHeight(newHeight: bannerView.frame.height, forPosition: index, withBannerView: bannerView)
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        guard let hDelegate = heightDelegate, let index = cellIndex else { return }
        hDelegate.updateAdCellHeight(newHeight: 0, forPosition: index, withBannerView: bannerView)
    }

    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        trackAdTapped()
    }

    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        trackAdTapped()
    }

    private func trackAdTapped() {
        print("AD TAPPED -> \(cellIndex)")
    }
}
