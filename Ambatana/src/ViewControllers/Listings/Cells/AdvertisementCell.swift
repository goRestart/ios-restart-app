//
//  AdvertisementCell.swift
//  LetGo
//
//  Created by Dídac on 12/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit
import GoogleMobileAds

class AdvertisementCell: UICollectionViewCell, ReusableCell, GADBannerViewDelegate, GADAdSizeDelegate {

    let customTargetingKey = "pos_var"

    var delegate: AdvertisementCellDelegate?
    var cellIndex: Int?
    var banner: DFPBannerView?
    var categories: [ListingCategory]?

    func setupWith(adData: AdvertisementData) {
        cellIndex = adData.adPosition
        categories = adData.categories
        delegate = adData.delegate

        if let loadedBanner = adData.bannerView {
            banner = loadedBanner as? DFPBannerView
        } else {
            banner = DFPBannerView(adSize: kGADAdSizeFluid)

            banner?.adUnitID = adData.adUnitId
            banner?.rootViewController = adData.rootViewController
            banner?.adSizeDelegate = self
            banner?.frame = contentView.frame

            banner?.delegate = self
            banner?.validAdSizes = [NSValueFromGADAdSize(kGADAdSizeFluid)]

            let request = DFPRequest()
            let customTargetingValue = adData.showAdsInFeedWithRatio.customTargetingValueFor(position: adData.adPosition)
            request.customTargeting = [customTargetingKey: customTargetingValue]
            banner?.load(request)
            banner?.tag = adData.adPosition
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
        delegate = nil
        categories = nil
    }

    private func setAccessibilityIds() {
        accessibilityId = .advertisementCell
        banner?.accessibilityId = .advertisementCellBanner
    }

    
    // MARK: - GADBannerViewDelegate

    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        delegate?.updateAdCellHeight(newHeight: size.size.height, forPosition: bannerView.tag, withBannerView: bannerView)
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) { }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.info, type: .monetization, message: "Feed banner in position \(bannerView.tag) failed with error: \(error.localizedDescription)")
        delegate?.updateAdCellHeight(newHeight: 0, forPosition: bannerView.tag, withBannerView: bannerView)
    }

    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        var feedPosition: EventParameterFeedPosition = .none
        if let index = cellIndex {
            feedPosition = .position(index: index)
        }
        delegate?.bannerWasTapped(adType: .dfp,
                                  willLeaveApp: .falseParameter,
                                  categories: categories,
                                  feedPosition: feedPosition)
    }

    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        var feedPosition: EventParameterFeedPosition = .none
        if let index = cellIndex {
            feedPosition = .position(index: index)
        }
        delegate?.bannerWasTapped(adType: .dfp,
                                  willLeaveApp: .trueParameter,
                                  categories: categories,
                                  feedPosition: feedPosition)
    }
}
