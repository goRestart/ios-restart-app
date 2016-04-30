//
//  Tab.swift
//  LetGo
//
//  Created by Eli Kohen on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
 Defines the tabs contained in the TabBarController
 */
enum Tab {
    case Home, Categories, Notifications, Sell, Chats, Profile

    init?(index: Int) {
        switch index {
        case 0:
            self = .Home
        case 1:
            self = FeatureFlags.notificationsSection ? .Notifications : .Categories
        case 2:
            self = .Sell
        case 3:
            self = .Chats
        case 4:
            self = .Profile
        default: return nil
        }
    }

    var tabIconImageName: String {
        switch self {
        case .Home:
            return "tabbar_home"
        case .Categories:
            return "tabbar_categories"
        case .Notifications:
            return "tabbar_notifications"
        case .Sell:
            return "tabbar_sell"
        case .Chats:
            return "tabbar_chats"
        case .Profile:
            return "tabbar_profile"
        }
    }

    var index: Int {
        switch self {
        case .Home:
            return 0
        case .Categories, .Notifications:
            return 1
        case .Sell:
            return 2
        case .Chats:
            return 3
        case .Profile:
            return 4
        }
    }

    static var all: [Tab] {
        if FeatureFlags.notificationsSection {
            return [.Home, .Notifications, .Sell, .Chats, .Profile]
        } else {
            return [.Home, .Categories, .Sell, .Chats, .Profile]
        }
    }
}
