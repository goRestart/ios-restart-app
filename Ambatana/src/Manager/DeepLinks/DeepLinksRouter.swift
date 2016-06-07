//
//  DeepLinksManager.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import Branch

class DeepLinksRouter {
    static let sharedInstance: DeepLinksRouter = DeepLinksRouter()

    let deepLinks = PublishSubject<DeepLink>()

    /// Helper filtering .Conversations, .Conversation and .Message
    var chatDeepLinks: Observable<DeepLink> {
        return deepLinks.asObservable().filter { deepLink in
            switch deepLink.action {
            case .Conversations, .Conversation, .Message:
                return true
            default:
                return false
            }
        }
    }

    private var initialDeepLink: DeepLink?

    // MARK: - Public methods

    func consumeInitialDeepLink() -> DeepLink? {
        let result = initialDeepLink
        initialDeepLink = nil
        return result
    }

    // MARK: > Init

    func initWithLaunchOptions(launchOptions: [NSObject: AnyObject]?) -> Bool {
        guard let launchOptions = launchOptions else { return false }

        let shortcut = checkInitShortcutAction(launchOptions)
        let uriScheme = checkInitUriScheme(launchOptions)
        let universalLink = checkInitUniversalLink(launchOptions)
        let pushNotification = checkInitPushNotification(launchOptions)

        return shortcut || uriScheme || universalLink || pushNotification
    }

    // MARK: > Shortcut actions (force touch)

    @available(iOS 9.0, *)
    func performActionForShortcutItem(shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        guard let shortCut = ShortcutItem.buildFromUIApplicationShortcutItem(shortcutItem) else { return }
        deepLinks.onNext(shortCut.deepLink)
    }

    // MARK: > Uri schemes

    func openUrl(url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        // If branch handles the deeplink we don't need to do anything as we will get the branch object through their callback
        if Branch.getInstance().handleDeepLink(url) { return true }

        guard let uriScheme = UriScheme.buildFromUrl(url) else { return false }
        deepLinks.onNext(uriScheme.deepLink)
        return true
    }

    // MARK: > Universal links

    func continueUserActivity(userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        logMessage(.Verbose, type: AppLoggingOptions.DeepLink, message: "Continue user activity: \(userActivity.webpageURL)")
        if let appsflyerDeepLink = AppsFlyerDeepLink.buildFromUserActivity(userActivity) {
            deepLinks.onNext(appsflyerDeepLink.deepLink)
            return true
        }

        if Branch.getInstance().continueUserActivity(userActivity) { return true }

        guard let universalLink = UniversalLink.buildFromUserActivity(userActivity) else {
            // Branch sometimes fails to return true for their own user activity so we return true for app.letgo.com links
            return UniversalLink.isBranchDeepLink(userActivity)
        }
        deepLinks.onNext(universalLink.deepLink)
        return true
    }

    // MARK: > Branch.io

    func deepLinkFromBranchObject(object: BranchUniversalObject?, properties: BranchLinkProperties?) {
        logMessage(.Verbose, type: .DeepLink, message: "received branch Object \(object)")
        guard let branchDeepLink = object?.deepLinkWithProperties(properties) else { return }
        logMessage(.Verbose, type: .DeepLink, message: "Resolved branch Object \(branchDeepLink.action)")
        deepLinks.onNext(branchDeepLink)
    }

    // MARK: > Push Notifications

    func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject], applicationState: UIApplicationState)
        -> PushNotification? {
            guard let pushNotification = PushNotification.buildFromUserInfo(userInfo,
                                                appActive: applicationState == .Active) else { return nil }
            deepLinks.onNext(pushNotification.deepLink)
            return pushNotification
    }

    func handleActionWithIdentifier(identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject],
        completionHandler: () -> Void) {
            //No actions implemented
    }


    // MARK: - Private methods

    private func checkInitShortcutAction(launchOptions: [NSObject: AnyObject]) -> Bool {
        guard let _ = ShortcutItem.buildFromLaunchOptions(launchOptions) else { return false }
        return true
    }

    private func checkInitUriScheme(launchOptions: [NSObject: AnyObject]) -> Bool {
        guard let _ = UriScheme.buildFromLaunchOptions(launchOptions) else { return false }
        return true
    }

    private func checkInitUniversalLink(launchOptions: [NSObject: AnyObject]) -> Bool {
        return launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey] != nil
    }

    private func checkInitPushNotification(launchOptions: [NSObject: AnyObject]) -> Bool {
        guard let pushNotification = PushNotification.buildFromLaunchOptions(launchOptions) else { return false }
        initialDeepLink = pushNotification.deepLink
        return true
    }
}
