import Foundation

import Foundation

protocol UserVerificationAwarenessAssembly {
    func buildUserVerificationAwarenessView(callToAction: @escaping () -> ()) -> UserVerificationAwarenessViewController
}

enum UserVerificationAwarenessBuilder {
    case modal(UIViewController)
}

extension UserVerificationAwarenessBuilder: UserVerificationAwarenessAssembly {
    func buildUserVerificationAwarenessView(callToAction: @escaping () -> ()) -> UserVerificationAwarenessViewController {
        switch self {
        case .modal(let vc):
            let vm = UserVerificationAwarenessViewModel(callToAction: callToAction)
            vm.navigator = UserVerificationAwarenessWireframe(vc: vc)
            let vc = UserVerificationAwarenessViewController(viewModel: vm)
            return vc
        }
    }
}
