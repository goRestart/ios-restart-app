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
    case home, categories, notifications, sell, chats, profile

    init?(index: Int,featureFlags: FeatureFlaggeable) {
        switch index {
        case 0:
            self = .home
        case 1:
            self = featureFlags.notificationsSection ? .notifications : .categories
        case 2:
            self = .sell
        case 3:
            self = .chats
        case 4:
            self = .profile
        default: return nil
        }
    }

    var tabIconImageName: String {
        switch self {
        case .home:
            return "tabbar_home"
        case .categories:
            return "tabbar_categories"
        case .notifications:
            return "tabbar_notifications"
        case .sell:
            return "tabbar_sell"
        case .chats:
            return "tabbar_chats"
        case .profile:
            return "tabbar_profile"
        }
    }

    var index: Int {
        switch self {
        case .home:
            return 0
        case .categories, .notifications:
            return 1
        case .sell:
            return 2
        case .chats:
            return 3
        case .profile:
            return 4
        }
    }

    var accessibilityId: AccessibilityId {
        switch self {
        case .home:
            return .TabBarFirstTab
        case .categories, .notifications:
            return .TabBarSecondTab
        case .sell:
            return .TabBarThirdTab
        case .chats:
            return .TabBarFourthTab
        case .profile:
            return .TabBarFifthTab
        }
    }

    func all(_ featureFlags: FeatureFlaggeable) -> [Tab] {
        if featureFlags.notificationsSection {
            return [.home, .notifications, .sell, .chats, .profile]
        } else {
            return [.home, .categories, .sell, .chats, .profile]
        }
    }
}
