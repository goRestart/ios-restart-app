import LGComponents
import LGCoreKit
import RxCocoa
import RxSwift

final class MainViewModel: BaseViewModel {
    var logOutButtonIsEnabled: Observable<Bool> {
        return logOutButtonIsEnabledVariable.asObservable()
    }
    private let logOutButtonIsEnabledVariable: Variable<Bool>
    weak var navigator: MainViewModelNavigator?

    private let sessionManager: SessionManager
    private let disposeBag: DisposeBag

    init(sessionManager: SessionManager) {
        self.logOutButtonIsEnabledVariable = Variable<Bool>(sessionManager.loggedIn)
        self.sessionManager = sessionManager
        self.disposeBag = DisposeBag()
        super.init()

        sessionManager.sessionEvents
            .map { if case .login = $0 { return true } else { return false } }
            .bind(to: logOutButtonIsEnabledVariable)
            .disposed(by: disposeBag)
    }

    func logoutButtonPressed() {
        sessionManager.logout()
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
