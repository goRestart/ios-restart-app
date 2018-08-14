import LGComponents
import AppsFlyerLib
import Foundation
import RxSwift
import Branch
import LGCoreKit

protocol DeepLinksRouter: class, AppsFlyerTrackerDelegate {
    var deepLinks: Observable<DeepLink> { get }
    var chatDeepLinks: Observable<DeepLink> { get }

    var initialDeeplinkAvailable: Bool { get }
    func consumeInitialDeepLink() -> DeepLink?

    func initWithLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    func performActionForShortcutItem(_ shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void)
    func openUrl(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool
    func continueUserActivity(_ userActivity: NSUserActivity, restorationHandler: ([Any]?) -> Void) -> Bool
    func deepLinkFromBranchObject(_ object: BranchUniversalObject?, properties: BranchLinkProperties?)
    @discardableResult
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], applicationState: UIApplicationState)
        -> PushNotification?
    func handleActionWithIdentifier(_ identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any],
                                    completionHandler: () -> Void)
}

class LGDeepLinksRouter: NSObject, DeepLinksRouter {
    private struct AppInstallKeys {
        struct Campaigns {
            static let facebook = "adgroup"
            static let other = "af_sub3"
        }

        struct Provider {
            static let appsflyer = "Appsflyer"
        }

        static let isFacebook = "is_fb"
        static let category = "-Category-"
        static let search = "-Search-"
        static let listing = "-Product-"
    }

    static let sharedInstance: LGDeepLinksRouter = LGDeepLinksRouter()

    var deepLinks: Observable<DeepLink> {
        return deepLinksSignal.asObservable()
    }

    /// Helper filtering .conversations, .conversation and .message
    var chatDeepLinks: Observable<DeepLink> {
        return deepLinks.filter { deepLink in
            switch deepLink.action {
            case .conversations, .conversation, .message:
                return true
            default:
                return false
            }
        }
    }

    private let deepLinksSignal = PublishSubject<DeepLink>()

    private var initialDeepLink: DeepLink?

    // MARK: - Public methods

    var initialDeeplinkAvailable: Bool { return initialDeepLink != nil }

    func consumeInitialDeepLink() -> DeepLink? {
        let result = initialDeepLink
        initialDeepLink = nil
        return result
    }

    // MARK: > Init

    func initWithLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let launchOptions = launchOptions else { return false }

        let shortcut = checkInitShortcutAction(launchOptions)
        let uriScheme = checkInitUriScheme(launchOptions)
        let universalLink = checkInitUniversalLink(launchOptions)
        let pushNotification = checkInitPushNotification(launchOptions)

