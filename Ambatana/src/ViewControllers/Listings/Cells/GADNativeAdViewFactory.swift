import GoogleMobileAds

final class GADNativeAdViewFactory {
    
    static func makeNativeAdView(fromContent nativeContentAd: GADNativeAd) -> UIView? {
        if let nativeContentAd = nativeContentAd as? GADNativeContentAd {
            let adxNativeContentView = GoogleAdxNativeContentView()
            adxNativeContentView.nativeContentAd = nativeContentAd
            return adxNativeContentView
        } else if let nativeAppInstallAd = nativeContentAd as? GADNativeAppInstallAd {
            let adxNativeAppInstallView = GoogleAdxNativeAppInstallView()
            adxNativeAppInstallView.nativeAppInstallAd = nativeAppInstallAd
            return adxNativeAppInstallView
        }
        return nil
    }
    
}
