import LGComponents
import IGListKit
import GoogleMobileAds

final class AdsSectionController: ListSectionController {
    
    weak var delegate: AdUpdated?
    
    private var adData: AdData?
    private var adLoader: GADAdLoader
    private var adxNativeView: UIView = NativeAdBlankStateView()
    
    private let tracker: Tracker
    private let adWidth: CGFloat
    
    init(tracker: Tracker = TrackerProxy.sharedInstance,
         adWidth: CGFloat,
         adUnitId: String,
         rootViewController: UIViewController,
         adTypes: [GADAdLoaderAdType]) {
        
        self.adWidth = adWidth
        self.tracker = tracker
        self.adLoader = GADAdLoader(adUnitID: adUnitId,
                                    rootViewController: rootViewController,
                                    adTypes: adTypes,
                                    options: nil)
        super.init()
        setupAdLoader()
    }
    
    private func setupAdLoader() {
        adLoader.delegate = self
        adLoader.load(GADRequest())
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
    
    private func updateAdView(nativeContentAd: GADNativeAd, adLoader: GADAdLoader)  {
        guard let position = adLoader.position else { return }
        nativeContentAd.delegate = self
        nativeContentAd.position = position
        
        guard let adxNativeView = GADNativeAdViewFactory.makeNativeAdView(fromContent: nativeContentAd) else { return }
        
        self.adxNativeView = adxNativeView
        updatedAdData(withView: adxNativeView)
    }
    
    private func updatedAdData(withView adView: UIView) {
        guard let adData = adData else { return }
        let adHeight = adView.viewHeightFittingIn(CGSize(width: adWidth,
                                                         height: LGUIKitConstants.advertisementCellDefaultHeight))
        self.adData = AdData.Lenses.height.set(adHeight, adData)
        delegate?.updatedAd()
    }
    
}

// MARK: - GADNativeContentAdLoaderDelegate & GADNativeAppInstallAdLoaderDelegate

extension AdsSectionController: GADNativeContentAdLoaderDelegate, GADNativeAppInstallAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
        updateAdView(nativeContentAd: nativeContentAd, adLoader: adLoader)
    }
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd) {
        updateAdView(nativeContentAd: nativeAppInstallAd, adLoader: adLoader)
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
        guard let position = nativeAd.position else { return }
        
        let trackerEvent = TrackerEvent.adTapped(listingId: nil,
                                                 adType: .adx,
                                                 isMine: .notAvailable,
                                                 queryType: nil,
                                                 query: nil,
                                                 willLeaveApp: .trueParameter,
                                                 typePage: .listingList,
                                                 categories: nil, // TODO: double check this param with money team
                                                 feedPosition: .position(index: position))
        tracker.trackEvent(trackerEvent)
    }
}

