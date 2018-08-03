import RxSwift
import LGComponents

enum NotificationSettingCellType {
    case accessor(title: String)
    case switcher(title: String, description: String?, isEnabled: Variable<Bool>, switchAction: ((Bool) -> Void))
    case marketing(switchValue: Variable<Bool>, changeClosure: ((Bool) -> Void))
    
    var title: String? {
        switch self {
        case let .accessor(title):
            return title
        case let .switcher(title, _, _, _):
            return title
        case .marketing:
            return R.Strings.settingsMarketingNotificationsSwitch
        }
    }
    
    var description: String? {
        switch self {
        case let .switcher(_, description, _, _):
            return description
        case .accessor, .marketing:
            return nil
        }
    }
    
    var switchValue: Variable<Bool>? {
        switch self {
        case let .switcher(_, _, switchValue, _):
            return switchValue
        case let .marketing(switchValue, _):
            return switchValue
        case .accessor:
            return nil
        }
    }
    
    var switchAction: ((Bool) -> Void)? {
        switch self {
        case let .switcher(_, _, _, switchAction):
            return switchAction
        case let .marketing(_, switchAction):
            return switchAction
        case .accessor:
            return nil
        }
    }
    
    var isSwitcher: Bool {
        switch self {
        case .switcher:
            return true
        case .marketing, .accessor:
            return false
        }
    }
}
