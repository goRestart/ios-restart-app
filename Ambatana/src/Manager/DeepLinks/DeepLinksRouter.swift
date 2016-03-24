//
//  DeepLinksManager.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Branch

class DeepLinksRouter {
    static let sharedInstance: DeepLinksRouter = DeepLinksRouter()

    let deepLink = Variable<DeepLink?>(nil)

    // MARK: - View lifecycle


    // MARK: - Public methods

    // MARK: > Init

    func initWithLaunchOptions(launchOptions: [NSObject: AnyObject]?) -> Bool {
        guard let launchOptions = launchOptions else { return false }

        let shortCut = checkInitShortcutAction(launchOptions)
        let uriScheme = checkInitUriScheme(launchOptions)
        let universalLink = checkInitUniversalLink(launchOptions)
        let pushNotification = checkInitPushNotification(launchOptions)

        return shortCut || uriScheme || universalLink || pushNotification
    }

    // MARK: > ShortCut actions (force touch)

    @available(iOS 9.0, *)
    func performActionForShortcutItem(shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        guard let shortCut = ShortcutItem.buildFromUIApplicationShortcutItem(shortcutItem) else { return }
        deepLink.value = shortCut.deepLink
    }

    // MARK: > Uri schemes

    func openUrl(url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        guard let uriScheme = UriScheme.buildFromUrl(url) else { return false }
        deepLink.value = uriScheme.deepLink
        return true
    }

    // MARK: > Universal links

    func continueUserActivity(userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        guard let universalLink = UniversalLink.buildFromUserActivity(userActivity) else { return false }
        deepLink.value = universalLink.deepLink
        return true
    }

    // MARK: > Branch.io

    func deepLinkFromBranchObject(object: BranchUniversalObject?, properties: BranchLinkProperties?) {
        guard let branchDeepLink = object?.deepLink else { return }
        deepLink.value = branchDeepLink
    }

    // MARK: > Push Notifications

    func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        guard let pushNotification = PushNotification.buildFromUserInfo(userInfo) else { return }
        deepLink.value = pushNotification.deepLink
    }

    func handleActionWithIdentifier(identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject],
        completionHandler: () -> Void) {
            //No actions implemented
    }


    // MARK: - Private methods

    private func checkInitShortcutAction(launchOptions: [NSObject: AnyObject]) -> Bool {
        guard let shortCut = ShortcutItem.buildFromLaunchOptions(launchOptions) else { return false }
        deepLink.value = shortCut.deepLink
        return true
    }

    private func checkInitUriScheme(launchOptions: [NSObject: AnyObject]) -> Bool {
        guard let uriScheme = UriScheme.buildFromLaunchOptions(launchOptions) else { return false }
        deepLink.value = uriScheme.deepLink
        return true
    }

    private func checkInitUniversalLink(launchOptions: [NSObject: AnyObject]) -> Bool {
        return launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey] != nil
    }

    private func checkInitPushNotification(launchOptions: [NSObject: AnyObject]) -> Bool {
        guard let pushNotification = PushNotification.buildFromLaunchOptions(launchOptions) else { return false }
        deepLink.value = pushNotification.deepLink
        return true
    }
}
