import GoogleMobileAds

final class GADNativeAdViewFactory {
    
    static func makeNativeAdView(fromNativeAd nativeAd: Any) -> UIView? {
        if let nativeContentAd = nativeAd as? GADNativeContentAd {
            let adxNativeContentView = GoogleAdxNativeContentView()
            adxNativeContentView.nativeContentAd = nativeContentAd
            return adxNativeContentView
        } else if let nativeAppInstallAd = nativeAd as? GADNativeAppInstallAd {
            let adxNativeAppInstallView = GoogleAdxNativeAppInstallView()
            adxNativeAppInstallView.nativeAppInstallAd = nativeAppInstallAd
            return adxNativeAppInstallView
        } else if let unifiedAd = nativeAd as? GADUnifiedNativeAd {
            let adxNativeUnifiedView = GoogleAdxNativeUnifiedView()
            adxNativeUnifiedView.nativeAd = unifiedAd
            return adxNativeUnifiedView
        }
        return nil
    }
    
}
