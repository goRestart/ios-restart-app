import LGComponents
import UIKit
import MoPub

final class MoPubAdsRequester {
    
    static func startMoPubRequestWith(data: AdvertisementMoPubData, completion: @escaping (MPNativeAd?, UIView?) -> Void) {
        guard let request = data.nativeAdRequest else { return }
        request.start { (moPub, response, error) in
            if let error = error {
                logMessage(.error, type: .monetization, message: "Error loading MoPub: \(error)")
                completion(nil, NativeAdBlankStateView())
            } else {
                if let nativeAd = response {
                    do {
                        let advertView = try nativeAd.retrieveAdView()
                        completion(nativeAd, advertView)
                    } catch {
                        logMessage(.error, type: .monetization, message: "Error retreiving advert view: \(error)")
                        completion(nativeAd, NativeAdBlankStateView())
                    }
                }
            }
        }
    }

}
