import GoogleMobileAds
import LGCoreKit
import LGComponents

final class AdsRequester {

    static let testglKey: String = "testgl"
    static let testglDefaultValue: String = "en"
    static let adtestKey: String = "adtest"
    static let adtestValue: String = "on"
    static let adTypeKey: String = "adType"
    static let adTypeValue: String = "plas"
    static let adHeightKey: String = "height"
    static let adHeightValue: String = "200"
    static let adWidthKey: String = "width"
    
    static let fullScreenFirstAdOffset = 20
    static let fullScreenNextAdFrequency = 20

    let locale: Locale
    let featureFlags: FeatureFlaggeable
    private var indexWithAds = Set<Int>()

    var adTestModeActive: Bool {
        return EnvironmentProxy.sharedInstance.adTestModeActive
    }

    convenience init() {
        self.init(locale: Locale.current, featureFlags: FeatureFlags.sharedInstance)
    }

    init(locale: Locale, featureFlags: FeatureFlaggeable) {
        self.locale = locale
        self.featureFlags = featureFlags
    }


    // MARK: Public methods

    func makeAFShoppingRequestWithQuery(query: String?, width: CGFloat, channel: String?) -> GADDynamicHeightSearchRequest {
        let adsRequest = GADDynamicHeightSearchRequest()

        adsRequest.adTestEnabled = adTestModeActive

        if adTestModeActive {
            adsRequest.setAdvancedOptionValue(locale.languageCode ?? AdsRequester.testglDefaultValue,
                                              forKey: AdsRequester.testglKey)
            adsRequest.setAdvancedOptionValue(AdsRequester.adtestValue, forKey: AdsRequester.adtestKey)
        }

        adsRequest.query = query
        adsRequest.channel = channel

        let stringWidth = String(Int(width))

        adsRequest.setAdvancedOptionValue(AdsRequester.adTypeValue, forKey: AdsRequester.adTypeKey)
        adsRequest.setAdvancedOptionValue(AdsRequester.adHeightValue, forKey: AdsRequester.adHeightKey)
        adsRequest.setAdvancedOptionValue(stringWidth, forKey: AdsRequester.adWidthKey)

        return adsRequest
    }
    
    func createAndLoadInterstitialForUserRepository(_ myUserRepository: MyUserRepository) -> GADInterstitial? {
        let myUserCreationDate = myUserRepository.myUser?.creationDate
        guard featureFlags.fullScreenAdsWhenBrowsingForUS.shouldShowFullScreenAdsForUser(createdIn: myUserCreationDate),
            let adUnitId = featureFlags.fullScreenAdUnitId else { return nil }
        let interstitial = GADInterstitial(adUnitID: adUnitId)
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func presentInterstitial(_ interstitial: GADInterstitial?, index: Int, fromViewController: UIViewController) {
        guard let interstitial = interstitial, interstitial.isReady else { return }
        guard shouldShowInterstitialForIndex(index) else { return }
        indexWithAds.insert(index)
        interstitial.present(fromRootViewController: fromViewController)
    }
    
    func shouldShowInterstitialForIndex(_ index: Int) -> Bool {
        guard !indexWithAds.contains(index) else { return false }
        return (index - AdsRequester.fullScreenFirstAdOffset) % AdsRequester.fullScreenNextAdFrequency == 0
    }
}
