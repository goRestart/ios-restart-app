import LGCoreKit

protocol PostAnotherListingAssembly {
    func buildPostAnotherListing() -> UIViewController
}

enum PostAnotherListingBuilder {
    case modal(UIViewController)
}

extension PostAnotherListingBuilder: PostAnotherListingAssembly {
    func buildPostAnotherListing() -> UIViewController {
        let vm = PostAnotherListingViewModel()
        switch self {
        case .modal(let vc):
            vm.navigator = PostAnotherListingWireframe(root: vc)
        }
        return PostAnotherListingViewController(viewModel: vm)
    }
}
