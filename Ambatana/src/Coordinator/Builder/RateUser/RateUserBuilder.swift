import Foundation
import LGCoreKit

protocol RateUserAssembly {
    func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool) -> UIViewController
}

enum RateUserBuilder {
    case modal(UIViewController)
    case standard(UINavigationController)
}

extension RateUserBuilder: RateUserAssembly {
    func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool) -> UIViewController {
        let vm = RateUserViewModel(source: source, data: data)
        let vc = RateUserViewController(viewModel: vm, showSkipButton: showSkipButton)
        switch self {
        case .standard(let nav):
            vm.navigator = RateUserStandardWireframe(nc: nav)
            return vc
        case .modal(let root):
            let nc = UINavigationController(rootViewController: vc)
            vm.navigator = RateUserModalWireframe(root: root)
            return nc
        }
    }
}

