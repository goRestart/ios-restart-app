import AppsFlyerLib
import LGCoreKit
import LGComponents

fileprivate extension TrackerEvent {
    var shouldTrack: Bool {
        switch name {
        case .loginFB, .loginEmail, .loginGoogle, .signupEmail, .firstMessage,
             .listingMarkAsSold, .listingSellStart, .listingSellComplete, .sessionOneMinuteFirstWeek,
             .listingDetailVisit, .searchComplete, .phoneNumberSent, .listingDetailCall,
             .buyer24h, .buyerLister24h, .lister24h:
            return true
        default:
            return false
        }
    }
}

final class AppsflyerTracker: Tracker {
    
    // MARK: - Tracker
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
                     featureFlags: FeatureFlaggeable) {
        AppsFlyerTracker.shared().appsFlyerDevKey = EnvironmentProxy.sharedInstance.appsFlyerAPIKey
        AppsFlyerTracker.shared().appleAppID = EnvironmentProxy.sharedInstance.appsFlyerAppleAppId
        AppsFlyerTracker.shared().appInviteOneLinkID = EnvironmentProxy.sharedInstance.appsFlyerAppInviteOneLinkID
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerTracker.shared().trackAppLaunch()
    }

    func setInstallation(_ installation: Installation?) { }

    func setUser(_ user: MyUser?) {
        guard let user = user else { return }

        let tracker = AppsFlyerTracker.shared()
        if let email = user.email {
            tracker?.setUserEmails([email], with: EmailCryptTypeSHA1)
        }
        AppsFlyerTracker.shared().customerUserID = user.objectId
    }
    
    func trackEvent(_ event: TrackerEvent) {
        guard event.shouldTrack else { return }
        let tracker = AppsFlyerTracker.shared()
        tracker?.trackEvent(event.actualName,
                            withValues: event.params?.stringKeyParams)
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) { }
    func setNotificationsPermission(_ enabled: Bool) {}
    func setGPSPermission(_ enabled: Bool) {}
    func setMarketingNotifications(_ enabled: Bool) {}
}
