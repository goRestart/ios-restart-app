import LGComponents
import IGListKit
import GoogleMobileAds

final class BannerSectionController: ListSectionController {
    
    weak var delegate: AdUpdated?
    
    private let tracker: Tracker
    private var adData: AdData?
    private var adWidth: CGFloat = 0
    private var bannerView: GADBannerView =  {
        let banner = DFPBannerView(adSize: kGADAdSizeLargeBanner)
        var adSizes = [NSValue]()
        adSizes.append(NSValueFromGADAdSize(kGADAdSizeBanner))
        adSizes.append(NSValueFromGADAdSize(kGADAdSizeMediumRectangle))
        adSizes.append(NSValueFromGADAdSize(kGADAdSizeLargeBanner))
        banner.validAdSizes = adSizes
        return banner
    }()
    
    init(tracker: Tracker = TrackerProxy.sharedInstance, adUnitId: String, rootViewController: UIViewController) {
        self.tracker = tracker
        self.bannerView.rootViewController = rootViewController
        self.bannerView.adUnitID = adUnitId
        super.init()
        loadDFPRequest()
    }
    
    private func loadDFPRequest() {
        bannerView.delegate = self
        bannerView.adSizeDelegate = self
        bannerView.load(DFPRequest())
    }

    override func sizeForItem(at index: Int) -> CGSize {
        adWidth = collectionContext?.containerSize.width ?? 0
        guard let adHeight = adData?.height else { return CGSize(width: adWidth, height: 0) }
        return CGSize(width: adWidth, height: adHeight)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: AdvertisementCell.self,
                                                                for: self,
                                                                at: index) as? AdvertisementCell else {
                                                                    fatalError("Cannot dequeue AdvertisementCell")
        }
        cell.setupWith(bannerView: bannerView)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        if let diffWrapper = object as? DiffableBox<AdData> {
            adData = diffWrapper.value
        }
    }

    private func updatedAdData(withSize size: CGSize) {
        guard let adData = adData else { return }
        self.adData = AdData.Lenses.height.set(size.height, adData)
        delegate?.updatedAd(isBannerSection: true)
    }
}

// MARK: - GADAdSizeDelegate, GADBannerViewDelegate
extension BannerSectionController: GADAdSizeDelegate, GADBannerViewDelegate {
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        let sizeFromAdSize = CGSizeFromGADAdSize(size)
        logMessage(.info, type: .monetization, message: "Banner Section new size: \(sizeFromAdSize)")
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        logMessage(.info, type: .monetization, message: "Banner Section banner received: \(bannerView)")
        let bannerSize = bannerView.adSize.size

        updatedAdData(withSize: bannerSize)

        let adType = AdRequestType.dfp.trackingParamValueFor(size: bannerSize)
        let trackerEvent = TrackerEvent.adShown(listingId: nil,
                                                adType: adType,
                                                isMine: .notAvailable,
                                                queryType: nil,
                                                query: nil,
                                                adShown: .trueParameter,
                                                typePage: .feed,
                                                categories: nil,
                                                feedPosition: .none)
        tracker.trackEvent(trackerEvent)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.info, type: .monetization, message: "Banner Section banner failed with error: \(error.localizedDescription)")
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        logMessage(.info, type: .monetization, message: "Banner Section banner tapped: \(bannerView)")
        let bannerSize = bannerView.adSize.size
        let adType = AdRequestType.dfp.trackingParamValueFor(size: bannerSize)
        let trackerEvent = TrackerEvent.adTapped(listingId: nil,
                                                 adType: adType,
                                                 isMine: .notAvailable,
                                                 queryType: nil,
                                                 query: nil,
                                                 willLeaveApp: .trueParameter,
                                                 typePage: .feed,
                                                 categories: nil, feedPosition: .none)
        tracker.trackEvent(trackerEvent)
    }
}
