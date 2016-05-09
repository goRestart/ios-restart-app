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

    static func buildFromLaunchOptions(launchOptions: [NSObject: AnyObject]) -> ShortcutItem? {
        if #available(iOS 9.0, *) {
            guard let shortcutItemRaw = launchOptions[UIApplicationLaunchOptionsShortcutItemKey]
                as? UIApplicationShortcutItem else { return nil }
            guard let shortcutItem = ShortcutItem.buildFromUIApplicationShortcutItem(shortcutItemRaw) else { return nil }
            return shortcutItem
        } else {
            return nil
        }
    }

    @available(iOS 9.0, *)
    static func buildFromUIApplicationShortcutItem(item: UIApplicationShortcutItem) -> ShortcutItem? {
        return ShortcutItem(rawValue: item.type)
    }

    var deepLink: DeepLink {
        switch self {
        case .Sell:
            return DeepLink.shortCut(.Sell)
        case .StartBrowsing:
            return DeepLink.shortCut(.Home)
        }
    }
}
