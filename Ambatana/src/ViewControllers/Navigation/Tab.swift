import LGComponents

/**
 Defines the tabs contained in the TabBarController
 */
enum Tab {
    case home, notifications, sell, chats, profile, community

    init?(index: Int,featureFlags: FeatureFlaggeable) {
        switch index {
        case 0:
            self = .home
        case 1:
            self = .notifications
        case 2:
            self = .sell
        case 3:
            self = .chats
        case 4:
            self = featureFlags.community.shouldShowOnTab ? .community : .profile
        default: return nil
        }
    }

    var tabIconImage: UIImage {
        switch self {
        case .home:
            return R.Asset.IconsButtons.tabbarHome.image
        case .notifications:
            return R.Asset.IconsButtons.tabbarNotifications.image
        case .sell:
            return R.Asset.IconsButtons.tabbarSell.image
        case .chats:
            return R.Asset.IconsButtons.tabbarChats.image
        case .profile:
            return R.Asset.IconsButtons.tabbarProfile.image
        case .community:
            return R.Asset.IconsButtons.tabbarCommunity.image
        }
    }

    var index: Int {
        switch self {
        case .home:
            return 0
        case .notifications:
            return 1
        case .sell:
            return 2
        case .chats:
            return 3
        case .profile, .community:
            return 4
        }
    }

    var accessibilityId: AccessibilityId {
        switch self {
        case .home:
            return .tabBarFirstTab
        case .notifications:
            return .tabBarSecondTab
        case .sell:
            return .tabBarThirdTab
        case .chats:
            return .tabBarFourthTab
        case .profile, .community:
            return .tabBarFifthTab
        }
    }

    func all(_ featureFlags: FeatureFlaggeable) -> [Tab] {
        if featureFlags.community.shouldShowOnTab {
            return [.home, .notifications, .sell, .chats, .community]
        } else {
            return [.home, .notifications, .sell, .chats, .profile]
        }
    }
}
