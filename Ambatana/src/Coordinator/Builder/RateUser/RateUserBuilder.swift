import Foundation
import LGCoreKit

protocol RateUserAssembly {
    func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool,
                       onRateUserFinishAction: OnRateUserFinishActionable?) -> UIViewController
}

enum RateUserBuilder {
    case modal(UIViewController)
    case standard(UINavigationController)
}

extension RateUserBuilder: RateUserAssembly {
    func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool,
                       onRateUserFinishAction: OnRateUserFinishActionable?) -> UIViewController {
        let vm = RateUserViewModel(source: source, data: data)
        let vc = RateUserViewController(viewModel: vm, showSkipButton: showSkipButton)
        switch self {
        case .standard(let nav):
            vm.navigator = RateUserStandardWireframe(nc: nav, onRateUserFinishAction: onRateUserFinishAction)
            return vc
        case .modal(let root):
            let nc = UINavigationController(rootViewController: vc)
            vm.navigator = RateUserModalWireframe(root: root, onRateUserFinishAction: onRateUserFinishAction)
            return nc
        }
    }
}

