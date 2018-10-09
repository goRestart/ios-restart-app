import LGComponents
import IGListKit
import GoogleMobileAds

final class AdsSectionController: ListSectionController {
    
    weak var delegate: AdUpdated?
    weak var unifiedAdsDelegate: GADUnifiedNativeAdDelegate?
    
    private var adData: AdData?
    private var adLoader: GADAdLoader
    private var adxNativeView: UIView = NativeAdBlankStateView()
    private let rootViewController: UIViewController
    private let bidder: PMBidder?
    private let tracker: Tracker
    private let adWidth: CGFloat
    
    init(tracker: Tracker = TrackerProxy.sharedInstance,
         adWidth: CGFloat,
         adUnitId: String,
         rootViewController: UIViewController,
         adTypes: [GADAdLoaderAdType],
         bidder: PMBidder?) {
        
        self.adWidth = adWidth
        self.tracker = tracker
        self.rootViewController = rootViewController
        self.bidder = bidder
        self.adLoader = GADAdLoader(adUnitID: adUnitId,
                                    rootViewController: rootViewController,
                                    adTypes: adTypes,
                                    options: nil)
        super.init()
        setupAdLoader()
    }
    
    private func setupAdLoader() {
        adLoader.delegate = self
        if let bidder = self.bidder {
            bidder.start(with: adLoader, viewController: rootViewController)
        } else {
            adLoader.load(GADRequest())
        }
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let adHeight = adData?.height else { return CGSize(width: adWidth, height: 0) }
        return CGSize(width: adWidth, height: adHeight)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: AdvertisementCell.self,
                                                                for: self,
                                                                at: index) as? AdvertisementCell else {
                                                                    fatalError("Cannot dequeue AdvertisementCell")
        }
        cell.setupWith(adContentView: adxNativeView)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        if let diffWrapper = object as? DiffableBox<AdData> {
            adData = diffWrapper.value
        }
    }
    
    private func updateAdView(nativeAd: Any)  {
        guard let adxNativeView = GADNativeAdViewFactory.makeNativeAdView(fromNativeAd: nativeAd) else { return }
        self.adxNativeView = adxNativeView
        updatedAdData(withView: adxNativeView)
    }
    
    private func updatedAdData(withView adView: UIView) {
        guard let adData = adData else { return }
        let adHeight = adView.viewHeightFittingIn(CGSize(width: adWidth,
                                                         height: LGUIKitConstants.advertisementCellDefaultHeight))
        self.adData = AdData.Lenses.height.set(adHeight, adData)
        delegate?.updatedAd(isBannerSection: false)
    }
    
}

// MARK: - GADNativeContentAdLoaderDelegate & GADNativeAppInstallAdLoaderDelegate

extension AdsSectionController: GADNativeContentAdLoaderDelegate, GADNativeAppInstallAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
        nativeContentAd.delegate = self
        updateAdView(nativeAd: nativeContentAd)
    }
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd) {
        nativeAppInstallAd.delegate = self
        updateAdView(nativeAd: nativeAppInstallAd)
    }
}

//  MARK: - GADAdLoaderDelegate

extension AdsSectionController: GADAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.info, type: .monetization, message: "Google Adx failed with error: \(error.localizedDescription)")
    }
}

//  MARK: - GADNativeAdDelegate

extension AdsSectionController: GADNativeAdDelegate {
    public func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        guard let position = adData?.adPosition else { return }
        var adType = EventParameterAdType.adx
        if let extraAssets = nativeAd.extraAssets,
            let network = extraAssets[SharedConstants.adNetwork] as? String,
            network == EventParameterAdType.polymorph.stringValue {
            adType = .polymorph
        }
        
        let trackerEvent = TrackerEvent.adTapped(listingId: nil,
                                                 adType: adType,
                                                 isMine: .notAvailable,
                                                 queryType: nil,
                                                 query: nil,
                                                 willLeaveApp: .trueParameter,
                                                 hasVideoContent: nil,
                                                 typePage: .listingList,
                                                 categories: nil, // TODO: double check this param with money team
                                                 feedPosition: .position(index: position))
        tracker.trackEvent(trackerEvent)
    }
}

// MARK: - GADUnifiedNativeAdLoaderDelegate

extension AdsSectionController: GADUnifiedNativeAdLoaderDelegate {
    
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        nativeAd.position = adData?.adPosition
        nativeAd.delegate = unifiedAdsDelegate
        updateAdView(nativeAd: nativeAd)
    }
}
