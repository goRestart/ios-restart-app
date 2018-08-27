import Foundation
import LGCoreKit

protocol HelpAssembly {
    func buildHelp() -> UIViewController
}

public enum LGHelpBuilder {
    case standard(UINavigationController)
}

extension LGHelpBuilder: HelpAssembly {
    public func buildHelp() -> UIViewController {
        let vm = HelpViewModel()
        let vc = HelpViewController(viewModel: vm)
        switch self {
        case .standard(let nav):
            vm.router = HelpWireframe(navigationController: nav)
        }
        return vc
    }
}