        return shortcut || uriScheme || universalLink || pushNotification
    }

    // MARK: > Appsflyer

    func onConversionDataReceived(_ installData: [AnyHashable : Any]!) {
        guard let deferredDeepLink = buildFromConversionData(installData) else { return }
        initialDeepLink = deferredDeepLink
    }

    func onConversionDataRequestFailure(_ error: Error!) {
        logMessage(.error, type: [.deepLink], message: "App install conversion failed")
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]!) {
        guard let deeplink = AppsFlyerDeepLink.buildFromAttributionData(attributionData) else { return }
        deepLinksSignal.onNext(deeplink)
    }
    
    func onAppOpenAttributionFailure(_ error: Error!) {
        logMessage(.error, type: [.deepLink], message: "App opening from AppsFlyer link failed")
    }

    // MARK: > Shortcut actions (force touch)

    func performActionForShortcutItem(_ shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        guard let shortCut = ShortcutItem.buildFromUIApplicationShortcutItem(shortcutItem) else { return }
        deepLinksSignal.onNext(shortCut.deepLink)
    }

    // MARK: > Uri schemes

    func openUrl(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        // If branch handles the deeplink we don't need to do anything as we will get the branch object through their callback
        if Branch.getInstance().handleDeepLink(url) { return true }

        guard let uriScheme = UriScheme.buildFromUrl(url) else { return false }
        deepLinksSignal.onNext(uriScheme.deepLink)
        return true
    }

    // MARK: > Universal links

    func continueUserActivity(_ userActivity: NSUserActivity, restorationHandler: ([Any]?) -> Void) -> Bool {
        logMessage(.verbose, type: AppLoggingOptions.deepLink, message: "Continue user activity: \(String(describing: userActivity.webpageURL))")
        if let appsflyerDeepLink = AppsFlyerDeepLink.buildFromUserActivity(userActivity) {
            deepLinksSignal.onNext(appsflyerDeepLink.deepLink)
            return true
        }

        if Branch.getInstance().continue(userActivity) { return true }
        
        if let url = userActivity.webpageURL, appShouldOpenInBrowser(url: url) {
            UIApplication.shared.openURL(url)
            return false
        }

        guard let universalLink = UniversalLink.buildFromUserActivity(userActivity) else {
            // Branch sometimes fails to return true for their own user activity so we return true for app.letgo.com links
            return UniversalLink.isBranchDeepLink(userActivity)
        }
        deepLinksSignal.onNext(universalLink.deepLink)
        return true
    }
    
    /// There are universal link exceptions. Some should not be handled in the app. Instead we
    /// open them back in the browser.
    func appShouldOpenInBrowser(url: URL) -> Bool {
        guard let host = url.host else { return false }
        let openInBrowserUrls = ["jobs.letgo.com", "we.letgo.com"]
        return openInBrowserUrls.contains(host)
    }

    // MARK: > Branch.io

    func deepLinkFromBranchObject(_ object: BranchUniversalObject?, properties: BranchLinkProperties?) {
        logMessage(.verbose, type: .deepLink, message: "received branch Object \(String(describing: object))")
        guard let branchDeepLink = object?.deepLinkWithProperties(properties) else { return }
        logMessage(.verbose, type: .deepLink, message: "Resolved branch Object \(branchDeepLink.action)")
        deepLinksSignal.onNext(branchDeepLink)
    }

    // MARK: > Push Notifications

    @discardableResult func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], applicationState: UIApplicationState)
        -> PushNotification? {
            guard let pushNotification = PushNotification.buildFromUserInfo(userInfo,
                                                appActive: applicationState == .active) else { return nil }
            deepLinksSignal.onNext(pushNotification.deepLink)
            return pushNotification
    }

    func handleActionWithIdentifier(_ identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any],
        completionHandler: () -> Void) {
            //No actions implemented
    }


    // MARK: - Private methods

    private func checkInitShortcutAction(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]) -> Bool {
        guard let _ = ShortcutItem.buildFromLaunchOptions(launchOptions) else { return false }
        return true
    }

    private func checkInitUriScheme(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]) -> Bool {
        guard let _ = UriScheme.buildFromLaunchOptions(launchOptions) else { return false }
        return true
    }

    private func checkInitUniversalLink(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]) -> Bool {
        return launchOptions[UIApplicationLaunchOptionsKey.userActivityDictionary] != nil
    }

    private func checkInitPushNotification(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]) -> Bool {
        guard let pushNotification = PushNotification.buildFromLaunchOptions(launchOptions) else { return false }
        initialDeepLink = pushNotification.deepLink
        return true
    }

    private func buildFromConversionData(_ installData: [AnyHashable : Any]?) -> DeepLink? {
        guard let data = installData else { return nil }
        if let isFacebook = data[AppInstallKeys.isFacebook] as? Bool, isFacebook {
            return buildFromAppInstall(data, withCampaignID: AppInstallKeys.Campaigns.facebook)
        }
        return buildFromAppInstall(data, withCampaignID: AppInstallKeys.Campaigns.other)
    }

    private func buildFromAppInstall(_ installData: [AnyHashable : Any], withCampaignID campaignID: String) -> DeepLink? {
        guard let campaign = installData[campaignID] as? String else { return nil }

        let splittedCategory = campaign.components(separatedBy: AppInstallKeys.category)
        if splittedCategory.count == 2, let category = splittedCategory.last {
            return DeepLink.appInstall(.search(query: "",
                                               categories: category,
                                               distanceRadius: nil,
                                               sortCriteria: nil,
                                               priceFlag: nil,
                                               minPrice: nil,
                                               maxPrice: nil),
                                       source: .external(source: AppInstallKeys.Provider.appsflyer))
        }
        let splittedSearch = campaign.components(separatedBy: AppInstallKeys.search)
        if splittedSearch.count == 2, let queryString = splittedSearch.last {
            return DeepLink.appInstall(.search(query: queryString,
                                               categories: nil,
                                               distanceRadius: nil,
                                               sortCriteria: nil,
                                               priceFlag: nil,
                                               minPrice: nil,
                                               maxPrice: nil),
                                       source: .external(source: AppInstallKeys.Provider.appsflyer))
        }
        let splittedListing = campaign.components(separatedBy: AppInstallKeys.listing)
        if splittedListing.count == 2, let listing = splittedListing.last {
            return DeepLink.appInstall(.listing(listingId: listing),
                                       source: .external(source: AppInstallKeys.Provider.appsflyer))
        }
        return nil
    }
}
