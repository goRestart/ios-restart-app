//
//  MockDeepLinksRouter.swift
//  LetGo
//
//  Created by Eli Kohen on 20/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxSwift
import Branch


class MockDeepLinksRouter: DeepLinksRouter {
    var deepLinks: Observable<DeepLink> { return deepLinksSignal.asObservable() }
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

    let deepLinksSignal = PublishSubject<DeepLink>()
    var initialDeepLink: DeepLink?

    func consumeInitialDeepLink() -> DeepLink? { return initialDeepLink }
    func initWithLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return false
    }
    @available(iOS 9.0, *)
    func performActionForShortcutItem(_ shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
    }
    func openUrl(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return false
    }
    func continueUserActivity(_ userActivity: NSUserActivity, restorationHandler: ([Any]?) -> Void) -> Bool {
        return false
    }
    func deepLinkFromBranchObject(_ object: BranchUniversalObject?, properties: BranchLinkProperties?) {

    }
    @discardableResult
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], applicationState: UIApplicationState)
        -> PushNotification? {
            return nil
    }
    func handleActionWithIdentifier(_ identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any],
                                    completionHandler: () -> Void) {

    }
}
