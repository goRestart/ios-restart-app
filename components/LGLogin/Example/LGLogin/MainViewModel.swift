import LGComponents

final class MainViewModel: BaseViewModel {
    weak var navigator: MainViewModelNavigator?

    override init() {
        super.init()
    }

    func numberOfItems() -> Int {
        return MainViewModelItem.allValues.count
    }

    func titleForItemAt(index: Int) -> String? {
        guard let item = itemAt(index: index) else { return nil }
        switch item {
        case .fullScreenLogin:
            return "Full Screen Login"
        case .popUpLogin:
            return "Pop Up Login"
        case .embeddedLogin:
            return "Embedded Login"
        case .changePassword:
            return "Change Password"
        case .actionAfterLogin:
            return "Action After Login"
        }
    }

    func selectItemAt(index: Int) {
        guard let item = itemAt(index: index) else { return }
        switch item {
        case .fullScreenLogin:
            navigator?.openFullScreenLogin()
        case .popUpLogin:
            navigator?.openPopUpLogin()
        case .embeddedLogin:
            navigator?.openEmbeddedLogin()
        case .changePassword:
            navigator?.openChangePassword()
        case .actionAfterLogin:
            navigator?.openLoginIfNeeded()
        }
    }

    private func itemAt(index: Int) -> MainViewModelItem? {
        let items = MainViewModelItem.allValues
        guard 0 <= index && index < items.count else { return nil }
        return items[index]
    }
}

private enum MainViewModelItem {
    case fullScreenLogin
    case popUpLogin
    case embeddedLogin
    case changePassword
    case actionAfterLogin

    static let allValues: [MainViewModelItem] = [.fullScreenLogin,
                                                 .popUpLogin,
                                                 .embeddedLogin,
                                                 .changePassword,
                                                 .actionAfterLogin]
}
