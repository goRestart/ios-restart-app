//
//  MockDeepLinksRouter.swift
//  LetGo
//
//  Created by Eli Kohen on 20/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxSwift

class MockDeepLinksRouter: NSObject, DeepLinksRouter {
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
    var initialDeeplinkAvailable: Bool { return initialDeepLink != nil }

    var didReceiveRemoteNotificationCalled: Bool = false

    func consumeInitialDeepLink() -> DeepLink? { return initialDeepLink }
    func initWithLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return false
    }
    func performActionForShortcutItem(_ shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
    }
    func openUrl(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return false
    }
    func continueUserActivity(_ userActivity: NSUserActivity, restorationHandler: ([Any]?) -> Void) -> Bool {
        return false
    }
    @discardableResult
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any], applicationState: UIApplicationState)
        -> PushNotification? {
            didReceiveRemoteNotificationCalled = true
            return nil
    }
    func handleActionWithIdentifier(_ identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any],
                                    completionHandler: () -> Void) {

    }

    func onConversionDataReceived(_ installData: [AnyHashable : Any]!) { }

    func onConversionDataRequestFailure(_ error: Error!) { }
}
