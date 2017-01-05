//
//  ShortcutItem.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum ShortcutItem: String {
    case Sell = "letgo.sell"
    case StartBrowsing = "letgo.startBrowsing"

    static func buildFromLaunchOptions(_ launchOptions: [AnyHashable: Any]) -> ShortcutItem? {
        if #available(iOS 9.0, *) {
            guard let shortcutItemRaw = launchOptions[UIApplicationLaunchOptionsKey.shortcutItem]
                as? UIApplicationShortcutItem else { return nil }
            guard let shortcutItem = ShortcutItem.buildFromUIApplicationShortcutItem(shortcutItemRaw) else { return nil }
            return shortcutItem
        } else {
            return nil
        }
    }

    @available(iOS 9.0, *)
    static func buildFromUIApplicationShortcutItem(_ item: UIApplicationShortcutItem) -> ShortcutItem? {
        return ShortcutItem(rawValue: item.type)
    }

    var deepLink: DeepLink {
        switch self {
        case .sell:
            return DeepLink.shortCut(.sell)
        case .StartBrowsing:
            return DeepLink.shortCut(.home)
        }
    }
}
