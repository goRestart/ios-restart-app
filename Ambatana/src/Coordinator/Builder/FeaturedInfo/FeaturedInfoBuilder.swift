import Foundation
import LGCoreKit

protocol FeaturedInfoAssembly {
    func buildFeaturedInfo() -> UIViewController
}

enum FeaturedInfoBuilder {
    case modal(UIViewController)
}

extension FeaturedInfoBuilder: FeaturedInfoAssembly {
    func buildFeaturedInfo() -> UIViewController {
        switch self {
        case .modal(let root):
            let vm = FeaturedInfoViewModel()
            vm.navigator = FeaturedInfoModalWireframe(root: root)
            return FeaturedInfoViewController(viewModel: vm)
        }
    }
}
